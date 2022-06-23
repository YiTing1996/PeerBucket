//
//  TabBarController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/22.
//

import Foundation
import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
//    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController)->Bool {
//        if let navController = viewController as? UINavigationController,
//           let _ = navController.viewControllers.first as? ChatViewController {
//            if fetchToken() {
//                return true
//            } else {
//                let logInViewController = LogInViewController()
//                logInViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
//                self.present(logInViewController, animated: false)
//                // 記得return false
//                return false
//            }
//        } else {
//            return true
//        }
//    }
//
//    func fetchToken() -> Bool {
//        return (KeychainManager.shared.check(service: "accessToken", account: "PeerBucket"))
//    }
    
}
