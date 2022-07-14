//
//  MessageManager.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/7/12.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

class MessageManager {
    
    static let shared = MessageManager()
    
    let dataBase = Firestore.firestore().collection("Chats")
    
//    func addChat(data: [String: Any],
//                           completion: @escaping (Result<[Chat], Error>) -> Void) {
//
//        dataBase.addDocument(data: data) { (error) in
//            if let error = error {
//                print("Unable to create chat! \(error)")
//                return
//            } else {
//                print("Document successfully updated")
//            }
//        }
//    }
    
    func deletChat(uid: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        dataBase.whereField("users", arrayContains: uid).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot, error != nil else {
                print("Error delete chat error")
                return
            }
            
            for doc in snapshot.documents {
                doc.reference.delete()
            }
            
        }
        
    }

}
