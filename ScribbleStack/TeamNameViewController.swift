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
    var ref: FIRDatabaseReference!
    var teamID: String!
    var changeName: Bool!
     
    
    @IBOutlet weak var teamName: UITextField!
    
    @IBAction func nextButton(_ sender: AnyObject) {
    if let user  = FIRAuth.auth()?.currentUser{
        let userID: String = user.uid
        if (teamName.text != nil){
        if changeName != true{
        name = teamName.text
        let nsName = NSString(string: name!)
        let interval = FIRServerValue.timestamp()
        teamID = ref.child("Teams").childByAutoId().key
        let post = ["team": nsName,
                    "time": interval] as [String : Any]
        
        let childUpdates = ["/Teams/\(teamID!)": post]
        ref.updateChildValues(childUpdates)
        
        self.ref.child("Teams/\(teamID!)/users").child("\(userID)").setValue([true])
        self.ref.child("Users").child(userID).child("Teams").child("\(teamID!)").setValue([true])

        performSegue(withIdentifier: "teamToInvite", sender: self)
        }
        
        else{
        if teamID != nil{
            name = teamName.text
            let nsName = NSString(string: name!)
            self.ref.child("Teams/\(teamID!)/team").setValue("\(nsName)")
            performSegue(withIdentifier: "unwindToTeam", sender: self)
        }
        }
            }
    }
    else{
        
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        self.view.backgroundColor = UIColorFromRGB(rgbValue: 0xE6E7E8)
        
       

        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        if let user  = FIRAuth.auth()?.currentUser{
            let userID: String = user.uid
            if changeName == nil{

            if teamID != nil{
                print(teamID)
                ref.child("Teams").child(teamID).removeValue { (error, ref) in
                    if error != nil {
                        print("error \(error)")
                    }
                }
                ref.child("Users").child(userID).child("Teams").child(teamID).removeValue { (error, ref) in
                    if error != nil {
                        print("error \(error)")
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
        }
        if segue.identifier == "unwindToTeam" {
            let controller = segue.destination as! TeamViewController
            controller.teamID = teamID
        }
    }

}
