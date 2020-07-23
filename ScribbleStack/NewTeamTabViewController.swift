//
//  NewTeamTabViewController.swift
//  ScribbleStacks
//
//  Created by Alex Cyr on 10/16/17.
//  Copyright © 2017 Alex Cyr. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleMobileAds




class NewTeamTabViewController: UIViewController {
    
    var loggedIn = false
    var coins: Int?
    
    
    @IBOutlet weak var bannerView: GADBannerView!
    @IBAction func newTeamButton(_ sender: Any) {
        if loggedIn == false{
            let loginAlert = UIAlertController(title: "Not Logged In", message: "You must be logged in to create a new team.", preferredStyle: UIAlertControllerStyle.alert)
            
            loginAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                
            }))
            present(loginAlert, animated: true, completion: nil)
        }
    }
    
    @IBOutlet weak var buttonOutlet: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let ads = UserDefaults.standard.bool(forKey: "ads")
        
        if ads{
            bannerView.adSize = kGADAdSizeSmartBannerPortrait
            bannerView.adUnitID = "ca-app-pub-4705463543336282/3929162414"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            
            
        }
        else{
            bannerView.frame.size.height = 0
            bannerView.isHidden = true
            print("not free")
        }
        if Auth.auth().currentUser != nil{
            loggedIn = true

        }
          else{
            buttonOutlet.setTitleColor(UIColorFromRGB(rgbValue: 0xAAAAAA), for: .normal)
            buttonOutlet.backgroundColor = UIColorFromRGB(rgbValue: 0xF1F1F2)
            loggedIn = false
        }
      /*
        let team1 = self.view.viewWithTag(111) as! UIImageView
        let team2 = self.view.viewWithTag(112) as! UIImageView
        
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y",
                                                               type: .tiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -30
        verticalMotionEffect.maximumRelativeValue = 30
        
        // Set horizontal effect
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x",
                                                                 type: .tiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -30
        horizontalMotionEffect.maximumRelativeValue = 30
        
        // Create group to combine both
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        
        // Add both effects to your view
        team1.addMotionEffect(group)
        let verticalMotionEffect2 = UIInterpolatingMotionEffect(keyPath: "center.y",
                                                                type: .tiltAlongVerticalAxis)
        verticalMotionEffect2.minimumRelativeValue = -10
        verticalMotionEffect2.maximumRelativeValue = 10
        
        // Set horizontal effect
        let horizontalMotionEffect2 = UIInterpolatingMotionEffect(keyPath: "center.x",
                                                                  type: .tiltAlongHorizontalAxis)
        horizontalMotionEffect2.minimumRelativeValue = -10
        horizontalMotionEffect2.maximumRelativeValue = 10
        
        // Create group to combine both
        let group2 = UIMotionEffectGroup()
        
        group2.motionEffects = [horizontalMotionEffect2, verticalMotionEffect2]
        team2.addMotionEffect(group2)
        */
        
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "TeamToName" {
            
            
            
            let controller = segue.destination as! TeamNameViewController
            
            controller.coins = coins
            
            
        }
 
        
    }
    
}


