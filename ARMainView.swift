//
//  ARMainView.swift
//  swiftStudentChallenge
//
//  Created by Spencer Steadman on 3/29/23.
//

import SwiftUI
import RealityKit

struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

struct ARMain: View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}
