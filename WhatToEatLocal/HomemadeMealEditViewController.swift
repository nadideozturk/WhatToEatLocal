//
//  HomemadeMealEditViewController.swift
//  WhatToEatLocal
//
//  Created by Engin Oruc Ozturk on 23.08.2018.
//  Copyright © 2018 NadideOzturk. All rights reserved.
//

import UIKit

class HomemadeMealEditViewController: UIViewController {
    
    var meal:HomemadeMeal? = nil
    
    
    @IBOutlet weak var lblHmmName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblHmmName.text = meal?.name
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
