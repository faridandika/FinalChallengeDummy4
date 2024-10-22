//
//  ContentView.swift
//  FinalChallengeDummy3
//
//  Created by Farid Andika on 21/10/24.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView: View {
    @State private var arView = ARView(frame: .zero)
    @State private var isFrameAdded = false
    @State private var currentAnchor: AnchorEntity?
    @State private var overlayColor: Color = .red // Default color is red

    var body: some View {
        ZStack {
            // ARView in the background
            ARViewContainer(arView: $arView)
                .edgesIgnoringSafeArea(.all)

            // Show the overlay with the current color
            if isFrameAdded {
                GreenOverlay(overlayColor: overlayColor) // Pass the current overlay color
                    .onAppear {
                        // Check color when overlay appears
//                        print(OverlayCcolor)
                        
                        checkOverlayColor()
                        
                    }
            }

            // Button layer on top of ARView
            VStack {
                Spacer()

                // Gallery, Shot, and Flip Buttons
                HStack {
                    // Gallery Button
                    Button(action: {
                        // Action for opening the gallery
                    }) {
                        Image(systemName: "photo.on.rectangle")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 30)

                    Spacer()

                    // Shot Button (Main capture button)
                    Button(action: {
                        toggleFrame()
                    }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .stroke(Color.gray, lineWidth: 4)
                                    .frame(width: 70, height: 70)
                            )
                    }

                    Spacer()

                    // Flip Camera Button
                    Button(action: {
                        // Action for flipping the camera
                    }) {
                        Image(systemName: "arrow.trianglehead.left.and.right.righttriangle.left.righttriangle.right")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 30)
                }
                .padding(.bottom, 50)
            }
        }
        .onChange(of: isFrameAdded) { newValue in
            // Check color when frame is toggled
            if newValue {
                checkOverlayColor()
            }
        }
    }

    // Function to check if the overlay frame aligns with the AR frame
    func checkOverlayColor() {
        // Simulate the AR frame position; this should match the actual position
        let arFramePosition = CGRect(x: UIScreen.main.bounds.midX - 125, y: UIScreen.main.bounds.midY - 125, width: 250, height: 250)

        // Overlay position, centered
        let overlayFrame = CGRect(x: UIScreen.main.bounds.midX - 125, y: UIScreen.main.bounds.midY - 125, width: 250, height: 250)

        // Check if the overlay frame aligns with the AR frame
        if arFramePosition.intersects(overlayFrame) {
            overlayColor = .green // Change to green if aligned
        } else {
            overlayColor = .red // Change to red if not aligned
        }
    }

    // Function to toggle the frame (add/remove)
    func toggleFrame() {
        if isFrameAdded {
            removeFrame()
        } else {
            addObject(at: arView)
        }
        isFrameAdded.toggle()
    }

    // Function to add the frame to ARView
    func addObject(at arView: ARView) {
        if let cameraTransform = arView.session.currentFrame?.camera.transform {
            let model = createPhotoFrame()

            let distance: Float = -0.5
            var translation = matrix_identity_float4x4
            translation.columns.3.z = distance
            
            let finalTransform = simd_mul(cameraTransform, translation)
            model.transform.matrix = finalTransform

            arView.scene.addAnchor(model)
            currentAnchor = model
        }
    }

    // Function to remove the frame from ARView
    func removeFrame() {
        if let anchor = currentAnchor {
            arView.scene.removeAnchor(anchor)
            currentAnchor = nil
        }
    }

    func createPhotoFrame() -> AnchorEntity {
        let frameThickness: Float = 0.005
        let outerSize: Float = 0.2

        let material = SimpleMaterial(color: .black, isMetallic: true)

        let top = ModelEntity(mesh: MeshResource.generateBox(size: [outerSize, frameThickness, frameThickness]), materials: [material])
        let bottom = ModelEntity(mesh: MeshResource.generateBox(size: [outerSize, frameThickness, frameThickness]), materials: [material])
        let left = ModelEntity(mesh: MeshResource.generateBox(size: [frameThickness, outerSize, frameThickness]), materials: [material])
        let right = ModelEntity(mesh: MeshResource.generateBox(size: [frameThickness, outerSize, frameThickness]), materials: [material])

        top.position = [0, (outerSize - frameThickness) / 2, 0]
        bottom.position = [0, -(outerSize - frameThickness) / 2, 0]
        left.position = [-(outerSize - frameThickness) / 2, 0, 0]
        right.position = [(outerSize - frameThickness) / 2, 0, 0]

        let anchor = AnchorEntity(world: [0, 0, 0])

        anchor.addChild(top)
        anchor.addChild(bottom)
        anchor.addChild(left)
        anchor.addChild(right)
        
        return anchor
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var arView: ARView

    func makeUIView(context: Context) -> ARView {
        let configuration = ARWorldTrackingConfiguration()
        arView.session.run(configuration)
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}
