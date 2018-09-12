//
//  Meal.swift
//  WhatToEatLocal
//
//  Created by Engin Oruc Ozturk on 27.01.2018.
//  Copyright © 2018 NadideOzturk. All rights reserved.
//

import UIKit
import os.log

class HomemadeMeal:Decodable, Encodable, Equatable {
    
     //MARK: Propeties
    var id: String
    var name: String
    var photoUrl: String
    var durationInMinutes: Int
    var lastEatenDate: String
    var photoContent: String
    var catId: String
    //MARK: Initialization
    init?(id: String, name: String, photoUrl: String, durationInMinutes: Int, lastEatenDate: String, photoContent: String, catId: String){
        //The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        self.name = name
        self.id = id
        self.photoUrl = photoUrl
        self.durationInMinutes = durationInMinutes
        self.lastEatenDate = lastEatenDate
        self.photoContent = photoContent
        self.catId = catId
    }
    
    static func == (lhs: HomemadeMeal, rhs: HomemadeMeal) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.photoUrl == rhs.photoUrl &&
        lhs.durationInMinutes == rhs.durationInMinutes &&
        lhs.lastEatenDate == rhs.lastEatenDate &&
        lhs.photoContent == rhs.photoContent &&
        lhs.catId == rhs.catId
    }
}
