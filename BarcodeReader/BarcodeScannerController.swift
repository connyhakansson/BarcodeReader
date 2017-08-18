//
//  BarcodeScannerViewController.swift
//  BarcodeReader
//
//  Created by Conny Hakansson on 2017-08-16.
//  Copyright © 2017 Creativity&Design IT in Sweden AB. All rights reserved.
//

import UIKit
import AVFoundation

class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var scanSession : AVCaptureSession?
    var previewLayer : AVCaptureVideoPreviewLayer?
    var captureInput : AVCaptureDeviceInput?
    var captureOutput : AVCaptureMetadataOutput?
    var codeView : UIView?
    @IBOutlet var scanView: UIView!
    @IBOutlet weak var codeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
            
            captureInput = try AVCaptureDeviceInput(device: captureDevice!)
            captureOutput = AVCaptureMetadataOutput()
            captureOutput?.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)

            scanSession = AVCaptureSession()
            scanSession!.addInput(captureInput!)
            scanSession!.addOutput(captureOutput!)
            
            // Set the input and output BEFORE adding supported code types or the array will be empty
            captureOutput?.metadataObjectTypes = captureOutput!.availableMetadataObjectTypes
            
            previewLayer = AVCaptureVideoPreviewLayer(session: scanSession!)
            previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            previewLayer?.frame = scanView.layer.bounds
            scanView.layer.addSublayer(previewLayer!)
            scanView.layer.borderColor = UIColor.green.cgColor
            scanView.layer.borderWidth = 4
            
            
            scanSession?.startRunning()
            
            codeView = UIView()
            
            if let codeView = codeView {
                codeView.layer.borderColor = UIColor.green.cgColor
                codeView.layer.borderWidth = 2
                view.addSubview(codeView)
                view.bringSubview(toFront: codeView)
            }
            
            // Do any additional setup after loading the view.
        } catch {
                print(error)
        }

    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            codeView?.frame = CGRect.zero
            codeLabel.text = "Code: code not detected"
            return
        }
        
        // Ignoring metadata objects of type AVMetadataFaceObject as it wont cast to AVMetadataMachineReadableCodeObject
        if let metadataObj = metadataObjects[0] as? AVMetadataFaceObject {
            print("Ignoring Metadata Object of type FACE")
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        // If you only want to process some specific code, you can use the metadataObj.type to select specific codes
        let barCodeObject = previewLayer?.transformedMetadataObject(for: metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            codeView?.frame = barCodeObject.bounds
                
        if metadataObj.stringValue != nil {
                codeLabel.text = metadataObj.stringValue
        }
    }
        
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
