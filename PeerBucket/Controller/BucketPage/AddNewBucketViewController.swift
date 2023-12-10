//
//  AddNewBucketViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/16.
//

import Foundation
import UIKit
import FirebaseAuth

protocol AddNewBucketDelegate: AnyObject {
    func didTappedClose()
}

final class AddNewBucketViewController: UIViewController, UIImagePickerControllerDelegate,
                                    UINavigationControllerDelegate {
    
    // MARK: - Properties

    weak var delegate: AddNewBucketDelegate?
                
    private lazy var iconLabel: UILabel = create {
        $0.textColor = .darkGray
        $0.font = UIFont.semiBold(size: 20)
        $0.text = "Pick an icon for your bucket !"
    }
    
    private lazy var nameLabel: UILabel = create {
        $0.textColor = .darkGray
        $0.font = UIFont.semiBold(size: 20)
        $0.text = "Name your own bucket !"
    }
    
    private lazy var categoryTextField: UITextField = create {
        $0.setThemeTextField(placeholder: "Type Category Here")
    }

    private lazy var cancelButton: UIButton = create {
        $0.setImage(UIImage(named: "icon_func_cancel"), for: .normal)
        $0.addTarget(self, action: #selector(tappedCloseBtn), for: .touchUpInside)
    }
    
    private lazy var submitButton: UIButton = create {
        $0.setTitle("SUBMIT", for: .normal)
        $0.addTarget(self, action: #selector(tappedSubmitBtn), for: .touchUpInside)
        $0.setTextBtn(bgColor: .mediumGray, titleColor: .white, font: 15)
    }
    
    private lazy var hStack: UIStackView = create {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 2
    }
    
    private lazy var scrollView: UIScrollView = create {
        $0.isPagingEnabled = true
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private var selectedIconIndex: Int?
    private var iconUrlString: String = ""
    private var iconButton: [UIButton] = []
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureConstraint()
    }
    
    // MARK: - UI

    private func configureUI() {
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 30
        view.clipsToBounds = true
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.addSubviews([categoryTextField, cancelButton, submitButton, scrollView, nameLabel, iconLabel])
        scrollView.addSubview(hStack)
        
        for index in 0...iconButtonImage.count - 1 {
            let button = UIButton()
            button.setImage(UIImage(named: iconButtonImage[index]), for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(tappedIconBtn), for: .touchUpInside)
            button.layer.cornerRadius = 10
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.mediumGray.cgColor
            button.anchor(width: 70, height: 70)
            hStack.spacing = 10
            hStack.addArrangedSubview(button)
            iconButton.append(button)
        }
    }
    
    private func configureConstraint() {
        cancelButton.anchor(top: view.topAnchor, right: view.rightAnchor,
                            paddingTop: 10, paddingRight: 10)
        iconLabel.anchor(top: cancelButton.bottomAnchor, left: view.leftAnchor,
                         paddingTop: 5, paddingLeft: 20, height: 50)
        scrollView.anchor(top: iconLabel.bottomAnchor, left: view.leftAnchor,
                          right: view.rightAnchor, paddingTop: 10, paddingLeft: 20,
                          paddingRight: 20, height: 80)
        hStack.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor,
                      bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor)
        
        nameLabel.anchor(top: scrollView.bottomAnchor, left: view.leftAnchor,
                         paddingTop: 10, paddingLeft: 20, height: 50)
        categoryTextField.anchor(top: nameLabel.bottomAnchor, left: view.leftAnchor,
                                 right: view.rightAnchor, paddingTop: 5, paddingLeft: 20,
                                 paddingRight: 20, height: 50)
        submitButton.anchor(top: categoryTextField.bottomAnchor, left: view.leftAnchor,
                            right: view.rightAnchor, paddingTop: 20, paddingLeft: 20,
                            paddingRight: 20, height: 50)
        
    }
    
    // MARK: - User interaction handler

    @objc
    private func tappedIconBtn(_ sender: UIButton) {
        sender.layer.borderWidth = 3
        for index in 0...iconButton.count-1 {
            if iconButton[index] == sender {
                self.selectedIconIndex = index
            } else {
                iconButton[index].layer.borderWidth = 1
            }
        }
        downloadIconImage()
    }
    
    @objc
    private func tappedCloseBtn() {
        delegate?.didTappedClose()
        categoryTextField.text = ""
    }
    
    @objc
    private func tappedSubmitBtn() {
        guard let text = categoryTextField.text, text.isNotEmpty,
              let currentUserUID = Info.shared.currentUser?.userID,
              selectedIconIndex != nil,
              iconUrlString.isNotEmpty else {
            presentAlert(title: "Error", message: "Please fill all the field")
            return
        }
        addBucketCategory(userID: currentUserUID, category: text)
        categoryTextField.text = ""
        delegate?.didTappedClose()
    }
    
    // MARK: - Firebase handler

    private func addBucketCategory(userID: String, category: String) {
        var bucketCategory: BucketCategory = BucketCategory(
            senderId: userID,
            category: category,
            id: "",
            image: iconUrlString
        )
        
        BucketListManager.shared.addBucketCategory(bucketCategory: &bucketCategory) { [weak self] result in
            switch result {
            case .success:
                self?.presentAlert()
            case .failure(let error):
                self?.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
            }
        }
    }
    
    // MARK: - Image handler

    private func downloadIconImage() {
        guard let selectedIconIndex = selectedIconIndex else { return }
        storage.child("categoryImage/\(iconButtonImage[selectedIconIndex]).png").downloadURL { [weak self] url, error in
            guard let url = url, error == nil else {
                return
            }
            let urlString = url.absoluteString
            self?.iconUrlString = urlString
            Log.v("download url: \(urlString)")
            UserDefaults.standard.set(urlString, forKey: "url")
        }
    }
}
