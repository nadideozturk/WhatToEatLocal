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

class HomemadeMealViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {

    private var homemadeMeals = [HomemadeMeal]()
    private var filteredHomemadeMeals: [HomemadeMeal] = []
    private var isFiltering: Bool = false
    
    private func getHomemadeMeals() -> [HomemadeMeal] {
        return isFiltering ? filteredHomemadeMeals : homemadeMeals
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadMeals()
    }
    
    func setup() {
        searchBarTopConstraint.constant = 0.0
        collectionView.addObserver(self, forKeyPath: "contentOffset", options: [.new, .old], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keypath = keyPath, keypath == "contentOffset", let collectionView = object as? UICollectionView {
            searchBarTopConstraint.constant = -1 * collectionView.contentOffset.y
        }
    }
    
    deinit {
        collectionView.removeObserver(self, forKeyPath: "contentOffset")
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
        let meal = getHomemadeMeals()[indexPath.row];
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homemadeMealCustomCell", for: indexPath) as! HomemadeMealCollectionViewCell
        cell.hmMealNameLabel.text = meal.name
        cell.hmMealImageView.image = #imageLiteral(resourceName: "HolderImage")
        CloudinaryClient.setImageViewImageAsync(imageView: cell.hmMealImageView, imageUrl: meal.photoUrl)
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 0.5
        cell.layer.cornerRadius = 5.0 // corner radius.addtional
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath as IndexPath)
        self.performSegue(withIdentifier: "showHomemadeMealDetailsSegue", sender: cell)
    }
    
    func reloadCollectionViewIfDataChanged(homeMadeMealList: [HomemadeMeal]) {
        if (homeMadeMealList != self.homemadeMeals) {
            self.homemadeMeals = homeMadeMealList
            self.collectionView.reloadData()
        }
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
                    let homeMadeMealList = try JSONDecoder().decode([HomemadeMeal].self, from: data)
                    DispatchQueue.main.async {
                        self.reloadCollectionViewIfDataChanged(homeMadeMealList: homeMadeMealList)
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
    
    // MARK: UISearchBar
    private func closeSearchInput() {
        // Hide keyboard when search button is clicked
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    private func checkSearchCancelled() {
        if !searchBar.text!.isEmpty {
            return
        }
        closeSearchInput()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filter(searchTerm: searchText)
        checkSearchCancelled()
        collectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        checkSearchCancelled()
        self.filter(searchTerm: "")
        collectionView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        closeSearchInput()
    }
}
