//
//  MealTableViewController.swift
//  WhatToEatLocal
//
//  Created by Engin Oruc Ozturk on 6.02.2018.
//  Copyright © 2018 NadideOzturk. All rights reserved.
//

import UIKit
import os.log
import GoogleSignIn
import Cloudinary

class HomemadeMealCollectionView: UICollectionViewController {

    var meals = [Meal]()
    var config = CLDConfiguration(cloudName: "dv0qmj6vt", apiKey: "752346693282248")
    var cloudinary:CLDCloudinary! = nil
    
    @IBOutlet var homemadeMealCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cloudinary = CLDCloudinary(configuration: self.config)
        homemadeMealCollection.dataSource = self
        loadMeals()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return meals.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = homemadeMealCollection.dequeueReusableCell(withReuseIdentifier: "homemadeMealCustomCell", for: indexPath) as! HomemadeMealCollectionViewCell
        cell.hmMealNameLabel.text = meals[indexPath.row].name
        cell.hmMealImageView.image = #imageLiteral(resourceName: "HolderImage")
        loadImageForCell(urlStr: meals[indexPath.row].photoUrl, cell: cell)
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 0.5
        cell.layer.cornerRadius = 5.0// corner radius.addtional
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath as IndexPath)
        self.performSegue(withIdentifier: "showHomemadeMealDetailsSegue", sender: cell)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showHomemadeMealDetailsSegue" {
            //let detailsVC: HomemadeMealDetailViewController = segue.destination as! HomemadeMealDetailViewController
            let navController: UINavigationController = segue.destination as! UINavigationController
            let detailsVC: HomemadeMealDetailViewController = navController.topViewController as! HomemadeMealDetailViewController
            //let detailsVC: HomemadeMealDetailViewController = navController. as! HomemadeMealDetailViewController
            let cell = sender as! HomemadeMealCollectionViewCell
            let indexPath = self.collectionView!.indexPath(for: cell)
            detailsVC.meal = meals[(indexPath?.row)!]
        }
    }
    /*
    private func loadMealsT(){
        //guard let url = URL(string: "http://ec2-34-209-47-4.us-west-2.compute.amazonaws.com:8080/homemademeals") else {
         guard let url = URL(string: "http://192.168.1.9:8080/homemademeals") else {
            return
        }
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            if let data = data {
                print(data)
                let status = (response as! HTTPURLResponse).statusCode
                if(status == 401){
                    return
                }
                do {
                    self.meals = try JSONDecoder().decode([Meal].self, from: data)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    return
                } catch let jsonErr {
                    os_log("Error serializing json:", log: OSLog.default, type: .debug)
                    fatalError("Error serializing json:" + jsonErr.localizedDescription)
                }
            }
            }.resume()
    } */
    private func loadMeals(){
        let urlComponents = BackendConfig.getUrl(path: "/homemademeals")
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
                    self.meals = try JSONDecoder().decode([Meal].self, from: data)
                    DispatchQueue.main.async {
                        //self.tableView.reloadData()
                        self.homemadeMealCollection.reloadData()
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
    
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        loadMeals()
    }
    private func loadImageForCell(urlStr: String, cell: HomemadeMealCollectionViewCell) {
        let url = URL(string: urlStr)
        self.cloudinary.createDownloader().fetchImage(urlStr, nil, completionHandler: { (result,error) in
            if let error = error {
                print("Error downloading image %@", error)
            }
            else {
                print("Image downloaded from Cloudinary successfully")
                do{
                    let data = try Data(contentsOf: url!)
                    var image: UIImage?
                    image = UIImage(data: data)
                    DispatchQueue.main.async {
                        cell.hmMealImageView.image = image
                    }
                }
                catch _ as NSError{
                }
            }
            
        })
    }
}
