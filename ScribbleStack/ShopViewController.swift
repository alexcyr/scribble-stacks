//
//  ShopViewController.swift
//  ScribbleStack
//
//  Created by Alex Cyr on 3/16/17.
//  Copyright © 2017 Alex Cyr. All rights reserved.
//


import UIKit
import FirebaseAuth
import FirebaseDatabase


protocol ShopButtonCellDelegate {
    func leftcellTapped(cell: ShopButtonCell)
    func rightcellTapped(cell: ShopButtonCell)
}



class ShopButtonCell: UITableViewCell {
    
    var buttonDelegate: ShopButtonCellDelegate?
    
    @IBOutlet weak var rightLabelOutlet: UILabel!
    @IBOutlet weak var leftLabelOutlet: UILabel!
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

class ShopViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ShopButtonCellDelegate  {
    
    func rightcellTapped(cell: ShopButtonCell) {
        let cellRow = self.tableView.indexPath(for: cell)!.row
        let count = self.tableData[0].count
        let rowCount = ((count/2) + (count%2))
        let sectionCount = self.tableView.indexPath(for: cell)!.section
        print(cellRow)
        print(rowCount)
        
        var cellTextRight = tableData[sectionCount][(2 * cellRow) + 1]
        let rightTitle = cellTextRight.name
        let rightValue = cellTextRight.value
        let rightOwned = cellTextRight.owned as Bool
        
        if sectionCount < 1{
            if rightOwned{
                let refreshAlert = UIAlertController(title: "Hey!", message: "You've already purchased this!", preferredStyle: UIAlertControllerStyle.alert)
                
                refreshAlert.addAction(UIAlertAction(title: "Okay.", style: .default, handler: { (action: UIAlertAction!) in
                    
                }))
                
                
                
                present(refreshAlert, animated: true, completion: nil)
            }
            if coins < rightValue{
                let refreshAlert = UIAlertController(title: "Sorry!", message: "You don't have enough coins.", preferredStyle: UIAlertControllerStyle.alert)
                
                refreshAlert.addAction(UIAlertAction(title: "Okay.", style: .default, handler: { (action: UIAlertAction!) in
                    
                }))
                
                
                
                present(refreshAlert, animated: true, completion: nil)
            }
            
            else{
            let refreshAlert = UIAlertController(title: "Purchase Item?", message: "Spend \(rightValue) coins to unlock \(rightTitle) wordpack?", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                
                self.ownedWords.append(rightTitle)
                cellTextRight.owned = true
                self.tableData[sectionCount][(2 * cellRow) + 1] = cellTextRight
                self.tableView.reloadData()

                
                self.ref?.child("Users/\(self.userID)/Words/\(rightTitle)").setValue(true)
                
                self.coins = self.coins - rightValue
                self.ref?.child("Users/\(self.userID)/currency").setValue(self.coins)
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "\(self.coins)💰", style: .plain, target: self, action: #selector(self.barButtonItemClicked))
                
                
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Cancel")
                
                
                
            }))
            
            present(refreshAlert, animated: true, completion: nil)
            }
        }
        else{
            let refreshAlert = UIAlertController(title: "Purchase Item?", message: "Purchase \(rightTitle) coins for $\(rightValue).00?", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                
                let coinValue = Int(rightTitle)

                self.coins = self.coins + coinValue!
                self.ref?.child("Users/\(self.userID)/currency").setValue(self.coins)
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "\(self.coins)💰", style: .plain, target: self, action: #selector(self.barButtonItemClicked))
                
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Cancel")
                
                
                
            }))
            
            present(refreshAlert, animated: true, completion: nil)
        }
        
        
        
    }

   func leftcellTapped(cell: ShopButtonCell) {
    let cellRow = self.tableView.indexPath(for: cell)!.row
    var sectionCount = self.tableView.indexPath(for: cell)!.section
   
    let cellTextLeft = tableData[sectionCount][2 * cellRow]
    let leftTitle = cellTextLeft.name
    let leftValue = cellTextLeft.value
    let leftOwned = cellTextLeft.owned
    
    if sectionCount < 1{
        if leftOwned{
            let refreshAlert = UIAlertController(title: "Hey!", message: "You've already purchased this!", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Okay.", style: .default, handler: { (action: UIAlertAction!) in
                
            }))
            
            
            
            present(refreshAlert, animated: true, completion: nil)
        }
        if coins < leftValue{
            let refreshAlert = UIAlertController(title: "Sorry!", message: "You don't have enough coins.", preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Okay.", style: .default, handler: { (action: UIAlertAction!) in
                
            }))
            
           
            
            present(refreshAlert, animated: true, completion: nil)
        }
        else{
        let refreshAlert = UIAlertController(title: "Purchase Item?", message: "Spend \(leftValue) coins to unlock \(leftTitle) wordpack?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.coins = self.coins - leftValue
            self.ownedWords.append(leftTitle)
            cellTextLeft.owned = true
            self.tableData[sectionCount][(2 * cellRow)] = cellTextLeft
            self.tableView.reloadData()
            
            
            self.ref?.child("Users/\(self.userID)/Words/\(leftTitle)").setValue(true)
            self.ref?.child("Users/\(self.userID)/currency").setValue(self.coins)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "\(self.coins)💰", style: .plain, target: self, action: #selector(self.barButtonItemClicked))
            
            
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Cancel")
            
            
            
        }))
        
        present(refreshAlert, animated: true, completion: nil)
        }
    }
    else{
        let refreshAlert = UIAlertController(title: "Purchase Item?", message: "Purchase \(leftTitle) coins for $\(leftValue).00?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            let coinValue = Int(leftTitle)
            self.coins = self.coins + coinValue!
            self.ref?.child("Users/\(self.userID)/currency").setValue(self.coins)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "\(self.coins)💰", style: .plain, target: self, action: #selector(self.barButtonItemClicked))
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Cancel")
            
            
            
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    

    }

    
    
    @IBOutlet weak var tableView: UITableView!
    var data : String!
    var wordPacks: [ShopItem] = []
    var coinPacks: [ShopItem] = []
    var ref: FIRDatabaseReference?
    var wordGroups: [Any] = []
    var ownedWords: [Any] = []
    var teamID: String!
    var tableData: [[ShopItem]] = []
    var ready = false
    var coins = 0
    var userID = ""
    
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
        
        var coinPack1 = ShopItem(name: "50", owned: false, value: 1)
        var coinPack2 = ShopItem(name: "150", owned: false, value: 2)
        var coinPack3 = ShopItem(name: "500", owned: false, value: 5)
        coinPacks.append(coinPack1)
        coinPacks.append(coinPack2)
        coinPacks.append(coinPack3)
        
       
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
                    let wordData = (snap["Words"] as! NSDictionary)
                    print("poop")
                    print(snapshot.value)
                    self.ownedWords = Array(wordData.allKeys)
                    print(self.ownedWords)
                    print("rocka")
                   
                   
                    group1.leave()
                }
                
                
                
                
            })
            
            group1.notify(queue: DispatchQueue.main, execute: {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "\(self.coins)💰", style: .plain, target: self, action: #selector(self.barButtonItemClicked))
            group2.enter()
            self.ref?.child("Words").observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                if snapshot.hasChildren(){
                    let snap = snapshot.value! as! NSDictionary
                    print("Tada")
                    print(snapshot.value)
                    self.wordGroups = Array(snap.allKeys)
                    print(self.wordGroups)
                    print("limes")
                    teamTotal = self.wordGroups.count
                    print(teamTotal)
                    var n = 0
                    for words in self.wordGroups{
                        
                        let word = words as! String
                        if word == "Base"{
                            self.wordGroups.remove(at: n)
                            n -= 1
                        }
                        else{
                        n += 1
                        var wordPack = ShopItem(name: "", owned: false, value: 50)
                        wordPack.name = word
                        for x in self.ownedWords{
                            let owned = x as! String
                            
                            if owned == word{
                                wordPack.owned = true
                            }
                        }
                        self.wordPacks.append(wordPack)
                        }
                    }
                    
                    group2.leave()
                }
                
                
                
                
            })
            
            group2.notify(queue: DispatchQueue.main, execute: {
                self.tableData.append(self.wordPacks)
                self.tableData.append(self.coinPacks)
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
        
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("section count")
        print(tableData[section].count)
        let count = tableData[section].count
        let rowCount = (count/2) + (count%2)
        return rowCount
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let n = indexPath.row
        
        
        
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "WordSelect", for: indexPath as IndexPath) as! ShopButtonCell
        
        
        
        if cell.buttonDelegate == nil {
            cell.buttonDelegate = self
        }
        
        cell.contentView.backgroundColor = UIColorFromRGB(rgbValue: 0xE6E7E8)
        cell.layer.borderColor = UIColorFromRGB(rgbValue: 0xE6E7E8).cgColor
        cell.layer.borderWidth = 3
        
        let cellTextLeft = tableData[indexPath.section][2 * n]
        let leftTitle = cellTextLeft.name
        let leftValue = cellTextLeft.value
        
        print(leftTitle)
        let count = self.tableData[0].count
        let rowCount = ((count/2) + (count%2))
        
        if indexPath.section < 1{
        cell.leftButtonOutlet.setTitle("\(leftTitle)", for: .normal)
        cell.leftLabelOutlet.text = "\(leftTitle) - \(leftValue)💰"
        let cellOwned = cellTextLeft.owned as Bool
            if cellOwned{
                cell.leftButtonOutlet.layer.borderWidth = 8
                cell.leftButtonOutlet.layer.borderColor = UIColorFromRGB(rgbValue: 0x01A7B9).cgColor
                
            }
        }
        else{
            cell.leftLabelOutlet.text = "\(leftTitle) coins - $\(leftValue).00"
        }
        if n%2 == 0{
            let cellTextRight = tableData[indexPath.section][(2 * n) + 1]
        var rightTitle = cellTextRight.name
        
            let rightValue = cellTextRight.value
            if indexPath.section < 1{
                cell.rightLabelOutlet.text = "\(rightTitle) - \(rightValue)💰"
                cell.rightButtonOutlet.setTitle("\(rightTitle)", for: .normal)
                let cellOwned = cellTextRight.owned as Bool
                if cellOwned{
                    cell.rightButtonOutlet.layer.borderWidth = 8
                    cell.rightButtonOutlet.layer.borderColor = UIColorFromRGB(rgbValue: 0x01A7B9).cgColor
                    
                }
            }
            else{
                cell.rightLabelOutlet.text = "\(rightTitle) coins - $\(rightValue).00"

            }
        }
        else{
            cell.rightButtonOutlet.isHidden = true
            cell.rightLabelOutlet.isHidden = true
        }
        return cell
        
        //  Now do whatever you were going to do with the title.
    }
    
    let headerTitles = ["Word Expansions", "Purchase Coins"]
    
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
