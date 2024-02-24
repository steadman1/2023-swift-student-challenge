//
//  ARMainView.swift
//  swiftStudentChallenge
//
//  Created by Spencer Steadman on 3/29/23.
//

import SwiftUI
import RealityKit
import ARKit
import SceneKit
import simd

class SharedARView: ObservableObject {
    enum ARState {
        case detectFloor, tutorial, sandbox, placeGeometry
    }
    
    enum FloorDetectState {
        case success, limitedDetection, inProgress, undetected
    }
    
    @ObservedObject static var shared = SharedARView()
    @Published var arState: ARState = .detectFloor
    @Published var floorDetectState: FloorDetectState = .undetected
    @Published var physicsState: PhysicsBodyMode = .dynamic
    @Published var floorTransform: simd_float3? = nil
    var arView = ARView(frame: .zero)
    
    static let floorAnchorName = "STATIC_FLOOR"
    static let size: SIMD3<Float> = SIMD3(repeating: 0.08)
    
    func installGestures(_ entity: ModelEntity) {
        self.arView.installGestures([.scale, .rotation, .translation], for: entity)
    }
    
    func createPhysicsBody(_ entity: ModelEntity, state: PhysicsBodyMode) -> PhysicsBodyComponent? {
        guard let entityModel = entity.model?.mesh else { return nil }

        let entityShape = ShapeResource.generateConvex(from: entityModel)
        let entityBody = PhysicsBodyComponent(shapes: [entityShape],
                                              mass: 1,
                                              mode: state)
        
        return entityBody
    }
    
    func removeGeometry() {
        for anchor in self.arView.scene.anchors {
            print(anchor)
            if anchor.name != SharedARView.floorAnchorName {
                self.arView.scene.removeAnchor(anchor)
            }
        }
    }
    
    func switchPhysicsState() {
        let newState: PhysicsBodyMode = SharedARView.shared.physicsState == .dynamic ? .kinematic : .dynamic
        for anchor in self.arView.scene.anchors {
            if anchor.name != SharedARView.floorAnchorName {
                let entity = anchor.children.first as! ModelEntity
                
                entity.components.set(self.createPhysicsBody(entity, state: newState)!)
                entity.generateCollisionShapes(recursive: true)
            }
        }
        SharedARView.shared.physicsState = newState
    }
    
    func detectFloor() {
        func generateFloor(_ transform: simd_float3) {
            let size: SIMD3<Float> = SIMD3(repeating: 100.0)
            
            let planeResource = MeshResource.generateBox(size: size)

            let floorEntity = ModelEntity(mesh: planeResource, materials: [])
            floorEntity.setPosition(transform, relativeTo: nil)
            
            let planeShape = ShapeResource.generateBox(width: size.x, height: 0.001, depth: size.y)
            let planeBody = PhysicsBodyComponent(shapes: [planeShape], mass: 1, mode: .static)
            floorEntity.components.set(planeBody)
            
            let physicsMaterial = PhysicsMaterialResource.generate(staticFriction: 2.5,
                                                                   dynamicFriction: 2.5,
                                                                   restitution: 1.15)
            floorEntity.collision = CollisionComponent(shapes: [planeShape])
            floorEntity.physicsBody?.material = physicsMaterial

            let anchorEntity = AnchorEntity(world: .zero)
            anchorEntity.name = SharedARView.floorAnchorName
            
            // Add the entity as a child of the new anchor.
            anchorEntity.addChild(floorEntity)

            // Add the anchor to the scene.
            self.arView.scene.anchors.append(anchorEntity)
        }
        
        let DESIRED_RAYCAST_COUNT: Float = 20
        
        let location: CGPoint = CGPoint(x: Screen.shared.width / 2, y: Screen.shared.height / 2)
        let estimatedPlane: ARRaycastQuery.Target = .estimatedPlane
        let alignment: ARRaycastQuery.TargetAlignment = .any
        
        var raycastResults: [ARRaycastResult] = []
        
        func averageRaycastTransform() -> simd_float3 {
            var averageX: Float = 0
            var averageY: Float = 0
            var averageZ: Float = 0
            
            for results in raycastResults {
                averageX += results.worldTransform.columns.3.x
                averageY += results.worldTransform.columns.3.y
                averageZ += results.worldTransform.columns.3.z
            }
            
            return simd_float3(averageX / DESIRED_RAYCAST_COUNT,
                               averageY / DESIRED_RAYCAST_COUNT,
                               averageZ / DESIRED_RAYCAST_COUNT)
        }
        
        var trackedRaycastQuery: ARTrackedRaycast?

        if SharedARView.shared.floorDetectState != .inProgress {
            
            SharedARView.shared.floorDetectState = .inProgress
            
            trackedRaycastQuery = self.arView.trackedRaycast(from: location,
                                       allowing: estimatedPlane,
                                       alignment: alignment) { results in
                
                guard let firstRaycastResult = results.first else {
                    trackedRaycastQuery!.stopTracking()
                    
                    SharedARView.shared.floorDetectState = .limitedDetection
                    
                    return
                }
                
                if raycastResults.count <= Int(DESIRED_RAYCAST_COUNT) {
                    raycastResults.append(firstRaycastResult)
                } else {
                    trackedRaycastQuery!.stopTracking()
                    
                    var transform = averageRaycastTransform()
                    
                    generateFloor(transform)
                    
                    transform.y += SharedARView.size.y
                    
                    SharedARView.shared.floorTransform = transform
                    SharedARView.shared.floorDetectState = .success
                }
            }
        }
        
        if trackedRaycastQuery == nil {
            SharedARView.shared.floorDetectState = .undetected
        }
    }
    
    func raycastGetSideOfEntity(_ tapLocation: CGPoint = CGPoint(x: Screen.shared.width / 2, y: Screen.shared.height / 2)) {
        let ray = arView.ray(through: tapLocation)!
        // Perform the raycast query and get a list of RaycastResult objects
        let raycastResults = arView.scene.raycast(from: ray.origin,
                                                  to: ray.direction,
                                                  query: .all,
                                                  mask: .default)
        guard let entity = raycastResults.first?.entity else { return }
        
        var newBoxPosition = raycastResults.count > 1 ? entity.transform.translation : raycastResults.first!.position
        
        // Get the normal of the surface that was hit
        let hitNormal = raycastResults.first!.normal
        
        if raycastResults.count > 1 {
            // Determine which side of the entity was hit
            if abs(hitNormal.x) > abs(hitNormal.y) && abs(hitNormal.x) > abs(hitNormal.z) {
                // The hit was on the left or right side of the entity
                if hitNormal.x > 0 {
                    newBoxPosition.x += SharedARView.size.x
                    print("right")
                    // The hit was on the right side of the entity
                    // Place a box to the right of this entity
                } else {
                    newBoxPosition.x -= SharedARView.size.x
                    print("left")
                    // The hit was on the left side of the entity
                    // Place a box to the left of this entity
                }
            } else if abs(hitNormal.y) > abs(hitNormal.z) {
                // The hit was on the top or bottom of the entity
                if hitNormal.y > 0 {
                    newBoxPosition.y += SharedARView.size.y
                    print("top")
                    // The hit was on the top of the entity
                    // Place a box on top of this entity
                } else {
                    newBoxPosition.y -= SharedARView.size.y
                    print("bottom")
                    // The hit was on the bottom of the entity
                    // Place a box below this entity
                }
            } else {
                // The hit was on the front or back side of the entity
                if hitNormal.z > 0 {
                    newBoxPosition.z += SharedARView.size.z
                    print("front")
                    // The hit was on the front side of the entity
                    // Place a box in front of this entity
                } else {
                    newBoxPosition.z -= SharedARView.size.z
                    print("back")
                    // The hit was on the back side of the entity
                    // Place a box behind this entity
                }
            }
            //newBoxPosition += entity.transform.rotation.axis
            self.generateBox(newBoxPosition, rotation: entity.transform.rotation)
        } else {
            self.generateBox(newBoxPosition)
        }
    }
    
    func raycastQuery(_ tapLocation: CGPoint = CGPoint(x: Screen.shared.width / 2, y: Screen.shared.height / 2)) -> simd_float3? {
        let estimatedPlane: ARRaycastQuery.Target = .estimatedPlane
        let alignment: ARRaycastQuery.TargetAlignment = .any

        let result: [ARRaycastResult] = self.arView.raycast(from: tapLocation,
                                                            allowing: estimatedPlane,
                                                            alignment: alignment)

        guard let rayCast: ARRaycastResult = result.first
        else { return nil }

        let anchor = AnchorEntity(world: rayCast.worldTransform)
        self.arView.scene.anchors.append(anchor)

        return simd_float3(rayCast.worldTransform.columns.3.x,
                           rayCast.worldTransform.columns.3.y,
                           rayCast.worldTransform.columns.3.z)     /* The distance from the ray origin to the hit */
        
//        let hitTestResults = self.arView.hitTest(self.arView.center, types: [.existingPlane, .featurePoint])
//        guard let result = hitTestResults.first else { return nil }
//        let hitCoordinates = simd_float3(x: result.worldTransform.columns.3.x,
//                                         y: result.worldTransform.columns.3.y,
//                                         z: result.worldTransform.columns.3.z)
//
//
//        return result
    }
    
    func generateBox(_ transform: simd_float3, rotation: simd_quatf = simd_quatf(real: 1.0, imag: SIMD3<Float>(repeating: 0.0))) {
        let boxResource = MeshResource.generateBox(size: SharedARView.size, cornerRadius: 0.008)

        let toonMaterial = SimpleMaterial(color: .white, roughness: 1, isMetallic: false)
    
        let myEntity = ModelEntity(mesh: boxResource, materials: [toonMaterial])
        myEntity.generateCollisionShapes(recursive: true)
        myEntity.setPosition(transform, relativeTo: nil)
        myEntity.setOrientation(rotation, relativeTo: nil)
        
        let boxShape = ShapeResource.generateBox(size: SharedARView.size)
        let boxBody = PhysicsBodyComponent(shapes: [boxShape], mass: 1, mode: self.physicsState)
        myEntity.components.set(boxBody)
        
        let physicsMaterial = PhysicsMaterialResource.generate(staticFriction: 0.55,
                                                               dynamicFriction: 0.85,
                                                               restitution: 1.15)
        myEntity.collision = CollisionComponent(shapes: [boxShape])
        myEntity.physicsBody?.material = physicsMaterial
        
        // Create a new Anchor Entity using Identity Transform.
        let anchorEntity = AnchorEntity(world: .zero)
        
        // Add the entity as a child of the new anchor.
        anchorEntity.addChild(myEntity)
        
        // install gestures for manipulation
        installGestures(myEntity)

        // Add the anchor to the scene.
        self.arView.scene.anchors.append(anchorEntity)
    }
    
    func generatePlaceHolderBox() {
        let boxMesh = MeshResource.generateBox(size: 0.8)
        let boxMaterial = SimpleMaterial(color: .white.withAlphaComponent(0.5), isMetallic: false)
        let boxEntity = ModelEntity(mesh: boxMesh, materials: [boxMaterial])
        let anchorEntity = AnchorEntity(world: .zero)
        anchorEntity.addChild(boxEntity)

        let boxTranslation = SIMD3<Float>(
            Float(arView.bounds.width / 2) - 0.1,
            Float(arView.bounds.height / 2) - 0.1,
            -0.5
        )
        boxEntity.setPosition(boxTranslation, relativeTo: nil)
        
        self.arView.scene.anchors.append(anchorEntity)
    }
    
    func placeBox() {
        let raycastPosition = raycastQuery()
        
        guard let raycastPosition else { return }
        
        generateBox(raycastPosition)
    }
}

struct ARViewContainer: UIViewRepresentable {
    var arView: ARView!
    var onTap: (CGPoint) -> Void
    
    init(onTap: @escaping (CGPoint) -> Void = { _ in }) {
        self.arView = SharedARView.shared.arView
        self.onTap = onTap
    }
    
    func makeUIView(context: Context) -> ARView {
//        let arConfigSupport = ARConfiguration.isSupported
        let trackingConfig = ARWorldTrackingConfiguration()
        let scanningConfiguration = ARObjectScanningConfiguration()
        
        let session = self.arView.session
        
        arView.environment.background = .cameraFeed()
        arView.environment.sceneUnderstanding.options.insert([.occlusion, .collision, .receivesLighting, .physics])
        arView.automaticallyConfigureSession = false
    
        arView.setupCoaching()
        
        trackingConfig.planeDetection = [.horizontal, .vertical]
        session.run(trackingConfig)
        session.run(scanningConfiguration)
        
        // Set debug options
        #if DEBUG
        self.arView.debugOptions = []//[.showFeaturePoints, .showAnchorOrigins]
        #endif
        
        let gestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(gestureRecognizer)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
            return Coordinator(onTap: onTap)
        }
        
    class Coordinator: NSObject {
        var onTap: (CGPoint) -> Void
        
        init(onTap: @escaping (CGPoint) -> Void) {
            self.onTap = onTap
        }
        
        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            let location = gestureRecognizer.location(in: gestureRecognizer.view)
            onTap(location)
            SharedARView.shared.raycastGetSideOfEntity(location)
        }
    }
}

extension PhysicsBodyMode {
    mutating func toggle() {
        guard self != .static else { return }
        self = self == .dynamic ? .kinematic : .dynamic
    }
}

extension ARView: ARCoachingOverlayViewDelegate {
    func setupCoaching() {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = self.session
        coachingOverlay.goal = .horizontalPlane
        self.addSubview(coachingOverlay)
    }
    
    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        
    }
}

struct ARMain: View {
    @ObservedObject private var arView = SharedARView.shared
    let arViewContainer = ARViewContainer()
    
    var body: some View {
        ZStack {
            arViewContainer
                .edgesIgnoringSafeArea(.all)
//            VStack {
//                Button {
//                    arView.raycastGetSideOfEntity()
//                } label: {
//                    ZStack {
//                        Text("get side of entity")
//                    }.padding(.all, 20)
//                }
//
//            }
//            Circle()
//                .frame(width: 20, height: 20)
//                .foregroundColor(Color.white)
//                .position(x: Screen.shared.width / 2, y: Screen.shared.height / 2)
        }
//        .onChange(of: arView.floorTransform) { newValue in
//            guard let newValue else { return }
//            arView.generateBox(newValue)
//        }
    }
}
