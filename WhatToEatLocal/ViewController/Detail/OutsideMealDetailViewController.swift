//
//  OutsideMealDetailViewController.swift
//  WhatToEatLocal
//
//  Created by Engin Oruc Ozturk on 5.08.2018.
//  Copyright © 2018 NadideOzturk. All rights reserved.
//

import UIKit
import GoogleSignIn
import os.log

class OutsideMealDetailViewController: UIViewController {
    
    // MARK: - Properties
    var  meal:OutsideMeal? = nil
    
    @IBOutlet weak var lblOutsideMealName: UILabel!
    
    @IBOutlet weak var lblOutsideMealPrice: UILabel!
    
    @IBOutlet weak var lblOutsideMealDate: UILabel!
    
    @IBOutlet weak var imgViewerOutsideMeal: UIImageView!
    
    @IBAction func editBtnClicked(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "showOutsideMealEditSegue", sender: UIBarButtonItem.self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUIComponentsData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showOutsideMealEditSegue" {
            let editVC: OutsideMealEditViewController = segue.destination as! OutsideMealEditViewController
            editVC.meal = self.meal
        }
    }
    
    @IBAction func unwindToOutsideMealDetail(segue:UIStoryboardSegue) {
        loadOutsideMealById()
    }
    
    // MARK: - Private Functions
    
    func setUIComponentsData(){
        if meal != nil {
            lblOutsideMealName.text = (meal?.name.capitalized)! + " at " + (meal?.restaurantName.capitalized)!
            let price:String = String(format:"%.2f", (meal?.price)!)
            lblOutsideMealPrice.text = price  + " CDN"
            lblOutsideMealDate.text = calculatetimePassed(lastEatenDate: (meal?.lastEatenDate)!)
            imgViewerOutsideMeal.image = #imageLiteral(resourceName: "HolderImage")
            CloudinaryClient.setImageViewImageAsync(imageView: imgViewerOutsideMeal, imageUrl: meal!.photoUrl)
        }
    }
    
    func calculatetimePassed(lastEatenDate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let aDate = dateFormatter.date(from: lastEatenDate)
        let timeInterval = aDate?.timeIntervalSinceNow
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.unitsStyle = .full
        dateComponentsFormatter.allowedUnits = [.year, .month, .weekOfMonth, .day]
        let dateString = dateComponentsFormatter.string(from: abs(timeInterval!))
        let strDate:String = (dateString?.uppercased())! + " AGO"
        return strDate
    }
    func loadOutsideMealById() {
        let urlComponents = BackendConfig.getUrl(path: "/outsidemeals/" + meal!.id)
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
                    self.meal = try JSONDecoder().decode(OutsideMeal.self, from: data)
                    DispatchQueue.main.async {
                        self.setUIComponentsData()
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
}
