//
//  OutsideMealEditViewController.swift
//  WhatToEatLocal
//
//  Created by Engin Oruc Ozturk on 23.08.2018.
//  Copyright © 2018 NadideOzturk. All rights reserved.
//

import UIKit
import GoogleSignIn
import Eureka
import ImageRow
import os.log

class OutsideMealEditViewController: FormViewController {
    
    var  meal:OutsideMeal? = nil
    var outsideMeallastEatenDate = Date()
    var imageUpdatedByUser:Bool = false
    var imageUpdatedInitially:Bool = false
    
    @IBOutlet weak var saveBtnEditOM: UIBarButtonItem!
    
    func updateSaveButtonEnabled() {
        saveBtnEditOM.isEnabled = self.form.isValid()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section()
            <<< ImageRow("outsideMealImage") {
                $0.title = "Pick up an image"
                $0.sourceTypes = [.PhotoLibrary, .SavedPhotosAlbum]
                $0.clearAction = .no
                $0.allowEditor = true
                $0.useEditedImage = true
                }.cellUpdate { cell, row in
                    cell.accessoryView?.layer.cornerRadius = 17
                    cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
                    self.updateSaveButtonEnabled()
            }
                .onChange { row in
                    if !self.imageUpdatedInitially {
                        self.imageUpdatedInitially = true
                    } else if !self.imageUpdatedByUser {
                        self.imageUpdatedByUser = true
                    }
            }
            <<< TextRow(){ row in
                row.title = "Meal Name"
                row.placeholder = "Enter meal name here"
                row.tag = "mealName"
                row.add(rule: RuleRequired())
                row.add(rule: RuleMinLength(minLength: 3))
                row.add(rule: RuleMaxLength(maxLength: 30))
                row.value = meal?.name
                }.cellUpdate { cell, row in
                    cell.textField.textAlignment = .left
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                    self.updateSaveButtonEnabled()
            }
            <<< TextRow(){ row in
                row.title = "Restaurant Name"
                row.placeholder = "Enter restaurant name here"
                row.tag = "restaurantName"
                row.add(rule: RuleRequired())
                row.add(rule: RuleMinLength(minLength: 3))
                row.add(rule: RuleMaxLength(maxLength: 30))
                row.value = meal?.restaurantName
                }.cellUpdate { cell, row in
                    cell.textField.textAlignment = .left
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                    self.updateSaveButtonEnabled()
            }
            <<< DecimalRow(){ row in
                row.title = "Price of Meal"
                row.placeholder = "Enter price here"
                row.tag = "price"
                row.useFormatterDuringInput = false
                row.add(rule: RuleRequired())
                row.add(rule: RuleGreaterThan(min: 0))
                row.add(rule: RuleSmallerThan(max: 9999))
                row.value = meal?.price
                }.cellUpdate { cell, row in
                    cell.textField.textAlignment = .left
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                    self.updateSaveButtonEnabled()
            }
            <<< DateRow(){ row in
                row.title = "Last eaten date"
                row.minimumDate = Calendar.current.date(byAdding: .year, value: -5, to: Date())!
                row.maximumDate = Date()
                row.tag = "lastEatenDate"
                let dateFormatterGet = DateFormatter()
                dateFormatterGet.dateFormat = "yyyy-MM-dd"
                let lastEatenDate = dateFormatterGet.date(from: (meal?.lastEatenDate)!)
                row.value = lastEatenDate
                }.onChange({ (row) in
                    self.outsideMeallastEatenDate = row.value!  //updating the value on change
                    self.updateSaveButtonEnabled()
                })
            <<< ButtonRow() { row in
                row.title = "Delete"
                }.cellUpdate { cell, row in
                    cell.textLabel?.textAlignment = .right
                }
                .onCellSelection({ [unowned self] (cell, row) in
                    self.deleteMeal()
                })
        CloudinaryClient.setImageRowImageAsync(imageRow: self.form.rowBy(tag: "outsideMealImage"), imageUrl: meal!.photoUrl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Actions
    
    @IBAction func saveBtnEditActionOM(_ sender: UIBarButtonItem) {
        self.form.validate()
        updateSaveButtonEnabled()
        if (!self.form.isValid()) {
            return
        }
        let row: TextRow? = form.rowBy(tag: "mealName")
        let name = row?.value
        let values = form.values()
        var imageBase64:String = "Empty"
        if(imageUpdatedByUser){
            let selectedImage = values["outsideMealImage"] as? UIImage
            let resizedImage = resizeImage(selectedImage!)
            let imageData:NSData = UIImagePNGRepresentation(resizedImage)! as NSData
            imageBase64 = "data:image/jpeg;base64," + imageData.base64EncodedString()
        }
        let strLastEatenDate = setLastEatenDate()
        let priceRow: DecimalRow? = form.rowBy(tag: "price")
        let price = priceRow?.value
        let resRow: TextRow? = form.rowBy(tag: "restaurantName")
        let restaurantName = resRow?.value
        let newMeal = OutsideMeal(id: (meal?.id)!, name: name!, photoUrl: (meal?.photoUrl)!, price: price!, lastEatenDate: strLastEatenDate, restaurantName: restaurantName!, photoContent: imageBase64)
        submitEditedOutsideMeal(meal: newMeal!) { (error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToOutsideMealDetailSegue" {
            let detailVC: OutsideMealDetailViewController = segue.destination as! OutsideMealDetailViewController
            if (self.meal == nil) {
                // Delete use case
                detailVC.meal = nil
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func submitEditedOutsideMeal(meal: OutsideMeal, completion:((Error?) -> Void)?){
        let urlComponents = BackendConfig.getUrl(path: "/outsidemeals")
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        
        // Specify this request as being a POST method
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        // Make sure that we include headers specifying that our request's HTTP body
        // will be JSON encoded
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        let token = GIDSignIn.sharedInstance().currentUser?.authentication?.idToken
        headers["Authorization"] = token
        request.allHTTPHeaderFields = headers
        
        // Now let's encode out Post struct into JSON data...
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(meal)
            // ... and set our request's HTTP body
            request.httpBody = jsonData
            // print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
        } catch {
            completion?(error)
        }
        
        // Create and run a URLSession data task with our JSON encoded POST request
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else {
                completion?(responseError!)
                return
            }
            // APIs usually respond with the data you just sent in your POST request
            if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
                print("response: ", utf8Representation)
            } else {
                print("no readable data received in response")
            }
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "unwindToOutsideMealDetailSegue", sender: self)
            }
        }
        task.resume()
    }
    
    func setLastEatenDate() -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        let lastEatenDate = dateFormatterGet.string(from: self.outsideMeallastEatenDate)
        return lastEatenDate
    }
    
    func resizeImage(_ image: UIImage) -> UIImage {
        var actualHeight = Float(image.size.height)
        var actualWidth = Float(image.size.width)
        let maxHeight: Float = 500.0
        let maxWidth: Float = 500.0
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight
        let compressionQuality: Float = 0.9
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = UIImageJPEGRepresentation(img!, CGFloat(compressionQuality))
        UIGraphicsEndImageContext()
        return UIImage(data: imageData!) ?? UIImage()
    }
    
    private func deleteMeal(){
        let urlComponents = BackendConfig.getUrl(path: "/outsidemeals/" + (self.meal?.id)!)
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        
        // Specify this request as being a POST method
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        // Make sure that we include headers specifying that our request's HTTP body
        // will be JSON encoded
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        let token = GIDSignIn.sharedInstance().currentUser?.authentication?.idToken
        headers["Authorization"] = token
        request.allHTTPHeaderFields = headers
        
        // Now let's encode out Post struct into JSON data...
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(self.meal)
            // ... and set our request's HTTP body
            request.httpBody = jsonData
            print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
        } catch let jsonErr {
            os_log("Error serializing json:", log: OSLog.default, type: .debug)
            fatalError("Error serializing json:" + jsonErr.localizedDescription)
        }
        
        // Create and run a URLSession data task with our JSON encoded DELETE request
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else {
                return
            }
            // APIs usually respond with the data you just sent in your DELETE request
            if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
                print("response: ", utf8Representation)
            } else {
                print("no readable data received in response")
            }
            DispatchQueue.main.async {
                self.meal = nil
                self.performSegue(withIdentifier: "unwindToOutsideMealDetailSegue", sender: self)
            }
        }
        task.resume()
    }

}
