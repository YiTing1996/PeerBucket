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

// for test
// var currentUserUID = "AITNzRSyUdMCjV4WrQxT"
 var currentUserUID = "Iq0Ssbo86uG3JXx26w3h"
// var currentUserUID = "04LcJa0gc4vXnOE5eMEn"

// for test
// var testUserID = "AITNzRSyUdMCjV4WrQxT"
 var testUserID = "Iq0Ssbo86uG3JXx26w3h"
// var testUserID = "04LcJa0gc4vXnOE5eMEn"

class UserManager {
    
    static let shared = UserManager()
    
    let dataBase = Firestore.firestore().collection("user")
    
    func sinInUp(email: String, name: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            guard let user = result?.user,
                  error == nil else {
                print("Error", error?.localizedDescription as Any)
                return
            }
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = name
            changeRequest?.commitChanges(completion: { error in
                guard error == nil else {
                    print(error?.localizedDescription as Any)
                    return
                }
            })
            print("註冊成功", user.uid)
        }
    }
    
    // MARK: - Query User Data
    
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
    
    // update user data (add paring user)
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
