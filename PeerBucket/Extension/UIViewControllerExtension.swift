//
//  UIViewControllerExtension.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/16.
//

import UIKit
import Lottie

extension UIViewController {
    
    func presentActionAlert(action: String,
                            title: String,
                            message: String,
                            completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: action, style: .destructive) { _ in
            guard let completion = completion else { return }
            completion()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.setAlertUI()
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func presentAlert(title: String = "Congrats",
                      message: String = "Success!",
                      completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.setAlertUI()
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            guard let completion = completion else { return }
            completion()
        }
        
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func presentInputAlert(title: String = "Setup Name",
                           message: String = "Please insert your name below",
                           completion: ((String) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.setAlertUI()
        
        alert.addTextField(configurationHandler: { (textField: UITextField!) -> Void in
            textField.placeholder = "Name"
        })
        
        let submitAction = UIAlertAction(title: "Submit", style: .destructive) { _ in
            guard let completion = completion else { return }
            let name = (alert.textFields?.first)! as UITextField
            completion(name.text ?? "")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(submitAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func loadAnimation(name: String, loopMode: LottieLoopMode) -> AnimationView {
        let animationView = AnimationView(name: name)
        let width = self.view.frame.width
        animationView.frame = CGRect(x: 0, y: 0, width: width, height: 300)
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFit
        view.addSubview(animationView)
        animationView.loopMode = loopMode
        
        return animationView
    }
    
    func stopAnimation(animationView: AnimationView) {
        animationView.stop()
        animationView.alpha = 0
        animationView.isHidden = true
    }
    
}

extension UIAlertController {
    
    func setAlertUI() {
        self.setTitlet(font: UIFont.semiBold(size: 20), color: UIColor.darkGray)
        self.setTint(color: UIColor.darkGray)
        self.setMessage(font: UIFont.regular(size: 15), color: UIColor.darkGray)
        self.setBackgroundColor(color: UIColor.lightGray)
    }
    
    // Set background color of UIAlertController
    func setBackgroundColor(color: UIColor) {
        if let bgView = self.view.subviews.first,
            let groupView = bgView.subviews.first,
            let contentView = groupView.subviews.first {
            contentView.backgroundColor = color
        }
    }
    
    // Set title font and title color
    func setTitlet(font: UIFont?, color: UIColor?) {
        guard let title = self.title else { return }
        let attributeString = NSMutableAttributedString(string: title) // 1
        if let titleFont = font {
            attributeString.addAttributes([NSAttributedString.Key.font: titleFont], // 2
                                          range: NSRange(location: 0, length: title.utf8.count))
        }
        
        if let titleColor = color {
            attributeString.addAttributes([NSAttributedString.Key.foregroundColor: titleColor], // 3
                                          range: NSRange(location: 0, length: title.utf8.count))
        }
        self.setValue(attributeString, forKey: "attributedTitle") // 4
    }
    
    // Set message font and message color
    func setMessage(font: UIFont?, color: UIColor?) {
        guard let message = self.message else { return }
        let attributeString = NSMutableAttributedString(string: message)
        if let messageFont = font {
            attributeString.addAttributes([NSAttributedString.Key.font: messageFont],
                                          range: NSRange(location: 0, length: message.utf8.count))
        }
        
        if let messageColorColor = color {
            attributeString.addAttributes([NSAttributedString.Key.foregroundColor: messageColorColor],
                                          range: NSRange(location: 0, length: message.utf8.count))
        }
        self.setValue(attributeString, forKey: "attributedMessage")
    }
    
    // Set tint color of UIAlertController
    func setTint(color: UIColor) {
        self.view.tintColor = color
    }
}
