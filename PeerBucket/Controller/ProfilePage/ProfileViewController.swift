//
//  ProfileViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/21.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var menuBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    var currentUser: User?
    
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
//        button.backgroundColor = UIColor.bgGray
        button.addTarget(self, action: #selector(tappedAvatarBtn), for: .touchUpInside)
        button.setTitle("Change Avatar", for: .normal)
        button.setTitleColor(UIColor.darkGreen, for: .normal)
//        button.layer.borderWidth = 0.5
//        button.layer.cornerRadius = 5
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
//        button.addTarget(self, action: #selector(tappedInviteBtn), for: .touchUpInside)
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
//        button.addTarget(self, action: #selector(tappedQRBtn), for: .touchUpInside)
        button.setTitle("Delete Account", for: .normal)
        button.setTitleColor(UIColor.darkGreen, for: .normal)
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.semiBold(size: 16)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        menuBottomConstraint.constant = -500
        blackView.backgroundColor = .black
        blackView.alpha = 0
        
        view.bringSubviewToFront(blackView)
        view.bringSubviewToFront(containerView)
        
        self.view.backgroundColor = .lightGray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downloadPhoto()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? QRCodeViewController {
            destination.delegate = self
        }
    }
    
    func downloadPhoto() {
        
        // fetch avatar photo from firebase
        UserManager.shared.fetchUserData(userID: currentUserUID) { result in
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

extension ProfileViewController: QRCodeViewControllerDelegate {
    func didTappedClose() {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.menuBottomConstraint.constant = -500
            self.blackView.alpha = 0
        }
    }
}
