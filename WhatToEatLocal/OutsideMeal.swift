//
//  OutsideMeal.swift
//  WhatToEatLocal
//
//  Created by Engin Oruc Ozturk on 24.04.2018.
//  Copyright © 2018 NadideOzturk. All rights reserved.
//

import Foundation
import os.log

class OutsideMeal:Decodable, Encodable {
    
    //MARK: Propeties
    var id: String
    var name: String
    var photoUrl: String
    var price: Double
    var lastEatenDate: String
    var restaurantName: String
    var photoContent: String
    //MARK: Initialization
    init?(id: String, name: String, photoUrl: String, price: Double, lastEatenDate: String, restaurantName: String, photoContent: String){
        //The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        self.name = name
        self.id = id
        self.photoUrl = photoUrl
        self.price = price
        self.lastEatenDate = lastEatenDate
        self.restaurantName = restaurantName
        self.photoContent = photoContent
    }
}
