//
//  MessageManager.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/30.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift
import UserNotifications

class MessageManager {
    
    static let shared = MessageManager()
    
    let dataBase = Firestore.firestore()
    
    var messages: [Message] = []
    var isFirstListener: Bool = true
    
    func fetchMessage(userID: String, user2UID: String) {
        
        let database = Firestore.firestore().collection("Chats").whereField("users", arrayContains: userID)
        
        database.getDocuments { (chatQuerySnap, error) in
            
            if let error = error {
                print("Error: \(error)")
                return
            } else {
                
                guard let queryCount = chatQuerySnap?.documents.count else {
                    return
                }
                
                if queryCount >= 1 {
                    
                    for doc in chatQuerySnap!.documents {
                        
                        doc.reference.collection("thread")
                            .order(by: "created", descending: false)
                            .addSnapshotListener { snapshot, error in
                                
                                guard let snapshot = snapshot else {
                                    print("Error: \(String(describing: error))")
                                    return
                                }
                                
                                snapshot.documentChanges.forEach { documentChange in
                                    switch documentChange.type {
                                    case .added:
                                        if self.isFirstListener == false {
                                            for value in Array(documentChange.document.data().values) where value as? String == user2UID {
//                                                print(documentChange.document.data())
                                                let data = documentChange.document.data()
                                                let name = data["senderName"]

                                                self.messageNotification(name: name as? String ?? "ParingUser")
                                            }
                                        }
                                    case .modified:
                                        break
                                    case .removed:
                                        break
                                    }
                                }
                                
                                self.isFirstListener = false
                                
                            }
                    }
                }
            }
        }
    }
    
    func messageNotification(name: String) {
        let content = UNMutableNotificationContent()
        content.title = "PeerBucket"
        content.body = "There is a new message from \(name)"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "notification",
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error in chatVC: \(error)")
            } else {
                //                print("Success")
            }
        }
    }
    
}
