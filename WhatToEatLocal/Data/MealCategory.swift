//
//  MealCategory.swift
//  WhatToEatLocal
//
//  Created by Engin Oruc Ozturk on 11.09.2018.
//  Copyright © 2018 NadideOzturk. All rights reserved.
//

import Foundation

class MealCategory {
    public static let mealCategory: [String: String] = ["Breakfast": "1",
                                                  "Main Dish": "2",
                                                  "Side": "3",
                                                  "Appetizer": "4",
                                                  "Dessert": "5",
                                                  "Drink": "6",
                                                  "Snack": "7"]
    
}
extension Dictionary where Value: Equatable {
    func someKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}
