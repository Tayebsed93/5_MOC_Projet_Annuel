//
//  PlayerBDD.swift
//  MyFoot
//
//  Created by Tayeb Sedraia on 23/09/2017.
//  Copyright © 2017 Tayeb Sedraia. All rights reserved.
//

import UIKit

import CoreData

extension PlayerController {
    
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
    
    
    func loadSearchData(_cleRecherche: String) {
        
        if let context = DataManager.shared.objectContext {
            
            //Avant il y avait juste ça
            //let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Eleve")
            
            ///Ajouter
            let managedObjectContext: NSManagedObjectContext
            let predicate = NSPredicate(format: "name == %@", _cleRecherche)
            //let predicate = NSPredicate(format: "name LIKE '*%1$@*'", _cleRecherche)
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Player")
            fetchRequest.predicate = predicate
            print(predicate.description)
            
            //fetchRequest.sortDescriptors = [] //optionally you can specify the order in which entities should ordered after fetch finishes
            
            ///Fin ajout
            do {
                
                players = try(context.fetch(fetchRequest)) as? [Player]
                print(players?.count)
                if players?.count == 0 {
                    loadData()
                }
                
                
                
            } catch let err {
                print(err)
            }
            
        }
    }

    
}


