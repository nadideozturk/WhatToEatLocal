//
//  HomemadeMealDetailViewController.swift
//  WhatToEatLocal
//
//  Created by Engin Oruc Ozturk on 5.08.2018.
//  Copyright © 2018 NadideOzturk. All rights reserved.
//

import UIKit
import Cloudinary

class HomemadeMealDetailViewController: UIViewController {
    
    var meal:Meal? = nil

    @IBOutlet weak var lblHomemadeMealName: UILabel!
    
    @IBOutlet weak var imgViewHomeMadeMealD: UIImageView!
    
    @IBOutlet weak var lblLastEatenDateHMMD: UILabel!
    
    @IBOutlet weak var lblDurInMinHMMD: UILabel!
    
    var config = CLDConfiguration(cloudName: "dv0qmj6vt", apiKey: "752346693282248")
    var cloudinary:CLDCloudinary! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblHomemadeMealName.text = meal?.name
        cloudinary = CLDCloudinary(configuration: self.config)
        if meal != nil {
            lblHomemadeMealName.text = (meal?.name.capitalized)!
            //let price:String = String(format:"%.2f", (meal?.price)!)
            //lblOutsideMealPrice.text = price  + " CDN"
            let strDurInMin = String((meal?.durationInMinutes)!)
            lblDurInMinHMMD.text = strDurInMin + " MIN"
            lblLastEatenDateHMMD.text = calculatetimePassed(lastEatenDate: (meal?.lastEatenDate)!)
            imgViewHomeMadeMealD.image = #imageLiteral(resourceName: "HolderImage")
            loadImageForDetail(urlStr: (meal?.photoUrl)!, imgViewer: imgViewHomeMadeMealD)
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
    
    private func loadImageForDetail(urlStr: String, imgViewer: UIImageView!) {
        let url = URL(string: urlStr)
        do {
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
                            imgViewer.image = image
                        }
                    }
                    catch _ as NSError{
                    }
                }
            })
        }catch {
        }
    }

}
