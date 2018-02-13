//
//  Styles.swift
//  ScribbleStacks
//
//  Created by Alex Cyr on 1/29/17.
//  Copyright © 2017 Alex Cyr. All rights reserved.
//

import UIKit

class Colors {
    static let White = UIColor(red: 255 / 255 , green: 255 / 255 , blue: 255 / 255 , alpha: 1.0 )
    static let Green = UIColor(red: 141 / 255 , green: 198 / 255 , blue: 63 / 255 , alpha: 1.0 )
    static let Gray = UIColor(red: 84 / 255 , green: 88 / 255 , blue: 90 / 255 , alpha: 1.0 )
    static let Orange = UIColor(red: 246 / 255 , green: 190 / 255 , blue: 0 / 255 , alpha: 1.0 )
    static let Blue = UIColor(red: 0 / 255 , green: 114 / 255 , blue: 206 / 255 , alpha: 1.0 )
    static let Purple = UIColor(red: 131 / 255 , green: 49 / 255 , blue: 119 / 255 , alpha: 1.0 )
    static let LightGray = UIColor(red: 217 / 255 , green: 217 / 255 , blue: 214 / 255 , alpha: 1.0 )
    static let ltGrey = UIColorFromRGB(rgbValue: 0xE6E7E8)
}

class Styles {
   // static let bodyFont = UIFont(name: "NewsCycle-Bold" , size: 14.0 )
    static let titleFont = UIFont(name: "NewsCycle-Bold" , size: 32.0 )
    static let normalButtonFont = UIFont(name: "NewsCycle-Bold" , size: 14.0 )
    static let importantButtonFont = UIFont(name: "NewsCycle-Bold" , size: 24.0 )
    
    static let setNormalBackgroundImage = UIImage(named: "button.png")
    static let normalButtonBackgroundColor = Colors.LightGray
    static let importantButtonBackgroundColor = Colors.Orange
    static let buttonTextColor = Colors.White
    static let lightGrey = Colors.ltGrey
    static let white = Colors.White
}


