//
//  HowToViewController.swift
//  ScribbleStack
//
//  Created by Alex Cyr on 1/20/18.
//  Copyright © 2018 Alex Cyr. All rights reserved.
//

import Foundation
import UIKit

class HowToViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var coins: Int?
    let howToText = ["Invite your friends to join your team. Be sure to name your team something RAD like “The Mighty #2”! On second thought, we’ll leave that up to you", "Each new game starts by selecting a word that you want to draw.", "Time to draw! You’re drawing the word you just selected, but as the game goes on, you’ll be drawing whatever captions you’re given.","Each time a drawing or caption is completed, it will be sent to the cloud for your friends to play. If there’s available games, they will be pulled from the cloud for you to play. It looks like there’s something coming in now...","You’ll also get to write captions for your friends drawings. Hmph?! What’s that even supposed to be?! Just make sure you write something. Anything will always better than nothing.", "This process will repeat itself until the game ends with everyone on your team playing on each others games.","At the end of the game, all the captions and drawings are shown in order, showing all the fun twists and turns."]
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //navbar logo
        let image = UIImage(named: "scribble-logo-light.png")
        let logoView = UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
        let imageView = UIImageView(frame: CGRect(x: -45, y: -8, width: 90, height: 46))
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        logoView.addSubview(imageView)
        self.navigationItem.titleView = logoView
        
        //coins
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
        
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.showsHorizontalScrollIndicator = false;
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160
        tableView.reloadData()
        
    }
    
  
    
   func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 8
    }
    
   
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let n = indexPath.row
        
        if n==0{
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "HeaderTitle", for: indexPath) as UITableViewCell
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
            
        }
        else{
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "HowToView", for: indexPath) as UITableViewCell
        let howToImage = cell.viewWithTag(100) as! UIImageView
        howToImage.image = UIImage(named: "howTo\(n).png")
        
        let textOutlet = cell.viewWithTag(101) as! UILabel
        textOutlet.text = howToText[n-1]
        
        cell.backgroundColor = UIColor.clear
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                
                return cell
        }
        
            
            
        }
            
            
    
        
    

 
    
    
    
}
