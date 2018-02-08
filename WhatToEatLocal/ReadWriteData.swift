//
//  ReadWriteData.swift
//  WhatToEatLocal
//
//  Created by Engin Oruc Ozturk on 6.02.2018.
//  Copyright © 2018 NadideOzturk. All rights reserved.
//

import Foundation
import os.log

class ReadWriteData {
    
    
    
    //MARK: Private Methods
    public func loadMeals()  {
        guard let url = URL(string: "http://localhost:8080/homemademeals") else {
            return
        }
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            if let data = data {
                print(data)
                do {
                    DataAccessSingleton.sharedDataContainer.meals = try JSONDecoder().decode([Meal].self, from: data)
                    let x = DataAccessSingleton.sharedDataContainer.meals.count
                    return
                } catch let jsonErr {
                    //print("Error serializing json:", jsonErr)
                    os_log("Error serializing json:", log: OSLog.default, type: .debug)
                    fatalError("Error serializing json:" + jsonErr.localizedDescription)
                }
            }
             }.resume()
        
    }
}
