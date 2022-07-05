//
//  UITextFieldExtension.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/16.
//

import UIKit

extension UITextField {
    
    func setLeftPaddingPoints(amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    func setTextField(placeholder: String) {
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 10
        self.backgroundColor = UIColor.lightGray
        self.setLeftPaddingPoints(amount: 10)
        self.textColor = .darkGray
        self.placeholder = placeholder
    }
    
}
