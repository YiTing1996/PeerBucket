//
//  LoginManager.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/20.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

class UserManager {
    
    static let shared = UserManager()
    
    let dataBase = Firestore.firestore().collection("user")
    
    // MARK: - Signin
    
    func signInWithApple(uid: String, name: String?, completion: @escaping (Result<(User, Bool), Error>) -> Void) {

        let document = dataBase.document(uid)
        
        let user = User(userID: uid,
                        userAvatar: "",
                        userHomeBG: "",
                        userName: name ?? "",
                        paringUser: [])
        
        // check if user exist
        checkUserExists(uid: uid) { isExist in
            if !isExist {
                do {
                    try document.setData(from: user)
                    completion(.success((user, false))) // create a new user
                } catch let error {
                    completion(.failure(error))
                }
            } else {
                completion(.success((user, true))) // log in directly
            }
        }
    }
    
    // MARK: - Delete
    
    // delete user data
    func deleteUserData(uid: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        dataBase.document(uid).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("deleted user: \(uid)"))
            }
        }
    }
    
    // MARK: - Fetch
    
    // check if user exist
    func checkUserExists(uid: String, isExist: @escaping (Bool) -> Void) {
        dataBase.document(uid).getDocument { document, _ in
            if let document = document {
                if document.exists {
                    isExist(true)
                } else {
                    isExist(false)
                }
            } else {
                isExist(false)
            }
        }
    }
    
    func checkParingUser(userID: String, completion: @escaping (Result<User, Error>) -> Void) {

        dataBase.whereField("userID", isEqualTo: userID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion(.failure(error))
                
            } else {
                for document in querySnapshot!.documents {
                    do {
                        if let user = try document.data(as: User?.self, decoder: Firestore.Decoder()) {
                            completion(.success(user))
                        }
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    // fetch user data
    func fetchUserData(userID: String, completion: @escaping (Result<User, Error>) -> Void) {
        dataBase.document(userID).getDocument { (querySnapshot, error) in
            if let user = try? querySnapshot?.data(as: User.self) {
                completion(.success(user))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
        
    // MARK: - Update
    
    // update user data (for adding paring user)
    func updateUserData(user: User, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            try dataBase.document(user.userID).setData(from: user)
            completion(.success(user.userID))
        } catch {
            print("update user data error: \(error)")
            completion(.failure(error))
        }
    }
    
}
