//
//  LocalPlayViewController.swift
//  ScribbleStack
//
//  Created by Alex Cyr on 10/16/17.
//  Copyright © 2017 Alex Cyr. All rights reserved.
//

import UIKit




class LocalPlayViewController: UIViewController {
    
    

    
    @IBOutlet weak var phoneWidthConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let iphoneImage = self.view.viewWithTag(111) as! UIImageView
        let arrow1 = self.view.viewWithTag(112) as! UIImageView
        let arrow2 = self.view.viewWithTag(113) as! UIImageView

        
        
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y",
                                                               type: .tiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -30
        verticalMotionEffect.maximumRelativeValue = 30
        
        // Set horizontal effect
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x",
                                                                 type: .tiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -30
        horizontalMotionEffect.maximumRelativeValue = 30
        
        // Create group to combine both
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        
        // Add both effects to your view
        iphoneImage.addMotionEffect(group)
        let verticalMotionEffect2 = UIInterpolatingMotionEffect(keyPath: "center.y",
                                                               type: .tiltAlongVerticalAxis)
        verticalMotionEffect2.minimumRelativeValue = -10
        verticalMotionEffect2.maximumRelativeValue = 10
        
        // Set horizontal effect
        let horizontalMotionEffect2 = UIInterpolatingMotionEffect(keyPath: "center.x",
                                                                 type: .tiltAlongHorizontalAxis)
        horizontalMotionEffect2.minimumRelativeValue = -10
        horizontalMotionEffect2.maximumRelativeValue = 10
        
        // Create group to combine both
        let group2 = UIMotionEffectGroup()

        group2.motionEffects = [horizontalMotionEffect2, verticalMotionEffect2]
        arrow1.addMotionEffect(group2)
        arrow2.addMotionEffect(group2)
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            phoneWidthConstraint.constant = 700.0
        }

        
}

}

