//
//  HealthKitCalls.swift
//  CalorieApp
//
//  Created by Neil Saigal on 4/14/20.
//  Copyright © 2020 AppleInterview. All rights reserved.
//

import UIKit
import HealthKit
import CoreData

class HealthKitAPI {
    
    let healthStore: HKHealthStore = HKHealthStore()
    
    /**
    Requests user authorization to access HealthKit data
    - Returns: True if success, False if not
     */
    func requestAuthorization(completion: @escaping (_ success: Bool) -> Void) {
        let writeDataTypes : Set = [HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!]
        
        let readDataTypes : Set = [HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!, HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!, HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!]
        
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }
        
        healthStore.requestAuthorization(toShare: writeDataTypes, read: readDataTypes) { (success, error) in
            completion(success)
        }
    }
    
    /**
     Gets Active and Basal calories burned from HealthKit
     - Parameter from: start timestamp of query
     - Parameter to: end timestamp of query
     - Returns: Calories: double
    */
    func getCaloriesBurned(from: Date, to: Date, completion: @escaping (_ calories: Double) -> Void) {
        let group = DispatchGroup()
        
        var activeCalories = 0.0
        var restingCalories = 0.0
        
        group.enter()
        self.getActiveCaloriesBurned(from: from, to: to) { (activeCals) in
           activeCalories = activeCals
           group.leave()
        }
        
        group.enter()
        self.getBasalCaloriesBurned(from: from, to: to) { (basalCals) in
           restingCalories = basalCals
           group.leave()
       }

        group.wait()
        group.notify(queue: DispatchQueue.main) {
            completion(activeCalories + restingCalories)
        }
    }
    
    /**
     Gets Basal calories burned from HealthKit
     - Parameter from: start timestamp of query
     - Parameter to: end timestamp of query
     - Returns: Calories: double
    */
    func getBasalCaloriesBurned(from: Date, to: Date, completion: @escaping (_ calories: Double) -> Void) {

        let predicate = HKQuery.predicateForSamples(withStart: from, end: to, options: [])

        let basalEnergyBurned = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.basalEnergyBurned)
       
        var interval = DateComponents()
        interval.day = 1
        
        let query = HKStatisticsQuery(quantityType: basalEnergyBurned!, quantitySamplePredicate: predicate, options: .cumulativeSum) { (query, results, error) in
            if error != nil {
                print(error as Any)
                return
            }

            if let myResults = results {

                if let quantity = myResults.sumQuantity() {

                    let cals = quantity.doubleValue(for: HKUnit.kilocalorie())
                    completion(cals)
                    
                }
                else {
                    completion(0)
                }
            }
            else {
                completion(0)
            }
        }

        self.healthStore.execute(query)
    }
    
    /**
     Gets Active calories burned from HealthKit
     - Parameter from: start timestamp of query
     - Parameter to: end timestamp of query
     - Returns: Calories: double
    */
    func getActiveCaloriesBurned(from: Date, to: Date, completion: @escaping (_ calories: Double) -> Void) {

        let predicate = HKQuery.predicateForSamples(withStart: from, end: to, options: [])

        let activeEnergyBurned = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)
            var interval = DateComponents()
            interval.day = 1
            
        let query = HKStatisticsQuery(quantityType: activeEnergyBurned!, quantitySamplePredicate: predicate, options: .cumulativeSum) { (query, results, error) in
                if error != nil {
                    print(error as Any)
                    return
                }

                if let myResults = results {

                    if let quantity = myResults.sumQuantity() {

                        let cals = quantity.doubleValue(for: HKUnit.kilocalorie())
                        completion(cals)
                        
                    }
                    else {
                        completion(0)
                    }
                }
                else {
                    completion(0)
                }
            }

        self.healthStore.execute(query)
    }
    
    /**
     Gets consumed calories burned from HealthKit
     - Parameter from: start timestamp of query
     - Parameter to: end timestamp of query
     - Returns: Calories: double
    */
    func getConsumedCalories(from: Date, to: Date, completion: @escaping (_ calories: Double) -> Void) {

        let predicate = HKQuery.predicateForSamples(withStart: from, end: to, options: [])

        let dietaryEnergyConsumed = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryEnergyConsumed)
            var interval = DateComponents()
            interval.day = 1
            
        let query = HKStatisticsQuery(quantityType: dietaryEnergyConsumed!, quantitySamplePredicate: predicate, options: .cumulativeSum) { (query, results, error) in
                if error != nil {
                    print(error as Any)
                    return
                }

                if let myResults = results {

                    if let quantity = myResults.sumQuantity() {

                        let cals = quantity.doubleValue(for: HKUnit.kilocalorie())
                        completion(cals)
                        
                    }
                    else {
                        completion(0)
                    }
                }
                else {
                    completion(0)
                }
            }

        self.healthStore.execute(query)
    }
    
    /**
     Saves diary entry into HealthKit "Dietary Energy" data
     - Parameter foodLabel: name of food for metadata
     - Parameter calories: calorie amount of food
     - Returns: True if successful, False if not
    */
    func saveCaloriesConsumed(foodLabel: String, calories: Double, completion: @escaping (_ success: Bool) -> Void) {
        let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryEnergyConsumed)
        
        let metadata = [HKMetadataKeyFoodType:foodLabel]
        
        let caloriesConsumed = HKQuantitySample.init(type: quantityType!, quantity: HKQuantity.init(unit: HKUnit.kilocalorie(), doubleValue: calories), start: Date(), end: Date(), metadata: metadata)
        
        healthStore.save(caloriesConsumed) { success, error in
            if (error != nil) {
                print("Error: \(String(describing: error))")
                completion(false)
            }
            if success {
                completion(true)
            }
        }
    }
    
    /**
     Deletes diary entries from HealthKit
     - Parameter from: start timestamp of query
     - Parameter to: end timestamp of query
     - Returns: True if successful, False if not
    */
    func deleteCalorieEntries(from: Date, to:Date, completion: @escaping (_ success: Bool) -> Void) {
                
        let predicate = HKQuery.predicateForSamples(withStart: from, end: to, options: [])

        let dietary = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryEnergyConsumed)
        
        let dietaryQuery = HKSampleQuery(sampleType: dietary!, predicate:predicate, limit: 1, sortDescriptors: nil) { query, results, error in

            if results!.count > 0
            {
                for result in results as! [HKQuantitySample]
                {
                    self.healthStore.delete(result) { (success, error) in
                        print("Deleted from HealthKit")
                        completion(true)
                    }
                }
                completion(false)
            }
            else {
                completion(false)
            }
        }
        self.healthStore.execute(dietaryQuery)
    }
}
