//
//  OutsideMealEditViewController.swift
//  WhatToEatLocal
//
//  Created by Engin Oruc Ozturk on 23.08.2018.
//  Copyright © 2018 NadideOzturk. All rights reserved.
//

import UIKit

class OutsideMealEditViewController: UIViewController {
    
    var  meal:OutsideMeal? = nil
    
    
    @IBOutlet weak var lblOusideMealName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblOusideMealName.text = meal?.name
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

}
