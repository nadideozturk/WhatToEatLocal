//
//  HomemadeMealEditViewController.swift
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

class HomemadeMealEditViewController: FormViewController {
    
    var meal:HomemadeMeal? = nil
    var hmMeallastEatenDate = Date()
    
    
    @IBOutlet weak var saveBtnEdit: UIBarButtonItem!

    
    
    func updateSaveButtonEnabled() {
        saveBtnEdit.isEnabled = self.form.isValid()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section()
            <<< ImageRow("homemadeMealImage") {
                $0.title = "Pick up an image"
                $0.sourceTypes = [.PhotoLibrary, .SavedPhotosAlbum]
                $0.clearAction = .no
                $0.allowEditor = true
                $0.useEditedImage = true
                if let decodedData = Data(base64Encoded: (meal?.photoContent)!, options: .ignoreUnknownCharacters) {
                    let image = UIImage(data: decodedData)
                    $0.value = image
                }
                }
                .cellUpdate { cell, row in
                    cell.accessoryView?.layer.cornerRadius = 17
                    cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
                    self.updateSaveButtonEnabled()
            }
            <<< TextRow(){ row in
                row.title = "Meal Name"
                row.placeholder = "Enter meal name here"
                row.tag = "homemadeMealName"
                row.value = meal?.name
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
            <<< IntRow(){ row in
                row.title = "Duration in minutes"
                row.placeholder = "Enter duration here"
                row.tag = "durInMin"
                row.value = meal?.durationInMinutes
                row.add(rule: RuleRequired())
                row.add(rule: RuleGreaterThan(min: 1))
                row.add(rule: RuleSmallerThan(max: 600))
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
                row.tag = "hmMeallastEatenDate"
                let dateFormatterGet = DateFormatter()
                dateFormatterGet.dateFormat = "yyyy-MM-dd"
                let lastEatenDate = dateFormatterGet.date(from: (meal?.lastEatenDate)!)
                row.value = lastEatenDate
                }.onChange({ (row) in
                    self.hmMeallastEatenDate = row.value!  //updating the value on change
                    self.updateSaveButtonEnabled()
                })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
