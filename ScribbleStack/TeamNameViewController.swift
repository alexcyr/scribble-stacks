//
//  TeamNameViewController.swift
//  ScribbleStack
//
//  Created by Alex Cyr on 11/20/16.
//  Copyright © 2016 Alex Cyr. All rights reserved.
//

import UIKit

import FirebaseAuth
import FirebaseDatabase


class TeamNameViewController: UIViewController {
    
    var name: String?
    var ref: DatabaseReference!
    var teamID: String!
    var changeName: Bool!
    var team: Team?
    var coins: Int?
     
    
    @IBOutlet weak var teamName: UITextField!
    
    @IBAction func nextButton(_ sender: AnyObject) {
        if (teamName.text != ""){
            
            if let user  = Auth.auth().currentUser{
                let userID: String = user.uid
                if changeName != true{
                    name = teamName.text
                    let nsName = NSString(string: name!)
                    let interval = ServerValue.timestamp()
                    teamID = ref.child("Teams").childByAutoId().key
                    let post = ["team": nsName,
                                "time": interval] as [String : Any]
                    
                    let childUpdates = ["/Teams/\(teamID!)/teamInfo": post]
                    ref.updateChildValues(childUpdates)
                    
                    self.ref.child("Teams/\(teamID!)/teamInfo/users").child("\(userID)").setValue(["activeGame": false])
                    self.ref.child("Users").child(userID).child("Teams").child("\(teamID!)").setValue([true])
                    
                    performSegue(withIdentifier: "teamToInvite", sender: self)
                }
                    
                else{
                    if teamID != nil{
                        name = teamName.text
                        let nsName = NSString(string: name!)
                        self.ref.child("Teams/\(teamID!)/teamInfo/team").setValue("\(nsName)")
                        self.team!.teamName = name!
                        performSegue(withIdentifier: "unwindToTeam", sender: self)
                    }
                }
            }
        }
        else{
            let refreshAlert = UIAlertController(title: "TEAM NAME BLANK", message: "You need a name for your team to continue.", preferredStyle: UIAlertControllerStyle.alert)
            
            
            
            refreshAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction!) in
                
                
                
                
            }))
            
            present(refreshAlert, animated: true, completion: nil)
            
        }
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        teamName.isEnabled = true
        teamName.becomeFirstResponder()
        //self.view.backgroundColor = UIColorFromRGB(rgbValue: 0xE6E7E8)
        
        //navbar logo
        let image = UIImage(named: "scribble-logo-light.png")
        let logoView = UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
        let imageView = UIImageView(frame: CGRect(x: -45, y: -8, width: 90, height: 46))
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        logoView.addSubview(imageView)
        self.navigationItem.titleView = logoView
        
        //coins
        let attachment = NSTextAttachment()
        attachment.bounds = CGRect(x: 0, y: -8,width: 30,height: 30);
        attachment.image = UIImage(named: "bobCoin.png")
        let attachmentString = NSAttributedString(attachment: attachment)
        var attributes = [NSAttributedStringKey: AnyObject]()
        attributes[NSAttributedStringKey.foregroundColor] = UIColorFromRGB(rgbValue: 0xF9A919)
        let myString = NSMutableAttributedString(string: "\(self.coins!) ", attributes: attributes)
        myString.append(attachmentString)
        
        let label = UILabel()
        label.attributedText = myString
        label.sizeToFit()
        let newBackButton = UIBarButtonItem(customView: label)
        
        if let font = UIFont(name: "BungeeShade-Regular", size: 15) {
            newBackButton.setTitleTextAttributes([NSAttributedStringKey.font:font], for: .normal)
        }
        self.navigationItem.rightBarButtonItem = newBackButton
   
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let user  = Auth.auth().currentUser{
            let userID: String = user.uid
            if changeName == nil{

            if teamID != nil{
                print(teamID)
                ref.child("Teams").child(teamID).removeValue { (error, ref) in
                    if error != nil {
                        print("error \(error ?? ": something went wrong" as! Error)")
                    }
                }
                ref.child("Users").child(userID).child("Teams").child(teamID).removeValue { (error, ref) in
                    if error != nil {
                        print("error \(error ?? ": something went wrong" as! Error)")
                    }
                }
                teamID = nil
                
            }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "teamToInvite" {
            let controller = segue.destination as! InviteViewController
            controller.teamID = teamID
            controller.teamName = teamName.text
            controller.coins = coins
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        }
        if segue.identifier == "unwindToTeam" {
            let controller = segue.destination as! TeamViewController
            controller.teamID = teamID
            controller.team = self.team
        }
    }

}
