//
//  Extentions.swift
//  CalorieApp
//
//  Created by Neil Saigal on 4/14/20.
//  Copyright © 2020 AppleInterview. All rights reserved.
//

import UIKit
import Photos

extension UIViewController {
    
    /**
     Moves view up when keyboard is present in order to not block the TextField while typing.
    */
    func makeTextFieldMoveWithKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        self.view.frame.origin.y = -100
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    /**
     Request access and present Photo Library.
    */
    func requestPhotoAccess() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            self.presentPhotos(sourceType: .photoLibrary)
        
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization( { granted in
                if granted == .authorized {
                    self.presentPhotos(sourceType: .photoLibrary)
                }
            })
        
        case .denied:
            return

        case .restricted:
            return
        default:
            return
        }
    }
    
    /**
     Request access and present camera.
    */
    func requestCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.presentPhotos(sourceType: .camera)

        
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted) in
                if granted {
                    self.presentPhotos(sourceType: .camera)
                }
            })
        
        case .denied:
            return

        case .restricted:
            return
        default:
            return
        }
    }
    
    /**
     Present camera/photo library.
    */
    func presentPhotos(sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let vc: UIImagePickerController = UIImagePickerController()
            vc.sourceType = sourceType
            vc.allowsEditing = true
            if let delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate {
                vc.delegate = delegate
            }
            self.present(vc, animated: true)
        }
    }
}

extension UIButton {
    /**
     Configure Save Button in Add To screens.
    */
    func formatSaveButton() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 20
        self.backgroundColor = UIColor(red: 0.231, green: 0.39, blue: 0.954, alpha: 1)
        self.setTitleColor(.white, for: .normal)
    }
    /**
     Configure border around Select Image button in Add To screens.
    */
    func dashBorder() {
        let yourViewBorder: CAShapeLayer = CAShapeLayer()
        yourViewBorder.strokeColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        yourViewBorder.lineDashPattern = [5, 5]
        yourViewBorder.frame = self.bounds
        yourViewBorder.fillColor = nil
        yourViewBorder.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 5).cgPath
        self.layer.addSublayer(yourViewBorder)
    }
}

extension UITableView {
    /**
     Sets tableview background for light/dark modes.
    */
    func setupDarkMode() {
        if self.traitCollection.userInterfaceStyle == .dark {
            self.backgroundColor = .clear
        }
        else {
            self.backgroundColor = UIColor.groupTableViewBackground.withAlphaComponent(0.50)
        }
    }
}

extension Date {
    /**
     Gets date format M/d (e.g. 12-31)
    */
    func getMonthDay() -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d"
        return dateFormatter.string(from: self)
    }
    
    /**
     Gets date format EEE  (e.g. Monday)
    */
    func getDayOfWeek() -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        return String(dateFormatter.string(from: self).prefix(3))
    }
    
    /**
     Gets date format LLLL (e.g. January)
    */
    func getMonthName() -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        return String(dateFormatter.string(from: self).prefix(3))
    }
    
    /**
     Gets first of the month of the given date
    */
    func getFirstOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    /**
     Gets midnight of the given date
    */
    func getStartOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    /**
     Gets minute before given date
    */
    func getMinuteBefore() -> Date {
        return Calendar.current.date(byAdding: .minute, value: -1, to: self)!
    }
    
    /**
     Gets minute after given date
    */
    func getMinuteAfter() -> Date {
        return Calendar.current.date(byAdding: .minute, value: 1, to: self)!
    }
    
    /**
     Gets tomorrow in reference to given date
    */
    func getTomorrow() -> Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }
    
    /**
     Gets last Sunday in reference to given date
    */
    func getLastSunday() -> Date {
        var component = Calendar.current.dateComponents([.weekOfYear, .yearForWeekOfYear], from: self)
        component.weekday = 1
        
        return Calendar.current.date(from: component)!
    }
}
