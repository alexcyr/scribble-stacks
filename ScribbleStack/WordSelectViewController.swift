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
    var ref: FIRDatabaseReference!
    var teamID: String?
    var gameID: String!
    var ownedWords: [Any] = []
    var ownedWordsBool: [Any] = []
    var userID = ""
    var coins = 0
    let game = Game(captions: [], images: [])
    var getRandomWord: [String] = []
    var words = ["WALK THE DOG","BRUSHING TEETH","POTATO","SKYDIVING","HOTDOG","CATDOG","PINATA","SUPERMAN","PIG IN A BLANKET","BANANA", "TACO","STAIRWAY TO HEAVEN","TURTLE SOUP","BASEBALL","BEACH","REINDEER LAYING AN EGG"]
    
    @IBAction func refreshWords(_ sender: AnyObject) {
        let refreshAlert = UIAlertController(title: "Refresh Words", message: "Spend 20💰 to get a new set of words?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.loadWords()
            
        }))
        
        
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColorFromRGB(rgbValue: 0xE6E7E8)
        self.tableView.backgroundColor = UIColorFromRGB(rgbValue: 0xE6E7E8)

        // Do any additional setup after loading the view, typically from a nib.

            // Do any additional setup after loading the view, typically from a nib.
        ref = FIRDatabase.database().reference()
        tableView.delegate = self
        tableView.dataSource = self
        
        //navbar logo
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "scribble-logo.png")
        imageView.image = image
        navigationItem.titleView = imageView
        
        if let user = FIRAuth.auth()?.currentUser{
            userID = user.uid
            loadWords()
            
        }
        else{
            
            let wordsLength = words.count
            let getRandom = randomSequenceGenerator(min: 1, max: wordsLength)
            for _ in 1...3 {
                print(getRandom())
                getRandomWord.append(words[getRandom()-1])
            }
        }
        
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

        let group1 = DispatchGroup()
        let group2 = DispatchGroup()
        
        group1.enter()
        
        self.ref?.child("Users/\(userID)").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            if snapshot.hasChildren(){
                let snap = snapshot.value! as! NSDictionary
                self.coins = (snap["currency"] as! Int)
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
        
        
        
        group1.notify(queue: DispatchQueue.main, execute: {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "\(self.coins)💰", style: .plain, target: self, action: #selector(self.barButtonItemClicked))
            
            self.ref.child("Words").observeSingleEvent(of: .value, with: { (snapshot) in
                print("licorice snape")
                let data = snapshot.value! as! NSDictionary
                print(data)
                self.words = []
                for word in self.ownedWords{
                    let wordArray = (data["\(word)"] as! [String])
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
                        
                    }
                }
            })
            
        })
    }
    func barButtonItemClicked(){
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
        cell.layer.borderColor = UIColorFromRGB(rgbValue: 0xE6E7E8).cgColor
        cell.layer.borderWidth = 3
        let label = cell.viewWithTag(1000) as! UILabel
        
        
            label.text = getRandomWord[indexPath.row]
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        if let cell = tableView.cellForRow(at: indexPath) {

        let label = cell.viewWithTag(1000) as! UILabel
        
            if teamID != nil{
                if let user  = FIRAuth.auth()?.currentUser{
                    var name: String?
                    name = user.displayName!
                    
                        let userID: String = user.uid
                        let word: String = label.text!
                        let interval = FIRServerValue.timestamp()
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
                    
                        self.ref.child("Teams").child(teamID!).child("users").child("\(userID)").setValue(["activeGame" : true])
                    
               
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
