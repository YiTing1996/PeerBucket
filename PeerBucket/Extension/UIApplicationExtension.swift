//
//  UIApplicationExtension.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2023/12/4.
//

import UIKit

extension UIApplication {
    var keyWindow: UIWindow? {
        connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first { $0.isKeyWindow }
    }
}
