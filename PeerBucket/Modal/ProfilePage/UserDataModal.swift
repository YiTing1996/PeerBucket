//
//  UserDataModal.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/20.
//

import Foundation
import MessageKit
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

struct User: Codable {
    
    var userID: String
    var userAvatar: String
    var userHomeBG: String
    var userName: String
    var paringUser: [String]
    
    enum CodingKeys: String, CodingKey {
        case userID
        case userAvatar
        case userHomeBG
        case userName
        case paringUser
    }
    
    var toDict: [String: Any] {
        return [
            "userID": userID as Any,
            "userAvatar": userAvatar as Any,
            "userHomeBG": userHomeBG as Any,
            "userName": userName as Any,
            "paringUser": paringUser as Any
        ]
    }
}

// MARK: - for chat room
struct ChatUser: SenderType, Equatable {
    var senderId: String
    var displayName: String
}
