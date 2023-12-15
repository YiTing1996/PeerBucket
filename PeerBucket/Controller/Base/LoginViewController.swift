//
//  LoginViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/20.
//

import UIKit
import AuthenticationServices

final class LoginViewController: UIViewController {
    
    // MARK: - Properties

    @IBOutlet weak var grayView: UIView!
    @IBOutlet weak var titleLabelGreen: UILabel!
    @IBOutlet weak var titleLabelGray: UILabel!

    private lazy var descriptionLabel: UILabel = create {
        $0.numberOfLines = 0
        $0.textColor = .darkGray
        $0.font = UIFont.semiBold(size: 15)
        $0.text = "Signin means you agree on\nour policy below."
    }
    
    private lazy var appleButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(type: .default, style: .black)
        button.addTarget(self, action: #selector(tappedAppleBtn), for: .touchUpInside)
        return button
    }()
    
    private lazy var privacyButton: UIButton = create {
        $0.setTitle("PRIVACY", for: .normal)
        $0.addTarget(self, action: #selector(tappedPrivacyBtn), for: .touchUpInside)
        $0.setTextBtn(bgColor: .clear, titleColor: .darkGray, border: 0, font: 10)
    }
    
    private lazy var eulaButton: UIButton = create {
        $0.setTitle("EULA", for: .normal)
        $0.addTarget(self, action: #selector(tappedEULABtn), for: .touchUpInside)
        $0.setTextBtn(bgColor: .clear, titleColor: .darkGray, border: 0, font: 10)
    }
    
    private lazy var dismissButton: UIButton = create {
        $0.setTitle("Cancel", for: .normal)
        $0.addTarget(self, action: #selector(tappedDismiss), for: .touchUpInside)
        $0.setTextBtn(bgColor: .darkGreen, titleColor: .lightGray, border: 0, font: 15)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureUI()
        view.backgroundColor = .darkGreen
    }
    
    // MARK: - User interaction handler
    
    @objc
    private func tappedPrivacyBtn() {
        guard let webVC = initFromStoryboard(with: .web) as? WebViewController else { return }
        webVC.link = "https://www.privacypolicies.com/live/a978eac4-298f-4f57-9525-3b1bf9c8e989"
        self.present(webVC, animated: true)
    }
    
    @objc
    private func tappedEULABtn() {
        guard let webVC = initFromStoryboard(with: .web) as? WebViewController else { return }
        webVC.link = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
        self.present(webVC, animated: true)
    }
    
    @objc
    private func tappedAppleBtn() {
        Info.shared.signInWithApple(self)
    }
    
    @objc
    private func tappedDismiss() {
        routeToRoot()
    }
    
    // MARK: - UI
    private func configureUI() {
        view.addSubviews([appleButton, privacyButton, eulaButton, dismissButton, descriptionLabel])
        grayView.layer.maskedCorners = [.layerMinXMinYCorner]
        grayView.layer.cornerRadius = 50
        grayView.backgroundColor = .lightGray
        titleLabelGray.textColor = .lightGray
        titleLabelGreen.textColor = .darkGreen
        
        appleButton.anchor(top: titleLabelGreen.bottomAnchor, left: view.leftAnchor,
                           paddingTop: 80, paddingLeft: 150, width: 200, height: 50)
        descriptionLabel.anchor(top: appleButton.bottomAnchor, left: view.leftAnchor,
                                paddingTop: 10, paddingLeft: 150, width: 300, height: 40)
        privacyButton.anchor(top: descriptionLabel.bottomAnchor, left: view.leftAnchor,
                             paddingTop: 5, paddingLeft: 150)
        eulaButton.anchor(top: descriptionLabel.bottomAnchor, left: privacyButton.rightAnchor,
                          paddingTop: 5, paddingLeft: 10)

        dismissButton.anchor(top: view.topAnchor, right: view.rightAnchor, paddingTop: 50,
                             paddingRight: 20, width: 50, height: 50)
        
    }
}
