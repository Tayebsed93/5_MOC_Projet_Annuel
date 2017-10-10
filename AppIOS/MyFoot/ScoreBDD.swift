//
//  ScoreBDD.swift
//  MyFoot
//
//  Created by Tayeb Sedraia on 04/10/2017.
//  Copyright © 2017 Tayeb Sedraia. All rights reserved.
//

import UIKit

import CoreData

extension ScoreController {
    
    func supprimer() {
        let context = DataManager.shared.objectContext
        
        //create a fetch request, telling it about the entity
        let fetchRequest: NSFetchRequest<Score> = Score.fetchRequest()
        
        do {
            //go get the results
            let array_users = try context?.fetch(fetchRequest)
            
            //You need to convert to NSManagedObject to use 'for' loops
            for user in array_users as! [NSManagedObject] {
                //get the Key Value pairs (although there may be a better way to do that...
                context?.delete(user)
            }
            //save the context
            
            do {
                try context?.save()
                print("saved!")
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            } catch {
                
            }
            
        } catch {
            print("Error with request: \(error)")
        }
    }
    
    func clearData() {
        
        if let context = DataManager.shared.objectContext {
            
            do {
                
                let entityNames = ["Score"]
                
                for entityName in entityNames {
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                    
                    let objects = try(context.fetch(fetchRequest)) as? [NSManagedObject]
                    //context.persistentStoreCoordinator?.managedObjectModel.entities
                    
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
    
    func setupData(_name: [String], _score: [Double]) {
        
       self.clearData()
        
        for i in 0 ... self.names.count - 1 {
            if let context = DataManager.shared.objectContext {
                
                
                let score = NSEntityDescription.insertNewObject(forEntityName: "Score", into: context) as! Score
                
                
                score.name = _name[i]
                score.score = _score[i]
                
                
                
                
                
                do {
                    try(context.save())
                } catch let err {
                    print(err)
                }
            }
        }
        
        
        
        
    }
    
    
    func loadData() {
        
        
        if let context = DataManager.shared.objectContext {
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Score")
            
            do {
                
                scores = try(context.fetch(fetchRequest)) as? [Score]
                print(scores?.count)
                
            } catch let err {
                print(err)
            }
            
        }
    }
    
    
}


