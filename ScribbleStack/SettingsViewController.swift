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
    
    @IBAction func buttonTap(_ sender: AnyObject) {
        
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
    
    
    internal func cellTapped(cell: SettingsButtonCell) {
       print("tapped")
        let cellRow = self.tableView.indexPath(for: cell)!.row

        if (self.tableView.indexPath(for: cell)!.section == 0) {
            sound = cell.switchOutlet.isOn
            self.ref?.child("Users/\(userID)/sound").setValue(sound)
        }
        else{
            print(cellRow)
            let wordInfo = tableWordsArray[cellRow]
            wordInfo.owned = cell.switchOutlet.isOn
            tableWordsArray[cellRow] = wordInfo

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
                    tableWordsArray[cellRow - 1] = wordEdit
                    self.ref?.child("Users/\(userID)/Words").child("\(wordEdit.name)").setValue(wordEdit.owned)
                }
                else{
                    let wordEdit = tableWordsArray[cellRow + 1]
                    wordEdit.owned = true
                    tableWordsArray[cellRow + 1] = wordEdit
                    self.ref?.child("Users/\(userID)/Words").child("\(wordEdit.name)").setValue(wordEdit.owned)
                }
                self.tableView.reloadData()

            }
                        self.ref?.child("Users/\(userID)/Words").child("\(wordInfo.name)").setValue(wordInfo.owned)

        }
    }

    
    
    
    @IBOutlet weak var tableView: UITableView!
    var data : String!
    var ref: FIRDatabaseReference?
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
            let user = FIRAuth.auth()?.currentUser
            if let user = user {
                let changeRequest = user.profileChangeRequest()
                
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
        
        self.view.backgroundColor = UIColorFromRGB(rgbValue: 0xE6E7E8)
        self.tableView.backgroundColor = UIColorFromRGB(rgbValue: 0xE6E7E8)
        self.tableView.allowsSelection = false
        
        
        //navbar logo
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "scribble-logo.png")
        imageView.image = image
        navigationItem.titleView = imageView
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        ref = FIRDatabase.database().reference()
        
       
        
        
        let group1 = DispatchGroup()
        let group2 = DispatchGroup()
        group1.enter()
        if let user  = FIRAuth.auth()?.currentUser{
            userID = user.uid
            print("dame")
            print(userID)
            
            var teamTotal = 0
            var teamCount = 0
            var teamGameCount = 0
            self.ref?.child("Users/\(userID)").observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                if snapshot.hasChildren(){
                    let snap = snapshot.value! as! NSDictionary
                    self.coins = (snap["currency"] as! Int)
                    self.username = (snap["username"] as! String)
                    self.sound = (snap["sound"] as! Bool)
                    let textField = self.view.viewWithTag(26) as! UITextField
                    textField.text = self.username
                    let wordData = (snap["Words"] as! NSDictionary)
                    print("poop")
                    print(snapshot.value)
                    self.ownedWords = Array(wordData.allKeys)
                    self.ownedWordsBool = Array(wordData.allValues)
                    print(self.ownedWords)
                    print(self.ownedWordsBool)
                    print("rocka")
                    
                    
                    group1.leave()
                }
                
                
                
                
            })
            
            group1.notify(queue: DispatchQueue.main, execute: {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "\(self.coins)💰", style: .plain, target: self, action: #selector(self.barButtonItemClicked))
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
        
    }
    func barButtonItemClicked(sender: UIBarButtonItem) {
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
            rowCount = 2
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
                withIdentifier: "ChangeName", for: indexPath as IndexPath) as! UITableViewCell
                return cell

            }
            else{
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "OnOffSwitch", for: indexPath as IndexPath) as! SettingsButtonCell
                cell.labelOutlet.text = "Sound Effects"
                cell.switchOutlet.isOn = sound
                if cell.buttonDelegate == nil {
                    cell.buttonDelegate = self
                }
                
                return cell

            }
        }
        
        
        else{
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "OnOffSwitch", for: indexPath as IndexPath) as! SettingsButtonCell
        
        
        
        if cell.buttonDelegate == nil {
            cell.buttonDelegate = self
        }
        
        cell.contentView.backgroundColor = UIColorFromRGB(rgbValue: 0xE6E7E8)
        cell.layer.borderColor = UIColorFromRGB(rgbValue: 0xE6E7E8).cgColor
        cell.layer.borderWidth = 3
        
        let cellInfo = tableWordsArray[n]
            let wordTitle = cellInfo.name
        let wordValue = cellInfo.owned
        
        cell.labelOutlet.text = wordTitle
        cell.switchOutlet.isOn = wordValue
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
        
        let header = view as! UITableViewHeaderFooterView
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
