//
//  HomemadeMealDetailViewController.swift
//  WhatToEatLocal
//
//  Created by Engin Oruc Ozturk on 5.08.2018.
//  Copyright © 2018 NadideOzturk. All rights reserved.
//

import UIKit

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
        self.lblHomemadeMealName.text = meal?.name
        if meal != nil {
            lblHomemadeMealName.text = (meal?.name.capitalized)!
            //let price:String = String(format:"%.2f", (meal?.price)!)
            //lblOutsideMealPrice.text = price  + " CDN"
            let strDurInMin = String((meal?.durationInMinutes)!)
            lblDurInMinHMMD.text = strDurInMin + " MIN"
            lblLastEatenDateHMMD.text = calculatetimePassed(lastEatenDate: (meal?.lastEatenDate)!)
            imgViewHomeMadeMealD.image = #imageLiteral(resourceName: "HolderImage")
            CloudinaryClient.setImageAsync(imageView: imgViewHomeMadeMealD, imageURL: meal!.photoUrl)
        }
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

    // MARK: - Private Functions
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
}
