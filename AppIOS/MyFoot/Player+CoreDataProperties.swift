//
//  Player+CoreDataProperties.swift
//  
//
//  Created by Tayeb Sedraia on 04/10/2017.
//
//

import Foundation
import CoreData


extension Player {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Player> {
        return NSFetchRequest<Player>(entityName: "Player")
    }

    @NSManaged public var age: Double
    @NSManaged public var club: String?
    @NSManaged public var name: String?
    @NSManaged public var nationality: String?
    @NSManaged public var rating: Double

}
