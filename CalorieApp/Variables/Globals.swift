//
//  Globals.swift
//  CalorieApp
//
//  Created by Neil Saigal on 4/14/20.
//  Copyright © 2020 AppleInterview. All rights reserved.
//

import UIKit

enum Meal: CaseIterable {
    case Breakfast
    case Lunch
    case Dinner
    case Snacks
    
    var image: UIImage {
        switch self {
        case .Breakfast: return UIImage(named: "breakfast")!
        case .Lunch: return UIImage(named: "lunch")!
        case .Dinner: return UIImage(named: "dinner")!
        case .Snacks: return UIImage(named: "snacks")!
        }
    }

    var name: String {
        switch self {
        case .Breakfast: return "Breakfast"
        case .Lunch: return "Lunch"
        case .Dinner: return "Dinner"
        case .Snacks: return "Snacks"
        }
    }
    
    var index: Int {
        switch self {
        case .Breakfast: return 0
        case .Lunch: return 1
        case .Dinner: return 2
        case .Snacks: return 3
        }
    }
}
