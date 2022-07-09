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
    
    func setTextButton(bgColor: UIColor, titleColor: UIColor, border: CGFloat = 1,
                       radius: CGFloat = 10, font: CGFloat) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = UIFont.semiBold(size: font)
        self.backgroundColor = bgColor
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
        self.layer.borderWidth = border
        self.layer.borderColor = UIColor.darkGreen.cgColor
        
    }
    
}
