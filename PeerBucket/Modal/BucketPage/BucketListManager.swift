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
    
    let dataBase = Firestore.firestore()
    
    // MARK: - Fetch
    
    // query bucket category by id of user
    func fetchBucketCategory(userID: String, completion: @escaping (Result<[BucketCategory], Error>) -> Void) {
        
        dataBase.collection("bucketCategory").whereField("senderId", isEqualTo: userID).getDocuments { (querySnapshot, error) in
            
            if let error = error {
                
                completion(.failure(error))
            } else if let querySnapshot = querySnapshot {
                
                let bucketLists = querySnapshot.documents.compactMap({ querySnapshot in
                    try? querySnapshot.data(as: BucketCategory.self)
                })
                
                completion(.success(bucketLists))
            }
        }
    }
    
    // query bucket list by id of bucket category
    func fetchBucketList(categoryID: String, completion: @escaping (Result<[BucketList], Error>) -> Void) {
        
        dataBase.collection("bucketList")
            .order(by: "createdTime", descending: true)
            .whereField("categoryId", isEqualTo: categoryID)
            .getDocuments { (querySnapshot, error) in
                
                if let error = error {
                    print("Error getting documents: \(error)")
                    completion(.failure(error))
                    
                } else {
                    
                    var bucketLists = [BucketList]()
                    
                    guard let querySnapshot = querySnapshot else {
                        print("Error getting snapshot")
                        return
                    }
                    
                    for document in querySnapshot.documents {
                        
                        do {
                            if let bucketList = try document.data(as: BucketList?.self, decoder: Firestore.Decoder()) {
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
    
    // query bucket list by id of bucket category
    func fetchBucketListBySender(senderId: String, completion: @escaping (Result<[BucketList], Error>) -> Void) {
        
        dataBase.collection("bucketList").whereField("senderId", isEqualTo: senderId).getDocuments { (querySnapshot, error) in
            
            if let error = error {
                print("Error getting documents: \(error)")
                completion(.failure(error))
            } else {
                var bucketLists = [BucketList]()
                for document in querySnapshot!.documents {
                    do {
                        if let bucketList = try document.data(as: BucketList?.self, decoder: Firestore.Decoder()) {
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
    
    // MARK: - Add
    
    func addBucketCategory(bucketCategory: inout BucketCategory,
                           completion: @escaping (Result<[BucketCategory], Error>) -> Void) {
        
        let document = dataBase.collection("bucketCategory").document()
        bucketCategory.id = document.documentID
        
        document.setData(bucketCategory.toDict) { error in
            
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func addBucketList(bucketList: inout BucketList,
                       completion: @escaping (Result<[BucketList], Error>) -> Void) {
        
        let document = dataBase.collection("bucketList").document()
        bucketList.listId = document.documentID
        bucketList.createdTime = Date()
        
        document.setData(bucketList.toDict) { error in
            
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    // MARK: - Update
    
    func updateBucketList(bucketList: BucketList, completion: @escaping(Result<String, Error>) -> Void) {
        do {
            try dataBase.collection("bucketList").document(bucketList.listId).setData(from: bucketList)
            completion(.success(bucketList.listId))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteBucketList(id: String, completion: @escaping(Result<String, Error>) -> Void) {
        dataBase.collection("bucketList").document(id).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("deleted bucketList \(id)"))
            }
        }
    }
    
    func deleteBucketListByCategory(id: String, completion: @escaping(Result<String, Error>) -> Void) {
        
        dataBase.collection("bucketList").whereField("categoryId", isEqualTo: id).getDocuments { (querySnapshot, error) in
            
            if let error = error {
                print("Error getting documents: \(error)")
                completion(.failure(error))
                
            } else {
                
                for document in querySnapshot!.documents {
                    document.reference.delete()
                }
                completion(.success("deleted bucketList \(id)"))
            }
        }
    }
    
    func deleteBucketCategory(id: String, completion: @escaping(Result<String, Error>) -> Void) {
        dataBase.collection("bucketCategory").document(id).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("deleted bucketList \(id)"))
            }
        }
    }
}
