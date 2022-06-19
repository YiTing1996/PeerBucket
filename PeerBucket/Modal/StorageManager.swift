//
//  StorageManager.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/19.
//

import Foundation
import CoreData
import UIKit

class StorageManager {
    
    static let shared = StorageManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PeerBucket")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            print(storeDescription)
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    func fetchFromCoreData() -> [Category]? {
        
        let managedContext = StorageManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Category")
        do {
            let image = try managedContext.fetch(fetchRequest)
            return image as? [Category]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
//        return nil
    }
    
    func saveToCoreData(category: String, image: String, id: String) {
        
        let managedContext = StorageManager.shared.persistentContainer.viewContext
        
        let newCategory = Category(context: managedContext)
        newCategory.name = category
        newCategory.image = image
        newCategory.id = id
        
        do {
            try managedContext.save()
        } catch {
            print(error)
        }
    }
    
//    func deleteFromCoreData(of order: Orders) {
//        let managedContext = StorageManager.shared.persistentContainer.viewContext
//        managedContext.delete(order)
//        do {
//            try managedContext.save()
//        } catch  {
//            print(error)
//        }
//
//        //資料有更新的時候就呼叫notification center
////        NotificationCenter.default.post(name: Notification.Name("subtractCartNumber"), object: nil)
//
//    }
//
//    func updateToCoreData(order: Orders, updateCount: Int) {
//        let managedContext = StorageManager.shared.persistentContainer.viewContext
//            order.setValue(Int16(updateCount), forKey: "count")
//            do {
//                try managedContext.save()
//            } catch {
//                print(error)
//            }
//    }
    
}
