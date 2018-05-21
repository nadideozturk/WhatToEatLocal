//
//  SecondViewController.swift
//  WhatToEatLocal
//
//  Created by Engin Oruc Ozturk on 13.01.2018.
//  Copyright © 2018 NadideOzturk. All rights reserved.
//

import UIKit
import os.log
import GoogleSignIn

class OutsideMealViewController: UIViewController, UICollectionViewDataSource {
    
    var outsideMeals = [OutsideMeal]()

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        loadMeals()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return outsideMeals.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "outsideMealCustomCell", for: indexPath) as! OutsideMealCollectionViewCell
        cell.outsideMealNameLbl.text = outsideMeals[indexPath.row].name
        cell.outsideRestLabel.text = outsideMeals[indexPath.row].restaurantName
        cell.outsideMealPriceLbl.text = "CDN$ " + String(outsideMeals[indexPath.row].price)
        cell.outsideMealImageView.image = #imageLiteral(resourceName: "Meal3")
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 0.5
        cell.layer.cornerRadius = 5.0//if you want corner radius.addtional
        return cell
    }
    
    // MARK: Private methods
    
    private func loadMeals(){
        let urlComponents = BackendConfig.getUrl(path: "/outsidemeals")
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        // Specify this request as being a GET method
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // Make sure that we include headers specifying that our request's HTTP body
        // will be JSON encoded
        var headers = request.allHTTPHeaderFields ?? [:]
        let token = GIDSignIn.sharedInstance().currentUser?.authentication?.idToken
        headers["Authorization"] = token
        request.allHTTPHeaderFields = headers
        // Create and run a URLSession data task with our JSON encoded POST request
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else {
                return
            }
            // APIs usually respond with the data you just sent in your POST request
            if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
                print("response: ", utf8Representation)
                print(data)
                let status = (response as! HTTPURLResponse).statusCode
                if(status == 401){
                    return
                }
                do {
                    self.outsideMeals = try JSONDecoder().decode([OutsideMeal].self, from: data)
                    DispatchQueue.main.async {
                        //self.tableView.reloadData()
                        self.collectionView.reloadData()
                    }
                    return
                } catch let jsonErr {
                    os_log("Error serializing json:", log: OSLog.default, type: .debug)
                    fatalError("Error serializing json:" + jsonErr.localizedDescription)
                }
            } else {
                print("no readable data received in response")
            }
        }
        task.resume()
    }
    @IBAction func unwindToOutsideMealList(sender: UIStoryboardSegue) {
        loadMeals()
    }
}

