//
//  UIButtonExtension.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/7/2.
//

import Foundation
import UIKit

extension UIButton {
    
    func setImageButton() {
        
    }
    
    func setTextButton(bgColor: UIColor, titleColor: UIColor, radius: CGFloat, font: CGFloat) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = UIFont.semiBold(size: font)
        self.backgroundColor = bgColor
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        self.layer.borderWidth = 0.8
        self.layer.borderColor = UIColor.darkGreen.cgColor
        
    }
    
}
