//
//  UIViewControllerExtension.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/16.
//

import UIKit

extension UIViewController {
    
    func setNavigationBarColor(bgColor: UIColor, textColor: UIColor, tintColor: UIColor, titleTextSize size: CGFloat = 22) {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = bgColor
        appearance.titleTextAttributes = [NSAttributedString.Key.font:
                                            UIFont.medium(size: size) as Any, NSAttributedString.Key.foregroundColor: textColor]
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        appearance.shadowColor = .clear
        navigationController?.navigationBar.tintColor = tintColor
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    func presentErrorAlert(title: String? = "Something went wrong", message: String?, completion: (() -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            guard let completion = completion else { return }
            completion()
        }

        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func presentDeleteAlert(title: String, message: String? = "Do you want to delete the record?", completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            guard let completion = completion else { return }
            completion()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func presentInviteAlert(title: String, message: String? = "Do you want to invite the user?", completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Invite", style: .destructive) { _ in
            guard let completion = completion else { return }
            completion()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func presentSuccessAlert(title: String = "Success",
                             message: String = "Congrats",
                             completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.setValue(UIColor.darkGreen, forKey: "titleTextColor")
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            guard let completion = completion else { return }
            completion()
        }
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
