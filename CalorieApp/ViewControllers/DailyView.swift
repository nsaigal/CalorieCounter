//
//  ViewController.swift
//  CalorieApp
//
//  Created by Neil Saigal on 4/14/20.
//  Copyright © 2020 AppleInterview. All rights reserved.
//

import UIKit
import CoreData
import CareKitUI

class DailyView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var diaryTable: UITableView!
    @IBOutlet var calorieLabel: UILabel!
    
    var selectedMealToAdd: Meal = .Breakfast
    var totalCalories: Int = 0
    
    var mealArrays: [[NSManagedObject]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        self.diaryTable.setupDarkMode()
        
        self.diaryTable.register(
            CustomHeader.nib,
            forHeaderFooterViewReuseIdentifier:
                CustomHeader.reuseIdentifier
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.populateTableView()
    }
    
    /**
     Retrieves daily log from Core Data.
    */
    func populateTableView() {
        let breakfastEntries: [NSManagedObject] = APICalls().getDiary(meal: 0)
        let lunchEntries: [NSManagedObject] = APICalls().getDiary(meal: 1)
        let dinnerEntries: [NSManagedObject] = APICalls().getDiary(meal: 2)
        let snackEntries: [NSManagedObject] = APICalls().getDiary(meal: 3)
        self.mealArrays = [breakfastEntries, lunchEntries, dinnerEntries, snackEntries]
        
        self.calculateTotal()
        diaryTable.reloadData()
    }
    
    /**
     Adds up total calories from daily log.
    */
    func calculateTotal() {
        totalCalories = 0
        
        for arr in self.mealArrays {
            for data in arr {
                if let calories = data.value(forKey: "calories") as? Int {
                    totalCalories += calories
                }
            }
        }
        
        calorieLabel.text = String(totalCalories) + " cal"
    }
    
    /**
     Triggered when Add Item button is clicked.
    */
    @objc func addClick(sender: UIButton) {
        selectedMealToAdd = Meal.allCases[sender.tag]
        
        self.performSegue(withIdentifier: "toAddScreen", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddScreen" {
            if let dest = segue.destination as? AddToDiary {
                dest.defaultMeal = self.selectedMealToAdd
            }
        }
    }
    
    // UITABLEVIEW PROTOCOL METHODS

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mealArrays[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: CustomHeader.reuseIdentifier) as? CustomHeader
        else {
            return UIView()
        }
        
        view.textLabel?.text = Meal.allCases[section].name
        
        view.addItemButton.addTarget(self, action: #selector(addClick), for: .touchUpInside)
        view.addItemButton.tag = section

        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CustomTodayCell = tableView.dequeueReusableCell(withIdentifier: "diaryEntryCell", for: indexPath) as! CustomTodayCell
        let diaryEntries: [NSManagedObject] = self.mealArrays[indexPath.section]
        cell.icon.image = Meal.allCases[indexPath.section].image
        cell.icon.layer.cornerRadius = 2

        if let imageData = diaryEntries[indexPath.row].value(forKey: "picture") as? Data {
            cell.icon.image = UIImage(data: imageData)
        }
        
        if let label = diaryEntries[indexPath.row].value(forKey: "label") as? String {
            cell.label.text = label
        }
        
        if let calories = diaryEntries[indexPath.row].value(forKey: "calories") as? Int {
            cell.calories.text = String(calories) + " cal"
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            let creationDate: Date = self.mealArrays[indexPath.section][indexPath.row].value(forKey: "date") as! Date
            
            if APICalls().deleteItem(objToDelete: self.mealArrays[indexPath.section][indexPath.row]) {
                self.mealArrays[indexPath.section].remove(at: indexPath.row)
                
                self.calculateTotal()
                
                self.diaryTable.deleteRows(at: [indexPath], with: .fade)
            }
            
            DispatchQueue.global(qos: .background).async {
                HealthKitAPI().requestAuthorization(completion: { (success) in
                    if success {
                        HealthKitAPI().deleteCalorieEntries(from: creationDate.getMinuteBefore(), to: creationDate.getMinuteAfter()) { (success) in
                        }
                    }
                })
            }
        }
    }
}
