//
//  Meal.swift
//  WhatToEatLocal
//
//  Created by Engin Oruc Ozturk on 27.01.2018.
//  Copyright © 2018 NadideOzturk. All rights reserved.
//

import UIKit
import os.log

class Meal: NSObject, NSCoding {
    
     //MARK: Propeties
    var ID: String
    var name: String
    var photo: UIImage?
    //MARK Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meals")
    
    //MARK: TYPES
    struct PropertyKey {
        static let ID = "ID"
        static let name = "name"
        static let photo = "photo"
    }
    //MARK: Initialization
    init?(ID: String, name: String, photo: UIImage?){
        
        // The ID must not be empty
        guard !ID.isEmpty else {
            return nil
        }
        
        //The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        self.name = name
        self.ID = ID
        self.photo = photo
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(photo, forKey: PropertyKey.photo)
        aCoder.encode(ID, forKey: PropertyKey.ID)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The ID is required. If we cannot decode a ID string, the initializer should fail.
        guard let ID = aDecoder.decodeObject(forKey: PropertyKey.ID) as? String else {
            os_log("Unable to decode the ID for a Meal object.",log:OSLog.default,type: .debug)
            return nil
        }
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }
        // Because photo is an optional property of Meal, just use conditional cast.
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
        // Must call designated initializer.
        self.init(ID: ID, name: name, photo: photo)
    }
    
   
}
