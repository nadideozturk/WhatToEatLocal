//
//  AppDelegate.swift
//  WhatToEatLocal
//
//  Created by Engin Oruc Ozturk on 13.01.2018.
//  Copyright © 2018 NadideOzturk. All rights reserved.
//

import UIKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?

    // Configure the GIDSignIn shared instance and set the sign-in delegate
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Initialize sign-in
        GIDSignIn.sharedInstance().clientID = "8792279534-3tv6nsf4apfh8ufuj1s43k7a2dqa6rnb.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        /* Code to show your tab bar controller */
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            if let tabBarVC = sb.instantiateViewController(withIdentifier: "TabBar") as? UITabBarController {
                window?.rootViewController = tabBarVC
            }
        /* code to show your login VC */
        } else {
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let signInVC = sb.instantiateViewController(withIdentifier: "SignIn")
            window?.rootViewController = signInVC
            
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // The method should call the handleURL method of the GIDSignIn instance, which will properly handle the URL that the application receives at the end of the authentication process
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
    }
    
    //for iOS 8, check availability, same above method
    @available(iOS, introduced: 8.0, deprecated: 9.0)
    func application(_ application: UIApplication,open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url as URL!, sourceApplication: sourceApplication!, annotation: annotation)
    }
    
    // Implementation of the GIDSignInDelegate protocol to handle the sign-in process by defining the following methods:
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            DispatchQueue.main.async {
                let sb = UIStoryboard(name: "Main", bundle: nil)
                if let tabBarVC = sb.instantiateViewController(withIdentifier: "TabBar") as? UITabBarController {
                    self.window?.rootViewController = tabBarVC
                }
            }
        }
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
    }

}

