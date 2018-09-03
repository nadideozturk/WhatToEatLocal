//
//  HomemadeMealViewController.swift
//  WhatToEatLocal
//
//  Created by Engin Oruc Ozturk on 6.02.2018.
//  Copyright © 2018 NadideOzturk. All rights reserved.
//

import UIKit
import os.log
import GoogleSignIn
import Cloudinary

class HomemadeMealViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {

    private var homemadeMeals = [HomemadeMeal]()
    private var filteredHomemadeMeals: [HomemadeMeal] = []
    private var isFiltering: Bool = false
    
    private func getHomemadeMeals() -> [HomemadeMeal] {
        return isFiltering ? filteredHomemadeMeals : homemadeMeals
    }
    
    var config = CLDConfiguration(cloudName: "dv0qmj6vt", apiKey: "752346693282248")
    var cloudinary:CLDCloudinary! = nil
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cloudinary = CLDCloudinary(configuration: self.config)
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
        loadMeals()
    }
    
    func filter(searchTerm: String) {
        if searchTerm.isEmpty {
            isFiltering = false
            filteredHomemadeMeals.removeAll()
            return
        }
        
        isFiltering = true
        filteredHomemadeMeals = homemadeMeals.filter({
             return $0.name.localizedCaseInsensitiveContains(searchTerm)
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getHomemadeMeals().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homemadeMealCustomCell", for: indexPath) as! HomemadeMealCollectionViewCell
        cell.hmMealNameLabel.text = getHomemadeMeals()[indexPath.row].name
        cell.hmMealImageView.image = #imageLiteral(resourceName: "HolderImage")
        loadImageForCell(urlStr: getHomemadeMeals()[indexPath.row].photoUrl, cell: cell)
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 0.5
        cell.layer.cornerRadius = 5.0 // corner radius.addtional
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath as IndexPath)
        self.performSegue(withIdentifier: "showHomemadeMealDetailsSegue", sender: cell)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showHomemadeMealDetailsSegue" {
            let detailsVC: HomemadeMealDetailViewController = segue.destination as! HomemadeMealDetailViewController
            let cell = sender as! HomemadeMealCollectionViewCell
            let indexPath = self.collectionView!.indexPath(for: cell)
            detailsVC.meal = getHomemadeMeals()[(indexPath?.row)!]
        }
    }
    
    // MARK: Private methods
    
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
                    self.homemadeMeals = try JSONDecoder().decode([HomemadeMeal].self, from: data)
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
    
    // MARK: UISearchBar
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchBar.showsCancelButton = false
        }
        self.filter(searchTerm: searchText)
        collectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.filter(searchTerm: "")
        collectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Hide keyboard when search button is clicked
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }
}
