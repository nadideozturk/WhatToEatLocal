//
//  SignInViewController.swift
//  WhatToEatLocal
//
//  Created by Engin Oruc Ozturk on 14.02.2018.
//  Copyright © 2018 NadideOzturk. All rights reserved.
//

import UIKit
import GoogleSignIn


class SignInViewController: UIViewController, GIDSignInUIDelegate {
    
    // MARK: Preoperties

    override func viewDidLoad() {
        super.viewDidLoad()
        // Adding Google Sign In buuton programmatically
        let googleSignInButton = GIDSignInButton()
        googleSignInButton.center = view.center
        view.addSubview(googleSignInButton)
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
