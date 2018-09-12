//
//  OutsideMeal.swift
//  WhatToEatLocal
//
//  Created by Engin Oruc Ozturk on 24.04.2018.
//  Copyright © 2018 NadideOzturk. All rights reserved.
//

import Foundation

class OutsideMeal:Decodable, Encodable, Equatable {
    
    //MARK: Propeties
    var id: String
    var name: String
    var photoUrl: String
    var price: Double
    var lastEatenDate: String
    var restaurantName: String
    var photoContent: String
    var catId: String
    //MARK: Initialization
    init?(id: String, name: String, photoUrl: String, price: Double, lastEatenDate: String, restaurantName: String, photoContent: String, catId: String){
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
        self.catId = catId
    }
    
    static func == (lhs: OutsideMeal, rhs: OutsideMeal) -> Bool {
        return lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.photoUrl == rhs.photoUrl &&
            lhs.price == rhs.price &&
            lhs.lastEatenDate == rhs.lastEatenDate &&
            lhs.restaurantName == rhs.restaurantName &&
            lhs.photoContent == rhs.photoContent &&
            lhs.catId == rhs.catId
    }
}
