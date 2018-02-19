# WhatToEat Swift Mobile Application
## Project Description
WhatToEat is an iOS application that helps users to decide their daily meal selection with meal recommendations based on personally entered meals. Explore feature helps discovering new meal ideas. A meal entry can be home made or restaurant meal. The user can enter meals eaten by them everyday, so the app also serves as an eating journal. The user will be able to add tags for each meal so they can find their favorite meals based on their own words.

The main differentiator for this app is, users are free to manage their own favorite meals for cooking or ordering for a personalized experience.

## Technologies and Platforms
### Backend
**Application:** RESTful API using Spring boot  
**Application Hosting:** EC2 on AWS  
**Database:** MySQL  
**Database Hosting:** Amazon RDS  
**Dependency management:** Maven  
**Libraries:** JPA, Lombok, Google Single Sign-on  
**Source control:** Git  
**IDE:** IntelliJ  
### Front-End
**Language:** Swift 4  
**Dependency management:** CocoaPods  
**Libraries:** Google Single Sign-on  
**Source control:** Git  
**IDE:** Xcode 9.2  

## Front-End Requirements
- [x] UI implementation for display all home made meals and navigation to new meal screen.
- [x] UI implementation for adding a home made meal and navigation to home made meal list screen.
- [ ] New home made meal screen UI elements need to be placed correctly.
- [ ] UI implementation for displaying all outside meals and adding a outside meal
- [ ] Adding date picker and last eaten date property.
- [ ] Tag property implementation.
- [x] User sign-in screen implementation and adding google sign in delegates.
- [ ] Edit and Delete a meal implementation.
- [ ] Create suggestion using tags. e.g. If users pick up a breakfast tag, show breakfast.
- [ ] Suggestion tab will be implemented.
- [ ] Explore tab implementation.
- [ ] Search box implementation for top of home and outside meals screen.
- [ ] For first login preparation of sample meals and tutorial.
- [ ] Settings tab implementation.
- [ ] Logout implementation.

## Solved Problems:
1. Some UI events need to be triggered when an async backend request is completed.  
**Solution:** Dispatching UI related code from async response handler, so that response handler thread can dispatch to UI thread.
2. How to decide whether or not show the login screen based on if the user previously signed in or not? One way that doesn't work is, checking *idToken* field of `GIDSignIn.sharedInstance().currentUser` for *nil* value.  
**Solution:** Instead of using *idToken* field, *hasAuthInKeychain()* method of user object is used to decide if the user is already signed-in.
3. How to set initial view (Storyboard Entry Point) of application programmatically if user already signed in with Google sign-in.  
**Solution:**
```swift
	/* Show tab bar controller from AppDelegate class */
    if GIDSignIn.sharedInstance().hasAuthInKeychain() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarVC = sb.instantiateViewController(withIdentifier: "TabBar") as?
            UITabBarController {
            window?.rootViewController = tabBarVC
        }
    /* Show login VC from AppDelegate class */
    } else {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let signInVC = sb.instantiateViewController(withIdentifier: "SignIn")
        window?.rootViewController = signInVC
    }
```
