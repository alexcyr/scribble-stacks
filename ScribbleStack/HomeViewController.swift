//
//  HomeViewController.swift
//  ScribbleStack
//
//  Created by Alex Cyr on 11/15/16.
//  Copyright © 2016 Alex Cyr. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase


class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var homeLabel: UILabel!
    var data : String!
    var playable: [Team] = []
    var pending: [Team] = []
    var ref: FIRDatabaseReference?
    var teamIDs: [Any] = []
    var teamID = "000000"
    var tableData: [[Team]] = []
    var ready = false
    var coins = 0
    var userID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.view.backgroundColor = UIColorFromRGB(rgbValue: 0xE6E7E8)
        self.tableView.backgroundColor = UIColorFromRGB(rgbValue: 0xE6E7E8)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Menu", style: .plain, target: self, action: #selector(menuTapped))
        
        //navbar logo
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "scribble-logo.png")
        imageView.image = image
        navigationItem.titleView = imageView
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        ref = FIRDatabase.database().reference()
        print("poop")
        
    }
    func barButtonItemClicked(sender: UIBarButtonItem) {
        print("clicked")
    }
    @IBAction func playPublicGame(_ sender: AnyObject) {
        teamID = "000000"
        
        performSegue(withIdentifier: "PublicGame", sender: self)

    }
    @IBAction func signOut(_ sender: AnyObject) {
        try! FIRAuth.auth()!.signOut()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.playable.removeAll()
        self.pending.removeAll()
        
        let group1 = DispatchGroup()
        let group2 = DispatchGroup()
        group1.enter()
        if let user  = FIRAuth.auth()?.currentUser{
            userID = user.uid
            print("poop")
            print(userID)
            
            var teamTotal = 0
            var teamCount = 0
            var teamGameCount = 0
            
            self.ref?.child("Users/\(userID)").observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                if snapshot.hasChildren(){
                    let snap = snapshot.value! as! NSDictionary
                    print("poop")
                    self.coins = (snap["currency"] as! Int)
                    let teamsData = (snap["Teams"] as! NSDictionary)
                    print(snapshot.value)
                    self.teamIDs = Array(teamsData.allKeys)
                    print(self.teamIDs)
                    print("baaaaah")
                    teamTotal = self.teamIDs.count
                    print(teamTotal)
                    group1.leave()
                }
                
                
                
                
            })
            
            group1.notify(queue: DispatchQueue.main, execute: {
                let attachment = NSTextAttachment()
                attachment.bounds = CGRect(x: 0, y: -8,width: 30,height: 30);
                attachment.image = UIImage(named: "bobCoin.png")
                let attachmentString = NSAttributedString(attachment: attachment)
                var attributes = [String: AnyObject]()
                attributes[NSForegroundColorAttributeName] = UIColor.white
                let myString = NSMutableAttributedString(string: "\(self.coins) ", attributes: attributes)
                myString.append(attachmentString)
                
                let label = UILabel()
                label.attributedText = myString
                label.sizeToFit()
                let newBackButton = UIBarButtonItem(customView: label)
                self.navigationItem.rightBarButtonItem = newBackButton
                
                var teamUsers: [Any?] = []
                print("alpha")
                print(self.teamIDs)
                print("beta")
                for data in self.teamIDs{
                    teamCount += 1
                    print(data)
                    
                    let team = Team(id: "", teamName: "", gameCount:0, userCount: 0, time: "")
                    team.id = "\(data)"
                    
                    self.ref?.child("Teams/\(data)/users").observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        print("candy")
                        let teamIDs = snapshot.value! as! NSDictionary
                        teamUsers = Array(teamIDs.allKeys)
                        print(snapshot.key)
                        team.userCount = teamUsers.count
                        print(team.userCount)
                        
                        
                        
                        
                    })
                    
                    print(team.userCount)
                    self.ref?.child("Teams/\(data)").observeSingleEvent(of: .value, with: { (snapshot) in
                        print("Bang Bang Shrimp")
                        let nameData = snapshot.value as? NSDictionary
                        team.teamName = (nameData?["team"]! as? String)!
                        //let games = (nameData?["games"]! as? NSDictionary)!
                        
                        
                        let users = nameData?["users"] as! NSDictionary!
                        let userValue = users?["\(self.userID)"] as! NSDictionary!
                        
                        let inuseTime = nameData?["time"]! as? TimeInterval
                        let currentTime = NSDate()
                        
                        let converted1 = NSDate(timeIntervalSince1970: inuseTime! / 1000)
                        print(converted1)
                        
                        
                        let formatter = DateComponentsFormatter()
                        formatter.unitsStyle = .full
                        formatter.allowedUnits = [.month, .day, .hour, .minute, .second]
                        formatter.maximumUnitCount = 1   // often, you don't care about seconds if the elapsed time is in months, so you'll set max unit to whatever is appropriate in your case
                        
                        team.time = formatter.string(from: converted1 as Date, to: currentTime as Date)!
                        
                        
                        
                        let activeGame: Bool? = userValue?["activeGame"]! as! Bool?
                        print(userValue)
                        if activeGame!{
                            
                        }
                        else{
                            team.gameCount += 1
                            
                        }
                        
                        
                        print(team.teamName)
                        print(team.userCount)
                        print(team.gameCount)
                        
                        
                    })
                    
                    
                    var count = 0
                    
                    let query = self.ref?.child("Teams/\(data)/games").queryOrderedByValue().queryEqual(toValue: true)
                    
                    query?.observeSingleEvent(of: .value, with: { (snapshot2) in
                        if snapshot2.value is NSNull {
                            print("This path was null!")
                            self.playable.append(team)
                            print("spaceballs")
                        }
                        else {
                            let gameID = snapshot2.value! as! NSDictionary
                            print("taco")
                            print(gameID)
                            let gameIDs = Array(gameID.allKeys)
                            teamGameCount = gameIDs.count
                            print(gameIDs)
                            
                            
                            for id in gameIDs{
                                group2.enter()
                                
                                self.ref?.child("Games/\(id)").observeSingleEvent(of: .value, with: { (snapshot3) in
                                    
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
                                    print(team.gameCount)
                                    if count == teamGameCount{
                                        if team.gameCount > 0 {
                                            self.playable.append(team)
                                            print("spaceballs")
                                            group2.leave()
                                        } else{
                                            self.pending.append(team)
                                            print("spacebutt")
                                            group2.leave()
                                        }
                                        
                                        print(teamCount)
                                        print("how dastardly")
                                        print(self.playable)
                                        print(self.pending)
                                        print(user)
                                        
                                    }
                                    
                                    
                                })
                                group2.notify(queue: DispatchQueue.main, execute: {
                                    print("Finish game loop")
                                    if teamCount == teamTotal{
                                        
                                        print("Finished all requests.")
                                        print(self.playable)
                                        print(self.pending)
                                        
                                        self.tableData.removeAll()
                                        self.tableData.append(self.playable)
                                        self.tableData.append(self.pending)
                                        self.tableView.reloadData()
                                        
                                        
                                    }
                                    
                                })
                            }
                        }
                        
                        
                    })
                    
                    
                    
                    
                }
                
                
                
                
            })
        }

        
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    
    func numberOfSections(in: UITableView) -> Int {
        
        return (tableData.count + 1)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("section count")
        if section == 0{
            return 1
        }
        else{
            print(section)
            let x = section - 1
            print(tableData[x].count)
            return tableData[x].count        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "PlayButtons", for: indexPath as IndexPath)
            cell.contentView.backgroundColor = UIColorFromRGB(rgbValue: 0xE6E7E8)
            return cell
        }
        else{
        let cellText = tableData[indexPath.section - 1][indexPath.row]
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "WordSelect", for: indexPath as IndexPath)
            cell.contentView.backgroundColor = UIColorFromRGB(rgbValue: 0xE6E7E8)

        cell.layer.borderColor = UIColorFromRGB(rgbValue: 0xE6E7E8).cgColor
        cell.layer.borderWidth = 3
        let label = cell.viewWithTag(1000) as! UILabel
        let playerLabel = cell.viewWithTag(1001) as! UILabel
        let gameLabel = cell.viewWithTag(1002) as! UILabel
        let timeLabel = cell.viewWithTag(1003) as! UILabel
          
            let viewA = view.viewWithTag(666)! as UIView
            let shadowPath = UIBezierPath(rect: viewA.bounds)
            viewA.layer.masksToBounds = false
            viewA.layer.shadowColor = UIColor.black.cgColor
            viewA.layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
            viewA.layer.shadowOpacity = 0.1
            viewA.layer.shadowPath = shadowPath.cgPath
        
        let gameText = gameLabel.text
        gameLabel.text = "\(cellText.gameCount)✎"
        
        
        playerLabel.text = "\(cellText.userCount)☺︎"
        
        timeLabel.text = "\(cellText.time) ago"
        
        label.text = cellText.teamName
            return cell
        }
        
        
        
        //  Now do whatever you were going to do with the title.
    }
    
    let headerTitles = ["", "Available Games", "Waiting on Players"]
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section
        {
        case 0:
            return headerTitles[0]
        case 1:
            return headerTitles[1]
        case 2:
            return headerTitles[2]
        default:
            return "No More Data"
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if(indexPath.section == 0){
                return 130.0
        }
        else{
            return 76.0
        }
        
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        
        let header = view as! UITableViewHeaderFooterView
        view.tintColor = UIColorFromRGB(rgbValue: 0xE6E7E8)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        if tableView.cellForRow(at: indexPath) != nil {
            if indexPath.section != 0{
            let cellText = tableData[indexPath.section-1][indexPath.row]
            
            teamID = cellText.id
            print(cellText.id)
 
            performSegue(withIdentifier: "ShowTeamView", sender: self)
            }
        }
    }
    
    func menuTapped(){
        performSegue(withIdentifier: "ToSideMenu", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTeamView" {
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            
            let controller = segue.destination as! TeamViewController
            if teamID != nil{
                controller.teamID = teamID
                self.ref?.removeAllObservers()
                
            }
            
        }
        if segue.identifier == "TestEnd" {
            
            let gameID = "-KdwB7ZmZ2a2ChfWxlxq"
            
            let controller = segue.destination as! EndGameViewController
            
                controller.gameID = gameID
   
            
        }
        if segue.identifier == "PublicGame" {
            
            
            let controller = segue.destination as! BufferScreenViewController
            
            controller.teamID = teamID
            self.ref?.removeAllObservers()
            
            
        }
    }
    
}
