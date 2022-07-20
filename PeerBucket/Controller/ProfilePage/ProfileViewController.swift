//
//  ProfileViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/21.
//

import Foundation
import UIKit
import FirebaseAuth
import Firebase
import Kingfisher

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var menuBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGreen
        view.layer.cornerRadius = 30
        return view
    }()
    
    var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var inviteView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.setCornerRadius(borderColor: UIColor.darkGreen.cgColor, width: 0.7, radius: 10)
        view.setShadow(color: .darkGreen, opacity: 0.1, radius: 3, offset: CGSize(width: 2, height: 2))
        return view
    }()
    
    var inviteLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGreen
        label.text = "Invite Partner"
        label.font = UIFont.bold(size: 28)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var inviteButton: UIButton = {
        let button = UIButton()
        button.setTitle("Scan QRCode", for: .normal)
        button.addTarget(self, action: #selector(tappedInviteBtn), for: .touchUpInside)
        button.setTextButton(bgColor: .lightGray, titleColor: .darkGreen, border: 0.7, font: 15)
        return button
    }()
    
    lazy var myQRButton: UIButton = {
        let button = UIButton()
        button.setTitle("Show QRCode", for: .normal)
        button.addTarget(self, action: #selector(tappedQRBtn), for: .touchUpInside)
        button.setTextButton(bgColor: .lightGray, titleColor: .darkGreen, border: 0.7, font: 15)
        return button
    }()
    
    var profileView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.setCornerRadius(borderColor: UIColor.darkGreen.cgColor, width: 0.7, radius: 10)
        view.setShadow(color: .darkGreen, opacity: 0.1, radius: 3, offset: CGSize(width: 2, height: 2))
        return view
    }()
    
    var profileLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGreen
        label.text = "Edit\nProfile"
        label.font = UIFont.bold(size: 28)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var nameButton: UIButton = {
        let button = UIButton()
        button.setTitle("Edit Name", for: .normal)
        button.addTarget(self, action: #selector(tappedNameBtn), for: .touchUpInside)
        button.setTextButton(bgColor: .lightGray, titleColor: .darkGreen, border: 0.7, font: 15)
        return button
    }()
    
    lazy var avatarButton: UIButton = {
        let button = UIButton()
        button.setTitle("Edit Avatar", for: .normal)
        button.addTarget(self, action: #selector(tappedAvatarBtn), for: .touchUpInside)
        button.setTextButton(bgColor: .lightGray, titleColor: .darkGreen, border: 0.7, font: 15)
        return button
    }()
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGreen
        label.text = "Welcome!"
        label.font = UIFont.bold(size: 32)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var settingButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 100, y: 100, width: 20, height: 20)
        button.setImage(UIImage(named: "icon_func_setting"), for: .normal)
        button.showsMenuAsPrimaryAction = true
        button.menu = UIMenu(children: [
            UIAction(title: "Sign Out", handler: { _ in
                self.tappedSignoutBtn()
            }),
            UIAction(title: "Disconnect Partner", handler: { _ in
                self.tappedBlockBtn()
            }),
            UIAction(title: "Delete Account", handler: { _ in
                self.tappedDeleteBtn()
            }),
            UIAction(title: "Privacy Policy", handler: { _ in
                self.tappedPrivacyBtn()
            })
        ])
        return button
    }()
    
    lazy var menuBarItem = UIBarButtonItem(customView: self.settingButton)
    
    var currentUser: User?
    var paringUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureAnchor()
        
        navigationItem.rightBarButtonItem = menuBarItem
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let currentUserUID = currentUserUID else {
            let loginVC = storyboard?.instantiateViewController(withIdentifier: "loginVC")
            guard let loginVC = loginVC as? LoginViewController else { return }
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true)
            return
        }
        
        fetchUserData(identityType: .currentUser, userID: currentUserUID)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2.08
    }
    
    func configureUI() {
        
        view.addSubview(nameLabel)
        view.addSubview(nameButton)
        view.addSubview(avatarImageView)
        
        view.addSubview(inviteView)
        view.addSubview(inviteLabel)
        inviteView.addSubview(inviteButton)
        inviteView.addSubview(myQRButton)
        
        view.addSubview(profileView)
        view.addSubview(profileLabel)
        profileView.addSubview(avatarButton)
        profileView.addSubview(nameButton)
        
        menuBottomConstraint.constant = hideMenuBottomConstraint
        blackView.backgroundColor = .black
        blackView.alpha = 0
        
        view.bringSubviewToFront(blackView)
        view.bringSubviewToFront(containerView)
        self.view.backgroundColor = .lightGray
        
    }
    
    func configureAnchor() {
        
        avatarImageView.anchor(top: view.topAnchor, paddingTop: 90, width: screenHeight * 0.3, height: screenHeight * 0.3)
        avatarImageView.centerX(inView: view)
        
        nameLabel.anchor(top: avatarImageView.bottomAnchor, left: view.leftAnchor,
                         paddingTop: 10, paddingLeft: 20, width: 300, height: 50)
        
        profileView.anchor(top: nameLabel.bottomAnchor, left: view.leftAnchor,
                           right: view.rightAnchor, paddingTop: 10,
                           paddingLeft: 20, paddingRight: 20, height: screenHeight * 0.18)
        profileLabel.anchor(top: profileView.topAnchor, left: profileView.leftAnchor,
                            paddingTop: 20, paddingLeft: 20, width: 150)
        
        profileLabel.centerY(inView: profileView)
        profileLabel.anchor(left: profileView.leftAnchor, paddingLeft: 20, width: 150)
        
        avatarButton.anchor(top: profileView.topAnchor, right: profileView.rightAnchor,
                            paddingTop: 20, paddingRight: 20, width: 150, height: screenHeight * 0.06)
        nameButton.anchor(top: avatarButton.bottomAnchor, right: profileView.rightAnchor,
                          paddingTop: 10, paddingRight: 20, width: 150, height: screenHeight * 0.06)
        
        inviteView.anchor(top: profileView.bottomAnchor, left: view.leftAnchor,
                          right: view.rightAnchor, paddingTop: 10,
                          paddingLeft: 20, paddingRight: 20, height: screenHeight * 0.18)
        inviteLabel.centerY(inView: inviteView)
        inviteLabel.anchor(left: inviteView.leftAnchor, paddingLeft: 20, width: 150)
        
        inviteButton.anchor(top: inviteView.topAnchor, right: inviteView.rightAnchor,
                            paddingTop: 20, paddingRight: 20, width: 150, height: screenHeight * 0.06)
        myQRButton.anchor(top: inviteButton.bottomAnchor, right: inviteView.rightAnchor,
                          paddingTop: 10, paddingRight: 20, width: 150, height: screenHeight * 0.06)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? QRCodeViewController {
            destination.delegate = self
        }
    }
    
    @objc func tappedInviteBtn() {
        guard currentUser?.paringUser == [] else {
            self.presentAlert(title: "Error", message: "Oops Already have a bucket peer")
            return
        }
        let inviteVC = storyboard?.instantiateViewController(withIdentifier: "inviteVC")
        guard let inviteVC = inviteVC as? InviteViewController else { return }
        navigationController?.pushViewController(inviteVC, animated: true)
    }
    
    @objc func tappedQRBtn() {
        guard currentUser?.paringUser == [] else {
            self.presentAlert(title: "Error", message: "Oops Already have a bucket peer")
            return
        }
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.menuBottomConstraint.constant = 140
            self.blackView.alpha = 0.5
        }
    }
    
    @objc func tappedAvatarBtn() {
        let avatarVC = storyboard?.instantiateViewController(withIdentifier: "avatarVC")
        guard let avatarVC = avatarVC as? AvatarViewController else { return }
        avatarVC.delegate = self
        navigationController?.pushViewController(avatarVC, animated: true)
    }
    
    @objc func tappedPrivacyBtn() {
        let webVC = storyboard?.instantiateViewController(withIdentifier: "webVC")
        guard let webVC = webVC as? WebViewController else { return }
        webVC.link = "https://www.privacypolicies.com/live/a978eac4-298f-4f57-9525-3b1bf9c8e989"
        self.present(webVC, animated: true)
    }
    
    // MARK: - Firebase data process
    
    @objc func tappedSignoutBtn() {
        do {
            try Auth.auth().signOut()
            
            let loginVC = storyboard?.instantiateViewController(withIdentifier: "loginVC")
            guard let loginVC = loginVC as? LoginViewController else { return }
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true)
            self.presentAlert()
            print("Successfully sign out")
            
        } catch let signOutError as NSError {
            print("Error signing out:", signOutError)
            self.presentAlert(title: "Error",
                              message: "Something went wrong. Please try again later.")
        }
    }
    
    @objc func tappedNameBtn() {
        
        self.presentInputAlert { name in
            
            guard let currentUser = self.currentUser else {
                return
            }
            
            let user = User(userID: currentUser.userID,
                            userAvatar: currentUser.userAvatar,
                            userHomeBG: currentUser.userHomeBG,
                            userName: name,
                            paringUser: currentUser.paringUser)
            
            self.updateUserData(identityType: .currentUser, user: user)
        }
    }
    
    @objc func tappedBlockBtn() {
        
        self.presentActionAlert(action: "Disconnect", title: "Disconnect Partner",
                                message: "Do you want to disconnect with partner?") {
            
            guard let currentUser = self.currentUser,
                  let paringUser = self.paringUser
            else {
                return
            }
            
            // update my paring status
            let user1 = User(userID: currentUser.userID,
                             userAvatar: currentUser.userAvatar,
                             userHomeBG: currentUser.userHomeBG,
                             userName: currentUser.userName,
                             paringUser: [])
            self.updateUserData(identityType: .currentUser, user: user1)
            
            // update paring user's paring status
            let user2 = User(userID: paringUser.userID,
                             userAvatar: paringUser.userAvatar,
                             userHomeBG: paringUser.userHomeBG,
                             userName: paringUser.userName,
                             paringUser: [])
            self.updateUserData(identityType: .paringUser, user: user2)
        }
    }
    
    @objc func tappedDeleteBtn() {
        
        self.presentActionAlert(action: "Delete", title: "Delete Account",
                                message: "Do you want to delete your acccount?") {
            
            Auth.auth().currentUser?.delete { error in
                
                if let error = error {
                    
                    let authErr = AuthErrorCode.Code(rawValue: error._code)
                    
                    if authErr == .requiresRecentLogin {
                        // authentication
                        self.presentActionAlert(action: "Login",
                                                title: "Authentication Required",
                                                message: """
                                                Delete account requires authentication which needs to relogin.
                                                Do you want to login again?
                                                """) {
                            // Signout
                            self.tappedSignoutBtn()
                        }
                    }
                    
                } else {
                    
                    print("Successfully delete account")
                    guard let currentUserUID = currentUserUID else {
                        return
                    }
                    
                    self.deleteUserData(userID: currentUserUID)
                    
                    // Disconnet partner
                    guard let paringUser = self.paringUser
                    else {
                        return
                    }
                    
                    let user2 = User(userID: paringUser.userID,
                                     userAvatar: paringUser.userAvatar,
                                     userHomeBG: paringUser.userHomeBG,
                                     userName: paringUser.userName,
                                     paringUser: [])
                    self.updateUserData(identityType: .paringUser, user: user2)
                }
            }
        }
        
    }
    
    func deleteUserData(userID: String) {
        UserManager.shared.deleteUserData(uid: userID, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                
                // back to loginVC
                let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC")
                guard let loginVC = loginVC as? LoginViewController else { return }
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: true)
                
                // present success
                self.presentAlert()
                print("Successfully delete account")
                
            case .failure(let error):
                self.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
                print("Delete account error: \(error)")
            }
        })
    }
    
    func fetchUserData(identityType: IdentityType, userID: String) {
        
        UserManager.shared.fetchUserData(userID: userID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                //                print("successfully find user in inviteVC")
                switch identityType {
                case .currentUser:
                    self.currentUser = user
                    
                    if user.userAvatar != "" {
                        let url = URL(string: user.userAvatar)
                        self.avatarImageView.kf.setImage(with: url)
                    } else {
                        self.avatarImageView.image = UIImage(named: "default_avatar")
                    }
                    
                    if user.userName != "" {
                        self.nameLabel.text = "Hi, \(user.userName)"
                    }
                    if user.paringUser != [] {
                        self.fetchUserData(identityType: .paringUser,
                                           userID: self.currentUser!.paringUser[0])
                    }
                case .paringUser:
                    self.paringUser = user
                }
            case .failure(let error):
                self.presentAlert(title: "Error",
                                  message: error.localizedDescription + " Please try again")
                print("can't find user in inviteVC")
            }
        }
    }
    
    func updateUserData(identityType: IdentityType, user: User) {
        UserManager.shared.updateUserData(user: user) { result in
            switch result {
            case .success:
                self.presentAlert()
                switch identityType {
                case .currentUser:
                    DispatchQueue.main.async {
                        self.nameLabel.text = "Hi \(user.userName)!"
                    }
                case .paringUser:
                    break
                }
            case .failure(let error):
                self.presentAlert(title: "Error",
                                  message: error.localizedDescription + " Please try again")
            }
        }
    }
}

// MARK: - Delegate

extension ProfileViewController: QRCodeViewControllerDelegate {
    func didTappedClose() {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.menuBottomConstraint.constant = hideMenuBottomConstraint
            self.blackView.alpha = 0
        }
    }
}

extension ProfileViewController: AvatarViewControllerDelegate {
    
    func didTappedSubmit() {
        guard let currentUserUID = currentUserUID else { return }
        fetchUserData(identityType: .currentUser, userID: currentUserUID)
    }
}
