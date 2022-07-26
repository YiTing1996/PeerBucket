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

class AddNewBucketViewController: UIViewController, UIImagePickerControllerDelegate,
                                    UINavigationControllerDelegate {
    
    // MARK: - Properties

    weak var delegate: AddNewBucketDelegate?
                
    lazy var iconLabel: UILabel = create {
        $0.textColor = .darkGray
        $0.font = UIFont.semiBold(size: 20)
        $0.text = "Pick an icon for your bucket !"
    }
    
    lazy var nameLabel: UILabel = create {
        $0.textColor = .darkGray
        $0.font = UIFont.semiBold(size: 20)
        $0.text = "Name your own bucket !"
    }
    
    lazy var categoryTextField: UITextField = create {
        $0.setTextField(placeholder: "Type Category Here")
    }

    lazy var cancelButton: UIButton = create {
        $0.setImage(UIImage(named: "icon_func_cancel"), for: .normal)
        $0.addTarget(self, action: #selector(tappedCloseBtn), for: .touchUpInside)
    }
    
    lazy var submitButton: UIButton = create {
        $0.setTitle("SUBMIT", for: .normal)
        $0.addTarget(self, action: #selector(tappedSubmitBtn), for: .touchUpInside)
        $0.setTextButton(bgColor: .mediumGray, titleColor: .white, font: 15)
    }
    
    lazy var hStack: UIStackView = create {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 2
    }
    
    lazy var scrollView: UIScrollView = create {
        $0.isPagingEnabled = true
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    var selectedIconIndex: Int?
    var iconUrlString: String = ""
    var iconButton: [UIButton] = []
    var iconButtonImage: [String] = [
        "icon_bucket_travel", "icon_bucket_movie", "icon_bucket_shopping",
        "icon_bucket_swim", "icon_bucket_mountain", "icon_bucket_guitar",
        "icon_bucket_book", "icon_bucket_favi", "icon_bucket_mountain2",
        "icon_bucket_basketball", "icon_bucket_game", "icon_bucket_cook",
        "icon_bucket_bar", "icon_bucket_diving"
    ]
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureConstraint()
        
    }
    
    // MARK: - UI handler

    func configureUI() {
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 30
        view.clipsToBounds = true
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        view.addSubview(categoryTextField)
        view.addSubview(cancelButton)
        view.addSubview(submitButton)
        view.addSubview(scrollView)
        scrollView.addSubview(hStack)
        
        view.addSubview(nameLabel)
        view.addSubview(iconLabel)
        
        for index in 0...iconButtonImage.count-1 {
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
    
    func configureConstraint() {
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

    @objc func tappedIconBtn(_ sender: UIButton) {
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
    
    @objc func tappedCloseBtn() {
        delegate?.didTappedClose()
        categoryTextField.text = ""
    }
    
    @objc func tappedSubmitBtn() {
        
        guard let category = categoryTextField.text,
              let currentUserUID = currentUserUID,
              categoryTextField.text != "",
              selectedIconIndex != nil,
              iconUrlString != ""
        else {
            presentAlert(title: "Error", message: "Please fill all the field")
            return
        }
        
        addBucketCategory(userID: currentUserUID, category: category)
        categoryTextField.text = ""
        delegate?.didTappedClose()
    }
    
    // MARK: - Firebase handler

    func addBucketCategory(userID: String, category: String) {
        var bucketCategory: BucketCategory = BucketCategory(
            senderId: userID,
            category: category,
            id: "",
            image: iconUrlString
        )
        
        BucketListManager.shared.addBucketCategory(bucketCategory: &bucketCategory) { result in
            
            switch result {
            case .success:
                self.presentAlert()
            case .failure(let error):
                self.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
            }
        }
    }
    
    // MARK: - Image handler

    func downloadIconImage() {
        
        guard let selectedIconIndex = selectedIconIndex else { return }
        storage.child("categoryImage/\(iconButtonImage[selectedIconIndex]).png").downloadURL { url, error in
            
            guard let url = url, error == nil else {
                return
            }
            
            let urlString = url.absoluteString
            self.iconUrlString = urlString
            
            print("Download url: \(urlString)")
            UserDefaults.standard.set(urlString, forKey: "url")
            
        }
    }
    
}
