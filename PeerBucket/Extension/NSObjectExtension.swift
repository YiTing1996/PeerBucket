//
//  NSObjectExtension.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/7/19.
//

import Foundation
import UIKit

extension NSObject {
    
    func create<T>(_ setup: ((T) -> Void)) -> T where T: NSObject {
        let obj = T()
        setup(obj)
        return obj
    }
    
}
