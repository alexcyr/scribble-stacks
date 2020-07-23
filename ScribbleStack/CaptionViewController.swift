//
//  CaptionViewController.swift
//  ScribbleStacks
//
//  Created by Alex Cyr on 10/22/16.
//  Copyright © 2016 Alex Cyr. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import NVActivityIndicatorView
import GoogleMobileAds

extension UIImage {
    class func imageWithLabel(label: UILabel) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

class CaptionViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var drawing: UIImageView!
    var game: Game!
    var ref: DatabaseReference?
    var dataHandler: DatabaseHandle?
    var turnsArray = [Any?]()
    var isSwiping: Bool!
    var gameID: String?
    var teamID: String!
    var typing = true
    var word: Caption!
    var counter = 60
    var coins = 0
    var base64String: NSString!
    var decodedImage: UIImage!
    var didStart = false
    var finishedWord = false
    var interstitial: GADInterstitial!

    
    @IBOutlet weak var successLabel2: UILabel!
    @IBOutlet weak var successLabel1: UILabel!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
   
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var startButtonOutlet: SpringButton!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var captionField: UITextField!
    
    @IBAction func goButton(_ sender: AnyObject) {
         performSegue(withIdentifier: "BufferScreen", sender: self)
    }
    
    @IBAction func keyboardButton(_ sender: AnyObject) {
        if typing {
        captionField.resignFirstResponder()
            typing = false
        }
        else{
            captionField.becomeFirstResponder()
            typing = true
        }
    }
    @IBAction func startButton(_ sender: AnyObject) {
        didStart = true
        let layerButton = self.view.viewWithTag(10) as! SpringButton
        layerButton.animation = "fadeOut"
        
        layerButton.animate()
        startButtonOutlet.isHidden = true
        
        let viewWithTag = self.view.viewWithTag(555)
        viewWithTag!.removeFromSuperview()
        let view1 = self.view.viewWithTag(768)
        view1!.removeFromSuperview()
        
        captionField.isEnabled = true
        captionField.becomeFirstResponder()
    }
   /*
   
    @IBAction func Q(_ sender: AnyObject) {
        captionField.text = captionField.text! + "Q"
    }
    
    @IBAction func W(_ sender: AnyObject) {
        captionField.text = captionField.text! + "W"
    }
    @IBAction func E(_ sender: AnyObject) {
        captionField.text = captionField.text! + "E"
    }
    
    @IBAction func R(_ sender: AnyObject) {
        captionField.text = captionField.text! + "R"
    }
    @IBAction func T(_ sender: AnyObject) {
        captionField.text = captionField.text! + "T"
    }
    
    @IBAction func Y(_ sender: AnyObject) {
        captionField.text = captionField.text! + "Y"
    }
    @IBAction func U(_ sender: AnyObject) {
        captionField.text = captionField.text! + "U"
    }
    @IBAction func I(_ sender: AnyObject) {
        captionField.text = captionField.text! + "I"
    }
    @IBAction func O(_ sender: AnyObject) {
        captionField.text = captionField.text! + "O"
    }
    @IBAction func P(_ sender: AnyObject) {
        captionField.text = captionField.text! + "P"
    }
    @IBAction func A(_ sender: AnyObject) {
        captionField.text = captionField.text! + "A"
    }
    @IBAction func S(_ sender: AnyObject) {
        captionField.text = captionField.text! + "S"
    }
    
    @IBAction func D(_ sender: AnyObject) {
        captionField.text = captionField.text! + "D"
    }
    @IBAction func F(_ sender: AnyObject) {
        captionField.text = captionField.text! + "F"
    }
    @IBAction func G(_ sender: AnyObject) {
        captionField.text = captionField.text! + "G"
    }
    @IBAction func H(_ sender: AnyObject) {
        captionField.text = captionField.text! + "H"
    }
    @IBAction func J(_ sender: AnyObject) {
        captionField.text = captionField.text! + "J"
    }
    @IBAction func L(_ sender: AnyObject) {
        captionField.text = captionField.text! + "L"
    }
    
    @IBAction func K(_ sender: AnyObject) {
        captionField.text = captionField.text! + "K"
    }
    @IBAction func Z(_ sender: AnyObject) {
        captionField.text = captionField.text! + "Z"
    }
    @IBAction func X(_ sender: AnyObject) {
        captionField.text = captionField.text! + "X"
    }
    @IBAction func C(_ sender: AnyObject) {
        captionField.text = captionField.text! + "C"
    }
    @IBAction func V(_ sender: AnyObject) {
        captionField.text = captionField.text! + "V"
    }
    @IBAction func B(_ sender: AnyObject) {
        captionField.text = captionField.text! + "B"
    }
    @IBAction func N(_ sender: AnyObject) {
        captionField.text = captionField.text! + "N"
    }
    @IBAction func M(_ sender: AnyObject) {
        captionField.text = captionField.text! + "M"
    }
    @IBAction func backSpace(_ sender: AnyObject) {
        var label = captionField.text
        if label != ""{
        label = label!.substring(to: label!.index(before: label!.endIndex))
        captionField.text = label
        }
    }
    @IBAction func space(_ sender: AnyObject) {
        captionField.text = captionField.text! + " "
    }
    
    @IBAction func done(_ sender: AnyObject) {
       captionDone()
        
    }
*/
    @IBAction func readyButton(_ sender: AnyObject) {
        performSegue(withIdentifier: "BufferScreen", sender: self)

    }
 
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //textField code
        
        textField.resignFirstResponder()  //if desired
        captionDone()
        return true
    }
    
  
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        createStartView()
        let layer2 = self.view.viewWithTag(12) as! SpringView
        let layer3 = self.view.viewWithTag(2222)
        self.view.backgroundColor = UIColorFromRGB(rgbValue: 0xE6E7E8)
        captionField.isEnabled = false
        captionField.becomeFirstResponder()
        captionField.delegate = self
        
        layer3?.isUserInteractionEnabled = true
        layer2.isHidden = true
        ref = Database.database().reference()

        let burst = self.view.viewWithTag(88) as! UIImageView
        rotateView(targetView: burst, duration: 20.0)
        
        
        // Do any additional setup after loading the view, typically from a nib.
        if (gameID != nil){
          print(self.gameID!)
            self.ref?.child("Games/\(gameID!)/status").setValue("inuse")
            ref?.child("Games/\(self.gameID!)/turns").queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
               
                self.turnsArray.append(snapshot.value)
                
                print(snapshot.key)
                
                let n = self.turnsArray.count
                
                let turnID = self.turnsArray[n-1] as! NSObject
                print(n)

                
                print("yankee \(n)")
                

              
                
               
                
                if n % 2 == 0{
                self.base64String = turnID.value(forKey: "content") as! NSString? ?? ""
                print(self.base64String)
                let decodedData = NSData(base64Encoded: self.base64String as String, options: NSData.Base64DecodingOptions())
                self.decodedImage = UIImage(data: decodedData! as Data)!
                self.drawing.image = self.decodedImage
                }
            }){ (error) in
                print(error.localizedDescription)
            }
            if let user  = Auth.auth().currentUser{
                
                let userID: String = user.uid
                self.ref?.child("Users/\(userID)").observeSingleEvent(of: .value, with: { (snapshot) in
                    print(snapshot)
                    if snapshot.hasChildren(){
                        let snap = snapshot.value! as! NSDictionary
                        self.coins = (snap["currency"] as! Int)
                    }
                })
                
                ref?.child("Games/\(gameID!)").observeSingleEvent(of: .value, with: { (snapshot) in
                    let data = snapshot.value as? NSDictionary
                    let team = data?["team"] as! String
                    let lastPlayer = data?["lastPlayer"] as! String
                    self.ref?.child("Games/\(self.gameID!)/secondLast").setValue(lastPlayer)
                    
                    self.ref?.child("Games/\(self.gameID!)/lastPlayer").setValue(userID)
                    self.teamID = team
                    
                })
            }
            

        }
        else{
            if (game != nil){
                drawing.image = game.images[(game.images.count)-1]
            }
        }
        var _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateCounter), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
            }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    func captionDone(){
       
        let ads = UserDefaults.standard.bool(forKey: "ads")
        
        if ads{
            if gameID != nil{
            var gameAdCount = UserDefaults.standard.integer(forKey: "gameAdCount")
            gameAdCount += 1
            UserDefaults.standard.setValue(gameAdCount, forKey: "gameAdCount")
                if gameAdCount >= 4 {
                    interstitial = GADInterstitial(adUnitID: "ca-app-pub-4705463543336282/5762841034")
                    let request = GADRequest()
                    interstitial.load(request)
                    UserDefaults.standard.setValue(0, forKey: "gameAdCount")
                    
                }

            }
        }
        
        didStart = false
        finishedWord = true
        
        let layer = self.view.viewWithTag(11) as! SpringView
        layer.animation = "fall"
        layer.force = 0.5
        layer.animate()
        
        let drawingLayer = self.view.viewWithTag(2025) as! SpringView
        
        let shadowPath = UIBezierPath(rect: drawingLayer.bounds)
        drawingLayer.layer.masksToBounds = true
        drawingLayer.layer.shadowColor = UIColor.black.cgColor
        drawingLayer.layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        drawingLayer.layer.shadowOpacity = 0.1
        drawingLayer.layer.shadowPath = shadowPath.cgPath
        
        drawingLayer.layer.cornerRadius = drawingLayer.frame.size.width/2
        drawingLayer.clipsToBounds = true
        
        
        let shadow = self.view.viewWithTag(2024)!
        shadow.layer.masksToBounds = true
        shadow.layer.cornerRadius = shadow.frame.size.width/2
        shadow.clipsToBounds = true

        
        let drawingLayerImage = self.view.viewWithTag(2026) as! UILabel
        drawingLayerImage.text = captionField.text! as String
        let text = captionField.text! as String
        let textArr = text.split(separator: " ")
        if textArr.count == 1{
            drawingLayerImage.numberOfLines = 1
        }
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            drawingLayerImage.font = UIFont(name: "Bungee-Regular", size: 48)
        }
        
        
        drawingLayer.animation = "zoomIn"
        drawingLayer.force = 1.0
        drawingLayer.animate()
        /*
        drawingLayer.animation = "flipX"
        drawingLayer.repeatCount = Float.infinity
        drawingLayer.duration = 6.0
        drawingLayer.curve = "easeInOut"
        drawingLayer.animate()
        */
        let coin1 = self.view.viewWithTag(31) as! SpringImageView
        
        coin1.animation = "zoomIn"
        coin1.force = 1.0
        coin1.delay = 0.25
        coin1.animate()
        
        coin1.animation = "flipX"
        coin1.repeatCount = Float.infinity
        coin1.duration = 2.0
        coin1.delay = 0.5
        coin1.curve = "easeInOut"
        coin1.animate()
        
        let coin2 = self.view.viewWithTag(32) as! SpringImageView
        
        coin2.animation = "zoomIn"
        coin2.force = 1.0
        coin2.delay = 1.0
        coin2.animate()
        
        coin2.animation = "flipX"
        coin2.repeatCount = Float.infinity
        coin2.duration = 2.0
        coin2.delay = 0.5
        coin2.curve = "easeInOut"
        coin2.animate()
        
        let coin3 = self.view.viewWithTag(33) as! SpringImageView
        
        coin3.animation = "zoomIn"
        coin3.force = 1.0
        coin3.delay = 1.5
        coin3.animate()
        
        coin3.animation = "flipX"
        coin3.repeatCount = Float.infinity
        coin3.duration = 2.0
        coin3.delay = 0.75
        coin3.curve = "easeInOut"
        coin3.animate()
        
        
        
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y",
                                                               type: .tiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -10
        verticalMotionEffect.maximumRelativeValue = 10
        
        // Set horizontal effect
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x",
                                                                 type: .tiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -10
        horizontalMotionEffect.maximumRelativeValue = 10
        
        // Create group to combine both
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        
        // Add both effects to your view
        drawingLayer.addMotionEffect(group)
        
        
        let layer2 = self.view.viewWithTag(12) as! SpringView
        layer2.isHidden = false
        goButton.isHidden = false
        layer2.animation = "slideUp"
        layer2.force = 0.5
        layer2.animate()
        
     
       
        
        // Create group to combine both
       
        // Add both effects to your view
        drawingLayer.addMotionEffect(group)
        successLabel1.addMotionEffect(group)
        
        
        
       
            
           
        
        if gameID != nil{
            statusLabel.text = "Sending to stack..."
             activityIndicator.startAnimating()
            goButton.isHidden = true
            didStart = true
            counter = 4
            
            
            if let user  = Auth.auth().currentUser{
                var name: String?
                name = user.displayName!
                
                let label = captionField.text! as String
                
                let userID: String = user.uid
                let interval = ServerValue.timestamp()
                self.ref?.child("Games/\(gameID!)/users").child("\(userID)").setValue(true)
                self.ref?.child("Games/\(gameID!)/turns").childByAutoId().setValue(["content": label, "user": userID,"username": name!, "time": interval, "votes": 0])
                self.ref?.child("Games/\(gameID!)/time").setValue(interval)
                self.ref?.child("Games/\(gameID!)/status").setValue("inplay")
                self.ref?.child("Teams/\(teamID!)/teamInfo/time").setValue(interval)
                self.coins = self.coins + 3
                self.ref?.child("Users/\(userID)/currency").setValue(self.coins)
                if (teamID!) == "000000"{
                    self.ref?.child("Users/\(userID)/Public/\(gameID!)").setValue(true)
                    
                }


                
                
            }
            
            
        }
        else{
            let label = captionField.text
            game.captions.append(Caption(phrase: label!))
            var earnedCoins = UserDefaults.standard.integer(forKey: "earnedCoins")
            earnedCoins += 3
            UserDefaults.standard.setValue(earnedCoins, forKey: "earnedCoins")
        }
    }
    
    
    
    
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BufferScreen" {
            
            let controller = segue.destination as! BufferScreenViewController
            if teamID != nil{
                controller.teamID = teamID
                controller.interstitial = interstitial
                self.ref?.removeAllObservers()

            }
            else{
                controller.game = game
            }
        }
     
    }
    
    
    private func rotateView(targetView: UIImageView, duration: Double) {
        UIImageView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            targetView.transform = targetView.transform.rotated(by: CGFloat(Double.pi))
        }) { finished in
            self.rotateView(targetView: targetView, duration: duration)
        }
    }
    
    func createStartView(){
        let viewA = self.view.viewWithTag(768)!

        if !UIAccessibilityIsReduceTransparencyEnabled() {
            
            viewA.backgroundColor = UIColor.clear
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.alpha = 1
            //always fill the view
            blurEffectView.tag = 555
            blurEffectView.frame = viewA.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            viewA.addSubview(blurEffectView)
            
        }
        else {
            let blurEffectView = UIView()
            blurEffectView.backgroundColor = UIColor.clear
            //always fill the view
            blurEffectView.tag = 555
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            viewA.addSubview(blurEffectView)
            viewA.backgroundColor = UIColor.white
        }
        let view1 = self.view.viewWithTag(758)!
        var view2 = view1
        view1.removeFromSuperview()
        
        view2.tag = 758
        viewA.addSubview(view2)
        view2 = self.view.viewWithTag(758)!
        UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse], animations: {
            
            view2.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            
            }, completion: nil)//if you have more UIViews, use an insertSubview API to place it where needed
        view2.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        view2.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        
        view2.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view2.heightAnchor.constraint(equalToConstant: 300).isActive = true

        
        
    }
    
    
    @objc func updateCounter() {
        if didStart && counter > 0 {
            counter -= 1
            countDownLabel.text = String(counter)
        }
        if didStart == true && counter == 0{
            if finishedWord == false{
         captionDone()
            }
            else{
                didStart = false
                 performSegue(withIdentifier: "BufferScreen", sender: self)
            }
            
        }
    }
    

    
}
