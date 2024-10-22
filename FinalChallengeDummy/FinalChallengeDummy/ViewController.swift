//
//  ViewController.swift
//  FinalChallengeDummy
//
//  Created by Farid Andika on 21/10/24.
//

import ARKit
import SceneKit
import UIKit

class ViewController: UIViewController, ARSCNViewDelegate {

    // Hanya deklarasi IBOutlet, karena kita menggunakan Storyboard
    @IBOutlet var sceneView: ARSCNView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Delegate untuk menangani event AR
        sceneView.delegate = self
        
        // Membuat konfigurasi AR dengan world tracking
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal // Deteksi permukaan horizontal untuk menempatkan objek
        
        // Jalankan sesi AR dengan konfigurasi
        sceneView.session.run(configuration)
        
        // Opsi debug untuk menampilkan poin fitur dan asal dunia (opsional)
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        // Menampilkan statistik seperti fps dan informasi waktu (opsional)
        sceneView.showsStatistics = true
        
        // Memanggil fungsi untuk setup tombol "Place Object"
        setupPlaceButton()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause sesi AR
        sceneView.session.pause()
    }
    @objc func placeObject() {
        // Buat kotak besar (kerangka luar)
        let outerBox = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
        let outerMaterial = SCNMaterial()
        outerMaterial.diffuse.contents = UIColor.red
        outerBox.materials = [outerMaterial]
        
        // Buat node untuk kotak besar
        let outerBoxNode = SCNNode(geometry: outerBox)
        
        // Buat kotak kecil (lubang di tengah)
        let innerBox = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let innerMaterial = SCNMaterial()
        innerMaterial.diffuse.contents = UIColor.black // Buat kotak kecil hitam agar tampak seperti lubang
        innerBox.materials = [innerMaterial]
        
        // Buat node untuk kotak kecil
        let innerBoxNode = SCNNode(geometry: innerBox)
        
        // Tempatkan kotak kecil di dalam kotak besar
        innerBoxNode.position = SCNVector3(0, 0, 0)
        
        // Tambahkan kotak besar dan kotak kecil ke node utama
        let boxNode = SCNNode()
        boxNode.addChildNode(outerBoxNode)
        boxNode.addChildNode(innerBoxNode)
        
        // Ambil posisi kamera saat ini
        if let cameraTransform = sceneView.session.currentFrame?.camera.transform {
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.5 // Tempatkan objek 0.5 meter di depan kamera
            boxNode.simdTransform = matrix_multiply(cameraTransform, translation)
        }
        
    
    }


    
    // Fungsi untuk setup tombol "Place Object"
    func setupPlaceButton() {
        let placeButton = UIButton(frame: CGRect(x: 50, y: 700, width: 150, height: 50))
        placeButton.setTitle("Place Object", for: .normal)
        placeButton.backgroundColor = .blue
        placeButton.addTarget(self, action: #selector(placeObject), for: .touchUpInside)
        self.view.addSubview(placeButton)
    }
}

