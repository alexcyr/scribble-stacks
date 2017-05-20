//
//  AppDelegate.swift
//  ScribbleStack
//
//  Created by Alex Cyr on 10/9/16.
//  Copyright © 2016 Alex Cyr. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import Firebase
import FirebaseDatabase
import FirebaseInvites
import FirebaseAuth



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

        
    var ref: FIRDatabaseReference!
    var teamID: String!
    

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
       
        FIRApp.configure()
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        ThemeManager.applyTheme()
      
        return true
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let err = error{
            print("Failed to log into Google", err)
        }
        print("Successfully logged into Google", user)
        guard let idToken = user.authentication.idToken else{return}
        guard let accessToken = user.authentication.accessToken else {return}
        let credentials = FIRGoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        FIRAuth.auth()?.signIn(with: credentials, completion: {(user, error) in
            if let err = error{
                print("Failed to create Firebase User with Google account: ", err)
            }
            guard let uid = user?.uid else {return}
            print("Successfully logged into Firebase with Google", uid)
            
           self.ref = FIRDatabase.database().reference()
          
            
            
            if let user = FIRAuth.auth()?.currentUser {
                for profile in user.providerData {
                    
                    var name: String = profile.displayName!
                    let userID: String = uid
                    let stringInputArr = name.components(separatedBy: " ")
                    name = stringInputArr[0] + " " + String(stringInputArr[1].characters.first!)
                    
                    print(name)
                    print(uid)
                    
                    let changeRequest = user.profileChangeRequest()
                    
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
                
                    self.ref?.child("Users/\(userID)/Teams").observeSingleEvent(of: .value, with: { (snapshot) in
                        print(snapshot)
                        if snapshot.hasChildren(){
                           
                        }
                        else{
                             self.ref.child("Users").child(userID).setValue(["username": name])
                            self.ref?.child("Users/\(userID)/currency").setValue(0)
                            self.ref?.child("Users/\(userID)/sound").setValue(true)
                            self.ref?.child("Users/\(userID)/Words").setValue(["Base": true])
                            self.ref?.child("Teams").child("000000").child("users").child("\(userID)").setValue(["activeGame" : false])

                        }
                        })
                    if (self.teamID != nil){

                        
                        self.ref.child("Teams/\(self.teamID!)/users").child("\(userID)").setValue(true)
                        self.ref.child("Users").child(userID).child("Teams").childByAutoId().child("\(self.teamID!)").setValue(true)
                    }
                    
                }
            }
            
            
           
            print("Successfully logged in with our user: ", user ?? "")
            
            })
    }
    
   
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

    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if let invite = FIRInvites.handle(url, sourceApplication:sourceApplication, annotation:annotation) as? FIRReceivedInvite {
            let matchType =
                (invite.matchType == .weak) ? "Weak" : "Strong"
            print("Invite received from: \(sourceApplication) Deeplink: \(invite.deepLink)," +
                "Id: \(invite.inviteId), Type: \(matchType)")
            let url = invite.deepLink
            let deeplinkTeamArray = url.components(separatedBy: "teamID=")
            teamID = deeplinkTeamArray[1] 
            print(teamID)
            
            
            let topWindow: UIWindow = UIWindow(frame: UIScreen.main.bounds)
            topWindow.rootViewController = UIViewController()
            topWindow.windowLevel = UIWindowLevelAlert + 1
            let alert = UIAlertController(title: "Alert", message: "Added to team \(teamID!)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction) -> Void in
                // continue your work
                // important to hide the window after work completed.
                // this also keeps a reference to the window until the action is invoked.
                topWindow.isHidden = true
            }))
            
            topWindow.makeKeyAndVisible()
            topWindow.rootViewController?.present(alert, animated: true, completion: { _ in })

            
            
            return true
        }
        
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
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
    

}

