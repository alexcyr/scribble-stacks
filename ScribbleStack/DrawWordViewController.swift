//
//  DrawWordViewController.swift
//  ScribbleStack
//
//  Created by Alex Cyr on 10/20/16.
//  Copyright © 2016 Alex Cyr. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import NVActivityIndicatorView

class DrawWordViewController: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var startButtonOutlet: UIButton!
    @IBOutlet weak var countDownLabel: UILabel!
    var ref: FIRDatabaseReference?
    var dataHandler: FIRDatabaseHandle?
    var turnsArray = [Any?]()
    var isSwiping: Bool!
    var game: Game!
    var gameID: String?
    var teamID: String!
    var word: Caption!
    var turnCount = 0
    var counter = 60
    var base64String: NSString!
    var finishedDrawing = false
    var didStart = false
    var lastPoint: CGPoint!
    var lineWidth: CGFloat = 5.0
    
    @IBOutlet weak var widthButtonsView: UIView!
    @IBOutlet weak var widthOutlet: UIButton!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBAction func goButton(_ sender: AnyObject) {
         performSegue(withIdentifier: "BufferScreen", sender: self)
    }
    
    
    @IBAction func width1(_ sender: AnyObject) {
        lineWidth = 2.0
        hideWidthButton()
    }
    @IBAction func width2(_ sender: AnyObject) {
        lineWidth = 5.0
        hideWidthButton()
    }
    
    @IBAction func width3(_ sender: AnyObject) {
        lineWidth = 8.0
        hideWidthButton()
    }
    
    @IBAction func width4(_ sender: AnyObject) {
        lineWidth = 12.0
        hideWidthButton()
    }
    
    @IBAction func widthButton(_ sender: AnyObject) {
        if widthButtonsView.isHidden{
            widthButtonsView.isHidden = false
        }
        else{
            widthButtonsView.isHidden = true
        }
    }
    
    @IBAction func reset(_ sender: AnyObject) {
        self.tempDrawImage.image = nil

    }

    @IBAction func startButton(_ sender: AnyObject) {
        didStart = true
        let layerButton = self.view.viewWithTag(10) as! SpringButton
        layerButton.animation = "fadeOut"
        
        layerButton.animate()
        startButtonOutlet.isHidden = true
        
        let viewWithTag = self.view.viewWithTag(555)
        viewWithTag!.removeFromSuperview()
        
    }
    
   
    func hideWidthButton(){
        widthButtonsView.isHidden = true
    }
    
    
    func updateCounter() {
        if didStart && counter > 0 {
            counter -= 1
            countDownLabel.text = String(counter)
        }
        if didStart && counter == 0{
            if finishedDrawing == true{
                performSegue(withIdentifier: "BufferScreen", sender: self)
                
                let layer = self.view.viewWithTag(12) as! SpringView
                layer.animation = "fall"
                layer.force = 0.25
                layer.animate()
                didStart = false

            }
            else{
            if (self.tempDrawImage.image == nil){
                UIGraphicsBeginImageContext(self.tempDrawImage.frame.size)
                self.tempDrawImage.image?.draw(in: CGRect(x: 0, y: 0, width: self.tempDrawImage.frame.size.width, height: self.tempDrawImage.frame.size.height))
                
                self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
            drawingDone()
            }
        }
    }
    
    @IBOutlet weak var tempDrawImage: UIImageView!
    
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        ref = FIRDatabase.database().reference()
        let layer2 = self.view.viewWithTag(12) as! SpringView
        self.view.backgroundColor = UIColorFromRGB(rgbValue: 0xE6E7E8)
        widthButtonsView.isHidden = true
        layer2.isHidden = true
        createStartView()
        if (gameID != nil){
            print(gameID!)
            self.ref?.child("Games/\(gameID!)/status").setValue("inuse")

            ref?.child("Games/\(gameID!)/turns").queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
                
                    self.turnsArray.append(snapshot.value)
                
                
                let label = self.view.viewWithTag(3) as! UILabel
                let n = self.turnsArray.count
               
                _ = snapshot.value as? NSDictionary
                print(self.turnsArray[0])
                let turnID = self.turnsArray[n-1] as! NSObject
                print(n)
               
                if n % 2 != 0{
                let content = turnID.value(forKey: "content") as? String ?? ""
                print(content)
                label.text = "\(content)"
                self.turnCount = self.turnsArray.count
                }
            }){ (error) in
                print(error.localizedDescription)
            }
            if let user  = FIRAuth.auth()?.currentUser{
                
                let userID: String = user.uid
            ref?.child("Games/\(gameID!)").observeSingleEvent(of: .value, with: { (snapshot) in
                let data = snapshot.value as? NSDictionary
                let team = data?["team"] as! String
                let lastPlayer = data?["lastPlayer"] as! String
                self.ref?.child("Games/\(self.gameID!)/secondLast").setValue(lastPlayer)
               
                self.ref?.child("Games/\(self.gameID!)/lastPlayer").setValue(userID)
                self.teamID = team
                print(self.teamID)
            })
            }
           
            
            
        }
        else{
            if (game != nil){
                let label = self.view.viewWithTag(3) as! UILabel
                word = game.captions[(game.captions.count)-1]
                
                label.text = "\(word.phrase)"
                
            }
        }
        var _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateCounter), userInfo: nil, repeats: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)

    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createStartView(){
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.view.backgroundColor = UIColor.clear
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.tag = 555
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.view.viewWithTag(11)!.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        }
        else {
            self.view.backgroundColor = UIColor.white
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?){
        isSwiping    = false
        if let touch = touches.first{
            lastPoint = touch.location(in: tempDrawImage)
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>,
                               with event: UIEvent?){
        
        isSwiping = true;
        if let touch = touches.first{
            let currentPoint = touch.location(in: tempDrawImage)
            UIGraphicsBeginImageContext(self.tempDrawImage.frame.size)
            self.tempDrawImage.image?.draw(in: CGRect(x: 0, y: 0, width: self.tempDrawImage.frame.size.width, height: self.tempDrawImage.frame.size.height))
            UIGraphicsGetCurrentContext()?.move(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
            UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x: currentPoint.x, y: currentPoint.y))
            UIGraphicsGetCurrentContext()?.setLineCap(CGLineCap.round)
            UIGraphicsGetCurrentContext()?.setLineWidth(lineWidth)
            UIGraphicsGetCurrentContext()?.strokePath()
            self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>,
                               with event: UIEvent?){
        if(!isSwiping) {
            // This is a single touch, draw a point
            UIGraphicsBeginImageContext(self.tempDrawImage.frame.size)
            self.tempDrawImage.image?.draw(in: CGRect(x: 0, y: 0, width: self.tempDrawImage.frame.size.width, height: self.tempDrawImage.frame.size.height))
            UIGraphicsGetCurrentContext()?.setLineCap(CGLineCap.round)
            UIGraphicsGetCurrentContext()?.setLineWidth(5.0)
            UIGraphicsGetCurrentContext()?.move(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
            UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
            UIGraphicsGetCurrentContext()?.strokePath()
            self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
    }
    @IBAction func done(_ sender: AnyObject) {
        if (self.tempDrawImage.image == nil){
            UIGraphicsBeginImageContext(self.tempDrawImage.frame.size)
            self.tempDrawImage.image?.draw(in: CGRect(x: 0, y: 0, width: self.tempDrawImage.frame.size.width, height: self.tempDrawImage.frame.size.height))
            
            self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        drawingDone()
       

    }
    func drawingDone(){
        self.view.backgroundColor = UIColorFromRGB(rgbValue: 0x01A7B9)

        
        didStart = false
       

        let layer = self.view.viewWithTag(11) as! SpringView
        layer.animation = "fall"
        layer.force = 1.0
        layer.duration = 1.0

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
        
        
        let drawingLayerImage = self.view.viewWithTag(2026) as! UIImageView
        drawingLayerImage.image = self.tempDrawImage.image
        
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
        layer2.force = 0.1
        layer2.animate()
        
        
        if gameID != nil{
            layer2.animation = "fall"
            layer2.force = 1.0
            layer2.duration = 1.0
            layer2.delay = 8.0
            layer2.animate()
            
            statusLabel.text = "Sending to stack..."
           
            activityIndicator.startAnimating()
          
            print("tomato")
            goButton.isHidden = true
            
            didStart = true
            counter = 8
            
            if let user  = FIRAuth.auth()?.currentUser{
                var name: String?
               
                    name = user.displayName!
                    
               
                
                let quality = 1.0
                let image = self.tempDrawImage.image!
                let data: NSData = UIImageJPEGRepresentation(image, CGFloat(quality))! as NSData
                self.base64String = data.base64EncodedString(options: []) as NSString!
                if turnCount == 7{
                    self.ref?.child("Games/\(gameID!)/status").setValue("ended")
                }
                else{
                    self.ref?.child("Games/\(gameID!)/status").setValue("inplay")
                }
                let userID: String = user.uid
                let interval = FIRServerValue.timestamp()
                self.ref?.child("Games/\(gameID!)/users").child("\(userID)").setValue(true)
                self.ref?.child("Games/\(gameID!)/turns").childByAutoId().setValue(["content": base64String, "user": userID,"username": name!, "time": interval, "votes": 0])
                self.ref?.child("Games/\(gameID!)/time").setValue(interval)
                self.ref?.child("Teams/\(teamID!)/time").setValue(interval)
                if (teamID!) == "000000"{
                    self.ref?.child("Users/\(userID)/Public/\(gameID!)").setValue(true)
                    
                }
                finishedDrawing = true

                
            }
            
        }
        else{
            game.images.append(self.tempDrawImage.image!)
            goButton.isHidden = false
        }
        
        
        
       
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BufferScreen" {
           
            let controller = segue.destination as! BufferScreenViewController
            if teamID != nil{
                controller.teamID = teamID
            }
            else{
            controller.game = game
            }
        }
    }
    
}

