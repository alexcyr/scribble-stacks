//
//  HomeViewController.swift
//  ScribbleStacks
//
//  Created by Alex Cyr on 11/15/16.
//  Copyright © 2016 Alex Cyr. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Fakery
import GoogleMobileAds

extension UITableView {
    func reloadData(with animation: UITableViewRowAnimation) {
        reloadSections(IndexSet(integersIn: 0..<numberOfSections), with: animation)
    }
}

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    
    @IBAction func testEnd(_ sender: AnyObject) {
        
        performSegue(withIdentifier: "testEndSegue", sender: self)
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var homeLabel: UILabel!
    var data : String!
    var first: Bool?
    var playable: [Team] = []
    var pending: [Team] = []
    var ref: DatabaseReference?
    var teamIDs: [Any] = []
    var teamID = "000000"
    var selectedTeam = Team(id: "", teamName: "", gameCount:0, userCount: 0, time: "", users: [])
    var tableData: [[Team]] = []
    var ready = false
    var coins = 0
    var userID = ""
    var noTeams = false
    let faker = Faker(locale: "nb-NO")
    var namesObj: [String] = []
    var nextViewNumber = 0
    var rando: String?
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    
    @IBAction func friends(_ sender: AnyObject) {
        let homeMenu = self.view.viewWithTag(41)! as UIView
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            homeMenu.alpha = 0 // Here you will get the animation you want
            }, completion: { _ in
                homeMenu.isHidden = true // Here you hide it when animation done
        })
    }
    @IBAction func newTeam(_ sender: AnyObject) {
        let homeMenu = self.view.viewWithTag(41)! as UIView
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            homeMenu.alpha = 0 // Here you will get the animation you want
            }, completion: { _ in
                homeMenu.isHidden = true // Here you hide it when animation done
        })
        nextViewNumber = 1
        performSegue(withIdentifier: "tabBar", sender: self)

    }
    @IBAction func passButton(_ sender: AnyObject) {
        let homeMenu = self.view.viewWithTag(41)! as UIView
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            homeMenu.alpha = 0 // Here you will get the animation you want
            }, completion: { _ in
                homeMenu.isHidden = true // Here you hide it when animation done
        })
        nextViewNumber = 2
        performSegue(withIdentifier: "tabBar", sender: self)

    }
    @IBAction func publicGame(_ sender: AnyObject) {
        let homeMenu = self.view.viewWithTag(41)! as UIView
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            homeMenu.alpha = 0 // Here you will get the animation you want
            }, completion: { _ in
                homeMenu.isHidden = true // Here you hide it when animation done
        })
        nextViewNumber = 3
        performSegue(withIdentifier: "tabBar", sender: self)
    }
    
    var refreshControl: UIRefreshControl!
   
    @objc func refresh(sender:AnyObject) {
        populateTable()
        refreshControl.endRefreshing()
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if FREE
            bannerView.adSize = kGADAdSizeSmartBannerPortrait
            bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            
            
        #else
            bannerView.frame.size.height = 0
            bannerView.isHidden = true
            print("not free")
        #endif
        
        NotificationCenter.default.addObserver(self, selector:#selector(populateTable), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)

        
        let homeSplash = self.view.viewWithTag(42)! as UIView
         homeSplash.alpha = 0
        homeSplash.isHidden = true
       
        print("yaahoo")
        
        /*
        let homeMenu = self.view.viewWithTag(41)! as UIView
        homeMenu.isHidden = true
        if first == true{
            homeMenu.isHidden = false
        }
        */
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.view.backgroundColor = UIColorFromRGB(rgbValue: 0xffffff)
        self.tableView.backgroundColor = UIColorFromRGB(rgbValue: 0xffffff)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        let earnedCoins = UserDefaults.standard.integer(forKey: "earnedCoins")
        self.coins = earnedCoins

        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Menu", style: .plain, target: self, action: #selector(menuTapped))
        
        //navbar logo
        let image = UIImage(named: "scribble-logo-light.png")
        let logoView = UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 20))
        let imageView = UIImageView(frame: CGRect(x: -45, y: -8, width: 90, height: 46))
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        logoView.addSubview(imageView)
        self.navigationItem.titleView = logoView
        
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        ref = Database.database().reference()
        print("poop")
        populateTable()
        
        loadWords()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
    }
    
    func loadWords(){
        
        if let user  = Auth.auth().currentUser{
            userID = user.uid
            
            self.ref?.child("Words").observeSingleEvent(of: .value, with: { (snapshot) in
                print("licorice snape")
                let words = snapshot.value! as! NSDictionary
                
                let userDefaults = UserDefaults.standard
                userDefaults.setValue(words, forKey: "wordList")             
                
            })
        }
    }
    
    
    @objc func populateTable(){
        
        self.playable.removeAll()
        
        
        self.pending.removeAll()
        
        
        let group1 = DispatchGroup()
        let group2 = DispatchGroup()
        group1.enter()
        if let user  = Auth.auth().currentUser{
            userID = user.uid
            print("poop")
            print(userID)
            
            var teamTotal = 0
            var teamCount = 0
            
            self.ref?.child("Users/\(userID)").observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                if snapshot.hasChildren(){
                    let snap = snapshot.value! as! NSDictionary
                    let dbCoins = (snap["currency"] as! Int)
                    self.coins = self.coins + dbCoins
                    print("poop")
                    
                    if let teamsData = (snap["Teams"] as? NSDictionary){
                        
                        self.teamIDs = Array(teamsData.allKeys)
                        print(self.teamIDs)
                        teamTotal = self.teamIDs.count
                        print(teamTotal)
                        
                    }
                    else{
                        let homeSplash = self.view.viewWithTag(42)! as UIView
                        homeSplash.isHidden = false
                        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                            homeSplash.alpha = 1 // Here you will get the animation you want
                        }, completion: { _ in
                            // Here you hide it when animation done
                        })
                        self.tableData.removeAll()
                        self.noTeams = false
                        self.tableData.append(self.playable)
                        self.tableData.append(self.pending)
                        self.tableView.reloadData()
                        
                    }
                    group1.leave()
                }
                
                
                
                
            })
            
            group1.notify(queue: DispatchQueue.main, execute: {
                
                
                var teamUsers: [Any?] = []
                print("alpha")
                print(self.teamIDs)
                print("beta")
                for data in self.teamIDs{
                    teamCount += 1
                    var count = 0
                    print(data)
                    
                    let team = Team(id: "", teamName: "", gameCount:0, userCount: 0, time: "", users: [])
                    team.id = "\(data)"
                    
                    
                    print(team.userCount)
                    self.ref?.child("Teams/\(data)/teamInfo").observeSingleEvent(of: .value, with: { (snapshot) in
                        print("Bang Bang Shrimp")
                        let nameData = snapshot.value as? NSDictionary
                        team.teamName = (nameData?["team"]! as? String)!
                        //let games = (nameData?["games"]! as? NSDictionary)!
                        
                        let users = nameData?["users"] as! NSDictionary!
                        let userValue = users?["\(self.userID)"]! as! NSDictionary!
                        
                        let inuseTime = nameData?["time"]! as? TimeInterval
                        let currentTime = NSDate()
                        
                        let converted1 = NSDate(timeIntervalSince1970: inuseTime! / 1000)
                        print(converted1)
                        
                        print("candy")
                        teamUsers = Array(users!.allKeys) as! [String]
                        team.users = teamUsers as! [String]
                        team.userCount = teamUsers.count
                        print(team.userCount)
                        
                        
                        let formatter = DateComponentsFormatter()
                        formatter.unitsStyle = .full
                        formatter.allowedUnits = [.month, .day, .hour, .minute, .second]
                        formatter.maximumUnitCount = 1   // often, you don't care about seconds if the elapsed time is in months, so you'll set max unit to whatever is appropriate in your case
                        
                        team.time = formatter.string(from: converted1 as Date, to: currentTime as Date)!
                        
                        
                        
                        let activeGame: Bool? = userValue?["activeGame"]! as! Bool?
                        if activeGame!{
                            
                        }
                        else{
                            team.gameCount += 1
                            
                        }
                        
                        
                        print(team.teamName)
                        print(team.userCount)
                        print(team.gameCount)
                        
                        
                    })
                    let query = self.ref?.child("Teams/\(data)/games").queryOrderedByValue().queryEqual(toValue: true)
                    
                    query?.observeSingleEvent(of: .value, with: { (snapshot2) in
                        if snapshot2.value is NSNull {
                            group2.enter()
                            print("This path was null!")
                            self.playable.append(team)
                            print("spaceballs")
                            group2.leave()
                        }
                        else {
                            let gameID = snapshot2.value! as! NSDictionary
                            print("taco")
                            print(gameID)
                            let gameIDs = Array(gameID.allKeys)
                            let teamGameCount = gameIDs.count
                            print(gameIDs)
                            group2.enter()
                            
                            for id in gameIDs{
                                
                                
                                self.ref?.child("Games/\(id)").observeSingleEvent(of: .value, with: { (snapshot3) in
                                    
                                    let gameData = snapshot3.value as? NSDictionary
                                    let status = (gameData?["status"]! as? String)!
                                    let userData = gameData?["users"] as! NSDictionary
                                    
                                    print(status)
                                    print("puffy taco")
                                    count += 1
                                    
                                    var userKey = true
                                    if team.userCount == 2 || team.userCount == 1{
                                        if self.userID == gameData?["lastPlayer"]! as! String{
                                            userKey = false
                                        }
                                    }
                                    else if team.userCount > 2 {
                                        if self.userID == gameData?["lastPlayer"]! as! String{
                                            userKey = false
                                        }
                                        else if self.userID == gameData?["secondLast"]! as! String{
                                            userKey = false
                                        }
                                    }
                                    
                                    
                                    if (status == "ended"){
                                        team.gameCount += 1
                                        print(team.gameCount)
                                        if let endUser = userData["\(self.userID)"] as? Bool{
                                            if endUser == false{
                                                team.gameCount -= 1
                                                
                                            }
                                        }
                                        
                                    }
                                 
                                    if userKey == true{
                                        if  (status == "inplay"){
                                            team.gameCount += 1
                                            print(team.gameCount)
                                            if let endUser = userData["\(self.userID)"] as? Bool{
                                                if endUser == false{
                                                    team.gameCount -= 1
                                                    
                                                }
                                            }
                                            
                                        }
                                        else if status == "inuse"{
                                            
                                            
                                            if let inuseTime = gameData?["time"]! as? TimeInterval{
                                                let currentTime = NSDate()
                                                
                                                print("time wizard")
                                                print(inuseTime)
                                                print(currentTime)
                                                let converted1 = NSDate(timeIntervalSince1970: inuseTime / 1000)
                                                print(converted1)
                                                let interval = currentTime.timeIntervalSince(converted1 as Date)
                                                print(interval)
                                                if interval > 300{
                                                    self.ref?.child("Games/\(id)/status").setValue("inplay")
                                                    team.gameCount += 1
                                                    
                                                }
                                            }
                                        }
                                        print(Int(snapshot2.childrenCount))
                                        
                                    }
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
                                
                                
                            }
                            
                        }
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
                                print(self.tableData)
                                print("right meow")
                                self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                                self.tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
                                
                            }
                            
                        })
                        
                    })
                    
                    
                    
                    
                }
                
                
                
                
            })
        }
        else{
            let homeSplash = self.view.viewWithTag(42)! as UIView
            homeSplash.isHidden = false

            
            
            UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
                homeSplash.alpha = 1 // Here you will get the animation you want
            }, completion: { _ in
                // Here you hide it when animation done
            })
            
            self.tableData.removeAll()
            self.noTeams = false
            self.tableData.append(self.playable)
            self.tableData.append(self.pending)
            self.tableView.reloadData()
            
        }
    }
    
    func loadJson(forFilename fileName: String) -> NSDictionary? {
        
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            if let data = NSData(contentsOf: url) {
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as? NSDictionary
                    
                    return dictionary
                } catch {
                    print("Error!! Unable to parse  \(fileName).json")
                }
            }
            print("Error!! Unable to load  \(fileName).json")
        }
        
        return nil
    }


    func barButtonItemClicked(sender: UIBarButtonItem) {
        print("clicked")
    }
    @IBAction func playPublicGame(_ sender: AnyObject) {
        teamID = "000000"
        
        performSegue(withIdentifier: "PublicGame", sender: self)

    }
    @IBAction func signOut(_ sender: AnyObject) {
        try! Auth.auth().signOut()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        
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
           
            if noTeams == true{
                return 2
            }
            else{
             return 1
            }
        }
        
        else{
            print(section)
            let x = section - 1
            print(tableData[x].count)
            if tableData[x].count > 0 {
                return tableData[x].count
            }
            else{
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
           
            if noTeams == true && (indexPath.row == 1){
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "WordSelect", for: indexPath as IndexPath)
                //cell.contentView.backgroundColor = UIColorFromRGB(rgbValue: 0xE6E7E8)
                
                
              
                let label = cell.viewWithTag(1000) as! UILabel
                let playerLabel = cell.viewWithTag(1001) as! UILabel
                let gameLabel = cell.viewWithTag(1002) as! UILabel
                let timeLabel = cell.viewWithTag(1003) as! UILabel
                playerLabel.isHidden = true
                gameLabel.isHidden = true
                timeLabel.isHidden = true
                label.text = "No Teams Found. Create a New Game to get started!"
                let viewA = view.viewWithTag(666)! as UIView
                viewA.isHidden = true
               cell.selectionStyle = .none
                
                 return cell
            }
            else{
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "PlayButtons", for: indexPath as IndexPath)
                cell.selectionStyle = .none
                
               
            return cell
            }
        }
        else if tableData[indexPath.section - 1].count == 0{
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "WordSelect", for: indexPath as IndexPath)
            cell.selectionStyle = .none
            let label = cell.viewWithTag(1000) as! UILabel
            let playerLabel = cell.viewWithTag(1001) as! UILabel
            let gameLabel = cell.viewWithTag(1002) as! UILabel
            let timeLabel = cell.viewWithTag(1003) as! UILabel

            gameLabel.text = ""
            playerLabel.text = ""
            timeLabel.text = ""
            
            label.text = "NO GAMES FOUND"
            label.textColor = UIColorFromRGB(rgbValue: 0xE6E7E8)
            label.font = UIFont(name: "BungeeInline-Regular", size: 30)
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                label.font = UIFont(name: "BungeeInline-Regular", size: 48)
            }
            label.sizeToFit()
            label.textAlignment = NSTextAlignment.center
            label.bounds = CGRect(x: 0, y: 200, width: tableView.frame.size.width, height: 30)
            
            
            return cell

        }
        else{
        let cellText = tableData[indexPath.section - 1][indexPath.row]
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "WordSelect", for: indexPath as IndexPath)
            cell.selectionStyle = .none

        let label = cell.viewWithTag(1000) as! UILabel
        let playerLabel = cell.viewWithTag(1001) as! UILabel
        let gameLabel = cell.viewWithTag(1002) as! UILabel
        let timeLabel = cell.viewWithTag(1003) as! UILabel


          /*
            let viewA = view.viewWithTag(666)! as UIView
            let shadowPath = UIBezierPath(rect: viewA.bounds)
            viewA.layer.masksToBounds = false
            viewA.layer.shadowColor = UIColor.black.cgColor
            viewA.layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
            viewA.layer.shadowOpacity = 0.1
            viewA.layer.shadowPath = shadowPath.cgPath
        */
        gameLabel.text = "\(cellText.gameCount)✎"
            
            let viewA = UIView(frame: cell.bounds)
            viewA.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            viewA.frame = CGRect( x:0, y:3, width:cell.frame.width, height:cell.frame.height - 6.0 )
            
            
            viewA.layer.borderWidth = 1.0
            
            cell.layer.borderWidth = 10.0
            cell.layer.borderColor = UIColor.clear.cgColor
            
            if indexPath.section == 1{
                let newColor = UIColorFromRGB(rgbValue: 0x01A7B9)
                viewA.layer.borderColor = newColor.cgColor
                gameLabel.textColor = UIColorFromRGB(rgbValue: 0x01A7B9)
            }
            else if indexPath.section == 2{
                let newColor = UIColorFromRGB(rgbValue: 0xD14759)
                viewA.layer.borderColor = newColor.cgColor
                gameLabel.textColor = UIColorFromRGB(rgbValue: 0xD14759)
            }

              label.text = cellText.teamName
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                label.font = UIFont(name: "Bungee-Regular", size: 48)
                playerLabel.font = UIFont(name: "Rajdhani-Bold", size: 18)
                gameLabel.font = UIFont(name: "Rajdhani-Bold", size: 18)
                timeLabel.font = UIFont(name: "Rajdhani-Light", size: 18)
            }

            label.numberOfLines = 1
            label.minimumScaleFactor = 0.3
            label.adjustsFontSizeToFitWidth = true

        playerLabel.text = "\(cellText.userCount)☺︎"
        
        timeLabel.text = "\(cellText.time) ago"
 cell.addSubview(viewA)
      
            return cell
        }
        
        
        
        //  Now do whatever you were going to do with the title.
    }
    
    let headerTitles = ["", "AVAILABLE GAMES", "WAITING ON PLAYERS",""]
    
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
    

        
        
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            let view = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:0))
            return view

        }
        else{
        let view = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:30))
        let label = UILabel(frame: CGRect(x:0, y:6, width:tableView.frame.size.width, height:30))
        let line = UIView(frame: CGRect(x:0, y:15, width:tableView.frame.size.width, height:30))
        line.bounds = CGRect(x: 0, y: -8, width: self.view.frame.width, height: 1)
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
        
    }
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0
            
        }
        else{
        return 35
        }
    }
    /*
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2{
            return 100
        }
        else{
            return 0
        }
    }
 */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if(indexPath.section == 0){
                return 1.0
        }
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            return 120.0
        }
        else if tableData[indexPath.section - 1].count == 0{
             return 60.0
        }
        else if tableData[indexPath.section - 1].count == 1{
            if indexPath.row == (tableData[indexPath.section-1].count){
                return 120.0
            }
            else{
                
                return 80.0
            }
        }
        else{
            return 80.0
        }
        
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
    if tableView.cellForRow(at: indexPath) != nil {
            if indexPath.section != 0{
                if tableData[indexPath.section - 1].count != 0 {
     let cellText = tableData[indexPath.section-1][indexPath.row]
            teamID = cellText.id
                    selectedTeam = cellText
            print(cellText.id)
                /*
                if indexPath.section == 1{
                    let viewA = cell.viewWithTag(666)! as UIView

                    let label = cell.viewWithTag(1000) as! UILabel
                    let playerLabel = cell.viewWithTag(1001) as! UILabel
                    let gameLabel = cell.viewWithTag(1002) as! UILabel
                    let timeLabel = cell.viewWithTag(1003) as! UILabel
                    playerLabel.textColor = UIColorFromRGB(rgbValue: 0xffffff)
                    gameLabel.textColor = UIColorFromRGB(rgbValue: 0xffffff)
                    timeLabel.textColor = UIColorFromRGB(rgbValue: 0xffffff)
                    label.textColor = UIColorFromRGB(rgbValue: 0xffffff)

                    
                    let newColor = UIColorFromRGB(rgbValue: 0x01A7B9)
                    viewA.layer.backgroundColor = newColor.cgColor
                    gameLabel.textColor = UIColorFromRGB(rgbValue: 0xffffff)
                    
                }
                else if indexPath.section == 2{
                    
                    let viewA = cell.viewWithTag(666)! as UIView
                    
                    let label = cell.viewWithTag(1000) as! UILabel
                    let playerLabel = cell.viewWithTag(1001) as! UILabel
                    let gameLabel = cell.viewWithTag(1002) as! UILabel
                    let timeLabel = cell.viewWithTag(1003) as! UILabel
                    playerLabel.textColor = UIColorFromRGB(rgbValue: 0xffffff)
                    gameLabel.textColor = UIColorFromRGB(rgbValue: 0xffffff)
                    timeLabel.textColor = UIColorFromRGB(rgbValue: 0xffffff)
                    label.textColor = UIColorFromRGB(rgbValue: 0xffffff)
                    
                    let newColor = UIColorFromRGB(rgbValue: 0xD14759)
                    viewA.layer.backgroundColor = newColor.cgColor
                    gameLabel.textColor = UIColorFromRGB(rgbValue: 0xffffff)
                }
*/
 
            performSegue(withIdentifier: "ShowTeamView", sender: self)
                }
            }
        }
    }
    
    @objc func menuTapped(){
        performSegue(withIdentifier: "ToSideMenu", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowTeamView" {
            
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            
            let controller = segue.destination as! TeamViewController
            if teamID != "000000"{
                controller.teamID = teamID
                controller.team = selectedTeam
                controller.coins = self.coins
                print("coins", coins)
                self.ref?.removeAllObservers()
                
            }
            
        }
        if segue.identifier == "HomeToHowTo" {
            
            
            let controller = segue.destination as! HowToViewController
            
                controller.coins = self.coins
   
            
        }
        if segue.identifier == "PublicGame" {
            
            
            let controller = segue.destination as! BufferScreenViewController
            
            controller.teamID = teamID
            self.ref?.removeAllObservers()
            
            
        }
        if segue.identifier == "tabBar" {
            
            let nextView = segue.destination as! TabBarViewController
            
            switch (nextViewNumber) {
            case 1:
                nextView.selectedIndex = 1
                
            case 2:
                nextView.selectedIndex = 2
            case 3:
                nextView.selectedIndex = 3
                
            default:
                break
            }
        }
    }
    
}
