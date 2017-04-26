//
//  QRScannerController.swift
//  QRCodeReader
//
//  Based on code by Simon Ng, AppCoda
//  Copyright © 2017 zimt.io. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation
import SwiftyJSON

class QRScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet var messageLabel:UILabel!
    @IBOutlet var topbar: UIView!
    @IBOutlet var EnterCode: UIButton!
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var purchaseSession: Purchase?
    var scannedEAN:String?
    var userKnown = false
    var emmaUID: String?
    private var timer: Timer?
    var scanningActive = true
    
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
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        EnterCode.isHidden = true
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
            view.bringSubview(toFront: EnterCode)
            // Initialize QR Code Frame to highlight the QR code
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
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
    
    @IBAction func SaveAction(_ sender: Any) {
        print("Saving Data")
        //session.add(uid: emmaUID!, ean: scannedEAN!)
    }
    
    func displayLabel(msg: String){
        messageLabel.text = msg
        print(msg)
    }

    // MARK: - AVCaptureMetadataOutputObjectsDelegate Methods
    
    func popupWarning(title: String, msg: String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("OK")
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func signalValidEntityBeep() {
        // issued when a valid user or valid stock EAN code is detected
        AudioServicesPlayAlertSound(SystemSoundID(1256))
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    func lookupUserCallback(val: Bool, resp: JSON) {
        if val == false {
            popupWarning(title: "Unknown User", msg: "User could not be found in Emma loyalty programme.")
        } else {
            emmaUID = resp["username"].description
            messageLabel.text = "Customer is: " + emmaUID!
            purchaseSession = Purchase(uid: emmaUID!)
            userKnown = true
            signalValidEntityBeep()
        }
    }
    
    func pauseScanning(duration: Int) {
        scanningActive = false
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(duration), repeats: false) { timer in
                //self.videoPreviewLayer?.connection.isEnabled = true // Restart scanning
                self.scanningActive = true
                print("RESTART SCANNING")
            }
        }
    }
    
    func lookupItemCallback(val: Bool, resp: JSON) {
        if val == true {
            signalValidEntityBeep() // Signal user that we're know this item
            //videoPreviewLayer?.connection.isEnabled = false // Stop scanning to avoid multiple entries
            scanningActive = false
            print("STOP SCANNING")
            DispatchQueue.main.async {
                self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { timer in
                    //self.videoPreviewLayer?.connection.isEnabled = true // Restart scanning
                    self.scanningActive = true
                    print("RESTART SCANNING")
                }
            }
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if (metadataObjects == nil || metadataObjects.count == 0){
            qrCodeFrameView?.frame = CGRect.zero
            EnterCode.isHidden = true
            if !userKnown { messageLabel.text = "No QR/barcode is detected" }
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) && scanningActive {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.type.description == "org.iso.QRCode" && userKnown == false {
                let scannedUserQR = metadataObj.stringValue
                let id = Identity()
                id.checkUserQR(scannedQR: scannedUserQR!, completion: lookupUserCallback)
            }
            
            if metadataObj.type.description == "org.iso.Code128" {
                scannedEAN = metadataObj.stringValue
                if !userKnown {
                    popupWarning(title: "Unknown Customer", msg: "Please scan Emma loyalty ID first")
                } else {
                    pauseScanning(duration: 2)
                    purchaseSession?.add(ean: scannedEAN!, completion: lookupItemCallback)
                    EnterCode.isHidden = false;

                }
                
            }
        }
    }

}
