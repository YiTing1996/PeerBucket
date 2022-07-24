//
//  AvatarViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/23.
//

import Foundation
import UIKit
import FirebaseAuth

protocol AvatarViewControllerDelegate: AnyObject {
    func didTappedSubmit()
}

class AvatarViewController: UIViewController {
    
    // MARK: - Properties

    weak var delegate: AvatarViewControllerDelegate?
    
    var currentUser: User?
    
    lazy var submitButton: UIButton = create {
        $0.setTitle("Submit", for: .normal)
        $0.addTarget(self, action: #selector(tappedSubmit), for: .touchUpInside)
        $0.setTextButton(bgColor: .clear, titleColor: .darkGreen, border: 0, font: 15)
    }
    
    lazy var menuBarItem = UIBarButtonItem(customView: self.submitButton)
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var hair: UIImageView!
    @IBOutlet weak var face: UIImageView!
    @IBOutlet weak var glasses: UIImageView!
    @IBOutlet weak var body: UIImageView!
    
    @IBOutlet weak var backgroundSlider: UISlider!
    @IBOutlet weak var selectionView: UIView!
    @IBOutlet weak var hairView: UIView!
    @IBOutlet weak var faceView: UIView!
    @IBOutlet weak var glassesView: UIView!
    @IBOutlet weak var bodyView: UIView!
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUserUID = currentUserUID else {
            return
        }
        fetchUserData(userID: currentUserUID)
        
        hairView.isHidden = false
        faceView.isHidden = true
        glassesView.isHidden = true
        bodyView.isHidden = true
        
        navigationItem.rightBarButtonItem = menuBarItem

        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Configure UI

    func configureUI() {
        backgroundView.anchor(top: view.topAnchor, left: view.leftAnchor,
                              bottom: selectionView.topAnchor, right: view.rightAnchor,
                              height: screenHeight * 0.5)
        backgroundSlider.anchor(left: view.leftAnchor, bottom: backgroundView.bottomAnchor,
                                right: view.rightAnchor, paddingLeft: 10, paddingBottom: 10,
                                paddingRight: 10, height: 50)
        selectionView.anchor(left: view.leftAnchor, right: view.rightAnchor,
                             height: screenHeight * 0.1)
        hairView.anchor(top: selectionView.bottomAnchor, left: view.leftAnchor,
                        bottom: view.bottomAnchor, right: view.rightAnchor,
                        height: screenHeight * 0.4)
        faceView.anchor(top: selectionView.bottomAnchor, left: view.leftAnchor,
                        bottom: view.bottomAnchor, right: view.rightAnchor,
                        height: screenHeight * 0.4)
        glassesView.anchor(top: selectionView.bottomAnchor, left: view.leftAnchor,
                           bottom: view.bottomAnchor, right: view.rightAnchor,
                           height: screenHeight * 0.4)
        bodyView.anchor(top: selectionView.bottomAnchor, left: view.leftAnchor,
                        bottom: view.bottomAnchor, right: view.rightAnchor,
                        height: screenHeight * 0.4)
        
    }
    
    // MARK: - Firebase handler
    
    func fetchUserData(userID: String) {
        
        UserManager.shared.fetchUserData(userID: userID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.currentUser = user
            case .failure(let error):
                self.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
                print("Can't find user in avatarVC")
            }
        }
    }
    
    func saveAvatar(urlString: String) {
        
        guard let currentUser = self.currentUser else {
            return
        }

        let user = User(userID: currentUser.userID,
                        userAvatar: urlString,
                        userHomeBG: currentUser.userHomeBG,
                        userName: currentUser.userName,
                        paringUser: currentUser.paringUser)
        
        UserManager.shared.updateUserData(user: user) { result in
            switch result {
            case .success:
                print("Successfully update avatar to firebase")
                self.delegate?.didTappedSubmit()
            case .failure:
                self.presentAlert(title: "Error",
                                  message: "Something went wrong. Please try again later.")
            }
        }
    }
    
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
            
            storage.child("avatar/\(imageName).png").downloadURL(completion: { url, error in
                guard let url = url, error == nil else {
                    return
                }
                let urlString = url.absoluteString
                UserDefaults.standard.set(urlString, forKey: "url")
                
                self.saveAvatar(urlString: urlString)
                
            })
        }
    }
    
    // MARK: - Button actions
    
    @objc func tappedSubmit() {
        let renderer = UIGraphicsImageRenderer(size: backgroundView.bounds.size)
        let image = renderer.image(actions: { _ in
           backgroundView.drawHierarchy(in: backgroundView.bounds, afterScreenUpdates: true)
        })
        avatarProcess(image: image)
        self.presentAlert(title: "Congrats", message: "Avatar successfully update", completion: {
            self.navigationController?.popViewController(animated: true)
        })
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
