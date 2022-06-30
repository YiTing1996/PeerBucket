//
//  UserDataModal.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/20.
//

import Foundation
import MessageKit

struct User: Codable {
    
//    var userEmail: String
    var userID: String
    var userAvatar: String
    var userHomeBG: String
    var userName: String
    var paringUser: [String]
    
    enum CodingKeys: String, CodingKey {
//        case userEmail
        case userID
        case userAvatar
        case userHomeBG
        case userName
        case paringUser
    }
    
    var toDict: [String: Any] {
        return [
//            "userEmail": userEmail as Any,
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
