//
//  DataAccess.swift
//  WhatToEatLocal
//
//  Created by Engin Oruc Ozturk on 20.01.2018.
//  Copyright © 2018 NadideOzturk. All rights reserved.
//

import Foundation
import UIKit
import os.log

class DataAccessSingleton {
    static let sharedDataContainer = DataAccessSingleton()
    // MARK: PROPERTIES
    var meals = [Meal]()
    
    init() {
        //loadMeals()
    }
    
    
    
    private func saveMeals() {
        /*let isSuccessfulSave = true;
        if isSuccessfulSave {
            os_log("Meals successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save meals...", log: OSLog.default, type: .error)
        }*/
    }
    
    private func loadSampleMeals(){
       /* let photo1 = UIImage(named: "Meal1")
        let photo2 = UIImage(named: "Meal2")
        let photo3 = UIImage(named: "Meal3")
        
        guard let meal1 = Meal(ID: "1", name: "Caprese Salad", photo: photo1) else {
            fatalError("Unable to instantiate meal1")
        }
        
        guard let meal2 = Meal(ID: "2", name: "Chicken and Potatoes", photo: photo2) else {
            fatalError("Unable to instantiate meal2")
        }
        
        guard let meal3 = Meal(ID: "3", name: "Pasta with Meatballs", photo: photo3) else {
            fatalError("Unable to instantiate meal2")
        }
        
        meals += [meal1, meal2, meal3] */
    }
}
