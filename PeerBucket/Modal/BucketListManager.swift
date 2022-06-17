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
    
    func fetchBucketCategory(completion: @escaping (Result<[BucketCategory], Error>) -> Void) {
        
        //        dataBase.order(by: "createdTime", descending: true).getDocuments() { (querySnapshot, error) in
        
        dataBase.collection("bucketCategory").getDocuments { querySnapshot, error in
            
            if let error = error {
                
                completion(.failure(error))
            } else {
                
                var bucketCategories = [BucketCategory]()
                
                for document in querySnapshot!.documents {
                    
                    do {
                        if let bucketCategory = try document.data(as: BucketCategory?.self, decoder: Firestore.Decoder()) {
                            bucketCategories.append(bucketCategory)
                        }
                        
                    } catch {
                        completion(.failure(error))
                    }
                }
                completion(.success(bucketCategories))
            }
        }
    }
    
    func fetchBucketList(id: String, completion: @escaping (Result<[BucketList], Error>) -> Void) {
        
        //        dataBase.order(by: "createdTime", descending: true).getDocuments() { (querySnapshot, error) in
        
        dataBase.collection("bucketList").whereField("categoryId", isEqualTo: id).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion(.failure(err))
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
        //        bucketList.createdTime = Date().millisecondsSince1970
        
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
        bucketList.createdTime = Date().millisecondsSince1970
        
        document.setData(bucketList.toDict) { error in
            
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    // MARK: - Update
    
    func updateBucketListStatus(bucketList: BucketList, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            try dataBase.collection("bucketList").document(bucketList.listId).setData(from: bucketList)
            completion(.success("update bucket list: \(bucketList)"))
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
    
}
