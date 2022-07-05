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

}
