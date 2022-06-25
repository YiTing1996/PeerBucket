//
//  LoginViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/20.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    
    var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type Name Here"
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 0.5
        textField.setLeftPaddingPoints(amount: 10)
        return textField
    }()
    
    var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type Email Here"
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 0.5
        textField.setLeftPaddingPoints(amount: 10)
        return textField
    }()
    
    var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type Password Here"
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 0.5
        textField.setLeftPaddingPoints(amount: 10)
        return textField
    }()
    
    lazy var submitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.lightGray
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.setTitle("Submit", for: .normal)
        button.addTarget(self, action: #selector(tappedSubmitBtn), for: .touchUpInside)
        button.backgroundColor = UIColor(red: 104/255, green: 34/255, blue: 139/255, alpha: 1)
        //        button.tintColor = .white
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureUI()
    }
    
    @objc func tappedSubmitBtn() {
//        if emailTextField.text != "" && passwordTextField.text != "" && nameTextField.text != "" {
//            FirebaseManager.shared.sinInUp(email: self.emailTexField.text!, name: self.nameTexField.text!,
//                                           password: self.passwordTextField.text!)
//            popAlert(title: "Success", message: "Login Sucess")
//            self.emailTexField.text = ""
//            self.nameTexField.text = ""
//            self.passwordTextField.text = ""
//            self.navigationController?.popViewController(animated: true)
//        } else {
//            popAlert(title: "Error", message: "Please make sure fill all the fields")
//        }
    }
    
    func configureUI() {
        view.addSubview(nameTextField)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(submitButton)
        
        nameTextField.anchor(top: view.topAnchor, left: view.leftAnchor,
                              paddingTop: 100, paddingLeft: 50, width: 300, height: 50)
        
        emailTextField.anchor(top: nameTextField.bottomAnchor, left: view.leftAnchor,
                              paddingTop: 50, paddingLeft: 50, width: 300, height: 50)
        
        passwordTextField.anchor(top: emailTextField.bottomAnchor, left: view.leftAnchor,
                                 paddingTop: 50, paddingLeft: 50, width: 300, height: 50)
        
        submitButton.anchor(top: emailTextField.bottomAnchor, left: view.leftAnchor,
                            paddingTop: 50, paddingLeft: 50, width: 300, height: 50)
        
    }
    
}
