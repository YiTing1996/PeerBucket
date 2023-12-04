//
//  CellExtension.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2023/12/4.
//

import UIKit

extension UICollectionViewCell {
    static var cellIdentifier: String {
        String(describing: self)
    }
}

extension UITableViewCell {
    static var cellIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionReusableView {
    static var headerIdentifier: String {
        String(describing: self)
    }
}
