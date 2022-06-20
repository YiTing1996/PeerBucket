//
//  UserDataModal.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/20.
//

import Foundation
import MessageKit

struct User: SenderType, Equatable {
    var senderId: String
    var displayName: String
}
