//
//  Menu.swift
//  CalorieApp
//
//  Created by Neil Saigal on 4/14/20.
//  Copyright © 2020 AppleInterview. All rights reserved.
//

import UIKit
import CoreData

class Menu: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var menuTable: UITableView!
    
    var selectedIndex: Int = 0
    var entries: [NSManagedObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.menuTable.setupDarkMode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        APICalls().getMenuItems { (items) in
            self.entries = items
            self.menuTable.reloadData()
        }
    }
    
    // UITABLEVIEW PROTOCOL METHODS
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        self.performSegue(withIdentifier: "toEditMenuItem", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CustomTodayCell = tableView.dequeueReusableCell(withIdentifier: "menuEntryCell", for: indexPath) as! CustomTodayCell

        if let label = entries[indexPath.row].value(forKey: "label") as? String {
            cell.label.text = label
        }
        if let calories = entries[indexPath.row].value(forKey: "calories") as? Int {
            cell.calories.text = String(calories) + " cal"
        }
        
        if let imageData = entries[indexPath.row].value(forKey: "picture") as? Data {
            cell.icon.image = UIImage(data: imageData)
        }
        else {
            cell.icon.image = Meal.Snacks.image
        }
        
        cell.icon.layer.cornerRadius = 2
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            if APICalls().deleteItem(objToDelete: entries[indexPath.row]) {
                entries.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditMenuItem" {
            if let dest: AddToMenu = segue.destination as? AddToMenu {
                dest.editManagedObject = entries[selectedIndex]
            }
        }
    }
}
