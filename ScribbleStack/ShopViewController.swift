//
//  ShopViewController.swift
//  ScribbleStacks
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
        
        let cellTextRight = tableData[sectionCount][(2 * cellRow) + 1]
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

                
                self.wordDictionary["\(rightTitle)"] = true
                UserDefaults.standard.setValue(self.wordDictionary, forKey: "ownedWords")
                
                var localCoins = UserDefaults.standard.integer(forKey: "earnedCoins")
                var total = rightValue
                var dbCoins = self.coins - localCoins
                if(dbCoins >= rightValue){
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
                    self.ref?.child("Users/\(self.userID)/currency").setValue(dbCoins)
                }
                
                self.setCoins()

                
                
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
                self.setCoins()

                
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Cancel")
                
                
                
            }))
            
            present(refreshAlert, animated: true, completion: nil)
        }
        
        
        
    }

   func leftcellTapped(cell: ShopButtonCell) {
    let cellRow = self.tableView.indexPath(for: cell)!.row
    let sectionCount = self.tableView.indexPath(for: cell)!.section
   
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
            self.ownedWords.append(leftTitle)
            cellTextLeft.owned = true
            self.tableData[sectionCount][(2 * cellRow)] = cellTextLeft
            self.tableView.reloadData()
            
            self.wordDictionary["\(leftTitle)"] = true
            UserDefaults.standard.setValue(self.wordDictionary, forKey: "ownedWords")
            
            var localCoins = UserDefaults.standard.integer(forKey: "earnedCoins")
            var total = leftValue
            var dbCoins = self.coins - localCoins
            if(dbCoins >= leftValue){
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
                self.ref?.child("Users/\(self.userID)/currency").setValue(dbCoins)
            }
            
            self.setCoins()

            
            
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
            self.setCoins()

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
    var ref: DatabaseReference?
    var wordGroups: [Any] = []
    var ownedWords: [Any] = []
    var wordDictionary: [String: Any] = [:]
    var teamID: String!
    var tableData: [[ShopItem]] = []
    var ready = false
    var coins = 0
    var itemCount = 0
    var userID = ""
    var base64String: NSString!
    let screenWidth = UIScreen.main.bounds.width

    
    fileprivate func setCoins() {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        wordDictionary = UserDefaults.standard.dictionary(forKey: "ownedWords")!
        self.ownedWords = Array(wordDictionary.keys)
        
        let earnedCoins = UserDefaults.standard.integer(forKey: "earnedCoins")
        self.coins = earnedCoins
        
        self.view.backgroundColor = UIColorFromRGB(rgbValue: 0xffffff)
        self.tableView.backgroundColor = UIColorFromRGB(rgbValue: 0xffffff)
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
        
        let coinPack1 = ShopItem(name: "50", owned: false, value: 1, image: UIImage(named: "bobCoin.png")!)
        let coinPack2 = ShopItem(name: "150", owned: false, value: 2,  image: UIImage(named: "bobCoin.png")!)
        let coinPack3 = ShopItem(name: "500", owned: false, value: 5,  image: UIImage(named: "bobCoin.png")!)
        
        coinPacks.append(coinPack1)
        
        coinPacks.append(coinPack2)
        coinPacks.append(coinPack3)
        
       
        let group1 = DispatchGroup()
        let group2 = DispatchGroup()
        group1.enter()
        
        var allWordsDict: NSDictionary?
        if let user  = Auth.auth().currentUser{
            userID = user.uid
            print("dame")
            print(userID)
           allWordsDict = UserDefaults.standard.dictionary(forKey: "wordList")! as NSDictionary
            
            self.ref?.child("Users/\(userID)").observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                if snapshot.hasChildren(){
                    let snap = snapshot.value! as! NSDictionary
                    self.coins = self.coins + (snap["currency"] as! Int)
                    _ = (snap["Words"] as! NSDictionary)
                    print("poop")
                    //self.ownedWords = Array(wordData.allKeys)
                    print(self.ownedWords)
                    print("rocka")
                   
                   
                    group1.leave()
                }
                
                
                
                
            })
        }
        else{
            allWordsDict = self.loadJson(forFilename: "words")
            group1.leave()
        }
            group1.notify(queue: DispatchQueue.main, execute: {
                self.setCoins()
            group2.enter()
           
               

                self.wordGroups = Array(allWordsDict!.allKeys)
                    print(self.wordGroups)
                    print("limes")
                    var n = 0
                    for words in self.wordGroups{
                        let word = words as! String
                        if word == "Easy" || word == "Medium" || word == "Hard"{
                            self.wordGroups.remove(at: n)
                            n -= 1
                        }
                        else{
                            self.itemCount += 1;
                        n += 1
                            let wordObject = (allWordsDict!["\(word)"] as! NSDictionary)
                            self.base64String = wordObject.value(forKey: "Image") as! NSString? ?? ""
                            print(self.base64String)
                            let decodedData = NSData(base64Encoded: self.base64String as String, options: NSData.Base64DecodingOptions())
                            let wordImage = UIImage(data: decodedData! as Data)!
                          
                            let wordPack = ShopItem(name: "", owned: false, value: 50, image: wordImage)
                            if word.range(of:"Expansion") != nil{
                                wordPack.value = 100
                            }
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
                    print(self.wordPacks)
                    
                    group2.leave()
             
            
            group2.notify(queue: DispatchQueue.main, execute: {
                self.tableData.append(self.wordPacks)
                self.tableData.append(self.coinPacks)
                self.tableView.reloadData()
                print(self.tableData)
            })
            })
        
        
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
        
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("section count")
        if section < 1{
        print(tableData[section].count)
        let count = tableData[section].count
        let rowCount = (count/2) + (count%2)
        return rowCount
        }
        else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let n = indexPath.row
        
        
        
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "WordSelect", for: indexPath as IndexPath) as! ShopButtonCell
        
        
        
        if cell.buttonDelegate == nil {
            cell.buttonDelegate = self
        }
        
        cell.contentView.backgroundColor = UIColorFromRGB(rgbValue: 0xffffff)
        cell.layer.borderColor = UIColorFromRGB(rgbValue: 0xffffff).cgColor
        cell.layer.borderWidth = 3
        
        let cellTextLeft = tableData[indexPath.section][2 * n]
        let leftTitle = cellTextLeft.name
        let leftValue = cellTextLeft.value
        
        print(leftTitle)
        let count = self.tableData[indexPath.section].count
        let rowCount = ((count/2) + (count%2))
        
        if indexPath.section < 1{
        cell.leftButtonOutlet.setTitle("\(leftTitle)", for: .normal)
            cell.leftButtonOutlet.titleLabel?.numberOfLines = 1
            cell.leftButtonOutlet.titleLabel?.adjustsFontSizeToFitWidth = true
            cell.leftButtonOutlet.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
            cell.leftButtonOutlet.setBackgroundImage(cellTextLeft.image, for: .normal)
            let attachment = NSTextAttachment()
            attachment.bounds = CGRect(x: -1, y: -2,width: 15,height: 15);
            attachment.image = UIImage(named: "bobCoin.png")
            let attachmentString = NSAttributedString(attachment: attachment)
            var attributes = [NSAttributedStringKey: AnyObject]()
            attributes[NSAttributedStringKey.foregroundColor] = UIColorFromRGB(rgbValue: 0x000000)
            let myString = NSMutableAttributedString(string: "\(leftTitle) - \(leftValue) ", attributes: attributes)
            myString.append(attachmentString)
        
        cell.leftLabelOutlet.attributedText = myString
        let cellOwned = cellTextLeft.owned as Bool
            if cellOwned{
                cell.leftButtonOutlet.layer.borderWidth = 8
                cell.leftButtonOutlet.layer.borderColor = UIColorFromRGB(rgbValue: 0xD83258).cgColor
            }
        }
        else{
            cell.leftButtonOutlet.setTitle("", for: .normal)
            cell.leftLabelOutlet.text = "\(leftTitle) coins - $\(leftValue).00"
            cell.leftButtonOutlet.setBackgroundImage(cellTextLeft.image, for: .normal)

        }
        if n != (rowCount - 1){
            
            let cellTextRight = tableData[indexPath.section][(2 * n) + 1]
        let rightTitle = cellTextRight.name
        
            let rightValue = cellTextRight.value
            if indexPath.section < 1{
                cell.leftButtonOutlet.setTitle("\(leftTitle)", for: .normal)
                cell.leftButtonOutlet.setBackgroundImage(cellTextLeft.image, for: .normal)
                cell.leftButtonOutlet.titleLabel?.numberOfLines = 1
                cell.leftButtonOutlet.titleLabel?.adjustsFontSizeToFitWidth = true
                cell.leftButtonOutlet.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
                let attachment = NSTextAttachment()
                attachment.bounds = CGRect(x: -1, y: -2,width: 15,height: 15);
                attachment.image = UIImage(named: "bobCoin.png")
                let attachmentString = NSAttributedString(attachment: attachment)
                var attributes = [NSAttributedStringKey: AnyObject]()
                attributes[NSAttributedStringKey.foregroundColor] = UIColorFromRGB(rgbValue: 0x000000)
                let myString = NSMutableAttributedString(string: "\(rightTitle) - \(rightValue) ", attributes: attributes)
                myString.append(attachmentString)
                
                cell.rightLabelOutlet.attributedText = myString
                cell.rightButtonOutlet.setTitle("\(rightTitle)", for: .normal)
                cell.rightButtonOutlet.setBackgroundImage(cellTextRight.image, for: .normal)
                cell.rightButtonOutlet.titleLabel?.numberOfLines = 1
                cell.rightButtonOutlet.titleLabel?.adjustsFontSizeToFitWidth = true
                cell.rightButtonOutlet.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
                

                let cellOwned = cellTextRight.owned as Bool
                if cellOwned{
                    cell.rightButtonOutlet.layer.borderWidth = 8
                    cell.rightButtonOutlet.layer.borderColor = UIColorFromRGB(rgbValue: 0xD83258).cgColor
                    
                }
            }
            else{
                cell.rightButtonOutlet.setTitle("", for: .normal)
                cell.rightLabelOutlet.text = "\(rightTitle) coins - $\(rightValue).00"
                cell.rightButtonOutlet.setBackgroundImage(cellTextRight.image, for: .normal)


            }
            
        }
        else{
            if count%2 == 0{
                let cellTextRight = tableData[indexPath.section][(2 * n) + 1]
                let rightTitle = cellTextRight.name
                
                let rightValue = cellTextRight.value
                if indexPath.section < 1{
                    let attachment = NSTextAttachment()
                    attachment.bounds = CGRect(x: -1, y: -2,width: 15,height: 15);
                    attachment.image = UIImage(named: "bobCoin.png")
                    let attachmentString = NSAttributedString(attachment: attachment)
                    var attributes = [NSAttributedStringKey: AnyObject]()
                    attributes[NSAttributedStringKey.foregroundColor] = UIColorFromRGB(rgbValue: 0x000000)
                    let myString = NSMutableAttributedString(string: "\(rightTitle) - \(rightValue) ", attributes: attributes)
                    myString.append(attachmentString)
                    
                    cell.rightLabelOutlet.attributedText = myString
                    cell.rightButtonOutlet.setTitle("\(rightTitle)", for: .normal)
                    cell.rightButtonOutlet.setBackgroundImage(cellTextRight.image, for: .normal)
                    cell.rightButtonOutlet.titleLabel?.numberOfLines = 1
                    cell.rightButtonOutlet.titleLabel?.adjustsFontSizeToFitWidth = true
                    cell.rightButtonOutlet.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
                    
                   
                    let cellOwned = cellTextRight.owned as Bool
                    if cellOwned{
                        cell.rightButtonOutlet.layer.borderWidth = 8
                        cell.rightButtonOutlet.layer.borderColor = UIColorFromRGB(rgbValue: 0xD83258).cgColor
                        
                    }
                }
                else{
                    cell.rightButtonOutlet.setTitle("", for: .normal)
                    cell.rightLabelOutlet.text = "\(rightTitle) coins - $\(rightValue).00"
                    cell.rightButtonOutlet.setBackgroundImage(cellTextRight.image, for: .normal)
                    
                }
            }
            else{
            cell.rightButtonOutlet.isHidden = true
            cell.rightLabelOutlet.isHidden = true
            }
        }
        return cell
        
        //  Now do whatever you were going to do with the title.
    }
    
    
    let headerTitles = ["Word Expansions", ""]
    
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
        view.tintColor = UIColorFromRGB(rgbValue: 0xffffff)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row != (self.itemCount/2 - 1){
       return (screenWidth/2) + 10.0
        }
        else{
            return (screenWidth/2) + 30.0
        }
        
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
     
        
       
    }
    
}
