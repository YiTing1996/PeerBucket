//
//  InviteViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/21.
//

import UIKit
import AVFoundation
import FirebaseAuth

final class InviteViewController: UIViewController {
    
    // MARK: - Properties
    
    private lazy var qrCodeFrameView: UIView = create {
        $0.layer.borderColor = UIColor.green.cgColor
        $0.layer.borderWidth = 2
    }
    
    private var captureSession = AVCaptureSession()
    private var videoPreviewLayer = AVCaptureVideoPreviewLayer()
    
    private var currentUser: User?
    private var paringUser: User?
//    private var paringUserName: String = ""
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning == true {
            captureSession.stopRunning()
        }
        tabBarController?.tabBar.isHidden = false
    }
    
    private func showInviteAlert(userID: String) {
        guard let paringUser = paringUser, let currentUser = currentUser else { return }
        presentActionAlert(
            action: "Invite",
            title: "Invite your BucketPeer to chat and share bucket list!",
            message: "Do you want to invite user \(paringUser.userName)?") { [weak self] in
                guard let self = self else { return }
                self.paringUser(for: currentUser, by: paringUser.userID)
                self.paringUser(for: paringUser, by: currentUser.userID)
                self.routeToRoot()
            }
    }
    
    // MARK: - Firebase handler
    
    private func paringUser(for user: User, by id: String) {
        let updatedUser = User(userID: user.userID,
                        userAvatar: user.userAvatar,
                        userHomeBG: user.userHomeBG,
                        userName: user.userName,
                        paringUser: [id])
        UserManager.shared.updateUserData(user: updatedUser) { [weak self] result in
            switch result {
            case .success:
                self?.presentAlert()
            case .failure(let error):
                self?.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
            }
        }
    }
    
    private func fetchUserData(userID: String) {
        UserManager.shared.fetchUserData(userID: userID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.currentUser = user
            case .failure(let error):
                self.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
            }
        }
    }
    
    private func fetchUser(userID: String) {
        UserManager.shared.checkParingUser(userID: userID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.paringUser = user
                self.showInviteAlert(userID: userID)
            case .failure:
                self.presentAlert(title: "Error", message: "Can't Find User")
            }
        }
    }
}

// MARK: - QRCode Reader
extension InviteViewController: AVCaptureMetadataOutputObjectsDelegate {
    func callingScanner() {
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            Log.e("fail to get device")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        } catch {
            Log.e(error.localizedDescription)
            return
        }
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)
        
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer)
        view.addSubview(qrCodeFrameView)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadata = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              metadata.type == .qr else {
            qrCodeFrameView.frame = .zero
            return
        }
        
        guard let barCodeObject = videoPreviewLayer.transformedMetadataObject(for: metadata) else {
            self.presentAlert(title: "Error", message: "Can't Find User")
            return
        }
        qrCodeFrameView.frame = barCodeObject.bounds
        if let metadataString = metadata.stringValue, metadataString.isNotEmpty {
            fetchUser(userID: metadata.stringValue ?? "")
        }
    }
}
