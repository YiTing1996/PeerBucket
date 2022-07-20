//
//  BaseVariable.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/7/20.
//

import Foundation
import FirebaseAuth

// Beta UID: "AITNzRSyUdMCjV4WrQxT"
var currentUserUID: String? {
    get {
        guard let userID = Auth.auth().currentUser?.uid else {
            return nil
        }
        return userID
    }
}

enum IdentityType: String, CaseIterable {
    case currentUser
    case paringUser
}

var imageCompressionQuality: Double = 0.5
var hideMenuBottomConstraint: CGFloat = -600
