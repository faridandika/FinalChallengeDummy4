//
//  FrameViewMOdel.swift
//  FinalChallengeDummy3
//
//  Created by Farid Andika on 22/10/24.
//

import Foundation
import RealityKit
import SwiftUI
import ARKit

class FrameViewModel: ObservableObject {
    @Published var model = FrameModel()
    private var timer: Timer?

    func toggleFrame(at arView: ARView) {
        if model.anchor != nil {
            removeFrame(from: arView)
        } else {
            addFrame(to: arView)
        }
    }

    // Menambahkan bingkai ke ARView
    private func addFrame(to arView: ARView) {
        if let cameraTransform = arView.session.currentFrame?.camera.transform {
            let modelEntity = createPhotoFrame()
            let distance: Float = -0.5
            var translation = matrix_identity_float4x4
            translation.columns.3.z = distance
            let finalTransform = simd_mul(cameraTransform, translation)
            modelEntity.transform.matrix = finalTransform
            arView.scene.addAnchor(modelEntity)
            model.anchor = modelEntity
            startLiveAlignmentCheck(arView: arView) // alignment check, start.
        }
    }

    // Nge hapus Frame
    private func removeFrame(from arView: ARView) {
        if let anchor = model.anchor {
            arView.scene.removeAnchor(anchor)
            model.anchor = nil
        }
        stopLiveAlignmentCheck()
    }

    // nge init frame
    private func createPhotoFrame() -> AnchorEntity {
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

    // Memulai pengecekan alignment secara berkala
    private func startLiveAlignmentCheck(arView: ARView) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            self.checkOverlayColor(arView: arView) // Panggil fungsi pengecekan penjajaran
        }
    }

    // Menghentikan pengecekan alignment secara berkala
    private func stopLiveAlignmentCheck() {
        timer?.invalidate()
        timer = nil
    }

    // Mengecek warna overlay berdasarkan alignment
    private func checkOverlayColor(arView: ARView) {
        guard let anchor = model.anchor else { return }
        guard let cameraTransform = arView.session.currentFrame?.camera.transform else { return }

        let anchorPosition = anchor.transform.translation
        let cameraPosition = cameraTransform.translation

        let distance = simd_distance(anchorPosition, cameraPosition)
        
        let acceptableDistance: Float = 0.5 //  50 cm
        let acceptableAngle: Float = 15.0 //  15 derajat

        if distance <= acceptableDistance {
            let cameraForward = cameraTransform.columns.2
            let anchorForward = anchor.transform.matrix.columns.2
            
            let angle = acos(dot(cameraForward, anchorForward) / (length(cameraForward) * length(anchorForward))) * (180.0 / .pi)
            
            if angle <= acceptableAngle {
                model.overlayColor = .green
                model.alignmentStatus = "Pas, sudah dalam kotak!"
            } else {
                model.overlayColor = .red
                model.alignmentStatus = "Belum pas bang, masukin kotak"
            }
        } else {
            model.overlayColor = .red
            model.alignmentStatus = "Belum pas bang, masukin kotak"
        }
    }
}

extension simd_float4x4 {
    var translation: SIMD3<Float> {
        return [columns.3.x, columns.3.y, columns.3.z]
    }
}
