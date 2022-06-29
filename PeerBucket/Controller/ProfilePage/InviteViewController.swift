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

enum IdentityType: String, CaseIterable {
    case currentUser
    case paringUser
}

class InviteViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var currentUser: User?
    var paringUser: User?
    
//    var outputTextView: UITextView = {
//        let textView = UITextView()
//        textView.backgroundColor = .lightGray
//        return textView
//    }()
    
    var qrCodeFrameView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.green.cgColor
        view.layer.borderWidth = 2
        return view
    }()
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var currentUserUID: String?
    //    var currentUserUID = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        configureUI()
        callingScanner()
        
        if isBeta {
            self.currentUserUID = "AITNzRSyUdMCjV4WrQxT"
        } else {
            self.currentUserUID = Auth.auth().currentUser?.uid ?? nil
        }
        
        guard let currentUserUID = currentUserUID else {
            return
        }
        
        fetchUserData(identityType: .currentUser, userID: currentUserUID)
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
    
//    func configureUI() {
//        view.addSubview(outputTextView)
//        outputTextView.anchor(bottom: view.bottomAnchor, paddingBottom: 20,
//                              width: view.frame.width, height: 50)
//
//    }
    
    func addSelfParing(paringUserID: String) {
        
        guard let currentUser = currentUser else {
            return
        }
        
        // 填入自己的資料
        let user = User(userID: currentUser.userID,
                        userAvatar: currentUser.userAvatar,
                        userHomeBG: currentUser.userHomeBG,
                        userName: currentUser.userName,
                        paringUser: [paringUserID])
        
        UserManager.shared.updateUserData(user: user) { result in
            switch result {
            case .success:
                self.presentSuccessAlert()
            case .failure(let error):
                self.presentErrorAlert(message: error.localizedDescription + " Please try again")
            }
        }
    }
    
    func addOthersParing(paringUserID: String) {
        
        guard let paringUser = paringUser else {
            return
        }
        
        // 填入他人的資料
        let user = User(userID: paringUser.userID,
                        userAvatar: paringUser.userAvatar,
                        userHomeBG: paringUser.userHomeBG,
                        userName: paringUser.userName,
                        paringUser: [paringUserID] )
        
        UserManager.shared.updateUserData(user: user) { result in
            switch result {
            case .success:
                self.presentSuccessAlert()
            case .failure(let error):
                self.presentErrorAlert(message: error.localizedDescription + " Please try again")
            }
        }
    }
    
    func fetchUserData(identityType: IdentityType, userID: String) {
        
        UserManager.shared.fetchUserData(userID: userID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                print("successfully find user in inviteVC")
                switch identityType {
                case .currentUser:
                    self.currentUser = user
                case .paringUser:
                    self.paringUser = user
                }
            case .failure(let error):
                self.presentErrorAlert(message: error.localizedDescription + " Please try again")
                print("can't find user in inviteVC")
            }
        }
    }
    
}

// MARK: - QRCode Reader
extension InviteViewController {
    
    func callingScanner() {
        // 取得後置鏡頭來擷取影片
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // 使用前一個裝置物件來取得 AVCaptureDeviceInput 類別的實例
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // 在擷取 session 設定輸入裝置
            captureSession.addInput(input)
            
        } catch {
            print(error)
            return
        }
        
        // 初始化一個 AVCaptureMetadataOutput 物件並將其設定做為擷取 session 的輸出裝置
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)
        
        // 設定委派並使用預設的調度佇列來執行回呼（call back）
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        // 初始化影片預覽層，並將其作為子層加入 viewPreview 視圖的圖層中
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        view.addSubview(qrCodeFrameView)
        view.bringSubviewToFront(qrCodeFrameView)
//        view.bringSubviewToFront(outputTextView)
        
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // 檢查metadataObjects 陣列為非空值，它至少需包含一個物件
        if metadataObjects.count == 0 {
            qrCodeFrameView.frame = CGRect.zero
//            outputTextView.text = "No QR code is detected"
            return
        }
        
        // 取得元資料（metadata）物件
        guard let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else { return }
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            // 若發現的元資料與 QR code 元資料相同，便更新狀態標籤的文字並設定邊界
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != "" {
                // query既有的user取得資料
                fetchUserData(identityType: .paringUser, userID: metadataObj.stringValue ?? "")
                
                // 如果已經有paring user 就不能再新增
                guard currentUser?.paringUser != [] else {
                    self.presentErrorAlert(message: "Oops!User \(String(describing: paringUser?.userName)) already have bucket peer")
                    
                    // 跳回首頁
                    let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "tabBarVC")
                    guard let tabBarVC = tabBarVC as? TabBarController else { return }
                    
                    let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                    sceneDelegate?.changeRootViewController(tabBarVC)
                    
                    return
                }
                
                guard let paringUserName = paringUser?.userName as? String else { return }
                
                self.presentInviteAlert(
                    title: "Invite your BucketPeer to chat and share bucket list!",
                    message: "Do you want to invite user \(paringUserName)?") {
                        
                        // 確認Invite -> 寫入自己＆partner的firebase
                        self.addSelfParing(paringUserID: metadataObj.stringValue ?? "")
                        self.addOthersParing(paringUserID: self.currentUserUID!)
                        
                        // 跳回首頁
                        let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "tabBarVC")
                        guard let tabBarVC = tabBarVC as? TabBarController else { return }
                        
                        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                        sceneDelegate?.changeRootViewController(tabBarVC)
                    }
            }
            
        }
    }
    
}
