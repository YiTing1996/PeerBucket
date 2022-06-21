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
    
    var inviteView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .bgGray
        view.layer.cornerRadius = 5
        return view
    }()
    
    var inviteLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "Invite friends join PeerBucket"
        label.font = UIFont(name: "Academy Engraved LET", size: 28)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var inviteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.bgGray
        button.addTarget(self, action: #selector(tappedInviteBtn), for: .touchUpInside)
        button.setTitle("Scan OQCode", for: .normal)
        button.setTitleColor(UIColor.textGray, for: .normal)
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.regular(size: 12)
        return button
    }()
    
    lazy var myQRButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.bgGray
        button.addTarget(self, action: #selector(tappedQRBtn), for: .touchUpInside)
        button.setTitle("Show QRCode", for: .normal)
        button.setTitleColor(UIColor.textGray, for: .normal)
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.regular(size: 12)
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
        
    }
    
    func configureUI() {
        
        view.addSubview(inviteView)
        view.addSubview(inviteLabel)
        view.addSubview(inviteButton)
        view.addSubview(myQRButton)
        
        inviteView.anchor(top: view.topAnchor, left: view.leftAnchor,
                          right: view.rightAnchor, paddingTop: 500,
                          paddingLeft: 20, paddingRight: 20, height: 150)
        inviteLabel.anchor(top: inviteView.topAnchor, left: inviteView.leftAnchor,
                           paddingTop: 20, paddingLeft: 20, width: 150)
        inviteButton.anchor(top: inviteView.topAnchor, right: inviteView.rightAnchor,
                            paddingTop: 20, paddingRight: 20, width: 150, height: 50)
        myQRButton.anchor(top: inviteButton.topAnchor, right: inviteView.rightAnchor,
                          paddingTop: 60, paddingRight: 20, width: 150, height: 50)

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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? QRCodeViewController {
            destination.delegate = self
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
