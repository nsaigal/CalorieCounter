//
//  DatabaseCalls.swift
//  CalorieApp
//
//  Created by Neil Saigal on 4/14/20.
//  Copyright © 2020 AppleInterview. All rights reserved.
//

import UIKit
import CoreData

class APICalls {

    /**
     Creates entry in Core Data for Menu Item/Diary Entry
     - Parameter label: Name of food item
     - Parameter calories: Amount of calories in food item
     - Parameter meal: Meal to log under (for Diary entries only)
     - Parameter picture: Picture of food item (optional)
    */
    public func createEntry(calories: Int, label: String, meal: Meal? = nil, picture: UIImage? = nil, date: Date = Date()) {
      
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
        }
          
        let managedContext: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
          
        //Create Menu Item
        var entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: "MenuItem", in: managedContext)!
        
        //Create Diary Item
        if meal != nil {
            entity = NSEntityDescription.entity(forEntityName: "DiaryEntry", in: managedContext)!
        }
          
        let object: NSManagedObject = NSManagedObject(entity: entity, insertInto: managedContext)
          
        object.setValue(calories, forKeyPath: "calories")
        object.setValue(label, forKeyPath: "label")
        
        //Create Diary Item
        if meal != nil {
            object.setValue(meal!.index, forKeyPath: "meal")
            object.setValue(date, forKeyPath: "date")
        }
        
        if let image = picture {
            if let data = image.pngData() as NSData? {
                object.setValue(data, forKey: "picture")
            }
        }

        do {
            try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    /**
     Updates entry in Core Data for Menu Item
     - Parameter label: Name of food item
     - Parameter calories: Amount of calories in food item
     - Parameter object: Core Data object to update
     - Parameter picture: Picture of food item (optional)
    */
    public func updateMenuEntry(calories: Int, label: String, picture:UIImage, object: NSManagedObject) {
      
        guard let appDelegate: AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext: NSManagedObjectContext = appDelegate.persistentContainer.viewContext

        object.setValue(Int(calories), forKeyPath: "calories")
        object.setValue(label, forKeyPath: "label")
        
        if let data = picture.pngData() as NSData? {
            object.setValue(data, forKey: "picture")
        }
          
        do {
            try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    /**
     Retrieves calories for Diary entries during given data range
     - Parameter start: Beginning of date range
     - Parameter end: End of date range
     - Returns: Total calories
    */
    public func getConsumedCaloriesForTimeframe(start: Date, end: Date) -> CGFloat {

        guard let appDelegate: AppDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
            return(0)
        }

        let managedContext: NSManagedObjectContext = appDelegate.persistentContainer.viewContext

        let fetchRequest: NSFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DiaryEntry")

        let dataPred: NSPredicate = NSPredicate(format: "date >= %@ AND date <= %@", start as NSDate, end as NSDate)
            
        fetchRequest.predicate = dataPred
        do {
            let entries: [NSManagedObject] = try managedContext.fetch(fetchRequest)
            return CGFloat(calculateTotal(entries: entries))

        } catch let error as NSError {
          print("Could not fetch calorie totals. \(error), \(error.userInfo)")
        }
        
        return 0
    }
    
    /**
     Adds total calories consumed for array of Diary entries
     - Parameter entries: Array of Diary entries
     - Returns: Total calories
    */
    fileprivate func calculateTotal(entries: [NSManagedObject]) -> Int {
        var totalCalories = 0
        
        for data in entries {
             totalCalories += data.value(forKey: "calories") as! Int
        }
        
        return totalCalories
    }
    
    /**
     Retrieves all menu items created by user.
     - Returns: Array of MenuItem objects
    */
    public func getMenuItems(completion: @escaping (_ menuItems: [NSManagedObject]) -> Void) {
        guard let appDelegate: AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            completion([])
            return
        }

        let managedContext: NSManagedObjectContext = appDelegate.persistentContainer.viewContext

        let fetchRequest: NSFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MenuItem")

        do {
            let items: [NSManagedObject] = try managedContext.fetch(fetchRequest)
            completion(items)
        } catch let error as NSError {
            print("Could not load menu items. \(error), \(error.userInfo)")
            completion([])
        }
    }
    
    /**
     Retrieves today's log of Diary entries by meal.
     - Parameter meal: Meal for which the food item was listed under.
     - Returns: Array of Diary Entry objects
    */
    public func getDiary(meal: Int) -> [NSManagedObject] {
        
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
            return []
        }

        let managedContext: NSManagedObjectContext = appDelegate.persistentContainer.viewContext

        let fetchRequest: NSFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DiaryEntry")
        
        let start: Date = Date().getStartOfDay()
        let end: Date = start.getTomorrow()

        let dataPred: NSPredicate = NSPredicate(format: "date >= %@ AND date <= %@", start as NSDate, end as NSDate)
        let mealPred: NSPredicate = NSPredicate(format: "meal == %i", meal)
        let andPredicate: NSPredicate = NSCompoundPredicate(type: .and, subpredicates: [dataPred, mealPred])
        
        fetchRequest.predicate = andPredicate
        
        do {
          return try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
          return []
        }
    }
    
    /**
     Deletes entry in Core Data for Menu Item/Diary Entry
     - Parameter objToDelete: Object to delete
     - Returns: True if success, False if not
    */
    public func deleteItem(objToDelete: NSManagedObject) -> Bool {
        guard let appDelegate: AppDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }
        
        let managedContext: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        managedContext.delete(objToDelete)
        
        do {
            try managedContext.save()
                return true
        }
        catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return false
        }
    }
}
