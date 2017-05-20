//
//  TeamViewController.swift
//  ScribbleStack
//
//  Created by Alex Cyr on 12/15/16.
//  Copyright © 2016 Alex Cyr. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Firebase
import GoogleSignIn
import FirebaseInvites
import FirebaseDynamicLinks



class TeamViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,  GIDSignInDelegate, GIDSignInUIDelegate, FIRInviteDelegate   {
    
    
    @IBOutlet weak var playGameButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var homeLabel: UILabel!
    var data : String = ""
    var users: [String] = []
    var usernames: [String] = []
    var ref: FIRDatabaseReference?
    var teamID: String!
    var tableData: [String] = []
    var ready = false
    var customUrl = ""
    var encodedURL = ""
    var changeName: Bool!
    var teamTitle = ""
    
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var teamName: UITextField!
    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var statusText: UILabel!
    
    @IBAction func unwindToTeam(segue: UIStoryboardSegue) {}

    
    @IBAction func playGamePressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "TeamToBuffer", sender: self)

    }
   
    @IBAction func changeTeamName(_ sender: AnyObject) {
        let refreshAlert = UIAlertController(title: "Change Team Name", message: "Do you want to change team name for 20💰?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.changeName = true
            self.performSegue(withIdentifier: "ToTeamName", sender: self)
            
        }))
        
        
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColorFromRGB(rgbValue: 0xE6E7E8)

        customUrl = "http://scribblestack.com/teamID=\(teamID!)"
        encodedURL = customUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        print(encodedURL)
        
        //navbar logo
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "scribble-logo.png")
        imageView.image = image
        navigationItem.titleView = imageView

        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))

        
        ref = FIRDatabase.database().reference()
        
        
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signInSilently()
        toggleAuthUI()
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillAppear(animated)
        
        self.usernames.removeAll()
        
        print("poop")
        let group1 = DispatchGroup()
        let group2 = DispatchGroup()
        
        if let user  = FIRAuth.auth()?.currentUser{
            let userID: String = user.uid
            print("poop")
            print(userID)
            
            var teamTotal = 0
            var teamCount = 0
            var teamGameCount = 0
            
            
            data = teamID!
            print(teamID)
            var teamUsers: [Any?] = []
            print(teamID)
            print("beta")
            group2.enter()
            teamCount += 1
            print(data)
            print(data)
            
            let team = Team(id: "", teamName: "", gameCount:0, userCount: 0, time: "")
            team.id = "\(data)"
            
            
            group1.enter()
            
            
            self.ref?.child("Teams/\(self.data)/users").observeSingleEvent(of: .value, with: { (snapshot) in
                
                let snap = snapshot.value! as! NSDictionary
                print("poop")
                print(snapshot.value)
                self.users = Array(snap.allKeys) as! [String]
                team.userCount = self.users.count
                group1.leave()
            })
            group1.notify(queue: DispatchQueue.main, execute: {
                group2.enter()
                for id in self.users{
                    var n = 0
                    self.ref?.child("Users/\(id)").observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        let nameData = snapshot.value as? NSDictionary
                        let username = (nameData?["username"]! as? String)!
                        self.usernames.append(username)
                    })
                    n += 1
                }
                group2.leave()
                
                
                self.ref?.child("Teams/\(self.data)").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let nameData = snapshot.value as? NSDictionary
                    team.teamName = (nameData?["team"]! as? String)!
                    self.title = team.teamName
                    let games = (nameData?["games"]! as? NSDictionary)!
                    
                    teamGameCount = games.count
                    print(team.teamName)
                    print(team.userCount)
                    print(team.gameCount)
                    self.title = team.teamName
                    self.teamTitle = team.teamName
                    
                })
                
                
                var count = 0
                self.ref?.child("Teams/\(self.data)/games").observe(.childAdded, with: { (snapshot2) in
                    
                    let gameID = snapshot2.key
                    print("taco")
                    
                    
                    self.ref?.child("Games/\(gameID)").observeSingleEvent(of: .value, with: { (snapshot3) in
                        
                        let gameData = snapshot3.value as? NSDictionary
                        let status = (gameData?["status"]! as? String)!
                        print(status)
                        print("puffy taco")
                        count += 1
                        if (status == "ended") || (status == "inplay"){
                            team.gameCount += 1
                            print(team.gameCount)
                            
                        }
                        print(Int(snapshot2.childrenCount))
                        
                        self.ready = true
                        print("mushu pork")
                        print(self.users)
                        print(team.gameCount)
                        if count == teamGameCount{
                            
                            if team.gameCount > 0 {
                                
                                print("spaceballs")
                                group2.leave()
                            } else{
                                
                                
                                print("spacebutt")
                                group2.leave()
                            }
                            
                            print(teamCount)
                            print("how dastardly")
                            
                            print(user)
                            group2.notify(queue: DispatchQueue.main, execute: {
                                print("Finish game loop")
                                
                                
                                
                                
                                
                                print("Dandy")
                                print(self.users)
                                
                                self.tableData.removeAll()
                                self.tableData = self.usernames
                                print(self.tableData)
                                self.tableView.reloadData()
                                
                                
                                
                            })
                        }
                        
                        
                    })
                    
                    
                    
                })
            })
            
        }
        
        
        
        
        
        

    }
    

    
    func addTapped(){
        GIDSignIn.sharedInstance().delegate = self
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            // Signed in
            if let invite = FIRInvites.inviteDialog() {
                invite.setInviteDelegate(self)
                
                // NOTE: You must have the App Store ID set in your developer console project
                // in order for invitations to successfully be sent.
                
                // A message hint for the dialog. Note this manifests differently depending on the
                // received invation type. For example, in an email invite this appears as the subject.
                invite.setMessage("Try this out!\n -\(GIDSignIn.sharedInstance().currentUser.profile.name!)")
                // Title for the dialog, this is what the user sees before sending the invites.
                invite.setTitle("Invite Friends")
                invite.setDeepLink("\(encodedURL)")
                invite.setCallToActionText("Install!")
                invite.setCustomImage("https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png")
                invite.open()
            }
            
        } else {
            
            let refreshAlert = UIAlertController(title: "Google Login Required", message: "Must be logged in with Google account to perform invites.", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                self.performSegue(withIdentifier: "ToMainMenu", sender: self)
            }))
            
           
            
            present(refreshAlert, animated: true, completion: nil)
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("section count")
       print(tableData.count)
        let count = tableData.count + 1
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < 1{
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "TeamNameCell", for: indexPath as IndexPath)
            
            let label = cell.viewWithTag(25) as! UILabel
            
            
            label.text = self.teamTitle
            
            
            
            return cell
        }
        else{
            let cellText = tableData[(indexPath.row)-1]
            print("holy roller")
            print(cellText)
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "WordSelect", for: indexPath as IndexPath)
        
        let label = cell.viewWithTag(1000) as! UILabel
        
        
        label.text = cellText
       
        
        
        return cell
        }
        
        //  Now do whatever you were going to do with the title.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TeamToBuffer" {
            
            let controller = segue.destination as! BufferScreenViewController
            if teamID != nil{
                controller.teamID = teamID
                self.ref?.removeAllObservers()
                
            }
            
        }
        if segue.identifier == "ToTeamName" {
            
            let controller = segue.destination as! TeamNameViewController
            if teamID != nil{
                controller.teamID = teamID
                controller.changeName = changeName

                self.ref?.removeAllObservers()
                
            }
            
        }
    }
    
        
    
        // [START signin_handler]
        func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
                // User Successfully signed in.
                if let name = user.profile.name {
                    print("Signed in")
                } else {
                    print("Signed in, profile name is not set")
                }
            }
            toggleAuthUI()
        }
        
        
        func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
            toggleAuthUI()
        }
        
    
    
        
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        super.viewWillDisappear(animated)
        
        
    }
        
        func toggleAuthUI() {
            
        }
        // [END toggle_auth]
        // [START invite_finished]
        func inviteFinished(withInvitations invitationIds: [Any], error: Error?) {
            if let error = error {
                print("Failed: " + error.localizedDescription)
            } else {
                print("Invitations sent")
            }
        }
    
 
}
