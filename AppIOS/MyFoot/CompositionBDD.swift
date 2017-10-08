//
//  CompositionBDD.swift
//  MyFoot
//
//  Created by Tayeb Sedraia on 22/09/2017.
//  Copyright © 2017 Tayeb Sedraia. All rights reserved.
//

import UIKit

import CoreData

extension CompositionController {
    
    func clearData() {
        
        if let context = DataManager.shared.objectContext {
            
            do {
                
                let entityNames = ["Player"]
                
                for entityName in entityNames {
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                    
                    let objects = try(context.fetch(fetchRequest)) as? [NSManagedObject]
                    
                    for object in objects! {
                        context.delete(object)
                    }
                }
                
                try(context.save())
                
                
            } catch let err {
                print(err)
            }
            
        }
    }
    
    func setupData(_name: [String], _age: [Double]) {
        
        clearData()
        
     
        for i in 0 ... self.names.count - 1 {
        if let context = DataManager.shared.objectContext {
            
            
            let player = NSEntityDescription.insertNewObject(forEntityName: "Player", into: context) as! Player
            

                player.name = _name[i]
                player.age = _age[i]

            
            
            do {
                try(context.save())
            } catch let err {
                print(err)
            }
        }
     }
        
        loadData()
        
    }
    
    
    func loadData() {
        
        if let context = DataManager.shared.objectContext {
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Player")
            
            do {
                
                players = try(context.fetch(fetchRequest)) as? [Player]
                
            } catch let err {
                print(err)
            }
            
        }
    }
    
    
}
 
