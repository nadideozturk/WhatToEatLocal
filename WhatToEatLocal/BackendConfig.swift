//
//  BackendConfig.swift
//  WhatToEatLocal
//
//  Created by Engin Oruc Ozturk on 23.04.2018.
//  Copyright © 2018 NadideOzturk. All rights reserved.
//

import Foundation
class BackendConfig {
    //static var hostLocal: String = "192.168.1.9"
    static func getUrl(path: String) -> URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        //urlComponents.host = "ec2-34-209-47-4.us-west-2.compute.amazonaws.com"
        urlComponents.host = "192.168.1.9"
        urlComponents.port = 8080
        urlComponents.path = path
        return urlComponents
    }
    
}
