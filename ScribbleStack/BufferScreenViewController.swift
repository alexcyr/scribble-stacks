//
//  BufferScreenViewController.swift
//  ScribbleStack
//
//  Created by Alex Cyr on 10/26/16.
//  Copyright © 2016 Alex Cyr. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import NVActivityIndicatorView
import Lottie



class BufferScreenViewController: UIViewController, NVActivityIndicatorViewable{
    
    var game: Game!
    var teamID: String?
    var gameID: String?
    var userCount = 0
    var ref: DatabaseReference!
    var turnsArray: [Any?] = []
    var users: [String] = []
    var currentUser: String?
    var newGame = false
    var endGame = false
    var wordFound = false
    var drawingFound = false
    var winnerFound = false
    var counter = 5
    var didStart = true
    var navScreenshot: UIImage?
    var voted = false
    let imageSwitch = false
    var noGames = true
    var strCnt = 0
    var coins = 0
    
    @IBOutlet weak var coinOutlet: UILabel!
    @IBOutlet weak var textAnimOutlet: UIView!
    @IBOutlet weak var newGameText: UIImageView!
    @IBOutlet weak var newGameOutlet: SpringView!
    @IBOutlet weak var completeOutlet: SpringView!
    @IBOutlet weak var noGamesOutlet: SpringView!
    @IBOutlet weak var scribbleDotAnim: NVActivityIndicatorView!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var readyOutlet: UIButton!
    
    @IBOutlet weak var autoType: UILabel!
    
    @IBAction func exitButton(_ sender: AnyObject) {
        readyOutlet.isEnabled = false

        let refreshAlert = UIAlertController(title: "Exit", message: "Leave current game and return to main menu?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.performSegue(withIdentifier: "BufferToHome", sender: self)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Cancel")
            
                self.readyOutlet.isEnabled = true
            
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    
    
    @IBAction func readyButton(_ sender: AnyObject) {
        if teamID != nil{
            if newGame == true{
                performSegue(withIdentifier: "BufferToWordSelect", sender: self)
                
                
            }
            else if winnerFound == true{
                performSegue(withIdentifier: "ShowEndGame", sender: self)
                
            }
            else if endGame == true{
                performSegue(withIdentifier: "ShowEndGame", sender: self)
                
            }
            else if wordFound == true{
                self.ref.child("Games/\(gameID!)").observeSingleEvent(of: .value, with: { (snapshot) in
                    print(snapshot.value)
                    let gameData = snapshot.value as? NSDictionary
                    
                    
                    if let gameStatus = gameData?["status"]! as? String{
                        
                        let inplay = "inplay"
                        if gameStatus == inplay{
                            
                            self.performSegue(withIdentifier: "ShowWordToDraw", sender: self)
                        }
                        else{
                            if let user  = Auth.auth().currentUser{
                                
                                let label = self.view.viewWithTag(10) as! UILabel
                                label.text = "Searching for games."
                                
                                let userID: String = user.uid
                                self.checkInPlay(teamID: self.teamID!, userID: userID)
                            }
                        }
                    }
                })
            }
            else if drawingFound == true{
                self.ref.child("Games/\(gameID!)").observeSingleEvent(of: .value, with: { (snapshot) in
                    print(snapshot.value)
                    let gameData = snapshot.value as? NSDictionary
                    
                    
                    if let gameStatus = gameData?["status"]! as? String{
                        
                        let inplay = "inplay"
                        if gameStatus == inplay{
                            self.performSegue(withIdentifier: "ShowDrawToWord", sender: self)
                        }
                        else{
                            if let user  = Auth.auth().currentUser{
                                
                                let label = self.view.viewWithTag(10) as! UILabel
                                label.text = "Searching for games."
                                
                                let userID: String = user.uid
                                self.checkInPlay(teamID: self.teamID!, userID: userID)
                            }
                        }
                    }
                })
                
            }
            else if(self.readyOutlet.currentTitle == "Search"){
                let found = self.view.viewWithTag(9) as! UILabel
found.text = ""
                self.readyOutlet.setTitle("READY", for: .normal)
                self.readyOutlet.isHidden = true
                noGamesOutlet.isHidden = true
                counter = 7
                didStart = true
                
                let animview = self.view.viewWithTag(333)! as UIView
                animview.isHidden = false
                
                ref = Database.database().reference()
                
                if let user  = Auth.auth().currentUser{
                    
                    let label = self.view.viewWithTag(10) as! UILabel
                    label.text = "Searching for games."
                    
                    let userID: String = user.uid
                    self.currentUser = userID
                    //checkEndGame(teamID: teamID!, userID: userID)
                    checkNewGame(teamID: teamID!, userID: userID)
                    
                    checkInPlay(teamID: teamID!, userID: userID)
                    
                    
                    
                }
                
            }
            else{
                
            }
        }
        else{
            if newGame == true{
                performSegue(withIdentifier: "BufferToWordSelect", sender: self)
                
                
            }
            else if(game.images.count != 0){
                
                
                if(game.images.count == 4){
                    
                    performSegue(withIdentifier: "ShowEndGame", sender: sender)
                    
                }
                
                if(game.captions.count > game.images.count){
                    
                    performSegue(withIdentifier: "ShowWordToDraw", sender: sender)
                    
                }
                    
                    
                else{
                    
                    performSegue(withIdentifier: "ShowDrawToWord", sender: sender)
                    
                    
                }
            }
        }
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let earnedCoins = UserDefaults.standard.integer(forKey: "earnedCoins")
        coins = earnedCoins
        coinOutlet.text = "\(coins)"
        let pencil = self.view.viewWithTag(111) as! UIImageView
        pencil.isHidden = true
        let found = self.view.viewWithTag(9) as! UILabel
        found.isHidden = true
        
        textAnimOutlet.isHidden = true
        noGamesOutlet.isHidden = true
        completeOutlet.isHidden = true
        newGameOutlet.isHidden = true
        
        let burst = self.view.viewWithTag(88) as! UIImageView
        burst.isHidden = true
        rotateView(targetView: burst, duration: 20.0)

        if teamID != nil{
            let label = self.view.viewWithTag(10) as! UILabel
            let type = "Searching for games."
            label.text = type
            
            activityIndicator.startAnimating()
            readyOutlet.isHidden = true
           
            let animview = self.view.viewWithTag(333)! as UIView
            let animationView = LOTAnimationView(name: "alienLoading")
            
            animationView.frame = CGRect(x: -20, y: 0, width: UIScreen.main.bounds.width + 40, height: UIScreen.main.bounds.width + 40)
            animationView.contentMode = .scaleAspectFill
            animationView.loopAnimation = true
        animationView.animationSpeed = 1.25
            animview.addSubview(animationView)
            
            animationView.play(completion: { finished in
                // Do Something
                
                
                
            })
            
            
        }
        else{
            
            // Do any additional setup after loading the view, typically from a nib.
            
            if game != nil{
            if(game.images.count != 0){
                let label = self.view.viewWithTag(10) as! UILabel
                let animview = self.view.viewWithTag(333)! as UIView
                animview.isHidden = true
                var type: String
                
                
                
                if(game.captions.count > game.images.count){
                    type = "Get ready to draw!"
                    label.text = type
                    print("Checkpoint")
                    pencilAnimStart()
                }
                if(game.captions.count == game.images.count){
                    type = "Get ready to type!"
                    label.text = type
                    print("Checkpoint2")
                    letterAnimStart()
                }
                if(game.images.count == 4){
                    textAnimOutlet.isHidden = true
                    type = "Game finished! View the results."
                    label.text = type
                    print("Checkpoint")
                    endGameAnim()

                }
            }
            }
            else{
                self.newGame = true
                
                let burst = self.view.viewWithTag(88) as! UIImageView
                burst.isHidden = false
                
                let label = self.view.viewWithTag(10) as! UILabel
                label.text = ""
                
                self.readyOutlet.isHidden = false
                self.readyOutlet.setTitle("READY", for: .normal)
                newGameOutlet.isHidden = false
                newGameOutlet.animation = "ZoomIn"
                newGameOutlet.force = 1.0
                newGameOutlet.duration = 1.0
                
                completeOutlet.animate()

            }
            
        }
                var _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateCounter), userInfo: nil, repeats: true)
    
    
    }
    
    @objc func updateCounter() {
        let label = self.view.viewWithTag(10) as! UILabel
        let text = label.text
        if text == "Searching for games."{
            label.text = "Searching for games.."
        }
        if text == "Searching for games.."{
            label.text = "Searching for games..."
        }
        if text == "Searching for games..."{
            label.text = "Searching for games."
        }
        if teamID != nil{
            
        if  didStart && counter > 0 {
            counter = counter - 1
            
            
        }
        if  didStart && counter == 0{
            didStart = false
            let animview = self.view.viewWithTag(333)! as UIView
            animview.isHidden = true
            let label = self.view.viewWithTag(10) as! UILabel
            let found = self.view.viewWithTag(9) as! UILabel

            if self.drawingFound == true {
                activityIndicator.stopAnimating()

                found.isHidden = false
                let type = "Get ready to type!"
                label.text = type
                self.readyOutlet.isHidden = false
                letterAnimStart()
            }
            else if self.newGame == true{
                activityIndicator.stopAnimating()
                let type = ""
                label.text = type
                
                let burst = self.view.viewWithTag(88) as! UIImageView
                burst.isHidden = false
                
                self.readyOutlet.isHidden = false
                self.readyOutlet.setTitle("READY", for: .normal)
                newGameOutlet.isHidden = false
                newGameOutlet.animation = "ZoomIn"
                newGameOutlet.force = 1.0
                newGameOutlet.duration = 1.0
                
                completeOutlet.animate()
            }
            else if self.endGame == true{
                activityIndicator.stopAnimating()
               endGameAnim()
                
            }
            else if ( self.wordFound == true ){
                activityIndicator.stopAnimating()
                pencilAnimStart()
                self.readyOutlet.isHidden = false
            }
            
            else if self.winnerFound == true{
                activityIndicator.stopAnimating()
                let label = self.view.viewWithTag(10) as! UILabel
                label.text = "You Win!"
                
                self.readyOutlet.isHidden = false
            }
            else if self.noGames == true{
                activityIndicator.stopAnimating()
                let found = self.view.viewWithTag(9) as! UILabel
                found.isHidden = false
                found.text = "Waiting On Other Players"
                label.text = "No available games found. Try searching again or quit to main menu."
                self.readyOutlet.isHidden = false
                self.readyOutlet.setTitle("Search", for: .normal)
                noGamesOutlet.isHidden = false
                noGamesOutlet.animation = "ZoomIn"
                noGamesOutlet.force = 1.0
                noGamesOutlet.duration = 1.0
                
                noGamesOutlet.animate()
                    var imageA = self.view.viewWithTag(101) as! UIImageView
                    var imageB = self.view.viewWithTag(102) as! UIImageView
                imageA.animationImages = [(UIImage(named: "tableFlipa1.png")!), (UIImage(named: "tableFlipa2.png")!)]
                imageA.animationDuration = 0.5
                imageB.animationImages = [(UIImage(named: "tableFlipb1.png")!), (UIImage(named: "tableFlipb2.png")!)]
                imageB.animationDuration = 0.5

                imageA.startAnimating()
                imageB.startAnimating()


                
            }
            
        }
        }
    }
    
    func endGameAnim(){
        let label = self.view.viewWithTag(10) as! UILabel

        let type = ""
        label.text = type
        let burst = self.view.viewWithTag(88) as! UIImageView
        burst.isHidden = false
        
        
        self.readyOutlet.isHidden = false
        self.readyOutlet.setTitle("VIEW RESULTS", for: .normal)
        completeOutlet.isHidden = false
        completeOutlet.animation = "ZoomIn"
        completeOutlet.force = 1.0
        completeOutlet.duration = 1.0
        
        completeOutlet.animate()
        
        for x in 1...5{
            let coinTag: Int = Int("3\(x)")!
            let coin = self.view.viewWithTag(coinTag) as! SpringImageView
            
            coin.animation = "zoomIn"
            coin.force = 1.0
            coin.delay = CGFloat(0.5 * Double(x))
            coin.animate()
            
            coin.animation = "flipX"
            coin.repeatCount = Float.infinity
            coin.duration = 2.0
            coin.delay = CGFloat(0.2 * Double(x))
            coin.curve = "easeInOut"
            coin.animate()
        }
        let earnedCoins = UserDefaults.standard.integer(forKey: "earnedCoins")
        coins = coins + 5
        coinOutlet.text = "\(coins)"

        UserDefaults.standard.setValue((earnedCoins+5), forKey: "earnedCoins")
    }
    func letterAnimStart(){
        let found = self.view.viewWithTag(9) as! UILabel

        textAnimOutlet.isHidden = false
        found.isHidden = false
        
        
        let letter = self.view.viewWithTag(734) as! SpringImageView
        letter.force = 0.5
        letter.duration = 1.5
        letter.repeatCount = Float.infinity
        letter.curve = "spring"

        letter.animation = "flip"
        letter.animate()
        letter.layer.zPosition = 0
        autoType.text = ""
        autoType.layer.zPosition = 1000
         var _ = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.typeWords), userInfo: nil, repeats: true)

    }
    
    @objc func typeWords(){
        let newText = "GET YOUR TYPING FINGERS READY"
        
        if strCnt == newText.count {
            strCnt = 0
            autoType.text = ""
        }
        else{
        let index = newText.index(newText.startIndex, offsetBy: strCnt)
        autoType.text!.append(newText[index])
        strCnt += 1
        }
        
        
    }
    func pencilAnimStart(){
        let found = self.view.viewWithTag(9) as! UILabel

        found.isHidden = false
        
        
        let circleSpacing: CGFloat = 2
        let circleSize = (self.scribbleDotAnim.bounds.size.width - circleSpacing * 2) / 7
        let deltaY = (self.scribbleDotAnim.bounds.size.width / 3 - circleSize / 2)
        let duration: CFTimeInterval = 1
        let beginTime = CACurrentMediaTime()
        let beginTimes: [CFTimeInterval] = [0.07, 0.14, 0.21, 0.28, 0.35, 0.42, 0.49]
        let timingFunciton = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        // Animation
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        
        animation.keyTimes = [0, 0.5, 1]
        animation.timingFunctions = [timingFunciton, timingFunciton, timingFunciton]
        animation.values = [deltaY, -deltaY, deltaY]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        let pencil = self.view.viewWithTag(111) as! UIImageView
        // Draw circles
        self.scribbleDotAnim.startAnimating()
        animation.beginTime = beginTime
        pencil.isHidden = false
        pencil.layer.add(animation, forKey: "animation")
        let type = "Time to draw some scribbles!"
        let label = self.view.viewWithTag(10) as! UILabel
        
        label.text = type
        
        let pencilView = self.view.viewWithTag(7) as! SpringView
        pencilView.animation = "ZoomIn"
        pencilView.force = 1.0
        pencilView.duration = 1.0

    }
   
    private func rotateView(targetView: UIImageView, duration: Double) {
        UIImageView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            targetView.transform = targetView.transform.rotated(by: CGFloat(M_PI))
        }) { finished in
            self.rotateView(targetView: targetView, duration: duration)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
        if let user  = Auth.auth().currentUser{
            let userID = user.uid
            print("yoda was here")
            ref = Database.database().reference()
            ref.child("Users/\(userID)").observeSingleEvent(of: .value, with: { (snapshot) in
                print("hallo")
                let data = snapshot.value as? NSDictionary
                let currency = data?["currency"] as! Int
                
                self.coins = self.coins + currency
                self.coinOutlet.text = "\(self.coins)"
                print("turnips", self.coins)
                
               
                
                
            })
            
        }
        if teamID != nil{
            ref = Database.database().reference()
            
            if let user  = Auth.auth().currentUser{
                print(teamID!)
                print("kanye was here")
                let userID: String = user.uid
                self.currentUser = userID
                
                if teamID != "000000"{
                    ref.child("Teams/\(teamID!)/teamInfo/users").observeSingleEvent(of: .value, with: { (snapshot) in
                       
                        let snap = snapshot.value! as! NSDictionary
                        let userArray = Array(snap.allKeys) as AnyObject as! [String]
                        self.userCount = userArray.count
                        
                    })

                }
                

                 //checkEndGame(teamID: teamID!, userID: userID)
                checkNewGame(teamID: teamID!, userID: userID)
               
                checkInPlay(teamID: teamID!, userID: userID)
                
                
                
                
                
            }
            
            
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
   
    
    func checkNewGame(teamID: String, userID: String ){
        ref.child("Teams/\(teamID)/teamInfo/users/\(userID)").observeSingleEvent(of: .value, with: { (snapshot) in
            let data = snapshot.value as? NSDictionary
            print (data)
            let activeGame: Bool? = data?["activeGame"]! as! Bool?
            if activeGame!{
            }
            else{
                print("check check: \(self.gameID)")
                
                if self.gameID == nil{
                    self.newGame = true
                    self.noGames = false
                    self.gameID = "000000"
                }
                
            }
        })
    }
    /*
    func checkEndGame(teamID: String, userID: String ){
        var array: [String] = []
        let group1 = DispatchGroup()
        group1.enter()
       
            let query = ref.child("Teams/\(teamID)/games").queryOrderedByValue().queryEqual(toValue: true)
            query.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChildren(){
                    let snap = snapshot.value! as! NSDictionary
                    
                    array = Array(snap.allKeys) as! [String]
                    group1.leave()
                    
                }
            })
            
       
        group1.notify(queue: DispatchQueue.main, execute: {
            if array.isEmpty{
            }
            else{
            for data in array{
                self.ref.child("Games/\(data)").observeSingleEvent(of: .value, with: { (snapshot) in
                    let gameData = snapshot.value as? NSDictionary
                    let userData = gameData?["users"] as! NSDictionary
                    let endUser = userData["\(userID)"] as! Bool
                    /*
                    if ((gameData?["winner"]) != nil) {
                        let winnerData = gameData?["winner"]! as! NSDictionary
                        let winnerArray = Array(winnerData.allValues)
                        let winnerIDArray = Array(winnerData.allKeys)
                        print("I CAN SEE YOU")
                        var count = 0
                        var seenCount = 0
                        
                        for n in winnerArray{
                            let arrayData = n as! NSObject
                            let userID = arrayData.value(forKey: "user")! as? String
                            
                            let seen = arrayData.value(forKey: "seen")! as? Bool
                            
                            if seen == true {
                                seenCount += 1
                            }
                            if self.currentUser! == userID!{
                                seenCount += 1
                                if self.gameID == nil{
                                    self.winnerFound = true
                                    self.gameID = data
                                    let winnerID = winnerIDArray[count] as? String
                                    self.ref?.child("Games/\(data)/winner/\(winnerID!)/seen").setValue(true)
                                    print("check 2: \(self.gameID)")
                                    
                                    
                                    print(" \(self.gameID)")
                                    
                                    self.voted = true
                                    
                                    
                                    
                                    
                                    
                                    
                                    //all users seen result && all winners seen win screen, tag game as done
                                    if seenCount == winnerArray.count{
                                        let gameStatus = gameData?["status"]! as? String
                                        if gameStatus == "didFinish"{
                                            self.ref?.child("Teams/\(self.teamID!)/games/\(self.gameID!)").setValue(false)
                                            
                                            if (teamID) == "000000"{
                                                for user in userArray{
                                                    self.ref?.child("Users/\(user)/Public/\(self.gameID!)").setValue(false)
                                                    
                                                }
                                            }
                                        }
                                    }}
                                count += 1
                            }}
                    }
                    */
                    if let gameStatus = gameData?["status"]! as? String{
                        print(gameStatus)
                        
                        if gameStatus == "ended"{
                            if endUser == true{
                            if let timestamp = gameData?["time"]! as? TimeInterval{
                                let currentTime = NSDate()
                                
                                print("time winner")
                                print(timestamp)
                                print(currentTime)
                                let converted1 = NSDate(timeIntervalSince1970: timestamp / 1000)
                                print(converted1)
                                let interval = currentTime.timeIntervalSince(converted1 as Date)
                                print(interval)
                                /*
                                self.ref?.child("Games/\(data)/winner").observeSingleEvent(of: .value, with: { (snapshot) in
                                    if snapshot.value is NSNull {
                                        if interval > 86400{
                                            self.voted = true
                                            
                                            print("This path was null!")
                                            self.ref?.child("Games/\(data)/turns").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                                                let snapData = snapshot.value as? NSDictionary
                                                
                                                let turnsArray = Array(snapData!.allValues)
                                                var count = 0
                                                var highVote = 0
                                                var tie : [Int] = []
                                                for turnData in turnsArray{
                                                    let dataObject = turnData as! NSObject
                                                    let votes = dataObject.value(forKey: "votes") as! Int
                                                    
                                                    if votes == highVote{
                                                        tie.append(count)
                                                    }
                                                    if votes > highVote{
                                                        highVote = votes
                                                        tie.removeAll()
                                                        tie.append(count)
                                                    }
                                                    
                                                    
                                                    count += 1
                                                }
                                                for n in tie{
                                                    let arrayData = turnsArray[n] as! NSObject
                                                    let userID = arrayData.value(forKey: "user")! as? String
                                                    let name = arrayData.value(forKey: "username")! as? String
                                                    print(name)
                                                    print(userID)
                                                    self.ref?.child("Games/\(data)/winner").childByAutoId().setValue(["user": userID!, "username": name!, "seen": false])
                                                }
                                                
                                            })
                                            
                                        }}
                                    else{
                                        self.voted = true
                                    }
                                })
                                */
                                
                                
                                
                            }
                            let userData = gameData?["users"]! as? NSDictionary
                            
                            print("poop")
                            var user = ""
                            self.users = Array(userData!.allKeys) as! [String]
                            let value = Array(userData!.allValues) as! [Bool]
                            var count = 0
                            for x in self.users{
                                let userValue = value[count]
                                count += 1
                                user = x
                                if userValue == true{
                                    if user == userID{
                                        print("poop2")
                                        if self.gameID == nil{
                                            
                                            self.gameID = data
                                            self.endGame = true
                                        }
                                    }
                                }
                                
                            }
                        }
                        }
                    }
                    
                })
                
                
            }
            }
            
        })
    }
    */
    func checkInPlay(teamID: String, userID: String ){
        var array: [String] = []
        var gameIDs: [Any?] = []
        var sortedArray: [String] = []
        var gameCount = 0
        print("taco")
        
        
        print("supreme")
        
        let group1 = DispatchGroup()
        group1.enter()
        
        
        
        let query = ref.child("Teams/\(teamID)/games").queryOrderedByValue().queryEqual(toValue: true)
        
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.value is NSNull {
                print("This path was null!")
                if self.newGame == true{
                    
                }
                else{
                    self.noGames = true
                }
                
            }
            else {
                let snap = snapshot.value! as! NSDictionary
                print(gameIDs)
                gameIDs = Array(snap.allKeys) as AnyObject as! [String]
                
                let turnKeys = Array(snap.allKeys) as AnyObject as! [String]
                sortedArray = turnKeys.sorted()
                print("alpha")
                
                print("beta")
                group1.leave()
                
            }
        })
        
        group1.notify(queue: DispatchQueue.main, execute: {
            if sortedArray.isEmpty{
            }
            else{
                for data in sortedArray{
                    array.append(data)
                    
                    print (data)
                    print("apple \(gameCount)")
                    gameCount += 1
                    if self.gameID != nil{
                        break
                    }
                    else{
                        
                        self.ref.child("Games/\(data)").observeSingleEvent(of: .value, with: { (snapshot) in
                            print(snapshot.value)
                            let gameData = snapshot.value as? NSDictionary
                            let userData = gameData?["users"] as! NSDictionary
                            var userKey = true
                            
                            
                            
                            
                            if let gameStatus = gameData?["status"]! as? String{
                                
                                print(gameStatus)
                                print(snapshot.childrenCount)
                                let inplay = "inplay"
                                let inuse = "inuse"
                                print(gameStatus)
                                print(inplay)
                                if (teamID) == "000000"{
                                }
                                else{
                                    if self.userCount == 2 || self.userCount == 1{
                                        if userID == gameData?["lastPlayer"]! as! String{
                                            userKey = false
                                        }
                                    }
                                    else if self.userCount > 2 {
                                        if userID == gameData?["lastPlayer"]! as! String{
                                            userKey = false
                                        }
                                        else if userID == gameData?["secondLast"]! as! String{
                                            userKey = false
                                        }
                                    }
                                }
                                if userKey == true{
                                if gameStatus == inplay{
                                    
                                        
                                        self.ref.child("Games/\(data)/turns").observeSingleEvent(of: .value, with: { (snapshot) in
                                            print(snapshot.childrenCount)
                                            
                                            
                                            
                                            
                                            let n = snapshot.childrenCount
                                            print("hot pretzles remaining: \(n)" )
                                            if n % 2 == 0{
                                                
                                                if self.gameID == nil{
                                                    
                                                    self.gameID = data as String!
                                                    self.drawingFound = true
                                                    self.noGames = false
                                                    
                                                }
                                                print("even")
                                            }
                                            else{
                                                if self.gameID == nil{
                                                    self.gameID = data as String!
                                                    self.wordFound = true
                                                    self.noGames = false
                                                    
                                                    
                                                    
                                                    
                                                }
                                                
                                                print("odd")
                                            }
                                            
                                        })
                                    }
                                
                                    if gameStatus == inuse{
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
                                                self.ref?.child("Games/\(data)/status").setValue("inplay")
                                                self.ref.child("Games/\(data)/turns").observeSingleEvent(of: .value, with: { (snapshot) in
                                                    print(snapshot.childrenCount)
                                                    
                                                    let n = snapshot.childrenCount
                                                    print("hot pretzles remaining: \(n)" )
                                                    if n % 2 == 0{
                                                        
                                                        if self.gameID == nil{
                                                            
                                                            self.gameID = data as String!
                                                            self.drawingFound = true
                                                        }
                                                        print("even")
                                                    }
                                                    else{
                                                        if self.gameID == nil{
                                                            
                                                            self.gameID = data as String!
                                                            self.wordFound = true
                                                            
                                                        }
                                                        
                                                        print("odd")
                                                    }
                                                    
                                                })
                                                
                                                
                                            }
                                        }
                                    }
                                }
                                    else if gameStatus == "ended"{
                                        if let endUser = userData["\(userID)"]{
                                            if endUser as! Bool == true{
                                                if let timestamp = gameData?["time"]! as? TimeInterval{
                                                    let currentTime = NSDate()
                                                    
                                                    print("time winner")
                                                    print(timestamp)
                                                    print(currentTime)
                                                    let converted1 = NSDate(timeIntervalSince1970: timestamp / 1000)
                                                    print(converted1)
                                                    let interval = currentTime.timeIntervalSince(converted1 as Date)
                                                    print(interval)
                                                    
                                                }
                                                let userData = gameData?["users"]! as? NSDictionary
                                                
                                                print("holy poop")
                                                var user = ""
                                                self.users = Array(userData!.allKeys) as! [String]
                                                let value = Array(userData!.allValues) as! [Bool]
                                                var count = 0
                                                for x in self.users{
                                                    let userValue = value[count]
                                                    count += 1
                                                    user = x
                                                    if userValue == true{
                                                        if user == userID{
                                                            print("poop2")
                                                            if self.gameID == nil{
                                                                
                                                                self.gameID = data
                                                                self.endGame = true
                                                            }
                                                        }
                                                    }
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                                
                            
                            
                            
                        })
                    }
                    
                }
            }
        })
    }
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BufferToWordSelect" {
            let controller = segue.destination as! WordSelectViewController
            if teamID != nil{
                controller.teamID = teamID
            }
            
        }
        if segue.identifier == "ShowWordToDraw" {
            let controller = segue.destination as! DrawWordViewController
            if (gameID != nil){
                controller.gameID = gameID
            }
            else{
                controller.game = game
                
            }
        }
        if segue.identifier == "ShowDrawToWord" {
            
            let controller = segue.destination as! CaptionViewController
            if (gameID != nil){
                controller.gameID = gameID
            }
            else{
                controller.game = game
                
            }
        }
        if segue.identifier == "ShowEndGame" {
            let DestViewController = segue.destination as! UINavigationController
            let targetController = DestViewController.topViewController as! EndGameViewController
          
            if (gameID != nil){
                targetController.gameID = gameID
                targetController.voted = voted
            }
            else{
                targetController.game = game
                
            }
        }
        if segue.identifier == "BufferToHome" {
            let DestViewController = segue.destination as! UINavigationController
            let targetController = DestViewController.topViewController as! TabBarViewController
            
            
        }

        
        
    }
}

