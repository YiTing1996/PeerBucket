//
//  FirebaseConstant.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/7/24.
//

import FirebaseFirestore
import FirebaseStorage

let storage = Storage.storage().reference()
let screenHeight = UIScreen.main.bounds.height
let screenWidth = UIScreen.main.bounds.width

enum IdentityType: String, CaseIterable {
    case currentUser
    case paringUser
}

struct ScreenConstant {
    static let hideMenuBottomConstraint: CGFloat = -600
}
