//
//  SideMenuViewController.swift
//  ScribbleStack
//
//  Created by Alex Cyr on 7/6/17.
//  Copyright © 2017 Alex Cyr. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn


class SideMenuViewController: UITableViewController  {
    
    var coins:Int?
    @IBOutlet weak var signOutOutlet: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if Auth.auth().currentUser != nil{

        }
        else{
            signOutOutlet.text = "SIGN IN"
        }
        
        self.title = "MENU"
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SignOutToLogin" {
            
          
            
            _ = segue.destination as! ViewController
            GIDSignIn.sharedInstance().signOut()
            try! Auth.auth().signOut()
            
            
        }
        if segue.identifier == "SideMenuToHowTo" {
            
            
            
            let controller = segue.destination as! HowToViewController
            controller.coins = coins
            
            
        }
        if segue.identifier == "SideMenuToAbout" {
            
            
            
            let controller = segue.destination as! AboutViewController
            controller.coins = coins
            
            
        }
        
        
        
    }
}
