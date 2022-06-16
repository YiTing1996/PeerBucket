//
//  BucketListManager.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/16.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

class BucketListManager {
    
    static let shared = BucketListManager()
    let dataBase = Firestore.firestore().collection("bucketList")
    
    func addBucketList(bucketList: inout BucketCategory) {
        
        let document = dataBase.document()
        bucketList.id = document.documentID
        //        bucketList.createdTime = Date().millisecondsSince1970
        
        document.setData(bucketList.toDict) { error in
            
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func fetchBucketList(completion: @escaping (Result<[BucketCategory], Error>) -> Void) {
        
        //        dataBase.order(by: "createdTime", descending: true).getDocuments() { (querySnapshot, error) in
        
        dataBase.getDocuments() { (querySnapshot, error) in
            
            if let error = error {
                
                completion(.failure(error))
            } else {
                
                var bucketLists = [BucketCategory]()
                
                for document in querySnapshot!.documents {
                    
                    do {
                        if let bucketList = try document.data(as: BucketCategory?.self, decoder: Firestore.Decoder()) {
                            bucketLists.append(bucketList)
                        }
                        
                    } catch {
                        completion(.failure(error))
                    }
                }
                completion(.success(bucketLists))
            }
        }
    }
    
    func updateBucketList(id: String, bucketList: String, completion: @escaping (Result<String, Error>) -> Void) {
        do {
//            try dataBase.document(bucketList.id).setData(from: bucketList)
            
            try dataBase.document(id).updateData([
                "content": FieldValue.arrayUnion([[
                    "senderId": "Doreen",
                    "createdTime": Date().millisecondsSince1970,
                    "status": false,
                    "list": bucketList
                ]])
            ])
            
            completion(.success(bucketList))
            
        } catch {
            completion(.failure(error))
        }
    }
    
}
