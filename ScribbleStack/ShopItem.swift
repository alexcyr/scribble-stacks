//
//  ShopItem.swift
//  ScribbleStacks
//
//  Created by Alex Cyr on 4/1/17.
//  Copyright © 2017 Alex Cyr. All rights reserved.
//

import UIKit

class ShopItem: NSObject{
    var name: String
    var owned: Bool
    var value: Int
    var image: UIImage
   
    
    init(name: String, owned: Bool, value: Int, image: UIImage){
        self.name = name
        self.owned = owned
        self.value = value
        self.image = image

        
        super.init()
    }
}

