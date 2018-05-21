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

class OutsideMealCrudViewController: FormViewController {

    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section()
//            <<< ImageRow() {
//                $0.title = "Pick up an image"
//                $0.sourceTypes = [.PhotoLibrary, .SavedPhotosAlbum, .Camera]
//                $0.clearAction = .no
//                }
//                .cellUpdate { cell, row in
//                    cell.accessoryView?.layer.cornerRadius = 17
//                    cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
//            }
            <<< TextRow(){ row in
                row.title = "Text Row"
                row.placeholder = "Enter text here"
                row.tag = "mealName"
        }
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
        //DispatchQueue.main.async {
            self.performSegue(withIdentifier: "unwindToOutsideMealListSegue", sender: self)
        //}
//        let newMeal = OutsideMeal(id: "", name: name, photoUrl: "blabla", durationInMinutes:intDurationInMin!,lastEatenDate: lastEatenDate!)
//        submitNewMeal(meal: newMeal!) { (error) in
//            if let error = error {
//                fatalError(error.localizedDescription)
//            }
//        }
    }
    
   
    @IBAction func cancelOutsideMeal(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}
