//
//  Team.swift
//  ScribbleStack
//
//  Created by Alex Cyr on 12/7/16.
//  Copyright © 2016 Alex Cyr. All rights reserved.
//

import UIKit

class Team: NSObject{
    var id: String
    var teamName: String
    var gameCount: Int
    var userCount: Int
    var users: [String]
    var time: String
    
    init(id: String, teamName: String, gameCount: Int, userCount: Int, time: String, users: [String]){
        self.id = id
        self.teamName = teamName
        self.gameCount = gameCount
        self.userCount = userCount
        self.time = time
        self.users = users
        super.init()
    }
}
