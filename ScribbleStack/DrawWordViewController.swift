//
//  DrawWordViewController.swift
//  ScribbleStacks
//
//  Created by Alex Cyr on 10/20/16.
//  Copyright © 2016 Alex Cyr. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import NVActivityIndicatorView
import GoogleMobileAds

extension UIImageView{
    func rotate() {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
}

class DrawWordViewController: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var startButtonOutlet: SpringButton!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var colorButtonOutlet: UIButton!
    var ref: DatabaseReference?
    var dataHandler: DatabaseHandle?
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
    var imgStore: [UIImage] = []
    var strokeCount = 0
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var opacity: CGFloat = 1.0
    var blankImage: UIImage?
    var interstitial: GADInterstitial!

    
    let colors: [(CGFloat, CGFloat, CGFloat)] = [
        (0, 0, 0),
        (105.0 / 255.0, 105.0 / 255.0, 105.0 / 255.0),
        (1.0, 0, 0),
        (0, 0, 1.0),
        (51.0 / 255.0, 204.0 / 255.0, 1.0),
        (102.0 / 255.0, 204.0 / 255.0, 0),
        (102.0 / 255.0, 1.0, 0),
        (160.0 / 255.0, 82.0 / 255.0, 45.0 / 255.0),
        (1.0, 102.0 / 255.0, 0),
        (1.0, 1.0, 0),
        (1.0, 1.0, 1.0),
        ]

    
    @IBOutlet weak var successLabel2: UILabel!
    @IBOutlet weak var successLabel1: UILabel!
    @IBOutlet weak var colorsOutlet: SpringView!
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
        lineWidth = 7.0
        hideWidthButton()
    }
    
    @IBAction func width3(_ sender: AnyObject) {
        lineWidth = 15.0
        hideWidthButton()
    }
    
    @IBAction func width4(_ sender: AnyObject) {
        lineWidth = 36.0
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
        
        let refreshAlert = UIAlertController(title: "Delete Image?", message: "Erase your image and start over? This cannot be undone.", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (action: UIAlertAction!) in
            
            UIGraphicsBeginImageContext(self.tempDrawImage.frame.size)
            self.blankImage?.draw(in: CGRect(x: 0, y: 0, width: self.tempDrawImage.frame.size.width, height: self.tempDrawImage.frame.size.height))
            
            self.blankImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            self.tempDrawImage.image = self.blankImage
            self.imgStore.removeAll()
            self.imgStore.append(self.tempDrawImage.image!)
            
            
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Cancel")
            
            
            
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    
    
    

    }

    @IBAction func startButton(_ sender: AnyObject) {
        didStart = true
        let layerButton = self.view.viewWithTag(778) as! SpringButton
        layerButton.animation = "fadeOut"
        
        layerButton.animate()
        startButtonOutlet.isHidden = true
        
        let viewWithTag = self.view.viewWithTag(555)
        viewWithTag!.removeFromSuperview()
        let viewWithTag2 = self.view.viewWithTag(768)
        viewWithTag2!.removeFromSuperview()
        
    }
    
   
    func hideWidthButton(){
        widthButtonsView.isHidden = true
    }
    
    
    @objc func updateCounter() {
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
        startButtonOutlet.titleLabel?.lineBreakMode = .byWordWrapping
        startButtonOutlet.titleLabel?.textAlignment = .left
        let burst = self.view.viewWithTag(88) as! UIImageView
        let label = self.view.viewWithTag(3) as! UILabel
        label.sizeToFit()
        label.adjustsFontSizeToFitWidth = true
        createStartView()
        rotateView(targetView: burst, duration: 20.0)

        let button = self.view.viewWithTag(755) as! UIButton

        button.imageView!.contentMode = UIViewContentMode.scaleAspectFit
        
        let screenSize: CGRect = UIScreen.main.bounds

        self.tempDrawImage.frame = CGRect(x: 0, y: 48, width: screenSize.width, height: screenSize.width)
        print("width",tempDrawImage.frame.width)
        print("height",tempDrawImage.frame.height)
print("size",self.tempDrawImage.frame.size)
        UIGraphicsBeginImageContext(self.tempDrawImage.frame.size)
        self.tempDrawImage.image?.draw(in: CGRect(x: 0, y: 0, width: self.tempDrawImage.frame.size.width, height: self.tempDrawImage.frame.size.height))
        
        
        colorsOutlet.isHidden = true
        self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext()
        blankImage = self.tempDrawImage.image!

        self.imgStore.append(self.tempDrawImage.image!)
        UIGraphicsEndImageContext()
        // Do any additional setup after loading the view, typically from a nib.
        ref = Database.database().reference()
        let layer2 = self.view.viewWithTag(12) as! SpringView
        self.view.backgroundColor = UIColorFromRGB(rgbValue: 0xE6E7E8)
        widthButtonsView.isHidden = true
        layer2.isHidden = true
        
        if (gameID != nil){
            print(gameID!)
            self.ref?.child("Games/\(gameID!)/status").setValue("inuse")

            ref?.child("Games/\(gameID!)/turns").queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
                
                    self.turnsArray.append(snapshot.value)
                
                
                let label = self.view.viewWithTag(3) as! UILabel
                let n = self.turnsArray.count
               
                _ = snapshot.value as? NSDictionary
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
            if let user  = Auth.auth().currentUser{
                
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
        if #available(iOS 11.0, *) {
            //self.navigationController?.additionalSafeAreaInsets.top = 10
        }
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            viewA.addSubview(blurEffectView)
           
        }
        else {
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
            UIGraphicsGetCurrentContext()?.setStrokeColor(red: red, green: green, blue: blue, alpha: 1)
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
        
        self.imgStore.append(self.tempDrawImage.image!)
        self.strokeCount =  self.strokeCount + 1
        if(!isSwiping) {
            // This is a single touch, draw a point
            UIGraphicsBeginImageContext(self.tempDrawImage.frame.size)
            self.tempDrawImage.image?.draw(in: CGRect(x: 0, y: 0, width: self.tempDrawImage.frame.size.width, height: self.tempDrawImage.frame.size.height))
            UIGraphicsGetCurrentContext()?.setLineCap(CGLineCap.round)
            UIGraphicsGetCurrentContext()?.setLineWidth(lineWidth)
            UIGraphicsGetCurrentContext()?.move(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
            UIGraphicsGetCurrentContext()?.addLine(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
            UIGraphicsGetCurrentContext()?.setStrokeColor(red: red, green: green, blue: blue, alpha: 1)

            UIGraphicsGetCurrentContext()?.strokePath()
            self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
        }
        
    }
    @IBAction func showColors(_ sender: AnyObject) {
        colorsOutlet.isHidden = false
        colorsOutlet.animation = "FadeInLeft"
        colorsOutlet.force = 1.0
        colorsOutlet.duration = 1.0
        
        colorsOutlet.animate()
    }
    @IBAction func closeColors(_ sender: AnyObject) {
        colorsOutlet.animation = "FadeOutLeft"
        colorsOutlet.force = 1.0
        colorsOutlet.duration = 1.0
        
        colorsOutlet.animateNext {
            self.colorsOutlet.isHidden = true
        }
        
       
       

        
    }
    @IBAction func colorButton(_ sender: AnyObject) {
        var index = sender.tag ?? 0
        if index < 0 || index >= colors.count {
            index = 0
        }
        
        // 2
        (red, green, blue) = colors[index]
        
        // 3
        if index == colors.count - 1 {
            opacity = 1.0
        }
        colorsOutlet.animation = "FadeOutLeft"
        colorsOutlet.force = 1.0
        colorsOutlet.duration = 1.0

        colorButtonOutlet.setTitleColor(UIColor(red: red, green: green, blue: blue, alpha: 1.0), for: UIControlState.normal)
        colorsOutlet.animate()
        colorsOutlet.isHidden = true
        
    }
    @IBAction func undoButton(_ sender: AnyObject) {
       
        if imgStore.count >= 2{
       
        self.tempDrawImage.image = imgStore[imgStore.count - 2]
             imgStore.removeLast()
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
       print(imgStore)
        print(imgStore.count)
        

    }
    func drawingDone(){
        self.view.backgroundColor = UIColorFromRGB(rgbValue: 0x01A7B9)

        #if FREE
            if gameID != nil {
            var gameAdCount = UserDefaults.standard.integer(forKey: "gameAdCount")
            gameAdCount += 1
                print("adCount: ", gameAdCount)
            UserDefaults.standard.setValue(gameAdCount, forKey: "gameAdCount")
                if gameAdCount >= 4 {
                    interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
                    let request = GADRequest()
                    interstitial.load(request)
                    UserDefaults.standard.setValue(0, forKey: "gameAdCount")

                }
            }
        #endif
        
        didStart = false
       

        let layer = self.view.viewWithTag(11) as! SpringView
        layer.animation = "fall"
        layer.force = 1.0
        layer.duration = 1.0

        layer.animate()
        
        
        let drawingLayer = self.view.viewWithTag(2025) as! SpringView
       
         let drawingLayerImage = self.view.viewWithTag(2026) as! UIImageView
        let shadowPath = UIBezierPath(rect: drawingLayerImage.bounds)
        drawingLayerImage.layer.masksToBounds = true
        drawingLayerImage.layer.shadowColor = UIColor.black.cgColor
        drawingLayerImage.layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        drawingLayerImage.layer.shadowOpacity = 0.1
        drawingLayerImage.layer.shadowPath = shadowPath.cgPath
        drawingLayerImage.layer.backgroundColor = UIColor.white.cgColor
        drawingLayerImage.layer.cornerRadius = drawingLayerImage.frame.size.width/2
        drawingLayerImage.clipsToBounds = true
        
        let shadow = self.view.viewWithTag(2024)!
        shadow.layer.masksToBounds = true
        shadow.layer.cornerRadius = shadow.frame.size.width/2
        shadow.clipsToBounds = true

        
        
       
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
        coin1.delay = 0.25
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
        
        var earnedCoins = UserDefaults.standard.integer(forKey: "earnedCoins")
        earnedCoins += 3
        UserDefaults.standard.setValue(earnedCoins, forKey: "earnedCoins")
        
        
        let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y",
                                                               type: .tiltAlongVerticalAxis)
        verticalMotionEffect.minimumRelativeValue = -20
        verticalMotionEffect.maximumRelativeValue = 20
        
        // Set horizontal effect
        let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x",
                                                                 type: .tiltAlongHorizontalAxis)
        horizontalMotionEffect.minimumRelativeValue = -20
        horizontalMotionEffect.maximumRelativeValue = 20
        
        // Create group to combine both
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
        
        // Add both effects to your view
        drawingLayer.addMotionEffect(group)
        successLabel1.addMotionEffect(group)

        
      
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
            counter = 4
            
            if let user  = Auth.auth().currentUser{
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
                let interval = ServerValue.timestamp()
                self.ref?.child("Games/\(gameID!)/users").child("\(userID)").setValue(true)
                self.ref?.child("Games/\(gameID!)/turns").childByAutoId().setValue(["content": base64String, "user": userID,"username": name!, "time": interval, "votes": 0])
                self.ref?.child("Games/\(gameID!)/time").setValue(interval)
                self.ref?.child("Teams/\(teamID!)/teamInfo/time").setValue(interval)
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
                controller.interstitial = interstitial
            }
            else{
            controller.game = game
            }
        }
    }
    
}

