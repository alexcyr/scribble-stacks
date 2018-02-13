//
//  Game.swift
//  ScribbleStacks
//
//  Created by Alex Cyr on 10/20/16.
//  Copyright © 2016 Alex Cyr. All rights reserved.
//

import UIKit

class Game: NSObject{
    var captions = [Caption]()
    var images = [UIImage]()
    
    init(captions: Array<Caption>, images: Array<UIImage>){
        self.captions = captions
        self.images = images
        super.init()
    }
}
