//
//  AddNewBucketViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/16.
//

import Foundation
import UIKit
import FirebaseStorage

protocol AddNewBucketDelegate: AnyObject {
    func didTappedClose()
}

class AddNewBucketViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    weak var delegate: AddNewBucketDelegate?
    
    private let storage = Storage.storage().reference()
    
    var categoryTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type Category Here"
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 0.5
        textField.setLeftPaddingPoints(amount: 10)
        return textField
    }()

    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.bgGray
        button.addTarget(self, action: #selector(tappedCloseBtn), for: .touchUpInside)
        return button
    }()
    
    lazy var submitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.bgGray
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.setTitle("Submit", for: .normal)
        button.addTarget(self, action: #selector(tappedSubmitBtn), for: .touchUpInside)
        return button
    }()
    
    lazy var addImageButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.bgGray
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.setTitle("+Image", for: .normal)
        button.addTarget(self, action: #selector(tappedImageBtn), for: .touchUpInside)
        return button
    }()
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var imageUrlString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
    }
    
    func configureUI() {
        view.addSubview(categoryTextField)
        view.addSubview(cancelButton)
        view.addSubview(submitButton)
        view.addSubview(addImageButton)
        view.addSubview(imageView)
        
        categoryTextField.anchor(top: view.topAnchor, left: view.leftAnchor,
                                 paddingTop: 100, paddingLeft: 50, width: 300, height: 50)

        cancelButton.anchor(top: view.topAnchor, right: view.rightAnchor, paddingTop: 10, paddingRight: 10)
        submitButton.anchor(top: categoryTextField.bottomAnchor, left: view.leftAnchor,
                            paddingTop: 50, paddingLeft: 50, width: 300, height: 50)
        
        addImageButton.anchor(top: view.topAnchor, right: view.rightAnchor, paddingTop: 10, paddingRight: 50)
        
        imageView.anchor(top: view.topAnchor, left: view.leftAnchor, paddingTop: 20, paddingLeft: 20, width: 50, height: 50)
        
    }
    
    @objc func tappedImageBtn() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
        
//        delegate?.didTappedClose()
    }
    
    @objc func tappedCloseBtn() {
        delegate?.didTappedClose()
        categoryTextField.text = ""
    }
    
    @objc func tappedSubmitBtn() {
        delegate?.didTappedClose()
        
        guard let category = categoryTextField.text else { return }
        
        var bucketCategory: BucketCategory = BucketCategory(
            senderId: "Doreen",
            category: category,
            id: "",
            image: imageUrlString
        )
        
        BucketListManager.shared.addBucketCategory(bucketCategory: &bucketCategory) { result in
            
            switch result {
            case .success:
                self.presentSuccessAlert()
            case .failure(let error):
                self.presentErrorAlert(message: error.localizedDescription + " Please try again")
            }
            
        }
        
        categoryTextField.text = ""
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        guard let imageData = image.pngData() else {
            return
        }
        
        let imageName = NSUUID().uuidString
        
        // create a reference to upload data
        storage.child("categoryImage/\(imageName).png").putData(imageData, metadata: nil) { _, error in
            
            guard error == nil else {
                print("Fail to upload image")
                return
            }
            
            self.storage.child("categoryImage/\(imageName).png").downloadURL(completion: { url, error in
                
                guard let url = url, error == nil else {
                    return
                }
                
                let urlString = url.absoluteString
                self.imageUrlString = urlString
                
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
                
                print("Download url: \(urlString)")
                UserDefaults.standard.set(urlString, forKey: "url")
                
            })
            
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
//    func downloadPhoto() {
//        guard let urlString = UserDefaults.standard.value(forKey: "url") as? String,
//              let url = URL(string: urlString) else {
//            return
//        }
//
//        
//        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
//            guard let data = data, error == nil else {
//                return
//            }
//            
//            DispatchQueue.main.async {
//                let image = UIImage(data: data)
//                self.imageView.image = image
//            }
//            
//        })
//        task.resume()
//    }
    
}
