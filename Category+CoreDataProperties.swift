//
//  Category+CoreDataProperties.swift
//  
//
//  Created by 陳憶婷 on 2022/6/19.
//
//

import Foundation
import CoreData

extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var name: String?
    @NSManaged public var image: String?
    @NSManaged public var id: String?

}
