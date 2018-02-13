//
//  TabBarViewController.swift
//  ScribbleStacks
//
//  Created by Alex Cyr on 7/13/17.
//  Copyright © 2017 Alex Cyr. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import NVActivityIndicatorView
import SwipeableTabBarController

extension UIView {
    
    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.topAnchor
        } else {
            return self.topAnchor
        }
    }
    
    var safeLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.leftAnchor
        }else {
            return self.leftAnchor
        }
    }
    
    var safeRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *){
            return self.safeAreaLayoutGuide.rightAnchor
        }else {
            return self.rightAnchor
        }
    }
    
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.bottomAnchor
        } else {
            return self.bottomAnchor
        }
    }
}


class TabBarViewController: SwipeableTabBarController {
    
    var userID = ""
    var data : String!
    var first: Bool!
    var coins = 0
  
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDiagonalSwipe(enabled: true)
        if let testController = self.viewControllers?[0] as? HomeViewController{
            testController.data = data
            testController.first = first
            
        }
        
        
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.view.backgroundColor = UIColorFromRGB(rgbValue: 0xffffff)
  
      
        let attachment = NSTextAttachment()
        attachment.bounds = CGRect(x: 0, y: -8,width: 30,height: 30);
        attachment.image = UIImage(named: "bobCoin.png")
        let attachmentString = NSAttributedString(attachment: attachment)
        var attributes = [NSAttributedStringKey: AnyObject]()
        attributes[NSAttributedStringKey.foregroundColor] = UIColor.white
        let myString = NSMutableAttributedString(string: "0", attributes: attributes)
        myString.append(attachmentString)
        
        let label = UILabel()
        label.attributedText = myString
        label.sizeToFit()
        let newBackButton = UIBarButtonItem(customView: label)
        
        self.navigationItem.rightBarButtonItem = newBackButton
        
       
        let button:UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 22, height: 18))
      
        button.setImage(UIImage(named: "hamburger.png"), for: .normal)
        button.addTarget(self, action:#selector(self.menuTapped), for: .touchUpInside)
        button.contentMode = .scaleAspectFit
        button.imageView?.contentMode = .scaleAspectFit
       
        let widthConstraint = button.widthAnchor.constraint(equalToConstant: 32)
        let heightConstraint = button.heightAnchor.constraint(equalToConstant: 32)
        heightConstraint.isActive = true
        widthConstraint.isActive = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        //navigationItem.largeTitleDisplayMode = .automatic
        
        //navbar logo
        
        let image = UIImage(named: "scribble-logo-light.png")
        let logoView = UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
        let imageView = UIImageView(frame: CGRect(x: -45, y: -8, width: 90, height: 46))
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        logoView.addSubview(imageView)
        self.navigationItem.titleView = logoView
        
        
       
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
    }
    override func viewWillAppear(_ animated: Bool) {
        let earnedCoins = UserDefaults.standard.integer(forKey: "earnedCoins")
        self.coins = earnedCoins
        let group1 = DispatchGroup()
        group1.enter()
        
        if let user  = Auth.auth().currentUser{
            
            let ref = Database.database().reference()
            userID = user.uid
            print("poop")
            print(userID)
           
            ref.child("Users/\(userID)").observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                if snapshot.hasChildren(){
                    let snap = snapshot.value! as! NSDictionary
                    print("poop")
                    let dbCoins = (snap["currency"] as! Int)
                    self.coins = self.coins + dbCoins
                    group1.leave()
                    if (snap["Teams"] as? NSDictionary) != nil{
                        
                        
                    }
                    else{
                        
                    }
                    
                }
                
                
                
                
            })
            
            
                    
                    
            
                
            
            
        }
        else{
            group1.leave()
        }
        
    group1.notify(queue: DispatchQueue.main, execute: {

        
        let attachment = NSTextAttachment()
        attachment.bounds = CGRect(x: 0, y: -8,width: 30,height: 30);
        attachment.image = UIImage(named: "bobCoin.png")
        let attachmentString = NSAttributedString(attachment: attachment)
        var attributes = [NSAttributedStringKey: AnyObject]()
        attributes[NSAttributedStringKey.foregroundColor] = UIColorFromRGB(rgbValue: 0xF9A919)
        let myString = NSMutableAttributedString(string: "\(self.coins) ", attributes: attributes)
        myString.append(attachmentString)
        
        let label = UILabel()
        label.attributedText = myString
        label.sizeToFit()
        let newBackButton = UIBarButtonItem(customView: label)
        self.navigationItem.rightBarButtonItem = newBackButton
        
        if let teamController = self.viewControllers?[1] as? NewTeamTabViewController{
            teamController.coins = self.coins
        }
        })
    }
    
    fileprivate func setCoins() {
        let attachment = NSTextAttachment()
        attachment.bounds = CGRect(x: 0, y: -8,width: 30,height: 30);
        attachment.image = UIImage(named: "bobCoin.png")
        let attachmentString = NSAttributedString(attachment: attachment)
        var attributes = [NSAttributedStringKey: AnyObject]()
        attributes[NSAttributedStringKey.foregroundColor] = UIColorFromRGB(rgbValue: 0xF9A919)
        let myString = NSMutableAttributedString(string: "\(self.coins) ", attributes: attributes)
        myString.append(attachmentString)
        
        let label = UILabel()
        label.attributedText = myString
        label.sizeToFit()
        let newBackButton = UIBarButtonItem(customView: label)
        
        
        self.navigationItem.rightBarButtonItem = newBackButton
    }
    @objc func menuTapped(){
        performSegue(withIdentifier: "ToSideMenu", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
        if segue.identifier == "TeamToName" {
            
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem

            let controller = segue.destination as! TeamNameViewController
            
            controller.coins = coins
            
            
        }
        if segue.identifier == "ToSideMenu" {
            
            let DestViewController = segue.destination as! UINavigationController
            let targetController = DestViewController.topViewController as! SideMenuViewController
            targetController.coins = coins
        
            
        }
        if segue.identifier == "ShowTeamView" {
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            
            let controller = segue.destination as! TeamViewController
            
            
            controller.coins = self.coins
            
            
        }
        
    
    }
}
