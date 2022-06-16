//
//  AddNewBucketViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/16.
//

import Foundation
import UIKit
import SwiftUI

protocol AddNewBucketDelegate: AnyObject {
    func didTappedClose()
}

class AddNewBucketViewController: UIViewController {
    
    weak var delegate: AddNewBucketDelegate?
    
    var categoryTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type Category Here"
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 0.5
        return textField
    }()

    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .lightGray
        button.addTarget(self, action: #selector(tappedCloseBtn), for: .touchUpInside)
        return button
    }()
    
    lazy var submitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .lightGray
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.setTitle("Submit", for: .normal)
        button.addTarget(self, action: #selector(tappedSubmitBtn), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI() {
        view.addSubview(categoryTextField)
        view.addSubview(cancelButton)
        view.addSubview(submitButton)
        categoryTextField.anchor(top: view.topAnchor, left: view.leftAnchor,
                                 paddingTop: 100, paddingLeft: 50, width: 300, height: 50)

        cancelButton.anchor(top: view.topAnchor, right: view.rightAnchor, paddingTop: 10, paddingRight: 10)
        submitButton.anchor(left: view.leftAnchor, bottom: view.bottomAnchor,
                            paddingLeft: 50, paddingBottom: 150, width: 300)
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
            content: [nil],
            id: ""
        )
        
        BucketListManager.shared.addBucketList(bucketList: &bucketCategory)
        
        categoryTextField.text = ""
    }
    
}
