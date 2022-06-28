//
//  TabBarController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/22.
//

import Foundation
import UIKit
import FirebaseAuth

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
//    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        if let navController = viewController as? UINavigationController,
//           let _ = navController.viewControllers.first as? ProfileViewController {
//            if fetchUser() {
//                return true
//            } else {
//                let homeVC = storyboard?.instantiateViewController(withIdentifier: "homeVC")
//                guard let homeVC = homeVC as? HomeViewController else { return false }
//                navigationController?.pushViewController(homeVC, animated: true)
//                return false
//            }
//        } else {
//            return true
//        }
//    }

    func fetchUser() -> Bool {
        if Auth.auth().currentUser != nil {
            return true
        } else {
            return false
        }
    }
    
}
