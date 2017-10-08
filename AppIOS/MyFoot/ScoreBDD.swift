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
    
    func clearData() {
        
        if let context = DataManager.shared.objectContext {
            
            do {
                
                let entityNames = ["Score"]
                
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
    
    func setupData(_name: [String], _score: [Double]) {
        
        clearData()
        
        
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
        
        loadData()
        
    }
    
    
    func loadData() {
        
        if let context = DataManager.shared.objectContext {
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Score")
            
            do {
                
                scores = try(context.fetch(fetchRequest)) as? [Score]
                
            } catch let err {
                print(err)
            }
            
        }
    }
    
    
}


