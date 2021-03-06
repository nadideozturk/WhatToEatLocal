//
//  OutsideMealCrudViewController.swift
//  WhatToEatLocal
//
//  Created by Engin Oruc Ozturk on 11.05.2018.
//  Copyright © 2018 NadideOzturk. All rights reserved.
//

import UIKit
import Eureka
import ImageRow
import os.log
import GoogleSignIn

class NewOutsideMealViewController: FormViewController {

    var lastEatenDate = Date()
    var category:String? = nil
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    func updateSaveButtonEnabled() {
        saveButton.isEnabled = self.form.isValid()
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
            <<< TextRow(){ row in
                row.title = "Meal Name"
                row.placeholder = "Enter meal name here"
                row.tag = "mealName"
                row.add(rule: RuleRequired())
                row.add(rule: RuleMinLength(minLength: 3))
                row.add(rule: RuleMaxLength(maxLength: 30))
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
                }.cellUpdate { cell, row in
                    cell.textField.textAlignment = .left
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                    self.updateSaveButtonEnabled()
            }
            <<< ActionSheetRow<String>() { row in
                row.title = "Category"
                row.selectorTitle = "Choose a category"
                row.options = Array(Category.mealCategory.keys)
                row.add(rule: RuleRequired())
                }
                .onPresent { from, to in
                    to.popoverPresentationController?.permittedArrowDirections = .up
                }
                .onChange({ (row) in
                    self.category = row.value!
                    self.updateSaveButtonEnabled()
                })
            <<< DateRow(){ row in
                row.title = "Last eaten date"
                row.minimumDate = Calendar.current.date(byAdding: .year, value: -5, to: Date())!
                row.maximumDate = Date()
                row.tag = "lastEatenDate"
                row.value = Date()
                }.onChange({ (row) in
                    self.lastEatenDate = row.value!  //updating the value on change
                    self.updateSaveButtonEnabled()
                })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // Save new Meal
    @IBAction func saveOutsideMeal(_ sender: UIBarButtonItem) {
        self.form.validate()
        updateSaveButtonEnabled()
        if (!self.form.isValid()) {
            return
        }
        
        let row: TextRow? = form.rowBy(tag: "mealName")
        let name = row?.value
        print(name ?? "Empty outside meal name")
        let values = form.values()
        let selectedImage = values["outsideMealImage"] as? UIImage
        let resizedImage = resizeImage(selectedImage!)
        let imageData:NSData = UIImagePNGRepresentation(resizedImage)! as NSData
        let imageBase64 = "data:image/jpeg;base64," + imageData.base64EncodedString()
        let strLastEatenDate = setLastEatenDate()
        let priceRow: DecimalRow? = form.rowBy(tag: "price")
        let price = priceRow?.value
        let resRow: TextRow? = form.rowBy(tag: "restaurantName")
        let restaurantName = resRow?.value
        let catId: String = Category.mealCategory[self.category!]!
        let newMeal = OutsideMeal(id: "", name: name!, photoUrl: " ", price: price!, lastEatenDate: strLastEatenDate, restaurantName: restaurantName!, photoContent: imageBase64, catId: catId)
        submitNewMeal(meal: newMeal!) { (error) in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    private func submitNewMeal(meal: OutsideMeal, completion:((Error?) -> Void)?){
        let urlComponents = BackendConfig.getUrl(path: "/outsidemeals")
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        
        // Specify this request as being a POST method
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
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
                self.performSegue(withIdentifier: "unwindToOutsideMealListSegue", sender: self)
            }
        }
        task.resume()
    }
   
    @IBAction func cancelOutsideMeal(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func setLastEatenDate() -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        let lastEatenDate = dateFormatterGet.string(from: self.lastEatenDate)
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
}
