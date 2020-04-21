//
//  AddToDiary.swift
//  CalorieApp
//
//  Created by Neil Saigal on 4/14/20.
//  Copyright © 2020 AppleInterview. All rights reserved.
//

import UIKit
import CoreData
import Photos

class AddToDiary: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet var menuTableView: UITableView!
    @IBOutlet var label: UITextField!
    @IBOutlet var calories: UITextField!
    @IBOutlet var meal: UITextField!
    @IBOutlet var quantity: UITextField!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var imageButton: UIButton!
    
    var menuItems: [NSManagedObject] = []
    var mealImages: [UIImage] = Meal.allCases.map {$0.image}
    var pickerData: [String] = Meal.allCases.map {$0.name}
    var defaultMeal: Meal = .Breakfast

    override func viewDidLoad() {

        self.setupPickerView()
        self.makeTextFieldMoveWithKeyboard()
        
        self.calories.delegate = self
        self.label.delegate = self
        self.quantity.delegate = self
        
        
        self.saveButton.formatSaveButton()
        self.imageButton.dashBorder()
        self.imageButton.clipsToBounds = true
                
        self.enableButton()
        
        self.menuTableView.register(
             CustomHeader.nib,
             forHeaderFooterViewReuseIdentifier:
                 CustomHeader.reuseIdentifier
         )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.loadMenuItems()
    }
    
    func loadMenuItems() {
        APICalls().getMenuItems { (items) in
            self.menuItems = items
            self.menuTableView.reloadData()
        }
    }
    
    // UI SETUP
    
    /**
     Configure PickerView for Meal TextField.
    */
    func setupPickerView() {
        let pickerView: UIPickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200))
        pickerView.delegate = self
        pickerView.dataSource = self
        self.meal.inputView = pickerView
        pickerView.selectRow(defaultMeal.index, inComponent: 0, animated: true)
        
        self.setPickerViewLabel()
        self.setupPickerViewToolbar()
    }
    
    /**
     Configure toolbar on UIPickerView.
    */
    func setupPickerViewToolbar() {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([spaceButton, spaceButton, doneButton], animated: true)
        toolbar.isUserInteractionEnabled = true
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        self.meal.inputAccessoryView = toolbar
    }
    
    func setPickerViewLabel() {
        self.meal.text = defaultMeal.name
    }
    
    /**
     Enables/disables Save Button based on TextField inputs.
    */
    func enableButton() {
        self.saveButton.isEnabled = false
        self.saveButton.backgroundColor = .lightGray
        
        if self.quantity.hasText && self.label.hasText && self.calories.hasText {
            if Int(self.quantity.text!) != nil && Int(self.calories.text!) != nil {
                self.saveButton.isEnabled = true
                self.saveButton.backgroundColor = UIColor(red: 0.231, green: 0.39, blue: 0.954, alpha: 1)
            }
        }
    }
    
    // BUTTON CLICKS
    
    /**
     Triggered when Done Button on toolbar is clicked.
    */
    @objc func doneClick() {
        self.meal.resignFirstResponder()
    }
    
    @IBAction func selectImageClick(_ sender: Any) {
        
        let actionSheet: UIAlertController = UIAlertController(title: "Pick Image Source", message: "", preferredStyle: .actionSheet)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        let photoLibraryAction: UIAlertAction = UIAlertAction(title: "Photo Library", style: .default) { action -> Void in
            self.requestPhotoAccess()
        }
        let cameraAction: UIAlertAction = UIAlertAction(title: "Camera", style: .default) { action -> Void in
            self.requestCameraAccess()
        }

        actionSheet.addAction(cancelAction)
        actionSheet.addAction(photoLibraryAction)
        actionSheet.addAction(cameraAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    /**
     Triggered when Close Button is clicked.
    */
    @IBAction func closeClick(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    /**
     Triggered when Save Button is clicked.
    */
    @IBAction func save() {
        
        if let image = self.imageButton.image(for: .normal) {
            if let calories = calories.text,
                let name = label.text,
                let qty = quantity.text {
                
                if let cal = Int(calories),
                    let q = Int(qty) {
                    APICalls().createEntry(calories: cal * q, label: name, meal: defaultMeal, picture: image)
                    
                    DispatchQueue.global(qos: .background).async {

                        HealthKitAPI().requestAuthorization(completion: { (success) in
                            if success {
                                
                                HealthKitAPI().saveCaloriesConsumed(foodLabel: name, calories: Double(cal * q)) { (success) in
                                    if success {
                                        print("Saved to HealthKit")
                                    }
                                    DispatchQueue.main.async {
                                        self.dismiss(animated: true)
                                    }
                                }
                            }
                            else {
                                DispatchQueue.main.async {
                                    self.dismiss(animated: true)
                                }                            }
                        })
                    }
                }
            }
        }
        else {
            if let calories = calories.text,
               let name = label.text,
               let qty = quantity.text {
               
                   if let cal = Int(calories),
                       let q = Int(qty) {
                
                    APICalls().createEntry(calories: cal * q, label: name, meal: defaultMeal)
                    DispatchQueue.global(qos: .background).async {

                        HealthKitAPI().requestAuthorization(completion: { (success) in
                            if success {
                                HealthKitAPI().saveCaloriesConsumed(foodLabel: name, calories: Double(cal * q)) { (success) in
                                    if success {
                                        print("Saved to HealthKit")
                                    }
                                    DispatchQueue.main.async {
                                        self.dismiss(animated: true)
                                    }
                                }
                            }
                            else {
                                DispatchQueue.main.async {
                                    self.dismiss(animated: true)
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    // UITABLEVIEW PROTOCOL METHODS

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //return CustomTodayCell(foodLabel: String, calories: Int, foodImage: Data)
        let cell: CustomTodayCell = tableView.dequeueReusableCell(withIdentifier: "menuItemCell", for: indexPath) as! CustomTodayCell
        
        if let label = menuItems[indexPath.row].value(forKey: "label") as? String {
            cell.label.text = label
        }
        if let calories = menuItems[indexPath.row].value(forKey: "calories") as? Int {
            cell.calories.text = String(calories) + " cal"
        }

        if let imageData = menuItems[indexPath.row].value(forKey: "picture") as? Data {
            cell.icon.image = UIImage(data: imageData)
        }
        else {
            cell.icon.image = Meal.Snacks.image
        }
        
        cell.icon.layer.cornerRadius = 2

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: CustomHeader.reuseIdentifier) as? CustomHeader
        else {
            return UIView()
        }
        if menuItems.count == 0 {
            return UIView()
        }

        view.textLabel?.text = "Or choose from your favorites"
        view.addItemButton.isHidden = true

        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let imageData = menuItems[indexPath.row].value(forKey: "picture") as? Data {
            if let image = UIImage(data: imageData) {
                APICalls().createEntry(calories: menuItems[indexPath.row].value(forKey: "calories") as! Int, label: menuItems[indexPath.row].value(forKey: "label") as! String, meal: defaultMeal, picture: image)
            }
            else {
                APICalls().createEntry(calories: menuItems[indexPath.row].value(forKey: "calories") as! Int, label: menuItems[indexPath.row].value(forKey: "label") as! String, meal: defaultMeal)
            }
        }
        else {
            APICalls().createEntry(calories: menuItems[indexPath.row].value(forKey: "calories") as! Int, label: menuItems[indexPath.row].value(forKey: "label") as! String, meal: defaultMeal)
        }
        
        DispatchQueue.global(qos: .background).async {
            HealthKitAPI().requestAuthorization(completion: { (success) in
                if success {
                    HealthKitAPI().saveCaloriesConsumed(foodLabel: self.menuItems[indexPath.row].value(forKey: "label") as! String, calories: Double(self.menuItems[indexPath.row].value(forKey: "calories") as! Int)) { (success) in
                        
                        DispatchQueue.main.async {
                            if success {
                                print("Saved to HealthKit")
                            }
                            self.dismiss(animated: true)
                        }
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                }
            })
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    // UIPICKERVIEW PROTOCOL METHODS
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.meal.text = self.pickerData[row]
        self.defaultMeal = Meal.allCases[row]
    }
    
    // UITEXTFIELD PROTOCOL METHODS
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        enableButton()
    }
    
    // UIIMAGEPICKER PROTOCOL METHODS
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        self.imageButton.setImage(image, for: .normal)
    }
}

