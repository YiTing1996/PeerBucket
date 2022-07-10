//
//  AddNewBucketViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/16.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseAuth

protocol AddNewBucketDelegate: AnyObject {
    func didTappedClose()
}

class AddNewBucketViewController: UIViewController, UIImagePickerControllerDelegate,
                                    UINavigationControllerDelegate {
    
    weak var delegate: AddNewBucketDelegate?
    
    private let storage = Storage.storage().reference()
        
    var currentUserUID: String?
    
    var iconLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.semiBold(size: 20)
        label.text = "Pick an icon for your bucket !"
        return label
    }()
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.semiBold(size: 20)
        label.text = "Name your own bucket !"
        return label
    }()
    
    var categoryTextField: UITextField = {
        let textField = UITextField()
        textField.setTextField(placeholder: "Type Category Here")
        return textField
    }()

    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_func_cancel"), for: .normal)
        button.addTarget(self, action: #selector(tappedCloseBtn), for: .touchUpInside)
        return button
    }()
    
    lazy var submitButton: UIButton = {
        let button = UIButton()
        button.setTitle("SUBMIT", for: .normal)
        button.addTarget(self, action: #selector(tappedSubmitBtn), for: .touchUpInside)
        button.setTextButton(bgColor: .mediumGray, titleColor: .white, font: 15)
        return button
    }()
    
    var hStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 2
        return stackView
    }()
    
    var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    var selectedIconIndex: Int?
    var iconUrlString: String = ""
    var iconButton: [UIButton] = []
    var iconButtonImage: [String] = ["icon_bucket_travel", "icon_bucket_movie", "icon_bucket_shopping",
                                     "icon_bucket_swim", "icon_bucket_mountain", "icon_bucket_guitar",
                                     "icon_bucket_book", "icon_bucket_favi", "icon_bucket_mountain2",
                                     "icon_bucket_basketball", "icon_bucket_game", "icon_bucket_cook",
                                     "icon_bucket_bar", "icon_bucket_diving"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 30
        view.clipsToBounds = true
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if isBeta {
            self.currentUserUID = "AITNzRSyUdMCjV4WrQxT"
        } else {
            self.currentUserUID = Auth.auth().currentUser?.uid ?? nil
        }
        
    }
    
    func configureUI() {
        view.addSubview(categoryTextField)
        view.addSubview(cancelButton)
        view.addSubview(submitButton)
        view.addSubview(scrollView)
        scrollView.addSubview(hStack)
        
        view.addSubview(nameLabel)
        view.addSubview(iconLabel)
        
        cancelButton.anchor(top: view.topAnchor, right: view.rightAnchor, paddingTop: 10, paddingRight: 10)

        iconLabel.anchor(top: cancelButton.bottomAnchor, left: view.leftAnchor,
                         paddingTop: 5, paddingLeft: 20, height: 50)
        scrollView.anchor(top: iconLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
                          paddingTop: 10, paddingLeft: 20, paddingRight: 20, height: 80)
        hStack.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor,
                      bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor)
        for index in 0...13 {
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
        
        nameLabel.anchor(top: scrollView.bottomAnchor, left: view.leftAnchor,
                         paddingTop: 10, paddingLeft: 20, height: 50)
        categoryTextField.anchor(top: nameLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
                                 paddingTop: 5, paddingLeft: 20, paddingRight: 20, height: 50)
        submitButton.anchor(top: categoryTextField.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
                            paddingTop: 20, paddingLeft: 20, paddingRight: 20, height: 50)
        
    }
    
    @objc func tappedIconBtn(_ sender: UIButton) {
        sender.layer.borderWidth = 3
        for index in 0...iconButton.count-1 {
            if iconButton[index] == sender {
                self.selectedIconIndex = index
            } else {
                iconButton[index].layer.borderWidth = 1
            }
        }
        getIconUrl()
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
        
        print("iconUrlString: \(iconUrlString)")
        var bucketCategory: BucketCategory = BucketCategory(
            senderId: currentUserUID,
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
        
        categoryTextField.text = ""
        
        delegate?.didTappedClose()
    }
    
    func getIconUrl() {
        
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
