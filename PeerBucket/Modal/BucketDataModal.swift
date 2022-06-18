//
//  FirebaseDataModal.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/16.
//

import Foundation

struct BucketCategory: Codable {

    var senderId: String
    var category: String
    var id: String
    var image: String
    
    enum CodingKeys: String, CodingKey {
        case senderId
        case category
        case id
        case image
    }
    
    var toDict: [String: Any] {
        return [
            "senderId": senderId as Any,
            "category": category as Any,
            "id": id as Any,
            "image": image as Any
        ]
    }
}

struct BucketList: Codable {
    
    var senderId: String
    var createdTime: Int64
    var status: Bool = false
    var list: String
    var categoryId: String
    var listId: String
    
    enum CodingKeys: String, CodingKey {
        case senderId
        case createdTime
        case status
        case list
        case categoryId
        case listId
    }
    
    var toDict: [String: Any] {
        return [
            "senderId": senderId as Any,
            "createdTime": createdTime as Any,
            "status": status as Any,
            "list": list as Any,
            "categoryId": categoryId as Any,
            "listId": listId as Any
        ]
    }
}
