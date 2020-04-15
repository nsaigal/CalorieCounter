//
//  TestData.swift
//  CalorieApp
//
//  Created by Neil Saigal on 4/14/20.
//  Copyright © 2020 AppleInterview. All rights reserved.
//

import UIKit

/**
 Generates various diary entries to test Trends charts
 */
class TestData {
    func generateTestData() {
        var date = Calendar.current.date(byAdding: .day, value: -90, to: Date())
        APICalls().createEntry(calories: 50000, label: "Test", meal: Meal.Breakfast, date: date!)
        
        date = Calendar.current.date(byAdding: .day, value: -120, to: Date())
        APICalls().createEntry(calories: 1000, label: "Test", meal: Meal.Breakfast, date: date!)
        
        date = Calendar.current.date(byAdding: .day, value: -150, to: Date())
        APICalls().createEntry(calories: 250, label: "Test", meal: Meal.Breakfast, date: date!)
    }
}
