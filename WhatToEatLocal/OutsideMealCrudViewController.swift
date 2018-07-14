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

class OutsideMealCrudViewController: FormViewController {

    var lastEatenDate = Date()
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section()
            <<< ImageRow("outsideMealImage") {
                $0.title = "Pick up an image"
                $0.sourceTypes = [.PhotoLibrary, .SavedPhotosAlbum, .Camera]
                $0.clearAction = .no
                }
                .cellUpdate { cell, row in
                    cell.accessoryView?.layer.cornerRadius = 17
                    cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
            }
            <<< TextRow(){ row in
                row.title = "Text Row"
                row.placeholder = "Enter meal name here"
                row.tag = "mealName"
        }
            <<< TextRow(){ row in
                row.title = "Restaurant Name"
                row.placeholder = "Enter restaurant name here"
                row.tag = "restaurantName"
            }
            <<< DecimalRow(){ row in
                row.title = "Price of Meal"
                row.placeholder = "Enter price here"
                row.tag = "price"
            }
            <<< DateRow(){ row in
                row.title = "Last eaten date"
                row.minimumDate = Date()
                row.tag = "lastEatenDate"
                row.value = Date()
                }.onChange({ (row) in
                    self.lastEatenDate = row.value!  //updating the value on change
                })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation
    
    // Save new Meal
    @IBAction func saveOutsideMeal(_ sender: UIBarButtonItem) {
        //let name = mealNameTxtField.text ?? ""
        //let photo = MealImageViewer.image
        //let durationInMin:String? = durationTimeInMinTxtField.text
        //let intDurationInMin:Int? = Int(durationInMin!)
        //let lastEatenDate:String? = setLastEatenDate()
        let row: TextRow? = form.rowBy(tag: "mealName")
        let name = row?.value
        print(name ?? "Empty outside meal name")
        let values = form.values()
        let selectedImage = values["outsideMealImage"] as? UIImage
        //let imageData:NSData = UIImagePNGRepresentation(image!)! as NSData
        let resizedImage = resizeImage(selectedImage!)
       
        let imageData:NSData = UIImagePNGRepresentation(resizedImage)! as NSData
        let imageBase64 = "data:image/jpeg;base64," + imageData.base64EncodedString()
        //let rowDate: TextRow? = form.rowBy(tag: "lastEatenDate")
        let strLastEatenDate = setLastEatenDate()
        let priceRow: DecimalRow? = form.rowBy(tag: "price")
        let price = priceRow?.value
        let resRow: TextRow? = form.rowBy(tag: "restaurantName")
        let restaurantName = resRow?.value
        let size = imageData.length
        //outsideMealImage
        //DispatchQueue.main.async {
            //self.performSegue(withIdentifier: "unwindToOutsideMealListSegue", sender: self)
       // }
//        let newMeal = OutsideMeal(id: "", name: name, photoUrl: "blabla", durationInMinutes:intDurationInMin!,lastEatenDate: lastEatenDate!)
        let newMeal = OutsideMeal(id: "", name: name!, photoUrl: " ", price: price!, lastEatenDate: strLastEatenDate, restaurantName: restaurantName!, photoContent: imageBase64)
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
            print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
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
        let maxHeight: Float = 300.0
        let maxWidth: Float = 400.0
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight
        let compressionQuality: Float = 0.5
        //50 percent compression
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
