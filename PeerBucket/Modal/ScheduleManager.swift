//
//  ScheduleManager.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/18.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

class ScheduleManager {
    
    static let shared = ScheduleManager()
    
    let dataBase = Firestore.firestore()
    
    func fetchSchedule(completion: @escaping (Result<[Schedule], Error>) -> Void) {
                
        dataBase.collection("schedule").getDocuments { querySnapshot, error in
            
            if let error = error {
                completion(.failure(error))
            } else {
                var schedules = [Schedule]()
                
                for document in querySnapshot!.documents {
                    
                    do {
                        if let schedule = try document.data(as: Schedule?.self, decoder: Firestore.Decoder()) {
                            schedules.append(schedule)
                        }
                    } catch {
                        completion(.failure(error))
                    }
                }
                completion(.success(schedules))
            }
        }
    }
    
    // MARK: - Add
    
    func addSchedule(schedule: inout Schedule,
                           completion: @escaping (Result<[Schedule], Error>) -> Void) {
        
        let document = dataBase.collection("schedule").document()
        schedule.id = document.documentID
        
        document.setData(schedule.toDict) { error in
            
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    // MARK: - Update
    
    func updateSchedule(schedule: Schedule, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            try dataBase.collection("schedule").document(schedule.id).setData(from: schedule)
            completion(.success("update schedule: \(schedule.id)"))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteBucketList(id: String, completion: @escaping(Result<String, Error>) -> Void) {
        dataBase.collection("schedule").document(id).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("deleted schedule: \(id)"))
            }
        }
    }
    
}

