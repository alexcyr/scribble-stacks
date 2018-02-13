//
//  ThemeManager.swift
//  ScribbleStacks
//
//  Created by Alex Cyr on 1/29/17.
//  Copyright © 2017 Alex Cyr. All rights reserved.
//


import UIKit

extension UIButton {
    var titleLabelFont: UIFont! {
        get { return self.titleLabel?.font }
        set { self.titleLabel?.font = newValue }
    }
}

extension UIImage {
    class func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 0.5)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

class ThemeManager {
    
    static func applyTheme() {
        /*
        let proxyNormalButton = UIButton.appearance()
        proxyNormalButton.setTitleColor(Styles.buttonTextColor, for: .normal)
        let buttonImage = Styles.setNormalBackgroundImage
        proxyNormalButton.setBackgroundImage(buttonImage, for: UIControlState())
        proxyNormalButton.titleLabelFont = Styles.normalButtonFont
        
    

        
        
       
        // Shadow and Radius
        proxyNormalButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        proxyNormalButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        proxyNormalButton.layer.shadowOpacity = 1.0
        proxyNormalButton.layer.shadowRadius = 0.0
        proxyNormalButton.layer.masksToBounds = false
        proxyNormalButton.layer.cornerRadius = 6.0
        */
        let blue = UIColorFromRGB(rgbValue: 0x01A7B9)
        let darkBlue = UIColorFromRGB(rgbValue: 0x047799)
  
       
        UINavigationBar.appearance().barTintColor = UIColorFromRGB(rgbValue: 0x01A7B9)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]

        // Sets Bar's Background Image (Color) //
        UINavigationBar.appearance().setBackgroundImage(UIImage.imageWithColor(color: blue), for: .default)
        // Sets Bar's Shadow Image (Color) //
        UINavigationBar.appearance().shadowImage = UIImage.imageWithColor(color: darkBlue)
        
        _ = UILabel.appearance()
        //proxyBodyLabel.font = Styles.bodyFont
        
        let proxySegmentedControl = UISegmentedControl.appearance()
        proxySegmentedControl.tintColor = Colors.Green
        
        let proxyTextField = UITextField.appearance()
        proxyTextField.backgroundColor = Colors.LightGray
        
        
    }
}
