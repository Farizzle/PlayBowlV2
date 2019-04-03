//
//  CoreDataHerlp.swift
//  JustCook
//
//  Created by Metricell Developer on 16/01/2019.
//  Copyright © 2019 Faris Zaman. All rights reserved.
//

import UIKit
import CoreData

struct CoreDataHelper {
    
    static public func saveUser(entityName: String, playerOneScore: [[Int]]?, playerTwoScore: [[Int]]?, timeOfMatch: Date){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext)!
        
        let scores = NSManagedObject(entity: entity, insertInto: managedContext)

        let playerOneData = NSKeyedArchiver.archivedData(withRootObject: playerOneScore)
        let playerTwoData = NSKeyedArchiver.archivedData(withRootObject: playerTwoScore)

        scores.setValue(playerOneData, forKey: "playerOneScore")
        scores.setValue(playerTwoData, forKey: "playerTwoScore")
        scores.setValue(timeOfMatch, forKey: "matchDate")
        
        do {
            try managedContext.save()
            print("Saved scores successfully")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    static public func loadCoreData(entityName: String) -> [NSManagedObject] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return [NSManagedObject].init()
        }
        var scoreDetails: [NSManagedObject] = []
    
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        
        do {
            scoreDetails = try managedContext.fetch(fetchRequest)
            print("Loaded user information successfully")
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return scoreDetails
    }
    
    static public func resetEntity(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Scoreboards")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try managedContext.execute(batchDeleteRequest)
            print("Cleaned CoreData")
        } catch {
            print("Failed to clear up CoreData")
        }

    }

}
