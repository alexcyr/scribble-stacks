//
//  WordSelectViewController.swift
//  ScribbleStack
//
//  Created by Alex Cyr on 10/9/16.
//  Copyright © 2016 Alex Cyr. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class WordSelectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var ref: DatabaseReference!
    var teamID: String?
    var gameID: String!
    var ownedWords: [Any] = []
    var ownedWordsBool: [Any] = []
    var userID = ""
    var coins = 0
    let game = Game(captions: [], images: [])
    var getRandomWord: [String] = []
    var words = ["DOG CHASING A CAR","BRUSHING TEETH","POTATO","SKYDIVING","HOTDOG","CATDOG","PINATA","SUPERMAN","PIG IN A BLANKET","BANANA", "TACO","STAIRWAY TO HEAVEN","TURTLE SOUP","BASEBALL","BEACH","REINDEER LAYING AN EGG"]
    
    @IBAction func refreshWords(_ sender: AnyObject) {
      
        let cost = 20
        if coins >= cost{
            
            let refreshAlert = UIAlertController(title: "Refresh Words", message: "Spend \(cost) coins to get a new set of words?", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
                
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                self.loadWords()
                var localCoins = UserDefaults.standard.integer(forKey: "earnedCoins")
                var total = cost
                var dbCoins = self.coins - localCoins
                if(dbCoins >= cost){
                    dbCoins = dbCoins - total
                }
                else{
                    
                    total = total - dbCoins
                    dbCoins = 0
                    localCoins = localCoins - total
                    UserDefaults.standard.setValue(localCoins, forKey: "earnedCoins")
                    
                }
                self.coins = localCoins + dbCoins
                if Auth.auth().currentUser != nil{
                    self.ref?.child("Users/\(self.userID)/currency").setValue(self.coins)
                }
                
                
                
            }))
            
            
            
            present(refreshAlert, animated: true, completion: nil)
        }
        else{
        let refreshAlert = UIAlertController(title: "Not Enough Coins", message: "You need at least \(cost) coins to get a new set of words?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            
        }))
       
        
        
        
        present(refreshAlert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColorFromRGB(rgbValue: 0xffffff)
        self.tableView.backgroundColor = UIColorFromRGB(rgbValue: 0xffffff)

        // Do any additional setup after loading the view, typically from a nib.

            // Do any additional setup after loading the view, typically from a nib.
        ref = Database.database().reference()
        tableView.delegate = self
        tableView.dataSource = self
        
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
        
            loadWords()
            
        
       
            /*
            let wordsLength = words.count
            let getRandom = randomSequenceGenerator(min: 1, max: wordsLength)
            for _ in 1...3 {
                print(getRandom())
                getRandomWord.append(words[getRandom()-1])
            }
        */
            
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
    func loadJson(forFilename fileName: String) -> NSDictionary? {
        
        if let path = Bundle.main.path(forResource: "\(fileName)", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? NSDictionary{
                        return jsonResult                }
            } catch {
                print("Error!! Unable to parse  \(fileName).json")
            }
        }
        print("Error!! Unable to load  \(fileName).json")
        
        return nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
  
    func randomSequenceGenerator(min: Int , max: Int) -> () -> Int {
        var numbers: [Int] = []
        return {
            if numbers.count == 0 {
                numbers = Array(min ... max)
            }
            
            let index = Int(arc4random_uniform(UInt32(numbers.count)))
            return numbers.remove(at: index)
        }
    }
    func loadWords(){
        self.ownedWords.removeAll()
        self.ownedWordsBool.removeAll()
        self.getRandomWord.removeAll()

        var wordDict: NSDictionary?
        
        let group1 = DispatchGroup()
        
        group1.enter()
        if let user = Auth.auth().currentUser{
            userID = user.uid
            wordDict = UserDefaults.standard.dictionary(forKey: "wordList") as! NSDictionary

        self.ref?.child("Users/\(userID)").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            if snapshot.hasChildren(){
                let snap = snapshot.value! as! NSDictionary
                self.coins = self.coins + (snap["currency"] as! Int)
                let wordData = (snap["Words"] as! NSDictionary)
                print("poop")
                print(snapshot.value)
                self.ownedWords = Array(wordData.allKeys)
                self.ownedWordsBool = Array(wordData.allValues)
                print(self.ownedWords)
                print(self.ownedWordsBool)
                print("rocka")
                var count = 0
                for _ in self.ownedWords{
                    let ownedBool = self.ownedWordsBool[count] as! Bool
                    if ownedBool == false{
                        self.ownedWordsBool.remove(at: count)
                        self.ownedWords.remove(at: count)
                        count = count - 1
                    }
                    count = count + 1
                    print(count)
                    print(self.ownedWords.count)
                    print("woah now")
                    if count == self.ownedWords.count{
                        group1.leave()
                    }
                }
            }
        })
        
        }
        else{
            wordDict = self.loadJson(forFilename: "words") 
            let wordData = UserDefaults.standard.dictionary(forKey: "ownedWords")!
            self.ownedWords = Array(wordData.keys)
            self.ownedWordsBool = Array(wordData.values)
            print(self.ownedWords)
            print(self.ownedWordsBool)
            print("rocka")
            var count = 0
            for _ in self.ownedWords{
                let ownedBool = self.ownedWordsBool[count] as! Bool
                if ownedBool == false{
                    self.ownedWordsBool.remove(at: count)
                    self.ownedWords.remove(at: count)
                    count = count - 1
                }
                count = count + 1
                print(count)
                print(self.ownedWords.count)
                print("woah now")
                if count == self.ownedWords.count{
                    group1.leave()
                }
            }
            
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
            
            let data = wordDict!
                print(data)
                self.words = []
                for word in self.ownedWords{
                    let wordObject = (data["\(word)"] as! NSDictionary)
                    let wordArray = (wordObject["WordList"] as! [String])
                    self.words.append(contentsOf: wordArray)
                }
                print(self.words)
                let wordsLength = self.words.count
                let getRandom = self.randomSequenceGenerator(min: 1, max: wordsLength)
                self.getRandomWord = []
                for n in 1...3 {
                    print(getRandom())
                    self.getRandomWord.append(self.words[getRandom()-1])
                    if n == 3{
                        self.tableView.reloadData()
                        let range = NSMakeRange(0, self.tableView.numberOfSections)
                        let sections = NSIndexSet(indexesIn: range)
                        self.tableView.reloadSections(sections as IndexSet, with: .automatic)
                    }
                }
            
            
        })
    }
    @objc func barButtonItemClicked(){
        print("clicked")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getRandomWord.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "WordSelect", for: indexPath)
        cell.layer.borderColor = UIColorFromRGB(rgbValue: 0xffffff).cgColor
        cell.layer.borderWidth = 6
        let label = cell.viewWithTag(1000) as! UILabel

        label.text = getRandomWord[indexPath.row]
        
        let borderBox = UIView(frame: cell.bounds)
        borderBox.layer.borderColor = UIColorFromRGB(rgbValue: 0xe5e5e5).cgColor
        borderBox.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        borderBox.layer.borderWidth = 7

        cell.addSubview(borderBox)

        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        if let cell = tableView.cellForRow(at: indexPath) {

        let label = cell.viewWithTag(1000) as! UILabel
        
            if teamID != nil{
                if let user  = Auth.auth().currentUser{
                    var name: String?
                    name = user.displayName!
                    
                        let userID: String = user.uid
                        let word: String = label.text!
                        let interval = ServerValue.timestamp()
                        gameID = ref.child("Games").childByAutoId().key
                        print(gameID)
                        let post = ["team": teamID!,
                                    "time": interval,
                                    "status": "inplay"] as [String : Any]
                        
                        let childUpdates = ["/Games/\(gameID!)": post]
                        ref.updateChildValues(childUpdates)
                        
                        self.ref.child("Games/\(gameID!)/users").child("\(userID)").setValue(true)
                    self.ref.child("Games/\(gameID!)/turns").childByAutoId().setValue(["content": word, "user": userID,"username": name!, "time": interval, "votes": 0])
                    
                        self.ref.child("Teams").child(teamID!).child("games").child("\(gameID!)").setValue(true)
                    
                        self.ref.child("Teams").child(teamID!).child("/teamInfo/users").child("\(userID)").setValue(["activeGame" : true])
                    
               
                            self.ref.child("Games/\(gameID!)/secondLast").setValue("")
                    
                            self.ref.child("Games/\(gameID!)/lastPlayer").setValue(userID)
                     
                   
                
                
                }
            }
        
        game.captions.append(Caption(phrase: label.text!))
        performSegue(withIdentifier: "ShowWordToDraw", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowWordToDraw" {
            let controller = segue.destination as! DrawWordViewController
            if teamID != nil{
                controller.gameID = gameID
            }
            else{
            controller.game = game
            }
        }
    }


}
