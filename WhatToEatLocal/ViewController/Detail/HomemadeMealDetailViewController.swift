//
//  HomemadeMealDetailViewController.swift
//  WhatToEatLocal
//
//  Created by Engin Oruc Ozturk on 5.08.2018.
//  Copyright © 2018 NadideOzturk. All rights reserved.
//

import UIKit
import GoogleSignIn
import os.log

class HomemadeMealDetailViewController: UIViewController {
    
    var meal:HomemadeMeal? = nil

    @IBOutlet weak var lblHomemadeMealName: UILabel!
    
    @IBOutlet weak var imgViewHomeMadeMealD: UIImageView!
    
    @IBOutlet weak var lblLastEatenDateHMMD: UILabel!
    
    @IBOutlet weak var lblDurInMinHMMD: UILabel!
    
    @IBAction func editBtnClicked(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "showHomemadeMealEditSegue", sender: UIBarButtonItem.self)
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
        if segue.identifier == "showHomemadeMealEditSegue" {
            let editVC: HomemadeMealEditViewController = segue.destination as! HomemadeMealEditViewController
            editVC.meal = self.meal
        }
    }
    
    @IBAction func unwindToHomemadeMealDetail(segue:UIStoryboardSegue) {
        loadHomemadeMealById()
        if (self.meal == nil) {
            // Delete use case, go back to list homemade meals screen
            _ = navigationController?.popViewController(animated: false)
            _ = navigationController?.popViewController(animated: false)
        }
    }

    // MARK: - Private Functions
    
    func setUIComponentsData(){
        if meal != nil {
            lblHomemadeMealName.text = (meal?.name.capitalized)!
            //let price:String = String(format:"%.2f", (meal?.price)!)
            //lblOutsideMealPrice.text = price  + " CDN"
            let strDurInMin = String((meal?.durationInMinutes)!)
            lblDurInMinHMMD.text = strDurInMin + " MIN"
            lblLastEatenDateHMMD.text = calculatetimePassed(lastEatenDate: (meal?.lastEatenDate)!)
            imgViewHomeMadeMealD.image = #imageLiteral(resourceName: "HolderImage")
            CloudinaryClient.setImageViewImageAsync(imageView: imgViewHomeMadeMealD, imageUrl: meal!.photoUrl)
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
    
    func loadHomemadeMealById() {
        if (meal == nil) {
            return
        }
        let urlComponents = BackendConfig.getUrl(path: "/homemademeals/" + meal!.id)
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
                    self.meal = try JSONDecoder().decode(HomemadeMeal.self, from: data)
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
