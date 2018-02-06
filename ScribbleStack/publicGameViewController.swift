//
//  publicGameViewController.swift
//  ScribbleStack
//
//  Created by Alex Cyr on 7/17/17.
//  Copyright © 2017 Alex Cyr. All rights reserved.
//


import UIKit

import FirebaseAuth
import FirebaseDatabase



class publicGameViewController: UIViewController {
    
    var loggedIn = false
    let game = Game(captions: [], images: [])
    
    @IBOutlet weak var globe: UIImageView!
    
    @IBOutlet weak var buttonOutlet: UIButton!
    
    @IBAction func playGameButton(_ sender: Any) {
        if loggedIn == false{
            let loginAlert = UIAlertController(title: "Not Logged In", message: "You must be logged in to play a public game.", preferredStyle: UIAlertControllerStyle.alert)
            
            loginAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                
            }))
            present(loginAlert, animated: true, completion: nil)
        }
        else{
            performSegue(withIdentifier: "publicToBuffer", sender: self)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if Auth.auth().currentUser != nil{
            loggedIn = true
            
        }
        else{
            buttonOutlet.setTitleColor(UIColorFromRGB(rgbValue: 0xAAAAAA), for: .normal)
            buttonOutlet.backgroundColor = UIColorFromRGB(rgbValue: 0xF1F1F2)
            loggedIn = false
        }
       
        rotateView(targetView: globe, duration: 60.0)

        
}
    private func rotateView(targetView: UIImageView, duration: Double) {
        UIImageView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            targetView.transform = targetView.transform.rotated(by: CGFloat(M_PI))
        }) { finished in
            self.rotateView(targetView: targetView, duration: duration)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "publicToBuffer" {
            let controller = segue.destination as! BufferScreenViewController
            
                controller.teamID = "000000"
          
                controller.game = game
            }
        }
    }


