//
//  AboutViewController.swift
//  ScribbleStack
//
//  Created by Alex Cyr on 2/7/18.
//  Copyright © 2018 Alex Cyr. All rights reserved.
//

import Foundation
import UIKit

class AboutViewController: UIViewController{
    
    var coins: Int?
  
    @IBAction func emailButton(_ sender: Any) {
        let email = "scribblestacks@gmail.com"
        if let url = NSURL(string: "mailto:\(email)") {
            UIApplication.shared.openURL(url as URL)
        }
    }
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
        
        
    }
    
    
    
    
}

