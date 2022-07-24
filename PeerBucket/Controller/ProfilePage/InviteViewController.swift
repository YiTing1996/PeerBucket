//
//  InviteViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/21.
//

import Foundation
import UIKit
import AVFoundation
import FirebaseAuth

class InviteViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    // MARK: - Properties

    lazy var qrCodeFrameView: UIView = create {
        $0.layer.borderColor = UIColor.green.cgColor
        $0.layer.borderWidth = 2
    }
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var currentUser: User?
    var paringUser: User?
    var paringUserName: String = ""
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        callingScanner()

        guard let currentUserUID = currentUserUID else {
            return
        }
        
        fetchUserData(userID: currentUserUID)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if captureSession.isRunning == false {
            captureSession.startRunning()
        }
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning == true {
            captureSession.stopRunning()
        }
        self.tabBarController?.tabBar.isHidden = false
    }
        
    // MARK: - Firebase handler
    
    func addSelfParing(paringUserID: String) {
        
        guard let currentUser = currentUser else {
            return
        }
        
        let user = User(userID: currentUser.userID,
                        userAvatar: currentUser.userAvatar,
                        userHomeBG: currentUser.userHomeBG,
                        userName: currentUser.userName,
                        paringUser: [paringUserID])
        
        UserManager.shared.updateUserData(user: user) { result in
            switch result {
            case .success:
                self.presentAlert()
            case .failure(let error):
                self.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
            }
        }
    }
    
    func addOthersParing(paringUserID: String) {
        
        guard let paringUser = paringUser else {
            return
        }
        
        let user = User(userID: paringUser.userID,
                        userAvatar: paringUser.userAvatar,
                        userHomeBG: paringUser.userHomeBG,
                        userName: paringUser.userName,
                        paringUser: [paringUserID] )
        
        UserManager.shared.updateUserData(user: user) { result in
            switch result {
            case .success:
                self.presentAlert()
            case .failure(let error):
                self.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
            }
        }
    }
    
    func fetchUserData(userID: String) {
        UserManager.shared.fetchUserData(userID: userID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.currentUser = user
            case .failure(let error):
                self.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
                print("can't find user in inviteVC")
            }
        }
    }
        
    func fetchUser(userID: String) {
        
        UserManager.shared.checkParingUser(userID: userID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.paringUserName = user.userName
                self.paringUser = user
                
                self.presentActionAlert(
                    action: "Invite",
                    title: "Invite your BucketPeer to chat and share bucket list!",
                    message: "Do you want to invite user \(self.paringUserName)?") {
                        
                        guard currentUserUID != nil else {
                            print("Error: can't find paring user in invite VC")
                            return
                        }
                        
                        self.addSelfParing(paringUserID: userID )
                        self.addOthersParing(paringUserID: currentUserUID ?? "")
                        
                        let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "tabBarVC")
                        guard let tabBarVC = tabBarVC as? TabBarController else { return }
                        
                        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                        sceneDelegate?.changeRootViewController(tabBarVC)
                    }
                
            case .failure:
                self.presentAlert(title: "Error", message: "Can't Find User")
            }
        }
        
    }
    
}

// MARK: - QRCode Reader
extension InviteViewController {
    
    func callingScanner() {
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession.addInput(input)
            
        } catch {
            print(error)
            return
        }
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)
        
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        view.addSubview(qrCodeFrameView)
        view.bringSubviewToFront(qrCodeFrameView)
        
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count == 0 {
            qrCodeFrameView.frame = CGRect.zero
            return
        }
        
        guard let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else { return }
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            guard let barCodeObject = barCodeObject else {
                self.presentAlert(title: "Error", message: "Can't Find User")
                return
            }
            qrCodeFrameView.frame = barCodeObject.bounds
            
            if metadataObj.stringValue != "" {
                fetchUser(userID: metadataObj.stringValue ?? "")
            }
        }
    }
    
}
