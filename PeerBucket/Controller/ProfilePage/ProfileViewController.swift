//
//  ProfileViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/21.
//

import UIKit
import FirebaseAuth
import Firebase
import Kingfisher

final class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var menuBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    private lazy var backgroundView: UIView = create {
        $0.backgroundColor = .darkGreen
        $0.layer.cornerRadius = 30
    }
    
    private lazy var avatarImageView: UIImageView = create {
        $0.contentMode = .scaleAspectFill
    }
    
    private lazy var inviteView: UIView = create {
        $0.backgroundColor = .lightGray
        $0.setCornerRadius(borderColor: UIColor.darkGreen.cgColor, width: 0.7, radius: 10)
        $0.setShadow(color: .darkGreen, opacity: 0.1, radius: 3, offset: CGSize(width: 2, height: 2))
    }
    
    private lazy var inviteLabel: UILabel = create {
        $0.textColor = .darkGreen
        $0.text = "Invite Partner"
        $0.font = UIFont.bold(size: 28)
        $0.numberOfLines = 0
    }
    
    private lazy var inviteButton: UIButton = create {
        $0.setTitle("Scan QRCode", for: .normal)
        $0.addTarget(self, action: #selector(tappedInviteBtn), for: .touchUpInside)
        $0.setTextBtn(bgColor: .lightGray, titleColor: .darkGreen, border: 0.7, font: 15)
    }
    
    private lazy var myQRButton: UIButton = create {
        $0.setTitle("Show QRCode", for: .normal)
        $0.addTarget(self, action: #selector(tappedQRBtn), for: .touchUpInside)
        $0.setTextBtn(bgColor: .lightGray, titleColor: .darkGreen, border: 0.7, font: 15)
    }
    
    private lazy var profileView: UIView = create {
        $0.backgroundColor = .lightGray
        $0.setCornerRadius(borderColor: UIColor.darkGreen.cgColor, width: 0.7, radius: 10)
        $0.setShadow(color: .darkGreen, opacity: 0.1, radius: 3, offset: CGSize(width: 2, height: 2))
    }
    
    private lazy var profileLabel: UILabel = create {
        $0.textColor = .darkGreen
        $0.text = "Edit\nProfile"
        $0.font = UIFont.bold(size: 28)
        $0.numberOfLines = 0
    }
    
    private lazy var nameButton: UIButton = create {
        $0.setTitle("Edit Name", for: .normal)
        $0.addTarget(self, action: #selector(tappedNameBtn), for: .touchUpInside)
        $0.setTextBtn(bgColor: .lightGray, titleColor: .darkGreen, border: 0.7, font: 15)
    }
    
    private lazy var avatarButton: UIButton = create {
        $0.setTitle("Edit Avatar", for: .normal)
        $0.addTarget(self, action: #selector(tappedAvatarBtn), for: .touchUpInside)
        $0.setTextBtn(bgColor: .lightGray, titleColor: .darkGreen, border: 0.7, font: 15)
    }
    
    private lazy var nameLabel: UILabel = create {
        $0.textColor = .darkGreen
        $0.text = "Welcome!"
        $0.font = UIFont.bold(size: 32)
        $0.numberOfLines = 0
    }
    
    private lazy var settingButton: UIButton = {
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
        
    private var currentUser: User?
    private var paringUser: User?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        menuBottomConstraint.constant = hideMenuBottomConstraint
        blackView.backgroundColor = .black
        blackView.alpha = 0
        view.bringSubviewToFront(blackView)
        view.bringSubviewToFront(containerView)
        view.backgroundColor = .lightGray
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.settingButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let currentUserUID = currentUserUID else {
            guard let loginVC = initFromStoryboard(with: .login) as? LoginViewController else { return }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? QRCodeViewController {
            destination.delegate = self
        }
    }
    
    // MARK: - UI
    
    private func configureUI() {
        view.addSubviews([
            nameLabel, nameButton, avatarImageView,
            inviteView, inviteLabel, profileView, profileLabel
        ])
        inviteView.addSubviews([inviteButton, myQRButton])
        profileView.addSubviews([avatarButton, nameButton])

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
    
    private func updateUserUI(identityType: IdentityType, user: User) {
        switch identityType {
        case .currentUser:
            self.currentUser = user
            if user.userAvatar.isNotEmpty {
                let url = URL(string: user.userAvatar)
                self.avatarImageView.kf.setImage(with: url)
            } else {
                self.avatarImageView.image = UIImage(named: "default_avatar")
            }
            
            if user.userName.isNotEmpty {
                self.nameLabel.text = "Hi \(user.userName) !"
            }
            if let paringUserId = currentUser?.paringUser.first, user.paringUser.isNotEmpty {
                self.fetchUserData(identityType: .paringUser,
                                   userID: paringUserId)
            }
        case .paringUser:
            self.paringUser = user
        }
    }
    
    // MARK: - User interaction handler
    
    @objc
    private func tappedInviteBtn() {
        guard currentUser?.paringUser == [] else {
            presentAlert(title: "Error", message: "Oops Already have a bucket peer")
            return
        }
        guard let inviteVC = initFromStoryboard(with: .invite) as? InviteViewController else { return }
        navigationController?.pushViewController(inviteVC, animated: true)
    }
    
    @objc
    private func tappedQRBtn() {
        guard let currentUser = currentUser, currentUser.paringUser.isEmpty else {
            presentAlert(title: "Error", message: "Oops Already have a bucket peer")
            return
        }
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.menuBottomConstraint.constant = 140
            self.blackView.alpha = 0.5
        }
    }
    
    @objc
    private func tappedAvatarBtn() {
        guard let avatarVC = initFromStoryboard(with: .avatar) as? AvatarViewController else { return }
        avatarVC.delegate = self
        navigationController?.pushViewController(avatarVC, animated: true)
    }
    
    @objc
    private func tappedPrivacyBtn() {
        guard let webVC = initFromStoryboard(with: .web) as? WebViewController else { return }
        webVC.link = "https://www.privacypolicies.com/live/a978eac4-298f-4f57-9525-3b1bf9c8e989"
        present(webVC, animated: true)
    }
    
    @objc
    private func tappedSignoutBtn() {
        do {
            try Auth.auth().signOut()
            Info.shared.signOut()
            guard let loginVC = initFromStoryboard(with: .login) as? LoginViewController else { return }
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true)
            presentAlert()
        } catch let signOutError as NSError {
            Log.e(signOutError)
            presentAlert(
                title: "Error",
                message: "Something went wrong. Please try again later.")
        }
    }
    
    @objc
    private func tappedNameBtn() {
        presentInputAlert { [weak self] name in
            guard let self = self, let currentUser = self.currentUser else {
                return
            }
            self.updatedName = name
            self.checkUserInfo(element: .name, identityType: .currentUser, user: currentUser)
        }
    }
    
    @objc
    private func tappedBlockBtn() {
        presentActionAlert(action: "Disconnect", title: "Disconnect Partner",
                                message: "Do you want to disconnect with partner?") { [weak self] in
            guard let self = self, let currentUser = self.currentUser, let paringUser = self.paringUser else {
                return
            }
            
            // update paring user status
            self.checkUserInfo(element: .paring, identityType: .currentUser, user: currentUser)
            self.checkUserInfo(element: .paring, identityType: .paringUser, user: paringUser)
        }
    }
    
    @objc
    private func tappedDeleteBtn() {
        presentActionAlert(action: "Delete", title: "Delete Account",
                                message: "Do you want to delete your acccount?") {
            Auth.auth().currentUser?.delete { [weak self] error in
                guard let self = self, error == nil else {
                    guard let errorCode = error?._code, AuthErrorCode.Code(rawValue: errorCode) == .requiresRecentLogin else {
                        Log.e(error?.localizedDescription)
                        return
                    }
                    
                    self?.presentActionAlert(
                        action: "Login",
                        title: "Authentication Required",
                        message: "Delete account requires authentication which needs to relogin. Do you want to login again?") {
                            self?.tappedSignoutBtn()
                        }
                    return
                }
                
                guard let currentUserUID = currentUserUID else { return }
                Log.v("delete account success")
                self.deleteUserData(userID: currentUserUID)
                
                guard let paringUser = self.paringUser else { return }
                Log.v("disconnect partner success")
                self.checkUserInfo(element: .paring, identityType: .paringUser, user: paringUser)
            }
        }
    }
    
    // MARK: - Firebase handler
    
    private func checkUserInfo(element: CheckElement, identityType: IdentityType, user: User) {
        switch element {
        case .paring:
            updatedParing = []
            updatedName = user.userName
        case .name:
            updatedParing = user.paringUser
        default:
            break
        }
        
        guard let updatedUser = formateDataModal(user: user) else {
            return
        }
        updateUserData(identityType: identityType, user: updatedUser)
    }
    
    private func formateDataModal(user: User?) -> User? {
        let newUserData: User = User(
            userID: user?.userID ?? "",
            userAvatar: user?.userAvatar ?? "",
            userHomeBG: user?.userHomeBG ?? "",
            userName: updatedName ?? user?.userName ?? "",
            paringUser: updatedParing ?? user?.paringUser ?? []
        )
        return newUserData
    }
    
    // TODO: 重構兩個屬性的更新邏輯
    private var updatedName: String?
    private var updatedParing: [String]?
    
    private func deleteUserData(userID: String) {
        UserManager.shared.deleteUserData(uid: userID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                guard let loginVC = self.initFromStoryboard(with: .login) as? LoginViewController else { return }
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: true)
                self.presentAlert()
                Log.v("delete account success")
            case .failure(let error):
                self.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
                Log.e(error.localizedDescription)
            }
        }
    }
    
    private func fetchUserData(identityType: IdentityType, userID: String) {
        UserManager.shared.fetchUserData(userID: userID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.updateUserUI(identityType: identityType, user: user)
            case .failure(let error):
                self.presentAlert(
                    title: "Error",
                    message: error.localizedDescription + " Please try again")
            }
        }
    }
    
    private func updateUserData(identityType: IdentityType, user: User) {
        UserManager.shared.updateUserData(user: user) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.presentAlert()
                switch identityType {
                case .currentUser:
                    DispatchQueue.main.async {
                        self.nameLabel.text = "Hi \(user.userName) !"
                    }
                case .paringUser:
                    break
                }
            case .failure(let error):
                self.presentAlert(
                    title: "Error",
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
