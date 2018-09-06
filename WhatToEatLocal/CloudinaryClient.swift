//
//  CloudinaryClient.swift
//  WhatToEatLocal
//
//  Created by Engin Oruc Ozturk on 5.09.2018.
//  Copyright © 2018 NadideOzturk. All rights reserved.
//

import Foundation
import Cloudinary

class CloudinaryClient {
    
    public static let cloudinary:CLDCloudinary = CLDCloudinary(configuration: config)
    
    private static let config = CLDConfiguration(cloudName: "dv0qmj6vt", apiKey: "752346693282248")
    
}
