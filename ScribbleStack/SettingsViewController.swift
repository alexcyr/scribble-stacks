//
//  SettingsViewController.swift
//  ScribbleStack
//
//  Created by Alex Cyr on 4/8/17.
//  Copyright © 2017 Alex Cyr. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase


protocol SettingsButtonCellDelegate {
    func cellTapped(cell: SettingsButtonCell)
    
}



class SettingsButtonCell: UITableViewCell {
    
    var buttonDelegate: SettingsButtonCellDelegate?
    
    @IBOutlet weak var labelOutlet: UILabel!
    @IBOutlet weak var switchOutlet: UISwitch!
    
    @IBAction func buttonTap(_ sender: Any) {
        
        if let delegate = buttonDelegate {
            delegate.cellTapped(cell: self)
            
        }
        
    }
    
}
class Word: NSObject {
    
    var name: String
    var owned: Bool
    
    
    init(name: String, owned: Bool){
        self.name = name
        self.owned = owned
        
        
        super.init()
    }
    
}



class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SettingsButtonCellDelegate  {
    
    
    func cellTapped(cell: SettingsButtonCell) {
        print("tapped")
        let cellRow = self.tableView.indexPath(for: cell)!.row
        var wordDictionary = UserDefaults.standard.dictionary(forKey: "ownedWords")!
        print("owned", wordDictionary)
        if (self.tableView.indexPath(for: cell)!.section == 0) {
            sound = cell.switchOutlet.isOn
            self.ref?.child("Users/\(userID)/sound").setValue(sound)
        }
        else{
            print(cellRow)
            let wordInfo = tableWordsArray[cellRow]
            wordInfo.owned = cell.switchOutlet.isOn
            tableWordsArray[cellRow] = wordInfo
            wordDictionary["\(wordInfo.name)"] = cell.switchOutlet.isOn
            
            var count = 0
            for word in tableWordsArray{
                
                if word.owned == false{
                    count = count + 1
                }
                
            }
            if count == tableWordsArray.count{
                if cellRow != 0{
                    let wordEdit = tableWordsArray[cellRow - 1]
                    wordEdit.owned = true
                    wordDictionary["\(wordEdit.name)"] = true
                    tableWordsArray[cellRow - 1] = wordEdit
                    //self.ref?.child("Users/\(userID)/Words").child("\(wordEdit.name)").setValue(wordEdit.owned)
                }
                else if tableWordsArray.count == 1 {
                    let wordEdit = tableWordsArray[cellRow]
                    wordEdit.owned = true
                    wordDictionary["\(wordEdit.name)"] = true
                    tableWordsArray[cellRow] = wordEdit
                    //self.ref?.child("Users/\(userID)/Words").child("\(wordEdit.name)").setValue(wordEdit.owned)
                    
                }
                else{
                    let wordEdit = tableWordsArray[cellRow + 1]
                    wordEdit.owned = true
                    wordDictionary["\(wordEdit.name)"] = true
                    tableWordsArray[cellRow + 1] = wordEdit
                    //self.ref?.child("Users/\(userID)/Words").child("\(wordEdit.name)").setValue(wordEdit.owned)
                }
                self.tableView.reloadData()
                
            }
            UserDefaults.standard.setValue(wordDictionary, forKey: "ownedWords")
            // self.ref?.child("Users/\(userID)/Words").child("\(wordInfo.name)").setValue(wordInfo.owned)
            
        }
    }
    
    
    
    
    @IBOutlet weak var tableView: UITableView!
    var data : String!
    var ref: DatabaseReference?
    var wordGroups: [Any] = []
    var ownedWords: [Any] = []
    var ownedWordsBool: [Any] = []
    var tableWordsArray: [Word] = []
    var teamID: String!
    var tableData: [[ShopItem]] = []
    var ready = false
    var coins = 0
    var sound = true
    var userID = ""
    var username = ""
    
    @IBAction func saveName(_ sender: AnyObject) {
        let textField = self.view.viewWithTag(26) as! UITextField
        let newName = textField.text!
        if newName != ""{
            self.ref?.child("Users/\(userID)/username").setValue("\(newName)")
            
            // Updates the user attributes:
            let user = Auth.auth().currentUser
            if let user = user {
                let changeRequest = user.createProfileChangeRequest()
                
                changeRequest.displayName = "\(newName)"
                
                changeRequest.commitChanges { error in
                    if error != nil {
                        // An error happened.
                        print("failed")
                    } else {
                        // Profile updated.
                        print("sucess")
                        
                        
                    }
                }
            }
            
            let refreshAlert = UIAlertController(title: "Success!", message: "Name changed to \(newName)!", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in
                
            }))
            
            
            
            present(refreshAlert, animated: true, completion: nil)
        }
        else{
            let refreshAlert = UIAlertController(title: "Hey!", message: "Name cannot be left blank.", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action: UIAlertAction!) in
                
            }))
            
            
            
            present(refreshAlert, animated: true, completion: nil)
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        let wordDictionary = UserDefaults.standard.dictionary(forKey: "ownedWords")!
        self.ownedWords = Array(wordDictionary.keys)
        self.ownedWordsBool = Array(wordDictionary.values)
        
        self.coins = UserDefaults.standard.integer(forKey: "earnedCoins")

        
        
        self.view.backgroundColor = UIColorFromRGB(rgbValue: 0xffffff)
        self.tableView.backgroundColor = UIColorFromRGB(rgbValue: 0xffffff)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.allowsSelection = false
        
        
        //navbar logo
        let image = UIImage(named: "scribble-logo-light.png")
        let logoView = UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
        let imageView = UIImageView(frame: CGRect(x: -45, y: -8, width: 90, height: 46))
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        logoView.addSubview(imageView)
        self.navigationItem.titleView = logoView
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        ref = Database.database().reference()
        
        
        
        
        let group1 = DispatchGroup()
        let group2 = DispatchGroup()
        group1.enter()
        if let user  = Auth.auth().currentUser{
            userID = user.uid
            print("dame")
            print(userID)
            
          
            self.ref?.child("Users/\(userID)").observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                if snapshot.hasChildren(){
                    let snap = snapshot.value! as! NSDictionary
                    self.coins = self.coins + (snap["currency"] as! Int)
                    self.username = (snap["username"] as! String)
                    self.sound = (snap["sound"] as! Bool)
                    let textField = self.view.viewWithTag(26) as! UITextField
                    textField.text = self.username
                    _ = (snap["Words"] as! NSDictionary)
                    print("poop")
                    //self.ownedWords = Array(wordData.allKeys)
                    // self.ownedWordsBool = Array(wordData.allValues)
                    print(self.ownedWords)
                    print(self.ownedWordsBool)
                    print("rocka")
                    
                    
                    group1.leave()
                }
                
                
                
                
            })
        }else{
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
            
            
            group2.enter()
            var count = 0
            for word in self.ownedWords{
                let ownedBool = self.ownedWordsBool[count] as! Bool
                let tableWord = Word(name: "\(word)", owned: ownedBool)
                self.tableWordsArray.append(tableWord)
                count = count + 1
                if count == self.ownedWords.count{
                    group2.leave()
                }
            }
            
            
            
            group2.notify(queue: DispatchQueue.main, execute: {
                
                self.tableView.reloadData()
                print(self.tableData)
            })
        })
        
        
    }
    @objc func barButtonItemClicked(sender: UIBarButtonItem) {
        print("clicked")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    func numberOfSections(in: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        if section == 0 {
            rowCount = 1
        }
        else{
            let count = self.tableWordsArray.count
            rowCount = count
        }
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        let n = indexPath.row
        
        if(indexPath.section == 0){
            if(n == 0){
                return 130.0
            }
        }
        
        
        return 50.0
        
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let n = indexPath.row
        
        
        if (indexPath.section == 0) {
            if n < 1{
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "ChangeName", for: indexPath as IndexPath)
                cell.contentView.backgroundColor = UIColorFromRGB(rgbValue: 0xffffff)
                
                return cell
                
            }
            else{
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "OnOffSwitch", for: indexPath as IndexPath) as! SettingsButtonCell
                cell.labelOutlet.text = "Sound Effects"
                cell.switchOutlet.isOn = sound
                cell.contentView.backgroundColor = UIColorFromRGB(rgbValue: 0xffffff)
                
                if cell.buttonDelegate == nil {
                    cell.buttonDelegate = self
                }
                
                return cell
                
            }
        }
            
            
        else{
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "OnOffSwitch", for: indexPath as IndexPath) as! SettingsButtonCell
            cell.contentView.backgroundColor = UIColorFromRGB(rgbValue: 0xffffff)
            
            
            
            
                cell.buttonDelegate = self
            
            
            cell.layer.borderColor = UIColorFromRGB(rgbValue: 0xffffff).cgColor
            cell.layer.borderWidth = 3
            
            let cellInfo = tableWordsArray[n]
            let wordTitle = cellInfo.name
            let wordValue = cellInfo.owned
            
            cell.labelOutlet.text = wordTitle
            cell.switchOutlet.setOn(wordValue, animated: true)
            return cell
        }
        
        //  Now do whatever you were going to do with the title.
    }
    
    let headerTitles = ["", "Activate Wordpacks"]
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section
        {
        case 0:
            return headerTitles[0]
        case 1:
            return headerTitles[1]
        default:
            return "No More Data"
        }
        
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        
        _ = view as! UITableViewHeaderFooterView
        view.tintColor = UIColorFromRGB(rgbValue: 0xE6E7E8)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        
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
    }
    
}


