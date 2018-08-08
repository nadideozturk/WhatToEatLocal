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
import Cloudinary

class OutsideMealViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var outsideMeals = [OutsideMeal]()
    
    var config = CLDConfiguration(cloudName: "dv0qmj6vt", apiKey: "752346693282248")
    var cloudinary:CLDCloudinary! = nil

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cloudinary = CLDCloudinary(configuration: self.config)
        collectionView.dataSource = self
        collectionView.delegate = self
        loadMeals()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return outsideMeals.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "outsideMealCustomCell", for: indexPath) as! OutsideMealCollectionViewCell
        cell.outsideMealNameLbl.text = outsideMeals[indexPath.row].name + " at " + outsideMeals[indexPath.row].restaurantName
        cell.outsideMealImageView.image = #imageLiteral(resourceName: "HolderImage")
        //cell.outsideRestLabel.text = outsideMeals[indexPath.row].restaurantName
        //cell.outsideMealPriceLbl.text = "CDN$ " + String(outsideMeals[indexPath.row].price)
        loadImageForCell(urlStr: outsideMeals[indexPath.row].photoUrl, cell: cell)
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 0.5
        cell.layer.cornerRadius = 5.0// corner radius.addtional
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath as IndexPath)
        self.performSegue(withIdentifier: "showOutsideMealDetailSegue", sender: cell)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showOutsideMealDetailSegue" {
            let detailsVC: OutsideMealDetailViewController = segue.destination as! OutsideMealDetailViewController
            let cell = sender as! OutsideMealCollectionViewCell
            let indexPath = self.collectionView!.indexPath(for: cell)
            detailsVC.meal = outsideMeals[(indexPath?.row)!]
        }
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
    private func loadImageForCell(urlStr: String, cell: OutsideMealCollectionViewCell) {
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
                        cell.outsideMealImageView.image = image
                    }
                }
                catch _ as NSError{
                }
            }

        })
    }
}

