//
//  QRScannerController.swift
//  QRCodeReader
//
//  Created by Simon Ng on 13/10/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import SVProgressHUD



class QRScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet var messageLabel:UILabel!
    @IBOutlet var topbar: UIView!
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    let supportedCodeTypes = [AVMetadataObjectTypeUPCECode,
                        AVMetadataObjectTypeCode39Code,
                        AVMetadataObjectTypeCode39Mod43Code,
                        AVMetadataObjectTypeCode93Code,
                        AVMetadataObjectTypeCode128Code,
                        AVMetadataObjectTypeEAN8Code,
                        AVMetadataObjectTypeEAN13Code,
                        AVMetadataObjectTypeAztecCode,
                        AVMetadataObjectTypePDF417Code,
                        AVMetadataObjectTypeQRCode]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        

        
        
        
        
        
        
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back)

        
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            
            
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
    
            
            // Set the input device on the capture session.
            captureSession?.addInput(input)

            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            captureSession?.startRunning()
            
            // Move the message label and top bar to the front
            view.bringSubview(toFront: messageLabel)
            view.bringSubview(toFront: topbar)
            
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.red.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - AVCaptureMetadataOutputObjectsDelegate Methods
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        
        //Database Setup
        var scannedEmailAddress :[String] = []
        var ref: DatabaseReference!
        ref = Database.database().reference()

        
        ref.child("redeem").observeSingleEvent(of: .value, with: { (snapshot) in

            
            let value = snapshot.value as? NSDictionary
   
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
    
        
        
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR/barcode is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        var countingObj = AVMetadataMachineReadableCodeObject()
        
        while metadataObj != countingObj {
            
            
            countingObj = metadataObj
            
            if supportedCodeTypes.contains(metadataObj.type) {
                
                
                // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
                
                let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
                qrCodeFrameView?.frame = barCodeObject!.bounds
                
                var testString = ""
                
                if metadataObj.stringValue != nil {
                    
                    let unwrappedObj = metadataObj.stringValue!
                    
                    scannedEmailAddress.append(unwrappedObj)
                    
                    
                    
                    while testString != unwrappedObj {
                        messageLabel.text = unwrappedObj
                        UIPasteboard.general.string = unwrappedObj
                        
                        
                        print("detected \(unwrappedObj)")
                        
                        
                        scannedEmailAddress.append(unwrappedObj)
                        
                        ref.child("redeem").setValue(["Redeemed": scannedEmailAddress])
                        
                        testString = unwrappedObj
                        
                        print("test String \(testString)")
                        print("Master List \(scannedEmailAddress)")
                        
                        
                    }
                    
                    
                }
            }
        }

        
            
        }
       
}
