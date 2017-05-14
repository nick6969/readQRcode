//
//  QRcodeScanVC.swift
//  readQRcode
//
//  Created by nickLin on 2017/5/14.
//  Copyright © 2017年 nickLin. All rights reserved.
//

import UIKit
import AVFoundation

class QRcodeScanVC: UIViewController , AVCaptureMetadataOutputObjectsDelegate {

    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    

    let supportedBarCodes = [AVMetadataObjectTypeQRCode]

    override func viewDidLoad() {
        super.viewDidLoad()

        checkCamera()
        setupCapture()

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession?.startRunning()
    }
    
    func checkCamera() {
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch authStatus {
        case AVAuthorizationStatus.authorized:
            print("AVAuthorizationStatus.Authorized")
        case .denied , .restricted:
            let alert = UIAlertController(title: "您尚未准予使用相機", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .destructive, handler: {_ in
                self.navigationController?.popViewController(animated: true)
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        case AVAuthorizationStatus.notDetermined:
            print("AVAuthorizationStatus.notDetermined")
        }
        
    }

    func setupCapture(){
        
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            captureMetadataOutput.metadataObjectTypes = supportedBarCodes
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            
        } catch {
            print(error.localizedDescription)
            return
        }
        
    }

    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!){
        
        guard metadataObjects != nil && metadataObjects.count != 0 else {
            qrCodeFrameView?.frame = .zero
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        guard supportedBarCodes.contains(metadataObj.type) else {
            return
        }
        
        if let str = metadataObj.stringValue{
            captureSession?.stopRunning()
            let alert = UIAlertController(title: "掃描到的文字", message: str, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .default, handler: { (_) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }

}
