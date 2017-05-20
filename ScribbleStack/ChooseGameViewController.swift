//
//  ChooseGameViewController.swift
//  ScribbleStack
//
//  Created by Alex Cyr on 11/15/16.
//  Copyright © 2016 Alex Cyr. All rights reserved.
//

import UIKit

class ChooseGameViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColorFromRGB(rgbValue: 0xE6E7E8)

     
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillAppear(animated)
    }
    
    
    
}

