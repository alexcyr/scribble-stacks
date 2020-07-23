//
//  AppDelegate.swift
//  ScribbleStacks
//
//  Created by Alex Cyr on 10/9/16.
//  Copyright © 2016 Alex Cyr. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseDatabase
import FirebaseInvites
import FirebaseDynamicLinks
import FirebaseAuth
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    
    var ref: DatabaseReference!
    var teamID = ""
    var userID: String = ""
    var first = false
    
    
    var window: UIWindow?
    var window2: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
            
      
        
        
            
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        //DynamicLinks.performDiagnostics(completion: nil)
        
        
        if !(UserDefaults.standard.bool(forKey: "hasLaunched")){
            
            
            
            let userDefaults = UserDefaults.standard
            userDefaults.setValue(0, forKey: "gameAdCount")
            UserDefaults.standard.setValue(true, forKey: "ads")
            userDefaults.setValue(0, forKey: "earnedCoins")
            userDefaults.setValue(0, forKey: "earnedCoins")
            userDefaults.setValue(true, forKey: "hasLaunched")
          
            let ownedWords: NSDictionary = ["Easy": true, "Medium": false, "Hard": false]
            userDefaults.setValue(ownedWords, forKey: "ownedWords")
            
        }
        let ads = UserDefaults.standard.bool(forKey: "ads")

        if ads{
            GADMobileAds.configure(withApplicationID: "ca-app-pub-4705463543336282~6802737761")
        }
      
       
        window2 = UIWindow(frame: UIScreen.main.bounds)
        if #available(iOS 11.0, *) {
            if (window2?.safeAreaInsets.top)! > CGFloat(0.0) || window2?.safeAreaInsets != .zero {
                print("iPhone X")
                application.isStatusBarHidden = false
                //or UIApplication.shared.isStatusBarHidden = true
            }
            else {
                print("Not iPhone X")
                application.isStatusBarHidden = true
            }
        }
        if (launchOptions?[UIApplicationLaunchOptionsKey.url] as? NSURL) != nil {
            //App opened from invite url
            print("is there something here?")
            //self.handleFirebaseInviteDeeplink()
        }
        
        
        
        return true
    }
    

    func returnFirst()->Bool{
        return first
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let err = error{
            print("Failed to log into Google", err)
        }
        else{
        print("potato")
        
        print("Successfully logged into Google", user)
        guard let idToken = user.authentication.idToken else{return}
        guard let accessToken = user.authentication.accessToken else {return}
        let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        Auth.auth().signIn(with: credentials, completion: {(user, error) in
            if let err = error{
                print("Failed to create Firebase User with Google account: ", err)
            }
            guard let uid = user?.uid else {return}
            print("Successfully logged into Firebase with Google", uid)
            
            self.ref = Database.database().reference()
            
            
            
            if let user = Auth.auth().currentUser {
                for profile in user.providerData {
                    
                    var name: String = profile.displayName!
                    self.userID = uid
                    let stringInputArr = name.components(separatedBy: " ")
                    name = stringInputArr[0] + " " + String(stringInputArr[1].prefix(1))
                    
                    print(name)
                    print(uid)
                    if self.teamID != ""{
                        
                        self.handleFirebaseInviteDeeplink()
                      
                    }
                    
                    self.ref?.child("Users/\(self.userID)").observeSingleEvent(of: .value, with: { (snapshot) in
                        print(snapshot)
                        if snapshot.hasChildren(){
                            var wordDictionary = UserDefaults.standard.dictionary(forKey: "ownedWords")!
                            let ownedWords = Array(wordDictionary.keys)
                            self.first = false
                            let snap = snapshot.value! as! NSDictionary
                            let wordData = (snap["Words"] as! NSDictionary)
                            let dbWords = Array(wordData.allKeys) as! [String]
                            for word in dbWords{
                                var owned = false
                                for localWord in ownedWords{
                                    if word == localWord{
                                        owned = true
                                    }
                                    
                                }
                                if owned == false{
                                    wordDictionary["\(word)"] = true
                                }
                            }
                            UserDefaults.standard.setValue(wordDictionary, forKey: "ownedWords")
                            


                        }
                        else{
                            self.first = true
                            
                            self.ref?.child("Teams").child("000000").child("teamInfo/users").child("\(self.userID)").setValue(["activeGame" : false])
                            

                            let changeRequest = user.createProfileChangeRequest()
                            
                            changeRequest.displayName = "\(name)"
                            
                            changeRequest.commitChanges { error in
                                if error != nil {
                                    // An error happened.
                                    print("failed")
                                } else {
                                    // Profile updated.
                                    print("sucess")
                                }
                            }
                            self.ref.child("Users").child(self.userID).setValue(["username": name, "currency": 0,"sound": true,"Words": ["Easy": true, "Medium": false, "Hard": false]])
                            
                            
                            
                            
                            
                        }
                    })
                    
                    
                }
            }
            
            
            print("Successfully logged in with our user: ", user ?? "")
            
        })
        }
    }
    
    func randomSequenceGenerator(min: Int , max: Int) -> () -> Int {
        var numbers: [Int] = []
        return {
            if numbers.count == 0 {
                numbers = Array(min ... max)
            }
            
            let index = Int(arc4random_uniform(UInt32(numbers.count)))
            return numbers.remove(at: index)
        }
        
    }
    /*
     @available(iOS 9.0, *)
     func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
     return application(app, open: url,
     sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
     annotation: "")
     }
     
     func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
     if let dynamicLink = DynamicLinks.dynamicLinks()?.dynamicLink(fromCustomSchemeURL: url) {
     // Handle the deep link. For example, show the deep-linked content or
     // apply a promotional offer to the user's account.
     // ...
     
     let urlString = dynamicLink.url
     print("yo link", urlString)
     let deepLink = url.absoluteString
     let teamArray = deepLink.components(separatedBy: "teamID=")
     teamID = teamArray[1]
     print(teamID)
     self.ref = Database.database().reference()
     
     
     var teamName: String = ""
     print("tintin")
     
        self.ref.child("Teams/\(self.teamID)/teamInfo/users").child("\(self.userID)").setValue(["activeGame": false])
        self.ref.child("Users").child(self.userID).child("Teams").child("\(self.teamID)").setValue([true])
     let topWindow: UIWindow = UIWindow(frame: UIScreen.main.bounds)
     topWindow.rootViewController = UIViewController()
     topWindow.windowLevel = UIWindowLevelAlert + 1
     let alert = UIAlertController(title: "Alert", message: "Added to team \(teamName))", preferredStyle: UIAlertControllerStyle.alert)
     alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction) -> Void in
     // continue your work
     // important to hide the window after work completed.
     // this also keeps a reference to the window until the action is invoked.
     
     topWindow.isHidden = true
     }))
     
     topWindow.makeKeyAndVisible()
     topWindow.rootViewController?.present(alert, animated: true, completion: nil)
     
     
     
     
     
     
     return true
     }
     return false
     }
 
     
     func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
     
     if let dynamicLink = DynamicLinks.dynamicLinks()?.dynamicLink(fromCustomSchemeURL: url){
     self.handleIncomingDynamicLink(dynamicLink: dynamicLink)
     
     return true
     
     }
     else{
     let handled = GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
     
     return handled
     }
     }
 
     @available(iOS 8.0, *)
     func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
     if let incomingURL = userActivity.webpageURL{
     let linkHandled = DynamicLinks.dynamicLinks()!.handleUniversalLink(incomingURL, completion:{ [weak self] (dynamiclink, error) in
     guard let strongSelf = self else{ return }
     if let dynamiclink = dynamiclink, let _ = dynamiclink.url {
     strongSelf.handleIncomingDynamicLink(dynamicLink: dynamiclink)
     }
     })
     return linkHandled
     }
     return false
     }
     
     func handleIncomingDynamicLink(dynamicLink: DynamicLink) {
     
     if dynamicLink.matchConfidence == .weak{
     }else {
     guard let pathComponents = dynamicLink.url?.pathComponents else { return }
     for nextPiece in pathComponents{
     
     }
     }
     print("incoming link \(dynamicLink.url)")
     }
 */
    /*
     @available(iOS 9.0, *)
     func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
     
     if(GIDSignIn.sharedInstance().handle(url,
     sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!,
     annotation: options[UIApplicationOpenURLOptionsKey.annotation])){
     return true
     }
     else if (self.application(application, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: "")){
     return true
     }
     
     return false
     }
     
     */
    /*
     Working on Firebase '4.0.4'
 */
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            print("hey2", url)
            if let invite = Invites.handle(url, sourceApplication:"", annotation:"") as? ReceivedInvite {
                
                let matchType =
                    (invite.matchType == .weak) ? "Weak" : "Strong"
                print("Invite received from: none Deeplink: \(invite.deepLink)," +
                    "Id: \(invite.inviteId), Type: \(matchType)")
                let url = invite.deepLink
                let deeplinkTeamArray = url.components(separatedBy: "teamID=")
                teamID = deeplinkTeamArray[1]
                print(teamID)
                self.ref = Database.database().reference()
                self.ref = Database.database().reference()
                
                self.handleFirebaseInviteDeeplink()
                
                
            }
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: [:])
    }

    
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        print("hey", url)
        if let invite = Invites.handle(url, sourceApplication:sourceApplication, annotation:annotation) as? ReceivedInvite {
            
            let matchType =
                (invite.matchType == .weak) ? "Weak" : "Strong"
            print("Invite received from: , Deeplink: \(invite.deepLink)," +
                "Id: \(invite.inviteId), Type: \(matchType)")
            let url = invite.deepLink
            let deeplinkTeamArray = url.components(separatedBy: "teamID=")
            teamID = deeplinkTeamArray[1]
            print(teamID)
            self.ref = Database.database().reference()
            self.ref = Database.database().reference()
            
            self.handleFirebaseInviteDeeplink()
            
            
        }
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: sourceApplication,
                                                 annotation: annotation)
    
}
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        guard let dynamicLinks = DynamicLinks.dynamicLinks() else {
            return false
        }
        let handled = dynamicLinks.handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
            let url = dynamiclink?.url
            let str = url?.absoluteString
            let deeplinkTeamArray = str!.components(separatedBy: "teamID=")
            self.teamID = deeplinkTeamArray[1]
            self.ref = Database.database().reference()
            self.ref = Database.database().reference()
            
            self.handleFirebaseInviteDeeplink()
        }
        
        return handled
    }


     /*
     func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler:([AnyObject]?)-> Void) -> Bool{
     if let incomingURL = userActivity.webpageURL{
     let linkHandled = DynamicLinks.dynamicLinks()!.handleUniversalLink(incomingURL, completion: {
     (dynamiclink, error) in
     if let dynamiclink = dynamiclink, let _ = dynamiclink.url{
     self.handleIncomingDynamicLink(dynamiclink: dynamiclink)
     }
     })
     return linkHandled
     }
     return false
     }
     func handleIncomingDynamicLink(dynamiclink: DynamicLink){
     print("incoming link: \(dynamiclink.url)")
     }
     
     @available(iOS 9.0, *)
     func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
     -> Bool {
     return self.application(application, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: "")
     }
     
     func application(_ application: UIApplication,
     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
     if GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation) {
     return true
     }
     
     return DynamicLinks.dynamicLinks()!.handleUniversalLink(url) { invite, error in
     // ...
     print("incoming link: \(url)")
     }
     }
     
     @available(iOS 9.0, *)
     func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
     -> Bool {
     print("woop woop", url)
     return self.application(application, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: "")
     }
     
     func application(_ application: UIApplication,
     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
     print("hmph", url)
     if GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation) {
     print("google signed in woop")
     
     return true
     }
     
     return Invites.handleUniversalLink(url) { invite, error in
     // [START_EXCLUDE]
     print("we have invites!")
     if let error = error {
     print(error.localizedDescription)
     return
     }
     if let invite = invite {
     //self.showAlertView(withInvite: invite)
     }
     // [END_EXCLUDE]
     }
     }
     // [END openurl]
     // [START continueuseractivity]
    
     func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
     return Invites.handleUniversalLink(userActivity.webpageURL!) { invite, error in
     print("rada rada")
     // [START_EXCLUDE]
     if let error = error {
     print(error.localizedDescription)
     return
     }
     if let invite = invite {
     self.showAlertView(withInvite: invite)
     }
     // [END_EXCLUDE]
     }
     }
     // [END continueuseractivity]
     func showAlertView(withInvite invite: ReceivedInvite) {
     let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
     let matchType = invite.matchType == .weak ? "weak" : "strong"
     let message = "Invite ID: \(invite.inviteId)\nDeep-link: \(invite.deepLink)\nMatch Type: \(matchType)"
     let alertController = UIAlertController(title: "Invite", message: message, preferredStyle: .alert)
     alertController.addAction(okAction)
     self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
     }
 
     
     
     @available(iOS 9.0, *)
     func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
     -> Bool {
     return self.application(application, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: "")
     }
     
     func application(_ application: UIApplication,
     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
     print("hello there", url)
     if GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation) {
     return true
     }
     
     return Invites.handleUniversalLink(url) { invite, error in
     // ...
     print("did it work? \(url)")
     
     }
     }
 */
    
    /*
    LAST WORKING
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            return self.application(application, open: (url as NSURL) as URL, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: "" as AnyObject)
    }
  
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        var dynamicLink: DynamicLink? = DynamicLinks().dynamicLink(fromCustomSchemeURL: url)
        print("hey a url!",url)
        print(dynamicLink?.url)
        if Invites.handleUniversalLink(url, completion: { (invite, error) in
            
            let matchType = (invite?.matchType == ReceivedInviteMatchType.weak) ? "Weak" : "Strong"
            print("\n------------------Invite received from: \(String(describing: sourceApplication)) Deeplink: \(String(describing: invite?.deepLink))," + "Id: \(String(describing: invite?.inviteId)), Type: \(matchType)")
            /*
             if (matchType == "Strong") {
             print("\n-------------- Invite Deep Link = \(invite.deepLink)")
             if !invite.deepLink.isEmpty {
             let url = NSURL(string: invite.deepLink)
             self.handleFirebaseInviteDeeplink(inviteUrl: url! as URL)
             }
             }
             
             */
            let url = invite?.deepLink
            let deeplinkTeamArray = url?.components(separatedBy: "teamID=")
            self.teamID = deeplinkTeamArray![1]
            print(self.teamID)
            self.ref = Database.database().reference()
            
            self.handleFirebaseInviteDeeplink()
            
        }) {
            return true
        }
        return GIDSignIn.sharedInstance().handle(url as URL!, sourceApplication: sourceApplication, annotation: annotation)
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        
        if userActivity.webpageURL != nil{
            let url = userActivity.webpageURL
            userActivity.webpageURL = nil
            print("hey a url!",url!)
            if Invites.handleUniversalLink(url!, completion: { (invite, error) in
                
                let matchType = (invite?.matchType == ReceivedInviteMatchType.weak) ? "Weak" : "Strong"
                print("\n------------------Invite received from:  Deeplink: \(String(describing: invite?.deepLink))," + "Id: \(String(describing: invite?.inviteId)), Type: \(matchType)")
                /*
                 if (matchType == "Strong") {
                 print("\n-------------- Invite Deep Link = \(invite.deepLink)")
                 if !invite.deepLink.isEmpty {
                 let url = NSURL(string: invite.deepLink)
                 self.handleFirebaseInviteDeeplink(inviteUrl: url! as URL)
                 }
                 }
                 
                 */
                let url = invite?.deepLink
                let deeplinkTeamArray = url?.components(separatedBy: "teamID=")
                self.teamID = deeplinkTeamArray![1]
                print(self.teamID)
                self.ref = Database.database().reference()
                
                self.handleFirebaseInviteDeeplink()
                
                
            }) {
                return true
            }
            return GIDSignIn.sharedInstance().handle(url as URL!, sourceApplication: "", annotation: "")
        }
        return true
    }
 */
    func handleFirebaseInviteDeeplink(){
        var teamName: String = ""
        print("tintin")
        if let user = Auth.auth().currentUser {
            for _ in user.providerData {
                let uid = user.uid
                print("Successfully logged into Firebase with Google", uid)
                
                self.userID = uid
                self.ref?.child("Users/\(self.userID)/Teams/\(self.teamID)").observeSingleEvent(of: .value, with: { (snapshot) in
                    print(snapshot)
                    if snapshot.hasChildren(){
                    }
                    else{
                        let group = DispatchGroup()
                        group.enter()
                        self.ref?.child("Teams/\(self.teamID)/teamInfo/").observeSingleEvent(of: .value, with: { (snapshot) in
                            let nameData = snapshot.value as? NSDictionary
                            teamName = (nameData?["team"]! as? String)!
                            print(teamName)
                            group.leave()
                        })
                        
                        group.notify(queue: DispatchQueue.main, execute: {

                        self.ref.child("Teams/\(self.teamID)/teamInfo/users").child("\(self.userID)").setValue(["activeGame": false])
                        self.ref.child("Users").child(self.userID).child("Teams").child("\(self.teamID)").setValue([true])
                        let topWindow: UIWindow = UIWindow(frame: UIScreen.main.bounds)
                        topWindow.rootViewController = UIViewController()
                        topWindow.windowLevel = UIWindowLevelAlert + 1
                        let alert = UIAlertController(title: "Alert", message: "Added to team \(teamName)!", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction) -> Void in
                            // continue your work
                            // important to hide the window after work completed.
                            // this also keeps a reference to the window until the action is invoked.
                            
                            topWindow.isHidden = true
                            
                        }))
                            topWindow.makeKeyAndVisible()
                            topWindow.rootViewController?.present(alert, animated: true, completion: nil)
                            })
                        
                       
                    }
                })
                
                
            }
            
        }
    }
 
    func showAlertAppDelegate(title : String,message : String,buttonTitle : String,window: UIWindow){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.default, handler: nil))
        window.rootViewController?.present(alert, animated: true, completion: nil)
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
    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "LoginToHome" {
            let DestViewController = segue.destination as! UINavigationController
            let targetController = DestViewController.topViewController as! TabBarViewController
            
            targetController.data = teamID
            targetController.first = self.first
        }
    }
    
}

