//
//  ContentView.swift
//  FinalChallengeDummy3
//
//  Created by Farid Andika on 21/10/24.
//

import SwiftUI
import RealityKit
import ARKit
import CoreHaptics

struct ContentView: View {
    @State private var arView = ARView(frame: .zero)
    @State private var isFrameAdded = false
    @State private var currentAnchor: AnchorEntity?
    @State private var overlayColor: Color = .red
    @State private var alignmentStatus: String = "Belum pas bang, masukin kotak" // Status live update
    @State private var timer: Timer? // Timer untuk live update

    var body: some View {
        ZStack {
            // ARView sebagai background
            ARViewContainer(arView: $arView)
                .edgesIgnoringSafeArea(.all)

            // Overlay dan status hanya muncul jika frame aktif
            if isFrameAdded {
                GreenOverlay(overlayColor: overlayColor)
                    .transition(.scale)
                    .animation(.easeInOut, value: isFrameAdded)

                // Teks indikator status keselarasan
                Text(alignmentStatus)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.top, 0)
            }

            // Tombol pengontrol di bagian bawah
            VStack {
                Spacer()
                HStack {
                    // Tombol Galeri
                    Button(action: {
                        // Action untuk membuka galeri
                    }) {
                        Image(systemName: "photo.on.rectangle")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 30)

                    Spacer()

                    // Tombol untuk menambah/menghapus frame
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

                    // Tombol Flip Kamera
                    Button(action: {
                        // Action untuk membalik kamera
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
            if newValue {
                startLiveAlignmentCheck() // Mulai pemeriksaan live ketika frame aktif
            } else {
                stopLiveAlignmentCheck() // Berhenti ketika frame dihapus
            }
        }
    }

    // Fungsi untuk memulai pemeriksaan status secara live
    func startLiveAlignmentCheck() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            checkOverlayColor()
        }
    }

    // Fungsi untuk menghentikan timer pemeriksaan
    func stopLiveAlignmentCheck() {
        timer?.invalidate()
        timer = nil
    }

    // Fungsi untuk memeriksa apakah overlay dan AR frame selaras
    func checkOverlayColor() {
        if let anchor = currentAnchor {
            if let screenPosition = convertWorldPositionToScreen(anchor.position, in: arView) {
                let overlayFrame = CGRect(
                    x: UIScreen.main.bounds.midX - 110,
                    y: UIScreen.main.bounds.midY - 110,
                    width: 220,
                    height: 220
                )

                let isAligned = overlayFrame.contains(screenPosition)

                withAnimation {
                    overlayColor = isAligned ? .green : .red
                    alignmentStatus = isAligned ? "Pas" : "Belom pas bang"
                }

                // Berikan vibrasi jika tidak aligned
                if !isAligned {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }
            }
        }
    }


    // Fungsi untuk menambah/menghapus frame
    func toggleFrame() {
        if isFrameAdded {
            removeFrame()
        } else {
            addObject(at: arView)
        }
        isFrameAdded.toggle()
    }

    // Fungsi untuk menambah frame ke ARView
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

    // Fungsi untuk menghapus frame dari ARView
    func removeFrame() {
        if let anchor = currentAnchor {
            arView.scene.removeAnchor(anchor)
            currentAnchor = nil
        }
    }

    // Fungsi untuk membuat model frame foto
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

    // Fungsi untuk mengonversi posisi dunia ke layar
    func convertWorldPositionToScreen(_ position: SIMD3<Float>, in arView: ARView) -> CGPoint? {
        let projectedPoint = arView.project(position)
        return projectedPoint
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

