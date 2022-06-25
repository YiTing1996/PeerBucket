//
//  AddPhotoViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/25.
//

import Foundation
import UIKit

protocol AddPhotoViewControllerDelegate: AnyObject {
    func didTappedClose()
}

class AddPhotoViewController: UIViewController {
    
    weak var delegate: AddPhotoViewControllerDelegate?
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_func_cancel"), for: .normal)
        button.addTarget(self, action: #selector(tappedCloseBtn), for: .touchUpInside)
        return button
    }()
    
    lazy var submitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .mediumGray
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 10
        button.setTitle("SUBMIT", for: .normal)
        button.titleLabel?.font = UIFont.semiBold(size: 15)
        button.addTarget(self, action: #selector(tappedSubmitBtn), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI() {
        view.addSubview(cancelButton)
        view.addSubview(submitButton)
        
        cancelButton.anchor(top: view.topAnchor, right: view.rightAnchor, paddingTop: 10, paddingRight: 10)

        submitButton.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor,
                            paddingLeft: 20, paddingBottom: 20, paddingRight: 20, width: 300, height: 50)
        
    }
    
    @objc func tappedCloseBtn() {
        delegate?.didTappedClose()
//        categoryTextField.text = ""
    }
    
    // upload to firebase
    @objc func tappedSubmitBtn() {
//        guard let category = categoryTextField.text,
//              categoryTextField.text != "",
//              selectedIconIndex != nil,
//              iconUrlString != ""
//        else {
//            presentErrorAlert(message: "Please fill all the field")
//            return
//        }
//
//        print("iconUrlString: \(iconUrlString)")
//        var bucketCategory: BucketCategory = BucketCategory(
//            senderId: testUserID,
//            category: category,
//            id: "",
//            image: iconUrlString
//        )
//
//        BucketListManager.shared.addBucketCategory(bucketCategory: &bucketCategory) { result in
//
//            switch result {
//            case .success:
//                self.presentSuccessAlert()
//            case .failure(let error):
//                self.presentErrorAlert(message: error.localizedDescription + " Please try again")
//            }
//        }
//
//        categoryTextField.text = ""
//
//        delegate?.didTappedClose()
    }
    
}

extension AddPhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //    func imagePickerController(_ picker: UIImagePickerController,
    //                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
    //
    //        picker.dismiss(animated: true, completion: nil)
    //
    //        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
    //            return
    //        }
    //
    //        guard let imageData = image.pngData() else {
    //            return
    //        }
    //
    //        let imageName = NSUUID().uuidString
    //
    //        // create a reference to upload data
    //        storage.child("categoryImage/\(imageName).png").putData(imageData, metadata: nil) { _, error in
    //
    //            guard error == nil else {
    //                print("Fail to upload image")
    //                return
    //            }
    //
    //            self.storage.child("categoryImage/\(imageName).png").downloadURL(completion: { url, error in
    //
    //                guard let url = url, error == nil else {
    //                    return
    //                }
    //
    //                let urlString = url.absoluteString
    //                self.imageUrlString = urlString
    //
    ////                DispatchQueue.main.async {
    ////                    self.imageView.image = image
    ////                }
    //
    //                print("Download url: \(urlString)")
    //                UserDefaults.standard.set(urlString, forKey: "url")
    //
    //            })
    //
    //        }
    //
    //    }
        
    //    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    //        picker.dismiss(animated: true, completion: nil)
    //    }
    
}
