//
//  ScheduleDataModal.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/18.
//

import Foundation

struct Schedule: Codable {

    var senderId: String
    var event: String
    var id: String
    var eventDate: Date = .init(timeIntervalSinceReferenceDate: 0)

    enum CodingKeys: String, CodingKey {
        case senderId
        case event
        case id
        case eventDate
    }
    
    var toDict: [String: Any] {
        return [
            "senderId": senderId as Any,
            "event": event as Any,
            "id": id as Any,
            "eventDate": eventDate as Any
        ]
    }
}

struct UpcomingSchedule: Codable {

    var event: String
    var distance: Int

    enum CodingKeys: String, CodingKey {
        case event
        case distance
    }
    
    var toDict: [String: Any] {
        return [
            "event": event as Any,
            "distance": distance as Any
        ]
    }
}
