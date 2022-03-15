//
//  BackAgeVC.swift
//  Face:X Age-Count
//
//  Created by Mayank Vadaliya on 07/08/19.
//  Copyright © 2019 Mayank Vadaliya. All rights reserved.
//

import UIKit
import AVKit
import Vision

class BackAgeVC: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var lblname: UILabel!
   
        override func viewDidLoad() {
            super.viewDidLoad()
            
            
            let captureSession = AVCaptureSession()
            captureSession.sessionPreset = .photo
            
            guard let captureDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first else { return }
            guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
            captureSession.addInput(input)
            
            captureSession.startRunning()
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            view.layer.addSublayer(previewLayer)
            previewLayer.frame = view.frame
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            captureSession.addOutput(dataOutput)
            
            
            
            
        }
        
        
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            
            
            guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            
            
            guard let model = try? VNCoreMLModel(for: ImageClassifier().model) else { return }
            let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
                
                
                
                guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
                
                guard let firstObservation = results.first else { return }
                
                print(firstObservation.identifier, firstObservation.confidence)
                
                DispatchQueue.main.async {
                    self.lblname.text = "Around your age:-\(firstObservation.identifier)"
                }
                
            }
            
            try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        }
        
        
}
