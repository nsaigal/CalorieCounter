//
//  AddToMenu.swift
//  CalorieApp
//
//  Created by Neil Saigal on 4/14/20.
//  Copyright © 2020 AppleInterview. All rights reserved.
//

import UIKit
import CoreData

class AddToMenu: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet var label: UITextField!
    @IBOutlet var calories: UITextField!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var header: UILabel!
    
    @IBOutlet var imageButton: UIButton!
    
    var editManagedObject: NSManagedObject? = nil

    override func viewDidLoad() {
        self.makeTextFieldMoveWithKeyboard()
        self.saveButton.formatSaveButton()
        self.enableButton()
        self.imageButton.dashBorder()
        self.imageButton.clipsToBounds = true
        
        self.calories.delegate = self
        self.label.delegate = self
        
        if let obj = editManagedObject {
            header.text = "Edit Menu Item"
            
            label.text = obj.value(forKey: "label") as? String
            
            calories.text = String(obj.value(forKey: "calories") as! Int) + " cal"
            
            if let imageData = obj.value(forKey: "picture") as? Data {
                imageButton.setTitle("", for: .normal)
                imageButton.setImage(UIImage(data: imageData), for: .normal)
            }
        }
    }
    
    /**
     Enables/disables Save Button depending on TextField inputs.
    */
    func enableButton() {
        self.saveButton.isEnabled = false
        self.saveButton.backgroundColor = .lightGray
        
        if self.label.hasText && self.calories.hasText {
            if Int(self.calories.text!) != nil {
                self.saveButton.isEnabled = true
                self.saveButton.backgroundColor = UIColor(red: 0.231, green: 0.39, blue: 0.954, alpha: 1)
            }
        }
    }
    
    // UITEXTFIELD PROTOCOL METHODS
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        enableButton()
    }
    
    /**
     Triggered when Select Image button is clicked.
    */
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

        if let obj = editManagedObject {
            if let image = self.imageButton.image(for: .normal),
                let name = self.label.text,
                let cal = calories.text {
                
                if let calInt = Int(cal.replacingOccurrences(of: " cal", with: "")) {
                    APICalls().updateMenuEntry(calories: calInt, label: name, picture: image, object: obj)
                    self.dismiss(animated: true)
                }
            }
            else {
                
            }
        }
        else {
            if let image = self.imageButton.image(for: .normal),
            let name = self.label.text,
            let cal = calories.text {
                if let calInt = Int(cal.replacingOccurrences(of: " cal", with: "")) {
                    APICalls().createEntry(calories: calInt, label: name, picture: image)
                    self.dismiss(animated: true)

                }
            }
            else if let name = self.label.text,
                let cal = calories.text {
                if let calInt = Int(cal.replacingOccurrences(of: " cal", with: "")) {
                    APICalls().createEntry(calories: calInt, label: name)
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    // UIIMAGEPICKER PROTOCOL METHODS
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }

        self.imageButton.setImage(image, for: .normal)
        imageButton.setTitle("", for: .normal)
    }
}
