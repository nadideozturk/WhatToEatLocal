//
//  AutoSigninViewController.swift
//  WhatToEatLocal
//
//  Created by Engin Oruc Ozturk on 16.02.2018.
//  Copyright © 2018 NadideOzturk. All rights reserved.
//

import UIKit
import GoogleSignIn

class AutoSigninViewController: UIViewController {
    // MARK: Properties
    //let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)

    override func viewDidLoad() {
        super.viewDidLoad()
        // start animating before the background task starts
        //activityIndicator.startAnimating()
        GIDSignIn.sharedInstance().signInSilently()
    }
    
}
