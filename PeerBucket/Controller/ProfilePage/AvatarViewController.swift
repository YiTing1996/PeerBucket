//
//  AvatarViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/23.
//

import Foundation
import UIKit
import FirebaseStorage

class AvatarViewController: UIViewController {
    
    private let storage = Storage.storage().reference()

    var currentUser: User?
    
    lazy var submitButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        button.addTarget(self, action: #selector(tappedSubmit), for: .touchUpInside)
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(UIColor.textGray, for: .normal)
        return button
    }()
    
    lazy var menuBarItem = UIBarButtonItem(customView: self.submitButton)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hairView.isHidden = false
        faceView.isHidden = true
        glassesView.isHidden = true
        bodyView.isHidden = true
        navigationItem.rightBarButtonItem = menuBarItem
        fetchUserData(userID: currentUserUID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var hair: UIImageView!
    @IBOutlet weak var face: UIImageView!
    @IBOutlet weak var glasses: UIImageView!
    @IBOutlet weak var body: UIImageView!
    
    @IBOutlet weak var hairView: UIView!
    @IBOutlet weak var faceView: UIView!
    @IBOutlet weak var glassesView: UIView!
    @IBOutlet weak var bodyView: UIView!
    
    @objc func tappedSubmit() {
        print("Tapped Submit")
        let renderer = UIGraphicsImageRenderer(size: backgroundView.bounds.size)
        let image = renderer.image(actions: { _ in
           backgroundView.drawHierarchy(in: backgroundView.bounds, afterScreenUpdates: true)
        })
        avatarProcess(image: image)
        presentSuccessAlert()
    }
    
    // fetch current user's data
    func fetchUserData(userID: String) {
        UserManager.shared.fetchUserData(userID: userID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.currentUser = user
                print("current user is: \(String(describing: self.currentUser))")
            case .failure(let error):
                self.presentErrorAlert(message: error.localizedDescription + " Please try again")
                print("Can't find user in homeVC")
            }
        }
    }
    
    // upload to firebase storage
    func avatarProcess(image: UIImage) {
        guard let imageData = image.pngData() else {
            return
        }
        
        let imageName = NSUUID().uuidString
        storage.child("avatar/\(imageName).png").putData(imageData, metadata: nil) { _, error in
            
            guard error == nil else {
                print("Fail to upload image")
                return
            }
            
            self.storage.child("avatar/\(imageName).png").downloadURL(completion: { url, error in
                guard let url = url, error == nil else {
                    return
                }
                let urlString = url.absoluteString
                UserDefaults.standard.set(urlString, forKey: "url")
                
                // save to firebase
                print("currentUser: \(String(describing: self.currentUser))")
                guard let currentUser = self.currentUser else {
                    return
                }

                let user = User(userEmail: currentUser.userEmail,
                                userID: currentUserUID,
                                userAvatar: urlString,
                                userHomeBG: currentUser.userHomeBG,
                                userName: currentUser.userName,
                                paringUser: currentUser.paringUser)
                
                UserManager.shared.updateUserData(user: user) { result in
                    switch result {
                    case .success:
                        print("Successfully update avatar to firebase")
                    case .failure(let error):
                        self.presentErrorAlert(message: error.localizedDescription + " Please try again")
                    }
                }
            })
        }
    }
    
    @IBAction func changeHair(_ sender: UIButton) {
        let image = sender.currentBackgroundImage
        hair.image = image
    }
    @IBAction func changeFace(_ sender: UIButton) {
        let image = sender.currentBackgroundImage
        face.image = image
    }
    @IBAction func changeGlasses(_ sender: UIButton) {
        let image = sender.currentBackgroundImage
        glasses.image = image
        if image?.isSymbolImage == true {
            glasses.image = nil
        }
    }
    
    @IBAction func chageBody(_ sender: UIButton) {
        let image = sender.currentBackgroundImage
        body.image = image
    }

    var colorValue: CGFloat = 0.5
    @IBAction func chageBackground(_ sender: UISlider) {
        // sender的index
        colorValue = CGFloat(sender.value)
        backgroundView.backgroundColor = UIColor(hue: colorValue, saturation: 0.8, brightness: 1, alpha: 1)
    }
    
    @IBAction func selectHair(_ sender: UIButton) {
        hairView.isHidden = false
        faceView.isHidden = true
        glassesView.isHidden = true
        bodyView.isHidden = true
    }
   
    @IBAction func selectFace(_ sender: UIButton) {
        hairView.isHidden = true
        faceView.isHidden = false
        glassesView.isHidden = true
        bodyView.isHidden = true
    }
    @IBAction func selectGlasses(_ sender: UIButton) {
        hairView.isHidden = true
        faceView.isHidden = true
        glassesView.isHidden = false
        bodyView.isHidden = true
    }
    
    @IBAction func selectBody(_ sender: UIButton) {
        hairView.isHidden = true
        faceView.isHidden = true
        glassesView.isHidden = true
        bodyView.isHidden = false
    }
    
}
