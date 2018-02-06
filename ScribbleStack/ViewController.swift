//
//  ViewController.swift
//  ScribbleStack
//
//  Created by Alex Cyr on 10/9/16.
//  Copyright © 2016 Alex Cyr. All rights reserved.
//

import UIKit

import FirebaseAuth
import FirebaseDatabase
import GoogleSignIn
import NVActivityIndicatorView

class ViewController: UIViewController,  GIDSignInUIDelegate {
    
    @IBOutlet weak var statusLabel: UILabel?
    let data = "This is the data"
    var ref: DatabaseReference!
    var first: Bool?
    var loggedIn = false
    var counter = Int.max
    var n = 0
    var didStart = false
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
 
        if (Auth.auth().currentUser) != nil  {
        statusLabel?.text = "Loading user data..."
        loggedIn = true
       activityIndicator.startAnimating()

       } else {
       
        setupGoogleButtons()
        
        
        ref = Database.database().reference()
            
       
       
        }
        var _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateCounter), userInfo: nil, repeats: true)
        
    }
    
    fileprivate func setupGoogleButtons(){
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: 16, y: 166 + 66, width: view.frame.width - 32, height:50)
        googleButton.addTarget(self, action: #selector(ViewController.googlePressed(button:)), for: .touchUpInside)
        googleButton.tag = 222
        view.addSubview(googleButton)
       
   
        GIDSignIn.sharedInstance().uiDelegate = self
     
    }
    
    @objc func googlePressed(button: UIButton){
        let button = self.view.viewWithTag(222)
        button?.isHidden = true
        didStart = true
        statusLabel?.text = "Logging in user..."
        activityIndicator.startAnimating()
    }
    @objc func updateCounter() {
        if didStart && counter > 0 {
            counter -= 1
            n += 1
            if (Auth.auth().currentUser) != nil  {
                performSegue(withIdentifier: "LoginToHome", sender: self)
                loggedIn = true
                didStart = false

            }
        }
        else if didStart && (n * 3) == 15{
            
            if (Auth.auth().currentUser) != nil  {
                performSegue(withIdentifier: "LoginToHome", sender: self)
                loggedIn = true
                didStart = false

            }
            
        }
                   else if didStart && n % 45 == 0{
                statusLabel?.text = "Unable to login. Try again?"
                let button = self.view.viewWithTag(222)
                button?.isHidden = false
                activityIndicator.stopAnimating()
                didStart = false
                n = 0
            }
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        if (Auth.auth().currentUser) != nil{
            print("hai")
            loggedIn = true
            performSegue(withIdentifier: "LoginToHome", sender: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
        
    }
  
    
    
    
    
    
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        
        if segue.identifier == "LoginToHome" {
            let DestViewController = segue.destination as! UINavigationController
            let targetController = DestViewController.topViewController as! TabBarViewController
            first = appDelegate.returnFirst()
            targetController.data = data
            targetController.first = first
        }
    }
}
