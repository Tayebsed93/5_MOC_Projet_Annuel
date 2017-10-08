//
//  Score+CoreDataProperties.swift
//  
//
//  Created by Tayeb Sedraia on 04/10/2017.
//
//

import Foundation
import CoreData


extension Score {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Score> {
        return NSFetchRequest<Score>(entityName: "Score")
    }

    @NSManaged public var name: String?
    @NSManaged public var score: Double

}
