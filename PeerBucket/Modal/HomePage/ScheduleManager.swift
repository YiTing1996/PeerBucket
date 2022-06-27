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
    
    // fetch upcoming event
    func fetchSchedule(userID: String, completion: @escaping (Result<UpcomingSchedule, Error>) -> Void) {
        
        dataBase.collection("schedule").whereField("senderId", isEqualTo: userID).getDocuments { querySnapshot, error in
            
            if let error = error {
                
                print("Error getting documents: \(error)")
                completion(.failure(error))
                
            } else if let querySnapshot = querySnapshot {
                
                let date = Date()
                var eventDistance: Int = 0
                var eventTitle: String = ""
                
                let allEvents = querySnapshot.documents.compactMap({ querySnapshot in
                    try? querySnapshot.data(as: Schedule.self)
                })
                
                _ = allEvents.compactMap { event -> Schedule? in
                    
                    let distance = event.eventDate.distance(from: date, only: .day)
                    // exclude today's event
                    if distance > 0 && distance < 30 {
                        eventDistance = distance
                        eventTitle = event.event
                        return event
                    } else {
                        return nil
                    }
                }
                
                let eventsUpcoming: UpcomingSchedule = UpcomingSchedule(event: eventTitle, distance: eventDistance)
                completion(.success(eventsUpcoming))
            }
        }
    }
    
    // fetch specific date's event
    func fetchSpecificSchedule(userID: String, date: Date, completion: @escaping (Result<[Schedule], Error>) -> Void) {
        
        dataBase.collection("schedule").whereField("senderId", isEqualTo: userID).getDocuments { (querySnapshot, error) in
            
            if let error = error {
                
                print("Error getting documents: \(error)")
                completion(.failure(error))
                
            } else if let querySnapshot = querySnapshot {
                
                let events = querySnapshot.documents.compactMap({ querySnapshot in
                    try? querySnapshot.data(as: Schedule.self)
                })
                
                let eventsOnDate = events.compactMap { event -> Schedule? in
                    if event.eventDate.hasSame(.day, as: date) {
                        return event
                    } else {
                        return nil
                    }
                }
                
                let specificDateEvents = eventsOnDate.sorted { $0.eventDate < $1.eventDate }
                
                completion(.success(specificDateEvents))
            }
        }
        
    }
    
    // MARK: - Add
    
    func addSchedule(schedule: inout Schedule, completion: @escaping (Result<[Schedule], Error>) -> Void) {
        
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
    
    func deleteSchedule(id: String, completion: @escaping(Result<String, Error>) -> Void) {
        dataBase.collection("schedule").document(id).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("deleted schedule: \(id)"))
            }
        }
    }
    
}
