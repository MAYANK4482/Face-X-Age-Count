//
//  MembercountVC.swift
//  Face:X Age-Count
//
//  Created by Mayank Vadaliya on 07/08/19.
//  Copyright © 2019 Mayank Vadaliya. All rights reserved.
//

import UIKit
import CoreML
import Vision
import AVKit



class MembercountVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblview: UILabel!
    
    var sublayers: [CALayer] = []
    
    lazy var faceDetectionRequest: VNDetectFaceRectanglesRequest = {
        let faceLandmarksRequest = VNDetectFaceRectanglesRequest(completionHandler: { [weak self] request, error in
            self?.handleDetection(request: request, errror: error)
        })
        return faceLandmarksRequest
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Face recognition
    
    fileprivate func launchDetection(image: UIImage) {
        
        let orientation = image.coreOrientation()
        guard let coreImage = CIImage(image: image) else { return }
        
        DispatchQueue.global().async {
            let handler = VNImageRequestHandler(ciImage: coreImage, orientation: orientation)
            do {
                try handler.perform([self.faceDetectionRequest])
            } catch {
                print("Failed to perform detection .\n\(error.localizedDescription)")
            }
        }
    }
    
    fileprivate func handleDetection(request: VNRequest, errror: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard let observations = request.results as? [VNFaceObservation] else {
                fatalError("unexpected result type!")
            }
            
            print("Detected \(observations.count) faces")
            self!.lblview.text = "Detected \(observations.count) faces"
            
            observations.forEach( { self?.addFaceRecognitionLayer($0) })
        }
    }
    
    fileprivate func addFaceRecognitionLayer(_ face: VNFaceObservation) {
        
        guard let image = imageView.image else { return }
        
        UIGraphicsBeginImageContextWithOptions(image.size, true, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        // draw the image
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        
        // draw line
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -image.size.height)
        let translate = CGAffineTransform.identity.scaledBy(x: image.size.width, y: image.size.height)
        let facebounds = face.boundingBox.applying(translate).applying(transform)
        
        context?.saveGState()
        context?.setStrokeColor(UIColor.red.cgColor)
        context?.setLineWidth(5.0)
        context?.addRect(facebounds)
        context?.drawPath(using: .stroke)
        context?.restoreGState()
        
        // get the final image
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // end drawing context
        UIGraphicsEndImageContext()
        
        imageView.image = finalImage
        
    }
    



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func came(_ sender: Any)
    {
        imageView.isHidden = false
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        let actionsheet = UIAlertController(title: "Face:X", message: "Choose A Sourece", preferredStyle: .actionSheet)
        actionsheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction)in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }else
            {
                self.noCamera()
            }
            
            
            
        }))
        actionsheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction)in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionsheet,animated: true, completion: nil)
    }
    
    @IBAction func vide(_ sender: Any)
    {
        let actionsheet = UIAlertController(title: "Face:X", message: "Choose A Sourece", preferredStyle: .actionSheet)
        actionsheet.addAction(UIAlertAction(title: "Front Camera", style: .default, handler: { (action:UIAlertAction)in
            
            let foo = self.storyboard?.instantiateViewController(withIdentifier: "FrontmemberVC") as! FrontmemberVC
            
            self.navigationController?.pushViewController(foo, animated: true)
            
            
        }))
        actionsheet.addAction(UIAlertAction(title: "Back Camera", style: .default, handler: { (action:UIAlertAction)in
            
            let foo = self.storyboard?.instantiateViewController(withIdentifier: "backmemberVC") as! backmemberVC
            
            self.navigationController?.pushViewController(foo, animated: true)
            
        }))
        actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionsheet,animated: true, completion: nil)
    }
   
}

extension MembercountVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        imageView.image = selectedImage
        self.launchDetection(image: selectedImage)
        picker.dismiss(animated: true, completion: nil)
        
        
        
        
        
        
        
        
        
    }
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(
            alertVC,
            animated: true,
            completion: nil)
    }
    
}


extension UIImage {
    
    func coreOrientation() -> CGImagePropertyOrientation {
        switch imageOrientation {
        case .up : return .up
        case .upMirrored: return .upMirrored
        case .down: return .down // 0th row at bottom, 0th column on right  - 180 deg rotation
        case .downMirrored : return .downMirrored// 0th row at bottom, 0th column on left   - vertical flip
        case .leftMirrored : return .leftMirrored // 0th row on left,   0th column at top
        case .right : return .right // 0th row on right,  0th column at top    - 90 deg CW
        case .rightMirrored : return .rightMirrored // 0th row on right,  0th column on bottom
        case .left : return .left // 0th row on left,   0th column at bottom - 90 deg CCW
        }
    }
}
