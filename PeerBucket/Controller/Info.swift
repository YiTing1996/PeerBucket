//
//  Info.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2023/12/4.
//

import UIKit

// TODO: Apple sign in and sign out
// TODO: Manage user data
class Info {
    
    static let shared = Info()
    
    private init() {}
    
    var currentUser: User?
    var paringUser: User?
    
    func signOut() {
        clearNotification()
    }
    
    private func clearNotification() {
        UIApplication.shared.unregisterForRemoteNotifications()
        let notifications = UNUserNotificationCenter.current()
        notifications.removeAllPendingNotificationRequests()
        notifications.removeAllDeliveredNotifications()
    }
}
