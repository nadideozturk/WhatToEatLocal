//
//  Meal.swift
//  WhatToEatLocal
//
//  Created by Engin Oruc Ozturk on 27.01.2018.
//  Copyright © 2018 NadideOzturk. All rights reserved.
//

import UIKit
import os.log

class Meal:Decodable, Encodable {
    
     //MARK: Propeties
    var id: String
    var name: String
    var photoUrl: String
    var durationInMinutes: Int
    //MARK: Initialization
    init?(id: String, name: String, photoUrl: String, durationInMinutes: Int){
        //The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        self.name = name
        self.id = id
        self.photoUrl = photoUrl
        self.durationInMinutes = durationInMinutes
    }
}
