//
//  TeamViewController.swift
//  ScribbleStacks
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

protocol RecentGamesButtonCellDelegate {
    func leftcellTapped(cell: RecentGamesButtonCell)
    func rightcellTapped(cell: RecentGamesButtonCell)
    
}
class RecentGamesButtonCell: UITableViewCell {
    
    var buttonDelegate: RecentGamesButtonCellDelegate?
 
    @IBOutlet weak var leftButtonOutlet: UIButton!
    @IBOutlet weak var rightButtonOutlet: UIButton!
    
    @IBAction func leftbuttonTap(_ sender: AnyObject) {
        
        if let delegate = buttonDelegate {
            delegate.leftcellTapped(cell: self)
            
        }
    }
    
    @IBAction func rightButtonTap(_ sender: AnyObject) {
        if let delegate = buttonDelegate {
            delegate.rightcellTapped(cell: self)
        }
    }
    
}



class TeamViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,  GIDSignInDelegate, GIDSignInUIDelegate, InviteDelegate, RecentGamesButtonCellDelegate   {
    
    
    
    @IBOutlet weak var playGameButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var homeLabel: UILabel!
    var data : String = ""
    var users: [String] = []
    var recentGames: [NSString] = []
    var recentGameID: [String] = []
    var usernames: [String] = []
    var ref: DatabaseReference?
    var teamID: String!
    var team: Team!
    var tableData: [String] = []
    var ready = false
    var customUrl = ""
    var encodedURL = ""
    var changeName: Bool!
    var teamTitle = ""
    var base64String: NSString!
    var decodedImage: UIImage!
    var selectedGame: String = ""
    var coins: Int?
    var recentPresent = false
    var userID = ""
    
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var teamName: UITextField!
    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var statusText: UILabel!
    
    @IBAction func unwindToTeam(segue: UIStoryboardSegue) {}
    
    @IBAction func deleteTeam(_ sender: Any) {
        let refreshAlert = UIAlertController(title: "Delete Team?", message: "Do you wish to remove yourself from this team?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            
            
                let coinAlert = UIAlertController(title: "Are You Sure?", message: "This cannot be undone.", preferredStyle: UIAlertControllerStyle.alert)
            
                coinAlert.addAction(UIAlertAction(title: "Yes I'm Sure", style: .default, handler: { (action: UIAlertAction!) in
                    self.ref?.child("Teams").child(self.teamID).child("teamInfo").child("users").child(self.userID).removeValue { (error, ref) in
                        if error != nil {
                            print("error \(error ?? ": something went wrong" as! Error)")
                        }
                    }
                    self.ref?.child("Users").child(self.userID).child("Teams").child(self.teamID).removeValue { (error, ref) in
                        if error != nil {
                            print("error \(error ?? ": something went wrong" as! Error)")
                        }
                    }
                    self.performSegue(withIdentifier: "DeleteToHome", sender: self)

                }))
            coinAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            }))
                
                self.present(coinAlert, animated: true, completion: nil)
            
           
        }))
        
        
        
        present(refreshAlert, animated: true, completion: nil)
        
    }
    func buttonTap(){
        
    }
    func leftCellTapped(cell: RecentGamesButtonCell){
        
    }
    func rightCellTapped(cell: RecentGamesButtonCell){
        
        
    }
    @IBAction func playGamePressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "TeamToBuffer", sender: self)

    }
    
    func leftcellTapped(cell: RecentGamesButtonCell){
        let cellRow = self.tableView.indexPath(for: cell)!.row
        self.selectedGame = recentGameID[(2 * cellRow)]
        performSegue(withIdentifier: "ViewGame", sender: self)

    }
    func rightcellTapped(cell: RecentGamesButtonCell){
        let cellRow = self.tableView.indexPath(for: cell)!.row
        self.selectedGame = recentGameID[(2 * cellRow) + 1]
        performSegue(withIdentifier: "ViewGame", sender: self)

        
    }
    
    @IBAction func changeTeamName(_ sender: AnyObject) {
        let refreshAlert = UIAlertController(title: "Change Team Name", message: "Do you want to change team name for 20 coins?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            
            if self.coins! < 20{
                let coinAlert = UIAlertController(title: "Sorry!", message: "You don't have enough coins.", preferredStyle: UIAlertControllerStyle.alert)
                
                coinAlert.addAction(UIAlertAction(title: "Okay.", style: .default, handler: { (action: UIAlertAction!) in
                    
                }))

                self.present(coinAlert, animated: true, completion: nil)
            }
            else{
            self.changeName = true
            
            self.performSegue(withIdentifier: "ToTeamName", sender: self)
            }
        }))
        
        
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColorFromRGB(rgbValue: 0xffffff)
        self.tableView.backgroundColor = UIColorFromRGB(rgbValue: 0xffffff)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.allowsSelection = false

        ref = Database.database().reference()

        
        customUrl = "http://ScribbleStacks.com/teamID=\(teamID!)"
        encodedURL = customUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        print(encodedURL)
        
        //navbar logo
        let image = UIImage(named: "scribble-logo-light.png")
        let logoView = UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
        let imageView = UIImageView(frame: CGRect(x: -45, y: -8, width: 90, height: 46))
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        logoView.addSubview(imageView)
        self.navigationItem.titleView = logoView
        
        let earnedCoins = UserDefaults.standard.integer(forKey: "earnedCoins")
        self.coins = earnedCoins
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let group1 = DispatchGroup()
        group1.enter()
        if let user  = Auth.auth().currentUser{
            userID = user.uid
            print("poop")
            print(userID)

            self.ref?.child("Users/\(userID)").observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                if snapshot.hasChildren(){
                    let snap = snapshot.value! as! NSDictionary
                    let dbCoins = (snap["currency"] as! Int)
                    self.coins = self.coins! + dbCoins
                    print("poop")
                   
                    group1.leave()
                }
                
                
                
                
            })
            
            group1.notify(queue: DispatchQueue.main, execute: {
        
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
        self.navigationItem.rightBarButtonItem = newBackButton
        
            })
        
        }
        
        
        
        
        
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
        self.navigationItem.rightBarButtonItem = newBackButton
        
        
        print("poop")
        let group2 = DispatchGroup()
        
        if let user  = Auth.auth().currentUser{
            userID = user.uid
            print("poop")
            print(userID)
            
            var teamCount = 0
            
            
            data = teamID!
            print(teamID)
            print(teamID)
            print("beta")
            group2.enter()
            teamCount += 1
            print(data)
            print(data)
            
            group2.enter()
            self.usernames.removeAll()
            var n = 0
            
            for id in team.users{
                self.ref?.child("Users/\(id)").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let nameData = snapshot.value as? NSDictionary
                    let username = (nameData?["username"]! as? String)!                    
                    self.usernames.append(username)
                    print("pandapandapanda")
                    print(username)
                    
                    n += 1
                    
                    if n >= self.team.users.count{
                        print("potato")
                        group2.leave()
                        self.tableData.removeAll()
                        self.tableData = self.usernames
                        print(self.tableData)
                        self.tableView.reloadData()
                    }
                })
            }
            
            
            
            self.title = team.teamName
            self.teamTitle = team.teamName
            
            
            
            
            
            /*
             let query = self.ref?.child("Teams/\(self.data)/games").queryOrderedByValue().queryEqual(toValue: true)
             
             query?.observeSingleEvent(of: .value, with: { (snapshot2) in
             
             
             if snapshot2.value is NSNull {
             print("This path was null!")
             self.tableData.removeAll()
             self.tableData = self.usernames
             print(self.tableData)
             self.tableView.reloadData()
             
             }
             else {
             let gameIDSnap = snapshot2.value! as! NSDictionary
             print("taco")
             print(gameIDSnap)
             let gameIDs = Array(gameIDSnap.allKeys)
             print(gameIDs)
             
             
             for gameID in gameIDs{
             
             
             
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
             
             }
             group2.notify(queue: DispatchQueue.main, execute: {
             print("Finish game loop")
             
             
             
             
             
             print("Dandy")
             print(self.users)
             
             self.tableData.removeAll()
             self.tableData = self.usernames
             print(self.tableData)
             self.tableView.reloadData()
             
             
             
             })
             
             })
             
             }}
             
             })*/
                print("step")
            if self.recentGames.isEmpty{
                print("one")

                let recentQuery = self.ref?.child("Teams/\(self.data)/games").queryOrderedByValue().queryEqual(toValue: false).queryLimited(toLast: 10)
                
                recentQuery?.observeSingleEvent(of: .value, with: { (snapshot2) in
                    
                    
                    if snapshot2.value is NSNull {
                        print("This path was null!")
                        
                    }
                    else {
                        self.recentGames.removeAll()
                        self.recentGameID.removeAll()
                        let gameIDSnap = snapshot2.value! as! NSDictionary
                        print("dankey kang")
                        print(gameIDSnap)
                        let gameIDs = Array(gameIDSnap.allKeys) as! [String]
                        print(gameIDs)
                        var sortedGames = gameIDs.sorted()
                        sortedGames.reverse()
                        
                        for gameID in sortedGames{
                            self.recentGameID.append(gameID)
                            self.ref?.child("Games/\(gameID)").observeSingleEvent(of: .value, with: { (snapshot4) in
                                print("snapdragon")
                                
                                print(snapshot4)
                                let gameData = snapshot4.value as? NSDictionary
                                let turnData = (gameData?["turns"]! as? NSDictionary)!
                                let turnKeys = Array(turnData.allKeys) as AnyObject as! [String]
                                let sortedArray = turnKeys.sorted()
                                var turns: [NSDictionary] = []
                                for key in sortedArray{
                                    turns.append(turnData["\(key)"] as! NSDictionary)
                                }
                                
                                // let turns = Array(turnData.allValues)
                                print(turns)
                                print("blue cheese")
                                
                                let turn = turns[1] as NSDictionary
                                
                                let turnImage = (turn["content"]! as? NSString)
                                self.recentGames.append(turnImage!)
                                if self.recentGames.count == gameIDs.count{
                                    self.tableView.reloadData()
                                }
                            })
                        }
                    }
                })
            }
            
            
        }
        
        
    
        
        

    }
    

    
    @objc private func addTapped(_ sender: UIButton?){
        GIDSignIn.sharedInstance().delegate = self
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            // Signed in
            if let invite = Invites.inviteDialog() {
                invite.setInviteDelegate(self)
                
                // NOTE: You must have the App Store ID set in your developer console project
                // in order for invitations to successfully be sent.
                
                // A message hint for the dialog. Note this manifests differently depending on the
                // received invation type. For example, in an email invite this appears as the subject.
                invite.setMessage("You've been invited to join team \(self.teamName!) in Scribble Stacks!")
                // Title for the dialog, this is what the user sees before sending the invites.
                invite.setTitle("Invite Friends")
                invite.setDeepLink("\(encodedURL)")
                invite.setCallToActionText("Install!")
                invite.setCustomImage("https://farm5.staticflickr.com/4767/40197564072_7528c2e158_z.jpg")
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
    func numberOfSections(in: UITableView) -> Int {
        if recentGames.count == 0{
            return 3
        }
        else{
            recentPresent = true
        return 4
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < 1{
             return 1
        }
        else if section == 1{
            print("arghhh mateee")
            print(tableData.count)
            return usernames.count
        }
        else if section == 2 && recentPresent{
            let rowCount = recentGames.count
            if (rowCount%2) == 0{
                return (rowCount/2)
            }
            else{
                return (rowCount/2) + 1
            }
            
        }
        else{
            return 1
        }
    }
    let headerTitles = ["", "TEAM MEMBERS", "RECENT GAMES", ""]
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            let view = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:0))
            return view
            
        }
        else if section == 1{
            let button = UIButton(frame: CGRect(x:tableView.frame.size.width - 150, y:6, width:150, height:30))
            button.addTarget(self, action: #selector(addTapped(_:)), for: .touchUpInside)
            button.titleLabel?.textAlignment = NSTextAlignment.right
           // button.semanticContentAttribute = .forceRightToLeft
            button.setTitle("+ADD PLAYERS", for: .normal)
            button.setTitleColor(UIColorFromRGB(rgbValue: 0x01A8B9), for: .normal)
            button.titleLabelFont = UIFont(name: "Rajdhani-Bold", size: 18)
            
            let view = UIView(frame: CGRect(x:15, y:0, width:tableView.frame.size.width - 30, height:30))
            let label = UILabel(frame: CGRect(x:15, y:6, width:tableView.frame.size.width - 30, height:30))
            let line = UIView(frame: CGRect(x:15, y:15, width:tableView.frame.size.width - 30, height:30))
            line.bounds = CGRect(x: 15, y: -8, width: self.view.frame.width - 30, height: 1)
            line.backgroundColor = UIColorFromRGB(rgbValue: 0xF9A919)
            print("im in ny")
            print(section)
            label.text = "\(headerTitles[section])"
            
            
            
            label.font = UIFont(name: "Rajdhani-Bold", size: 14)
            label.textColor = UIColorFromRGB(rgbValue: 0xF9A919)
            view.addSubview(button)
            view.addSubview(label)
            view.addSubview(line)
            view.backgroundColor = UIColor.white;
            return view
        }
        else if section == 2 && recentPresent{
            let view = UIView(frame: CGRect(x:15, y:0, width:tableView.frame.size.width - 30, height:30))
            let label = UILabel(frame: CGRect(x:15, y:6, width:tableView.frame.size.width - 30, height:30))
            let line = UIView(frame: CGRect(x:15, y:15, width:tableView.frame.size.width - 30, height:30))
            line.bounds = CGRect(x: 15, y: -8, width: self.view.frame.width - 30, height: 1)
            line.backgroundColor = UIColorFromRGB(rgbValue: 0xF9A919)
            print("im in ny")
            print(section)
            label.text = "\(headerTitles[section])"
            
            
            
            label.font = UIFont(name: "Rajdhani-Bold", size: 14)
            label.textColor = UIColorFromRGB(rgbValue: 0xF9A919)
            view.addSubview(label)
            view.addSubview(line)
            view.backgroundColor = UIColor.white;
            return view
        }
        else{
            let view = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:0))
            return view
        }
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0
            
        }
        else if section == 1{
            return 35
        }
        else if section == 2 && recentPresent{
            return 35
        }
        else {
            return 0
            
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section
        {
        case 0:
            return headerTitles[0]
        case 1:
            return headerTitles[1]
        case 2:
            if recentPresent{
            return headerTitles[2]
            }
            else{
                return headerTitles[3]
            }
        case 3:
            return headerTitles[3]
        default:
            return "No More Data"
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let n = indexPath.section
       
            if(n == 0){
                return 138.0
            }
            else if n == 1{
                    return 25.0
            }
            else if n == 2 && recentPresent{
                return (UIScreen.main.bounds.width / 2)
                
            }
        else{
            return 138.0
        }
        
         
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let n = indexPath.row
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "TeamNameCell", for: indexPath as IndexPath)
            cell.contentView.backgroundColor = UIColorFromRGB(rgbValue: 0xffffff)

            let label = cell.viewWithTag(25) as! UILabel
            
            label.text = self.teamTitle

            return cell
        }
        else if indexPath.section == 1{
            let cellText = usernames[n]
            print("holy roller")
            print(cellText)
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "WordSelect", for: indexPath as IndexPath)
            cell.contentView.backgroundColor = UIColorFromRGB(rgbValue: 0xffffff)
            //cell.layer.borderColor = UIColorFromRGB(rgbValue: 0xE6E7E8).cgColor
            //cell.layer.borderWidth = 1

        let label = cell.viewWithTag(1000) as! UILabel
        
        
        label.text = cellText
       
        
        
        return cell
        }
        else if indexPath.section == 2 && recentPresent{
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "RecentGames", for: indexPath as IndexPath) as! RecentGamesButtonCell
            cell.contentView.backgroundColor = UIColorFromRGB(rgbValue: 0xffffff)
            
            
            
            if cell.buttonDelegate == nil {
                cell.buttonDelegate = self
            }
            
           
            
       
           //left image
            print("count54321")

            print(recentGames.count)
            print(recentGames)
            if (recentGames[2 * n] as NSString!) != nil{
            self.base64String = recentGames[2 * n] as NSString!
            var decodedData = NSData(base64Encoded: self.base64String as String, options: NSData.Base64DecodingOptions())
                if decodedData != nil{
            self.decodedImage = UIImage(data: decodedData! as Data)!
                }
            var gameImage = self.decodedImage!
            cell.leftButtonOutlet.setImage(gameImage.withRenderingMode(.alwaysOriginal), for: .normal)
                cell.leftButtonOutlet.layer.borderColor = UIColorFromRGB(rgbValue: 0xE6E7E8).cgColor
                cell.leftButtonOutlet.layer.borderWidth = 1

            //right image
             if (recentGames.count)%2 != 0{
                if (recentGames.count/2 == n){
                    cell.rightButtonOutlet.isHidden = true
                }
                    
                else{
            self.base64String = recentGames[(2 * n) + 1] as NSString!
            decodedData = NSData(base64Encoded: self.base64String as String, options: NSData.Base64DecodingOptions())
            self.decodedImage = UIImage(data: decodedData! as Data)!
            gameImage = self.decodedImage!
            cell.rightButtonOutlet.setImage(gameImage.withRenderingMode(.alwaysOriginal), for: .normal)
                    cell.rightButtonOutlet.layer.borderColor = UIColorFromRGB(rgbValue: 0xE6E7E8).cgColor
                    cell.rightButtonOutlet.layer.borderWidth = 1

            }
            }
             else{
                self.base64String = recentGames[(2 * n) + 1] as NSString!
                decodedData = NSData(base64Encoded: self.base64String as String, options: NSData.Base64DecodingOptions())
                self.decodedImage = UIImage(data: decodedData! as Data)!
                gameImage = self.decodedImage!
                cell.rightButtonOutlet.setImage(gameImage.withRenderingMode(.alwaysOriginal), for: .normal)
                cell.rightButtonOutlet.layer.borderColor = UIColorFromRGB(rgbValue: 0xE6E7E8).cgColor
                cell.rightButtonOutlet.layer.borderWidth = 1
                }}
            return cell

        }
        else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "DeleteCell", for: indexPath as IndexPath)
            cell.contentView.backgroundColor = UIColorFromRGB(rgbValue: 0xffffff)
            
            
            
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
                controller.team = team
                controller.coins = self.coins

                self.ref?.removeAllObservers()
                
            }
            
        }
        if segue.identifier == "ViewGame" {
            
            let controller = segue.destination as! EndGameViewController
            if teamID != nil{
                controller.gameID = selectedGame
                
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
                if (user.profile.name) != nil {
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
    private func inviteFinished(withInvitations invitationIds: [Any], error: Error?) {
            if let error = error {
                print("Failed: " + error.localizedDescription)
            } else {
                print("Invitations sent")
            }
        }
    
 
}
