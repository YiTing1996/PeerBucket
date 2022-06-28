//
//  ProfileViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/21.
//

import Foundation
import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var menuBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var containerView: UIView!
        
    var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.layer.cornerRadius = 100
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var avatarButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(tappedAvatarBtn), for: .touchUpInside)
        button.setTitle("Change Avatar", for: .normal)
        button.setTitleColor(UIColor.darkGreen, for: .normal)
        button.titleLabel?.font = UIFont.semiBold(size: 12)
        return button
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
        label.text = "Invite friends join PeerBucket"
        label.font = UIFont.bold(size: 25)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var inviteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.lightGray
        button.addTarget(self, action: #selector(tappedInviteBtn), for: .touchUpInside)
        button.setTitle("Scan OQCode", for: .normal)
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
    
    var accountView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 10
        return view
    }()
    
    var accountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGreen
        label.text = "Manage your account"
        label.font = UIFont.bold(size: 25)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.lightGray
        button.addTarget(self, action: #selector(tappedSignoutBtn), for: .touchUpInside)
        button.setTitle("Log Out", for: .normal)
        button.setTitleColor(UIColor.darkGreen, for: .normal)
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.semiBold(size: 16)
        return button
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.lightGray
        button.addTarget(self, action: #selector(tappedDeleteBtn), for: .touchUpInside)
        button.setTitle("Delete Account", for: .normal)
        button.setTitleColor(UIColor.darkGreen, for: .normal)
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.semiBold(size: 16)
        return button
    }()
    
    var currentUserUID: String?
    //    var currentUserUID = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isBeta {
            self.currentUserUID = "AITNzRSyUdMCjV4WrQxT"
        } else {
            self.currentUserUID = Auth.auth().currentUser?.uid ?? nil
        }
        
        configureUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let currentUserUID = currentUserUID else {
            
            let loginVC = storyboard?.instantiateViewController(withIdentifier: "loginVC")
            guard let loginVC = loginVC as? LoginViewController else { return }
//            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true)
            
            return
        }
        downloadPhoto(userID: currentUserUID)

    }
    
    func configureUI() {
        view.addSubview(avatarImageView)
        view.addSubview(avatarButton)
        view.addSubview(inviteView)
        view.addSubview(inviteLabel)
        view.addSubview(inviteButton)
        view.addSubview(myQRButton)
        
        view.addSubview(accountView)
        view.addSubview(accountLabel)
        view.addSubview(logoutButton)
        view.addSubview(deleteButton)
        
        menuBottomConstraint.constant = -500
        blackView.backgroundColor = .black
        blackView.alpha = 0
        
        view.bringSubviewToFront(blackView)
        view.bringSubviewToFront(containerView)
        self.view.backgroundColor = .lightGray
        
        avatarImageView.anchor(top: view.topAnchor, paddingTop: 100,
                               width: 200, height: 200)
        avatarImageView.centerX(inView: view)
        avatarButton.anchor(bottom: avatarImageView.bottomAnchor, right: avatarImageView.rightAnchor,
                            paddingBottom: -50, paddingRight: 20, width: 150, height: 50)
        
        inviteView.anchor(top: avatarImageView.bottomAnchor, left: view.leftAnchor,
                          right: view.rightAnchor, paddingTop: 100,
                          paddingLeft: 20, paddingRight: 20, height: 150)
        inviteLabel.anchor(top: inviteView.topAnchor, left: inviteView.leftAnchor,
                           paddingTop: 20, paddingLeft: 20, width: 150)
        inviteButton.anchor(top: inviteView.topAnchor, right: inviteView.rightAnchor,
                            paddingTop: 20, paddingRight: 20, width: 150, height: 50)
        myQRButton.anchor(top: inviteButton.bottomAnchor, right: inviteView.rightAnchor,
                          paddingTop: 10, paddingRight: 20, width: 150, height: 50)

        accountView.anchor(top: inviteView.bottomAnchor, left: view.leftAnchor,
                          right: view.rightAnchor, paddingTop: 20,
                          paddingLeft: 20, paddingRight: 20, height: 150)
        accountLabel.anchor(top: accountView.topAnchor, left: accountView.leftAnchor,
                           paddingTop: 20, paddingLeft: 20, width: 150)
        logoutButton.anchor(top: accountView.topAnchor, right: accountView.rightAnchor,
                            paddingTop: 20, paddingRight: 20, width: 150, height: 50)
        deleteButton.anchor(top: logoutButton.bottomAnchor, right: accountView.rightAnchor,
                          paddingTop: 10, paddingRight: 20, width: 150, height: 50)
    }
    
    @objc func tappedInviteBtn() {
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
        navigationController?.pushViewController(avatarVC, animated: true)
    }
    
    @objc func tappedSignoutBtn() {
        do {
          try Auth.auth().signOut()

            let loginVC = storyboard?.instantiateViewController(withIdentifier: "loginVC")
            guard let loginVC = loginVC as? LoginViewController else { return }
            navigationController?.pushViewController(loginVC, animated: true)
            self.presentSuccessAlert()
            print("Successfully sign out")
        } catch let signOutError as NSError {
            print("Error signing out:", signOutError)
            self.presentErrorAlert(message: signOutError.localizedDescription + " Please try again")
        }
    }
    
    // MARK: - Firebase data process

    @objc func tappedDeleteBtn() {
        
        do {
            
            // TODO: 沒被刪掉？？
            Auth.auth().currentUser?.delete()
                        
            guard let currentUserUID = currentUserUID else {
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
                    self.presentSuccessAlert()
                    print("Successfully delete account")
                    
                case .failure(let error):
                    self.presentErrorAlert(message: error.localizedDescription + " Please try again")
                    print("Delete account error: \(error)")
                }
            })

        } catch let deleteError as NSError {
            print("Delete account error:", deleteError)
            self.presentErrorAlert(message: deleteError.localizedDescription + " Please try again")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? QRCodeViewController {
            destination.delegate = self
        }
    }
    
    func downloadPhoto(userID: String) {
        
        // fetch avatar photo from firebase
        UserManager.shared.fetchUserData(userID: userID) { result in
            switch result {
            case .success(let user):
                
                guard let urlString = user.userAvatar as String?,
                      let url = URL(string: urlString) else {
                    return
                }
                
                let task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
                    guard let data = data, error == nil else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        let image = UIImage(data: data)
                        self.avatarImageView.image = image
                    }
                })
                task.resume()
                
            case .failure(let error):
                self.presentErrorAlert(message: error.localizedDescription + " Please try again")
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
