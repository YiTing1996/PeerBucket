//
//  UserDataModal.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/20.
//

import Foundation
import MessageKit
import FirebaseAuth

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
    
    static func dummy() -> Self {
        User(userID: "", userAvatar: "", userHomeBG: "", userName: "", paringUser: [])
    }
}

// MARK: - for chat room
struct ChatUser: SenderType, Equatable {
    var senderId: String
    var displayName: String
}
