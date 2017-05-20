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
    var ref: FIRDatabaseReference!
    var loggedIn = false
    var counter = 3
    var didStart = false
    
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue){
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
 
        if (FIRAuth.auth()?.currentUser) != nil  {
        statusLabel?.text = "Loading user data..."
        loggedIn = true
       activityIndicator.startAnimating()

       } else {
       
        setupGoogleButtons()
        
        
        ref = FIRDatabase.database().reference()

       
       
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
    
    func googlePressed(button: UIButton){
        let button = self.view.viewWithTag(222)
        button?.isHidden = true
        didStart = true
        statusLabel?.text = "Logging in user..."
        activityIndicator.startAnimating()
    }
    func updateCounter() {
        if didStart && counter > 0 {
            counter -= 1
            
        }
        else if didStart && counter == 3{
            
            if (FIRAuth.auth()?.currentUser) != nil  {
                performSegue(withIdentifier: "LoginToHome", sender: self)
                
            }
            
        }
        else if didStart && counter == 0{
            didStart = false
            counter = 3
            if (FIRAuth.auth()?.currentUser) != nil  {
                performSegue(withIdentifier: "LoginToHome", sender: self)
                
            }
            else{
                statusLabel?.text = "Unable to login. Try again?"
                let button = self.view.viewWithTag(222)
                button?.isHidden = false
                activityIndicator.stopAnimating()
            }
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {
        if (FIRAuth.auth()?.currentUser) != nil{
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
            let targetController = DestViewController.topViewController as! HomeViewController
            
            targetController.data = data
        }
    }
}
