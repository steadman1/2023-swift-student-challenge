//
//  OverlayVuew.swift
//  Challenge
//
//  Created by Spencer Steadman on 3/30/23.
//

import SwiftUI

struct Overlay: View {
    @ObservedObject var screen = Screen.shared
    @ObservedObject var arView = SharedARView.shared
    @State var isGeometryPresented = false
    @State var selection = 0
    
    var body: some View  {
        ZStack {
            ZStack {
                VStack(spacing: Screen.padding) {
                    HStack {
                        OverlayButton {
                            arView.arState = .tutorial
                        } label: {
                            Text("👋")
                                .font(.icon)
                        }
                        
                        Spacer()
                        
                        OverlayButton {
                            arView.detectFloor()
                        } label: {
                            if arView.floorDetectState == .success {
                                ZStack {
                                    Image(systemName: "square.dashed")
                                        .font(.icon)
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 10, weight: .black))
                                }
                            } else if arView.floorDetectState == .inProgress {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.white)
                            } else {
                                ZStack {
                                    Image(systemName: "square.dashed")
                                        .font(.icon)
                                }
                            }
                        }
                    }
                    OverlayButton {
                        arView.switchPhysicsState()
                    } label: {
                        if arView.physicsState == .kinematic {
                            Image(systemName: "play.fill")
                                .font(.icon)
                        } else {
                            Image(systemName: "pause.fill")
                                .font(.icon)
                        }
                    }.alignRight()
                    OverlayButton {
                        arView.removeGeometry()
                    } label: {
                        Image(systemName: "trash")
                            .font(.icon)
                    }.alignRight()
                    Spacer()
                    AddGeometryButton(isGeometryPresented: $isGeometryPresented)
                }.padding(Screen.padding)
            }
        }.frame(width: screen.width, height: screen.height)
            .customSheet(isPresented: $isGeometryPresented) {
                AddGeometryCarousel(isPresented: $isGeometryPresented,
                                    selection: $selection,
                                    title: "Add Geometry",
                                    subtitle: "Tap to add to your sandbox.")
            }
    }
}
