//
//  ARViewContainer.swift
//  FinalChallengeDummy3
//
//  Created by Farid Andika on 22/10/24.
//

import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    @Binding var arView: ARView

    func makeUIView(context: Context) -> ARView {
        let configuration = ARWorldTrackingConfiguration()
        arView.session.run(configuration) // Start the AR session with the configuration
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
    }
}
