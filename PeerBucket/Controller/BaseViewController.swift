//
//  BaseViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2023/12/5.
//

import UIKit

class BaseViewController: UIViewController {
    
    var currentUser: User? {
        Info.shared.currentUser
    }
    
    var paringUser: User? {
        Info.shared.paringUser
    }
    
    deinit {
        Log.v("vc deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard currentUser != nil else {
            configureGuestUI()
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserData(for: .currentUser)
    }
    
    /// For override
    func configureGuestUI() {}
    
    /// For override (will call on viewWillAppear after finish fetching user data)
    func configureAfterFetchUserData() {}
    
    func fetchUserData(for identity: IdentityType = .currentUser, id: String? = nil) {
        Info.shared.fetchUserData(identityType: identity, id: id) { [weak self] isSuccess in
            if isSuccess {
                self?.configureAfterFetchUserData()
            } else {
                self?.presentErrorAlert()
            }
        }
    }
    
    func updateUserData(for identity: IdentityType = .currentUser, id: String? = nil, avatar: String? = nil,
                        homebg: String? = nil, name: String? = nil, paringUser: [String]? = nil, completion: (() -> Void)? = nil) {
        guard let user = currentUser else { return }
        let updatedUser = User(
            userID: id ?? user.userID,
            userAvatar: avatar ?? user.userAvatar,
            userHomeBG: homebg ?? user.userHomeBG,
            userName: name ?? user.userName,
            paringUser: paringUser ?? user.paringUser
        )
        UserManager.shared.updateUserData(user: updatedUser) { [weak self] result in
            switch result {
            case .success:
                self?.fetchUserData(for: .currentUser)
                self?.presentAlert()
            case .failure:
                self?.presentErrorAlert()
            }
        }
    }
}
