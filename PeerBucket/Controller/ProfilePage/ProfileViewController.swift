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
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 100
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var inviteView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 10
        return view
    }()
    
    var inviteLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGreen
        label.text = "Invite Friends Joining"
        label.font = UIFont.bold(size: 25)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var inviteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.lightGray
        button.addTarget(self, action: #selector(tappedInviteBtn), for: .touchUpInside)
        button.setTitle("Scan QRCode", for: .normal)
        button.setTitleColor(UIColor.darkGreen, for: .normal)
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.semiBold(size: 16)
        return button
    }()
    
    lazy var myQRButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.lightGray
        button.addTarget(self, action: #selector(tappedQRBtn), for: .touchUpInside)
        button.setTitle("Show QRCode", for: .normal)
        button.setTitleColor(UIColor.darkGreen, for: .normal)
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.semiBold(size: 16)
        return button
    }()
    
    var profileView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 10
        return view
    }()
    
    var profileLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGreen
        label.text = "Edit\nProfile"
        label.font = UIFont.bold(size: 25)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var nameButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.lightGray
        button.addTarget(self, action: #selector(tappedNameBtn), for: .touchUpInside)
        button.setTitle("Edit Name", for: .normal)
        button.setTitleColor(UIColor.darkGreen, for: .normal)
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.semiBold(size: 16)
        return button
    }()
    
    lazy var avatarButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.lightGray
        button.addTarget(self, action: #selector(tappedAvatarBtn), for: .touchUpInside)
        button.setTitle("Edit Avatar", for: .normal)
        button.setTitleColor(UIColor.darkGreen, for: .normal)
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.semiBold(size: 16)
        return button
    }()
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGreen
        label.text = "Welcome!"
        label.font = UIFont.bold(size: 30)
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
            UIAction(title: "Block User", handler: { _ in
                self.tappedBlockBtn()
            }),
            UIAction(title: "Delete Account", handler: { _ in
                self.tappedDeleteBtn()
            })
        ])
        return button
    }()
        
    var currentUser: User?
    var currentUserUID: String?
    
    lazy var menuBarItem = UIBarButtonItem(customView: self.settingButton)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureAnchor()
        
        navigationItem.rightBarButtonItem = menuBarItem

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isBeta {
            self.currentUserUID = "AITNzRSyUdMCjV4WrQxT"
        } else {
            self.currentUserUID = Auth.auth().currentUser?.uid ?? nil
        }
        
        guard let currentUserUID = currentUserUID else {
            let loginVC = storyboard?.instantiateViewController(withIdentifier: "loginVC")
            guard let loginVC = loginVC as? LoginViewController else { return }
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true)
            return
        }
        
        fetchUserData(userID: currentUserUID)
        
    }
    
    func configureUI() {

        view.addSubview(nameLabel)
        view.addSubview(nameButton)
        view.addSubview(avatarImageView)
        view.addSubview(inviteView)
        view.addSubview(inviteLabel)
        view.addSubview(inviteButton)
        view.addSubview(myQRButton)
        
        view.addSubview(profileView)
        view.addSubview(profileLabel)
        view.addSubview(avatarButton)
        view.addSubview(nameButton)
        
        menuBottomConstraint.constant = -500
        blackView.backgroundColor = .black
        blackView.alpha = 0
        
        view.bringSubviewToFront(blackView)
        view.bringSubviewToFront(containerView)
        self.view.backgroundColor = .lightGray
        
    }
    
    func configureAnchor() {
                
        avatarImageView.anchor(top: view.topAnchor, paddingTop: 100,
                               width: 250, height: 250)
        avatarImageView.centerX(inView: view)
        
        nameLabel.anchor(top: avatarImageView.bottomAnchor, left: view.leftAnchor,
                         paddingTop: 20, paddingLeft: 20, width: 300, height: 50)
        
        inviteView.anchor(top: nameLabel.bottomAnchor, left: view.leftAnchor,
                          right: view.rightAnchor, paddingTop: 20,
                          paddingLeft: 20, paddingRight: 20, height: 150)
        inviteLabel.anchor(top: inviteView.topAnchor, left: inviteView.leftAnchor,
                           paddingTop: 20, paddingLeft: 20, width: 150)
        inviteButton.anchor(top: inviteView.topAnchor, right: inviteView.rightAnchor,
                            paddingTop: 20, paddingRight: 20, width: 150, height: 50)
        myQRButton.anchor(top: inviteButton.bottomAnchor, right: inviteView.rightAnchor,
                          paddingTop: 10, paddingRight: 20, width: 150, height: 50)
        
        profileView.anchor(top: inviteView.bottomAnchor, left: view.leftAnchor,
                          right: view.rightAnchor, paddingTop: 10,
                          paddingLeft: 20, paddingRight: 20, height: 150)
        profileLabel.anchor(top: profileView.topAnchor, left: profileView.leftAnchor,
                           paddingTop: 20, paddingLeft: 20, width: 150)
        avatarButton.anchor(top: profileView.topAnchor, right: profileView.rightAnchor,
                            paddingTop: 20, paddingRight: 20, width: 150, height: 50)
        nameButton.anchor(top: avatarButton.bottomAnchor, right: profileView.rightAnchor,
                          paddingTop: 10, paddingRight: 20, width: 150, height: 50)
        
    }
    
    @objc func tappedInviteBtn() {
        guard currentUser?.paringUser != nil else {
            self.presentAlert(title: "Error", message: "Oops Already have a bucket peer")
            return
        }
        let inviteVC = storyboard?.instantiateViewController(withIdentifier: "inviteVC")
        guard let inviteVC = inviteVC as? InviteViewController else { return }
        navigationController?.pushViewController(inviteVC, animated: true)
    }
    
    @objc func tappedQRBtn() {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.menuBottomConstraint.constant = 200
            self.blackView.alpha = 0.5
        }
    }
    
    @objc func tappedAvatarBtn() {
        let avatarVC = storyboard?.instantiateViewController(withIdentifier: "avatarVC")
        guard let avatarVC = avatarVC as? AvatarViewController else { return }
        avatarVC.delegate = self
        navigationController?.pushViewController(avatarVC, animated: true)
        
    }
    
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
            self.presentAlert(title: "Error", message: "Something went wrong. Please try again later.")
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
            
            UserManager.shared.updateUserData(user: user) { result in
                switch result {
                case .success:
                    self.fetchUserData(userID: currentUser.userID)
                    DispatchQueue.main.async {
                        self.nameLabel.text = "Hi \(name)!"
                    }
                    self.presentAlert()
                case .failure(let error):
                    self.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
                }
            }
        }
    }
    
    // Clear paring user
    @objc func tappedBlockBtn() {
        
        self.presentActionAlert(action: "Block", title: "Block User",
                                message: "Do you want to block your paring user?") {
            
            guard let currentUser = self.currentUser else {
                return
            }
            
            let user = User(userID: currentUser.userID,
                            userAvatar: currentUser.userAvatar,
                            userHomeBG: currentUser.userHomeBG,
                            userName: currentUser.userName,
                            paringUser: [])
            
            UserManager.shared.updateUserData(user: user) { result in
                switch result {
                case .success:
                    self.presentAlert()
                    
                case .failure(let error):
                    self.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
                }
            }
        }
    }
    
    // MARK: - Firebase data process
    
    @objc func tappedDeleteBtn() {
        
        self.presentActionAlert(action: "Delete", title: "Delete Account",
                                message: "Do you want to delete your acccount?") {
            
            Auth.auth().currentUser?.delete { error in
                if let error = error {
                    print("Error in profileVC: \(error)")
                } else {
                    print("Successfully delete account")
                    guard let currentUserUID = self.currentUserUID else {
                        return
                    }
                    
                    UserManager.shared.deleteUserData(uid: currentUserUID, completion: { [weak self] result in
                        guard let self = self else { return }
                        switch result {
                        case .success:
                            
                            // back to loginVC
                            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC")
                            guard let loginVC = loginVC as? LoginViewController else { return }
                            self.navigationController?.pushViewController(loginVC, animated: true)
                            
                            // present success
                            self.presentAlert()
                            print("Successfully delete account")
                            
                        case .failure(let error):
                            self.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
                            print("Delete account error: \(error)")
                        }
                    })
                }
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? QRCodeViewController {
            destination.delegate = self
        }
    }
    
    func fetchUserData(userID: String) {
        
        // fetch avatar photo from firebase
        UserManager.shared.fetchUserData(userID: userID) { result in
            switch result {
            case .success(let user):
                
                self.currentUser = user
                
                let url = URL(string: user.userAvatar)
                self.avatarImageView.kf.setImage(with: url)
                if user.userName != "" {
                    self.nameLabel.text = "Hi, \(user.userName)"
                }
                
            case .failure(let error):
                self.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
            }
        }
    }
    
}

// MARK: - Delegate

extension ProfileViewController: QRCodeViewControllerDelegate {
    func didTappedClose() {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.menuBottomConstraint.constant = -500
            self.blackView.alpha = 0
        }
    }
}

extension ProfileViewController: AvatarViewControllerDelegate {
    
    func didTappedSubmit() {
        guard let currentUserUID = currentUserUID else { return }
        fetchUserData(userID: currentUserUID)
    }
    
}
