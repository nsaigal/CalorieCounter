//
//  CustomHeader.swift
//  CalorieApp
//
//  Created by Neil Saigal on 4/14/20.
//  Copyright © 2020 AppleInterview. All rights reserved.
//

import UIKit

/**
 Initializes CustomHeader.xib file
 */
class CustomHeader: UITableViewHeaderFooterView {
    static let reuseIdentifier: String = String(describing: self)
    
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
    
    @IBOutlet override var textLabel: UILabel? {
        get { return _textLabel }
        set { _textLabel = newValue }
    }
    
    private var _textLabel: UILabel?
    
    @IBOutlet var addItemButton: UIButton!
}
