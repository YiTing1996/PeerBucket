//
//  UIFontExtension.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/16.
//

import UIKit

enum FontName: String {

    case regular = "PingFangTC-Regular"

    case medium = "PingFangTC-Medium"

    case semiBold = "PingFangTC-Semibold"

}

extension UIFont {

    static func regular(size: CGFloat) -> UIFont? {

        return UIFont(name: FontName.regular.rawValue, size: size)
    }

    static func medium(size: CGFloat) -> UIFont? {

        return UIFont(name: FontName.medium.rawValue, size: size)
    }

    static func semiBold(size: CGFloat) -> UIFont? {

        return UIFont(name: FontName.semiBold.rawValue, size: size)
    }

    private static func font(_ font: FontName, size: CGFloat) -> UIFont? {

        return UIFont(name: font.rawValue, size: size)
    }
}
