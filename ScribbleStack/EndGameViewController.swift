//
//  EndGameViewController.swift
//  ScribbleStack
//
//  Created by Alex Cyr on 10/27/16.
//  Copyright © 2016 Alex Cyr. All rights reserved.
//
import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import Photos
import AVFoundation




protocol ButtonCellDelegate {
    func cellTapped(cell: ButtonCell, type: String)
    func cellTapped0(cell: ButtonCell, type: String)
}



class ButtonCell: UITableViewCell {
    
    var buttonDelegate: ButtonCellDelegate?
    
    @IBOutlet weak var imageButtonOutlet1: UIButton!
    @IBOutlet weak var imageButtonOutlet0: UIButton!
    
    @IBOutlet weak var captionButtonOutlet1: UIButton!
    @IBOutlet weak var captionButtonOutlet0: UIButton!
    
    @IBAction func buttonTap0(_ sender: AnyObject) {
        if let delegate = buttonDelegate {
            delegate.cellTapped0(cell: self, type: "caption")
        }
    }
    @IBAction func buttonTap(_ sender: AnyObject) {
    
        if let delegate = buttonDelegate {
            delegate.cellTapped(cell: self, type: "caption")
        }
    }
    
    @IBAction func imageButtonTap(_ sender: AnyObject) {
        if let delegate = buttonDelegate {
            delegate.cellTapped(cell: self, type: "image")
        }
    }
    @IBAction func imageButtonTap0(_ sender: AnyObject) {
        if let delegate = buttonDelegate {
            delegate.cellTapped0(cell: self, type: "image")
        }
    }
    
}



extension UITableView {
    
    override var screenshot : UIImage? {
        return self.screenshotExcludingHeadersAtSections(excludedHeaderSections: nil, excludingFootersAtSections:nil, excludingRowsAtIndexPaths: nil)
    }
    
    func screenshotOfCellAtIndexPath(indexPath:NSIndexPath) -> UIImage? {
        var cellScreenshot:UIImage?
        
        let currTableViewOffset = self.contentOffset
        
        self.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
        
        cellScreenshot = self.cellForRow(at: indexPath as IndexPath)?.screenshot
        
        self.setContentOffset(currTableViewOffset, animated: false)
        
        return cellScreenshot;
    }
    
    var screenshotOfHeaderView : UIImage? {
        let originalOffset = self.contentOffset
        if let headerRect = self.tableHeaderView?.frame {
            self.scrollRectToVisible(headerRect, animated: false)
            let headerScreenshot = self.screenshotForCroppingRect(croppingRect: headerRect)
            self.setContentOffset(originalOffset, animated: false)
            
            return headerScreenshot;
        }
        return nil
    }
    
    var screenshotOfFooterView : UIImage? {
        let originalOffset = self.contentOffset
        if let footerRect = self.tableFooterView?.frame {
            self.scrollRectToVisible(footerRect, animated: false)
            let footerScreenshot = self.screenshotForCroppingRect(croppingRect: footerRect)
            self.setContentOffset(originalOffset, animated: false)
            
            return footerScreenshot;
        }
        return nil
    }
    
    func screenshotOfHeaderViewAtSection(section:Int) -> UIImage? {
        let originalOffset = self.contentOffset
        let headerRect = self.rectForHeader(inSection: section)
        
        self.scrollRectToVisible(headerRect, animated: false)
        let headerScreenshot = self.screenshotForCroppingRect(croppingRect: headerRect)
        self.setContentOffset(originalOffset, animated: false)
        
        return headerScreenshot;
    }
    
    func screenshotOfFooterViewAtSection(section:Int) -> UIImage? {
        let originalOffset = self.contentOffset
        let footerRect = self.rectForFooter(inSection: section)
        
        self.scrollRectToVisible(footerRect, animated: false)
        let footerScreenshot = self.screenshotForCroppingRect(croppingRect: footerRect)
        self.setContentOffset(originalOffset, animated: false)
        
        return footerScreenshot;
    }
    
    
    func screenshotExcludingAllHeaders(withoutHeaders:Bool, excludingAllFooters:Bool, excludingAllRows:Bool) -> UIImage? {
        
        var excludedHeadersOrFootersSections:[Int]?
        
        if withoutHeaders || excludingAllFooters {
            excludedHeadersOrFootersSections = self.allSectionsIndexes
        }
        
        var excludedRows:[NSIndexPath]?
        
        if excludingAllRows {
            excludedRows = self.allRowsIndexPaths
        }
        
        return self.screenshotExcludingHeadersAtSections( excludedHeaderSections: withoutHeaders ? NSSet(array: excludedHeadersOrFootersSections!) : nil,
       
                                                          excludingFootersAtSections:excludingAllFooters ? NSSet(array:excludedHeadersOrFootersSections!) : nil, excludingRowsAtIndexPaths:excludingAllRows ? NSSet(array:excludedRows!) : nil)
    }
    
    func screenshotExcludingHeadersAtSections(excludedHeaderSections:NSSet?, excludingFootersAtSections:NSSet?,
                                              excludingRowsAtIndexPaths:NSSet?) -> UIImage? {
        var screenshots = [UIImage]()
        
        if let headerScreenshot = self.screenshotOfHeaderView {
            screenshots.append(headerScreenshot)
        }
        
        for section in 0..<self.numberOfSections {
            if let headerScreenshot = self.screenshotOfHeaderViewAtSection(section: section, excludedHeaderSections: excludedHeaderSections) {
                screenshots.append(headerScreenshot)
            }
            
            for row in 0..<self.numberOfRows(inSection: section) {
                let cellIndexPath = NSIndexPath(row: row, section: section)
                if let cellScreenshot = self.screenshotOfCellAtIndexPath(indexPath: cellIndexPath) {
                    screenshots.append(cellScreenshot)
                }
                
            }
            
            if let footerScreenshot = self.screenshotOfFooterViewAtSection(section: section, excludedFooterSections:excludingFootersAtSections) {
                screenshots.append(footerScreenshot)
            }
        }
        
        
        if let footerScreenshot = self.screenshotOfFooterView {
            screenshots.append(footerScreenshot)
        }
        
        return UIImage.verticalImageFromArray(imagesArray: screenshots)
        
    }
    
    func screenshotOfHeadersAtSections(includedHeaderSection:NSSet, footersAtSections:NSSet?, rowsAtIndexPaths:NSSet?) -> UIImage? {
        var screenshots = [UIImage]()
        
        for section in 0..<self.numberOfSections {
            if let headerScreenshot = self.screenshotOfHeaderViewAtSection(section: section, includedHeaderSections: includedHeaderSection) {
                screenshots.append(headerScreenshot)
            }
            
            for row in 0..<self.numberOfRows(inSection: section) {
                if let cellScreenshot = self.screenshotOfCellAtIndexPath(indexPath: NSIndexPath(row: row, section: section), includedIndexPaths: rowsAtIndexPaths) {
                    screenshots.append(cellScreenshot)
                }
            }
            
            if let footerScreenshot = self.screenshotOfFooterViewAtSection(section: section, includedFooterSections: footersAtSections) {
                screenshots.append(footerScreenshot)
            }
        }
        
        return UIImage.verticalImageFromArray(imagesArray: screenshots)
    }
    
    func screenshotOfCellAtIndexPath(indexPath:NSIndexPath, excludedIndexPaths:NSSet?) -> UIImage? {
        if excludedIndexPaths == nil || !excludedIndexPaths!.contains(indexPath) {
            return nil
        }
        return self.screenshotOfCellAtIndexPath(indexPath: indexPath)
    }
    
    func screenshotOfHeaderViewAtSection(section:Int, excludedHeaderSections:NSSet?) -> UIImage? {
        if excludedHeaderSections != nil && !excludedHeaderSections!.contains(section) {
            return nil
        }
        
        var sectionScreenshot = self.screenshotOfHeaderViewAtSection(section: section)
        if sectionScreenshot == nil {
            sectionScreenshot = self.blankScreenshotOfHeaderAtSection(section: section)
        }
        return sectionScreenshot;
    }
    
    func screenshotOfFooterViewAtSection(section:Int, excludedFooterSections:NSSet?) -> UIImage? {
        if excludedFooterSections != nil && !excludedFooterSections!.contains(section) {
            return nil
        }
        
        var sectionScreenshot = self.screenshotOfFooterViewAtSection(section: section)
        if sectionScreenshot == nil {
            sectionScreenshot = self.blankScreenshotOfFooterAtSection(section: section)
        }
        return sectionScreenshot;
    }
    
    func screenshotOfCellAtIndexPath(indexPath:NSIndexPath, includedIndexPaths:NSSet?) -> UIImage? {
        if includedIndexPaths != nil && !includedIndexPaths!.contains(indexPath) {
            return nil
        }
        return self.screenshotOfCellAtIndexPath(indexPath: indexPath)
    }
    
    func screenshotOfHeaderViewAtSection(section:Int, includedHeaderSections:NSSet?) -> UIImage? {
        if includedHeaderSections != nil && !includedHeaderSections!.contains(section) {
            return nil
        }
        
        var sectionScreenshot = self.screenshotOfHeaderViewAtSection(section: section)
        if sectionScreenshot == nil {
            sectionScreenshot = self.blankScreenshotOfHeaderAtSection(section: section)
        }
        return sectionScreenshot;
    }
    
    func screenshotOfFooterViewAtSection(section:Int, includedFooterSections:NSSet?)
        -> UIImage? {
            if includedFooterSections != nil && !includedFooterSections!.contains(section) {
                return nil
            }
            var sectionScreenshot = self.screenshotOfFooterViewAtSection(section: section)
            if sectionScreenshot == nil {
                sectionScreenshot = self.blankScreenshotOfFooterAtSection(section: section)
            }
            return sectionScreenshot;
    }
    
    func blankScreenshotOfHeaderAtSection(section:Int) -> UIImage? {
        
        let headerRectSize = CGSize(width: self.bounds.size.width, height: self.rectForHeader(inSection: section).size.height)
        
        return UIImage.imageWithColor(color: UIColor.clear, size:headerRectSize)
    }
    
    func blankScreenshotOfFooterAtSection(section:Int) -> UIImage? {
        let footerRectSize = CGSize(width: self.bounds.size.width, height: self.rectForFooter(inSection: section).size.height)
        return UIImage.imageWithColor(color: UIColor.clear, size:footerRectSize)
    }
    
    var allSectionsIndexes : [Int]
    {
        let numSections = self.numberOfSections
        
        var allSectionsIndexes = [Int]()
        
        for section in 0..<numSections {
            allSectionsIndexes.append(section)
        }
        return allSectionsIndexes
    }
    
    
    var allRowsIndexPaths : [NSIndexPath] {
        var allRowsIndexPaths = [NSIndexPath]()
        for sectionIdx in self.allSectionsIndexes {
            for rowNum in 0..<self.numberOfRows(inSection: sectionIdx) {
                let indexPath = NSIndexPath(row: rowNum, section: sectionIdx)
                allRowsIndexPaths.append(indexPath)
            }
        }
        return allRowsIndexPaths;
    }
    
}
extension UIImage {
    
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
    
    class func imageWithColor(color:UIColor, size:CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        if context == nil {
            return nil
        }
        color.set()
        context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    class func verticalAppendedTotalImageSizeFromImagesArray(imagesArray:[UIImage]) -> CGSize {
        var totalSize = CGSize.zero
        for im in imagesArray {
            let imSize = im.size
            totalSize.height += imSize.height
            totalSize.width = max(totalSize.width, imSize.width)
        }
        return totalSize
    }
    
    
    class func verticalImageFromArray(imagesArray:[UIImage]) -> UIImage? {
        
        var unifiedImage:UIImage?
        let totalImageSize = self.verticalAppendedTotalImageSizeFromImagesArray(imagesArray: imagesArray)
        
        UIGraphicsBeginImageContextWithOptions(totalImageSize,false, 0)
        
        var imageOffsetFactor:CGFloat = 0
        
        for img in imagesArray {
            img.draw(at: CGPoint(x: 0, y: imageOffsetFactor))
            imageOffsetFactor += img.size.height;
        }
        unifiedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return unifiedImage
    }
}

extension UIView {
   
    func asImage() -> UIImage? {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
            defer { UIGraphicsEndImageContext() }
            guard let currentContext = UIGraphicsGetCurrentContext() else {
                return nil
            }
            self.layer.render(in: currentContext)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
    }

    
    func screenshotForCroppingRect(croppingRect:CGRect) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(croppingRect.size, false, 0.0);
        
        let context = UIGraphicsGetCurrentContext()
        if context == nil {
            return nil;
        }
        
        context!.translateBy(x: -croppingRect.origin.x, y: -croppingRect.origin.y)
        self.layoutIfNeeded()
        self.layer.render(in: context!)
        
        let screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return screenshotImage
    }
    
    @objc var screenshot : UIImage? {
        return self.screenshotForCroppingRect(croppingRect: self.bounds)
    }
}



class EndGameViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ButtonCellDelegate {
    
    var ref: DatabaseReference?
    
    @IBOutlet weak var tableView: UITableView!
    var turnsArray = [Any?]()
    var turnCount = 0
    var gameCount = 0
    var game: Game!
    var teamID: String!
    var gameID: String?
    var base64String: NSString!
    var decodedImage: UIImage!
    var navScreenshot: UIImage!
    var colorBar: UIImage!
    var voted = false
    var ended = false
    var tableLoaded = false
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    var images: [UIImage] = []
    var userIDs: [String] = []
    var usernames: [String] = []
    var turnIDs: [String] = []
    
  /*
    @IBOutlet weak var startButtonOutlet: SpringButton!
    
    @IBAction func startButton(_ sender: AnyObject) {
        startButtonOutlet.animation = "fadeOut"
        
        startButtonOutlet.animate()
        startButtonOutlet.isHidden = true
        
        let viewWithTag = self.view.viewWithTag(555)
        viewWithTag!.removeFromSuperview()

    }
    */
    func cellTapped0(cell: ButtonCell, type: String) {
        let cellRow = tableView.indexPath(for: cell)!.row
        let turnID = turnIDs[cellRow]
        let turn = turnsArray[cellRow] as! NSObject
        let userID = turn.value(forKey: "user") as? String ?? ""
        var votes = turn.value(forKey: "votes") as! Int
        print(votes)
        print(turnID)
        if(type == "caption"){
            if (cell.captionButtonOutlet0.currentTitle == "▽"){
                
                cell.captionButtonOutlet0.setTitle("▼", for: .normal)
                if(cell.captionButtonOutlet1.currentTitle == "▲"){
                    cell.captionButtonOutlet1.setTitle("△", for: .normal)
                    votes = votes - 1
                    minusCurrency(userID: userID)

                    
                }
                votes = votes - 1

                minusVotes(turnID: turnID, userID: userID, gameID: self.gameID!, votes: votes)
                
            }
            else{
                cell.captionButtonOutlet0.setTitle("▽", for: .normal)
                votes = votes + 1

                addVotes(turnID: turnID, userID: userID, gameID: self.gameID!, votes: votes)
            }
        }
        if(type == "image"){
            if (cell.imageButtonOutlet0.currentTitle == "▽"){
                cell.imageButtonOutlet0.setTitle("▼", for: .normal)
                if(cell.imageButtonOutlet1.currentTitle == "▲"){
                    cell.imageButtonOutlet1.setTitle("△", for: .normal)
                    minusCurrency(userID: userID)

                    votes = votes - 1
                }
                votes = votes - 1
                minusVotes(turnID: turnID, userID: userID, gameID: self.gameID!, votes: votes)
                
            }
            else{
                cell.imageButtonOutlet0.setTitle("▽", for: .normal)
                votes = votes + 1
                addVotes(turnID: turnID, userID: userID, gameID: self.gameID!, votes: votes)
            }
        }
        turn.setValue(votes, forKey: "votes")
        
        turnsArray[cellRow] = turn
        
        
        
        voted = true
        
        tableView.reloadData()
        
    }
    
    
    func cellTapped(cell: ButtonCell, type: String) {
        let cellRow = tableView.indexPath(for: cell)!.row
        let turnID = turnIDs[cellRow]
        let turn = turnsArray[cellRow] as! NSObject
        let userID = turn.value(forKey: "user") as? String ?? ""
        var votes = turn.value(forKey: "votes") as! Int
        print(votes)
        print(turnID)
        if(type == "caption"){
            if (cell.captionButtonOutlet1.currentTitle == "△"){
                cell.captionButtonOutlet1.setTitle("▲", for: .normal)
                if(cell.captionButtonOutlet0.currentTitle == "▼"){
                    cell.captionButtonOutlet0.setTitle("▽", for: .normal)
                    votes = votes + 1

                }
                votes = votes + 1
                addVotes(turnID: turnID, userID: userID, gameID: self.gameID!, votes: votes)
                addCurrency(userID: userID)
                
            }
            else{
                cell.captionButtonOutlet1.setTitle("△", for: .normal)
                votes = votes - 1
                minusCurrency(userID: userID)
                minusVotes(turnID: turnID, userID: userID, gameID: self.gameID!, votes: votes)
            }
        }
        if(type == "image"){
            if (cell.imageButtonOutlet1.currentTitle == "△"){
                cell.imageButtonOutlet1.setTitle("▲", for: .normal)
                if(cell.imageButtonOutlet0.currentTitle == "▼"){
                    cell.imageButtonOutlet0.setTitle("▽", for: .normal)
                    votes = votes + 1
                    
                }
                votes = votes + 1
                addCurrency(userID: userID)
                addVotes(turnID: turnID, userID: userID, gameID: self.gameID!, votes: votes)
                
            }
            else{
                cell.imageButtonOutlet1.setTitle("△", for: .normal)
                votes = votes - 1
                minusCurrency(userID: userID)
                minusVotes(turnID: turnID, userID: userID, gameID: self.gameID!, votes: votes)
            }
            
            
        }
        
        
        //Determine Most Votes Winner
        /*
        if ended == true{
            var count = 0
            var highVote = 0
            var tie : [Int] = []
            for data in turnsArray{
                let dataObject = data as! NSObject
                var votes = dataObject.value(forKey: "votes") as! Int
                if count == cellRow{
                    votes = votes + 1
                }
            
            if votes == highVote{
                tie.append(count)
            }
                if votes > highVote{
                    highVote = votes
                    tie.removeAll()
                    tie.append(count)
                }
                
                count += 1
            }
            print(tie)
            for n in tie{
                let data = turnsArray[n] as! NSObject
                let userID = data.value(forKey: "user")! as? String
                let name = data.value(forKey: "username")! as? String
                self.ref?.child("Games/\(self.gameID!)/winner").childByAutoId().setValue(["user": userID!, "username": name!, "seen": false])
            }
        }
 */
        turn.setValue(votes, forKey: "votes")
       
            turnsArray[cellRow] = turn
            
       
        
        voted = true

        tableView.reloadData()

    }
    func addVotes(turnID: String, userID: String, gameID: String, votes: Int){
        
        self.ref?.child("Games/\(gameID)/turns/\(turnID)/votes").setValue(votes)
        
        
    }
    func minusVotes(turnID: String, userID: String, gameID: String, votes: Int){
        
        self.ref?.child("Games/\(gameID)/turns/\(turnID)/votes").setValue(votes)
        
    }
    func addCurrency(userID: String){
        ref?.child("Users/\(userID)").observeSingleEvent(of: .value, with: { (snapshot) in
            let data = snapshot.value as? NSDictionary
            var currency = data?["currency"] as! Int
            currency = currency + 1
            
            self.ref?.child("Users/\(userID)/currency").setValue(currency)
            
        })
    }
    func minusCurrency(userID: String){
        ref?.child("Users/\(userID)").observeSingleEvent(of: .value, with: { (snapshot) in
            let data = snapshot.value as? NSDictionary
            var currency = data?["currency"] as! Int
            currency = currency - 1
            
            self.ref?.child("Users/\(userID)/currency").setValue(currency)
            
        })
    }
    
    
    func showAlertForRow(row: Int) {
        let alert = UIAlertController(
            title: "BEHOLD",
            message: "Cell at row \(row) was tapped!",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Gotcha!", style: UIAlertActionStyle.default, handler: { (test) -> Void in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(
            alert,
            animated: true,
            completion: nil)
    }
    
    
    @IBAction func continuePlaying(_ sender: AnyObject) {
        
            performSegue(withIdentifier: "EndToBuffer", sender: self)
        
        
    }
    @IBAction func saveButton(_ sender: AnyObject) {
        
        let playButton = self.view.viewWithTag(503) as! UIButton
        let quitButton = self.view.viewWithTag(504) as! UIButton
        let cameraButton = self.view.viewWithTag(505) as! UIButton
        
        playButton.isHidden = true
        quitButton.isHidden = true
        cameraButton.isHidden = true
        
        var image = self.tableView.screenshotExcludingHeadersAtSections(excludedHeaderSections: nil, excludingFootersAtSections:nil, excludingRowsAtIndexPaths: [IndexPath(row:0, section: 1), NSIndexPath(row:8, section: 1 )])
        let imageArray = [navScreenshot, colorBar, image]
        image = UIImage.verticalImageFromArray(imagesArray:imageArray as! [UIImage])
        //UIImageWriteToSavedPhotosAlbum(image!,nil,nil,nil)
        
        

      
        // If you want to put an image
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [image!], applicationActivities: nil)
        
        // This lines is for the popover you need to show in iPad
        activityViewController.popoverPresentationController?.sourceView = (sender as! UIButton)
        
        // This line remove the arrow of the popover to show in iPad
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivityType.postToWeibo,
            UIActivityType.print,
            UIActivityType.assignToContact,
            UIActivityType.addToReadingList,
            UIActivityType.postToFlickr,
            UIActivityType.postToVimeo,
            UIActivityType.postToTencentWeibo
        ]
        
        self.present(activityViewController, animated: true, completion: {
            playButton.isHidden = false
            quitButton.isHidden = false
            cameraButton.isHidden = false
        })
        
        
    }
    /*
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
 */
 
    override func viewDidLoad() {
        super.viewDidLoad()
        //createStartView()
        
        self.view.backgroundColor = UIColorFromRGB(rgbValue: 0xffffff)
        self.tableView.backgroundColor = UIColorFromRGB(rgbValue: 0xffffff)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        
        navigationItem.leftBarButtonItem = nil
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "scribble-logo-light.png")
        imageView.image = image
        navigationItem.titleView = imageView
        
        // Do any additional setup after loading the view, typically from a nib.
        ref = Database.database().reference()
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        if (gameID != nil){
            print(gameID!)
            /*
                if self.voted == false {
                    self.startButtonOutlet.setTitle("Vote For Your Favorite\nTap Anywhere to View Results", for: .normal)
                    

                }
                else{
                    self.startButtonOutlet.setTitle("Voting Phase Has Ended\nTap Anywhere to View Results", for: .normal)
                   

                }
            */
            
            ref?.child("Games/\(gameID!)/turns").queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
               
                self.turnsArray.append(snapshot.value)
                self.turnIDs.append(snapshot.key)
                
                let n = self.turnsArray.count
                
                
               
                _ = self.turnsArray[n-1] as! NSObject
                print(n)
                
                if n == 8{
                    print(n)
                    print("poopturds")
                    self.turnCount = self.turnsArray.count
                    self.gameCount = (self.turnsArray.count)
                    let range = NSMakeRange(0, self.tableView.numberOfSections)
                    let sections = NSIndexSet(indexesIn: range)
                    self.tableView.reloadSections(sections as IndexSet, with: .automatic)

                }
                
            }){ (error) in
                print(error.localizedDescription)
            }
            
            if let user  = Auth.auth().currentUser{
                
                
                let userID: String = user.uid
                ref?.child("Games/\(gameID!)").observeSingleEvent(of: .value, with: { (snapshot) in
                    let data = snapshot.value as? NSDictionary
                    let team = data?["team"] as! String
                    let gameStatus = data?["status"]! as? String
                    self.teamID = team
                    
                    let turnID = self.turnsArray[0] as! NSObject
                    let query = self.ref?.child("Games/\(self.gameID!)/users").queryOrderedByValue().queryEqual(toValue: true)
                    query?.observeSingleEvent(of: .value, with: { (snapshot) in
                        let userViewCount = snapshot.childrenCount
                        if userViewCount <= 1
                        {
                            self.ref?.child("Games/\(self.gameID!)/status").setValue("didFinish")
                            self.ref?.child("Teams/\(self.teamID!)/games/\(self.gameID!)").setValue(false)

                            self.ended = true
                        }
                        self.ref?.child("Games/\(self.gameID!)/users/\(userID)").setValue(false)
                    })
                    
                    
                    
                    let initialUser = turnID.value(forKey: "user") as? String ?? ""
                    print(initialUser)
                    print("potato pancakes")
                    if userID == initialUser{
                        if gameStatus != "didFinish"{
                        print("banana pancakes")
                        self.ref?.child("Teams/\(self.teamID!)/teamInfo/users/\(userID)/activeGame").setValue(false)
                        }
                        
                    }
                    
                    
                    
                    
                    
                    
                })
            }
            
            
            
        }
        else{
            for index in 1...game.images.count {
                images.append(game.images[index-1])
            }
            self.gameCount = 2 * (game.images.count)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        if let view1 = self.navigationController?.navigationBar {
            navScreenshot = view1.asImage()
        }
        let view2 = view.viewWithTag(8)!
        colorBar = view2.asImage()


    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (gameCount+1)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let n = indexPath.row
        
            if(indexPath.row != (gameCount)){
               
               
                    if(gameID != nil){
                        if(n%2 == 0){
                            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                                return 120.0
                            }

                            return 98.0
                        }
                        else{
                            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                                return (screenWidth + 60.0)
                            }
                        return (screenWidth + 50.0)
                        }
                    }
                    else{
                        if(n%2 == 0){
                            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                                return 100.0
                            }
                            return 80.0
                        }
                        else{
                            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                                return (screenWidth + 60.0)
                            }
                            return (screenWidth)
                        }
                    }
                
            }
            else{
                return 60.0
            }
       
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let n = indexPath.row

        if(indexPath.row != (gameCount)){
            if (n == 0){
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "StartingWord", for: indexPath) as! ButtonCell
                
                if cell.buttonDelegate == nil {
                    cell.buttonDelegate = self
                }
                
               
                
                let label = cell.viewWithTag(500) as! UILabel
                var word: String?
                if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                    label.font = UIFont(name: "Bungee-Regular", size: 52)
                }
                
                if (gameID != nil){
                    let wordTurn = self.turnsArray[n] as! NSObject
                    print(wordTurn)
                    
                    
                    
                    word = wordTurn.value(forKey: "content")! as? String
                    label.text = word!
                    print(word!)
                    
                    
                }
                else{
                    
                    let caption = game.captions[(n/2)]
                    word = caption.phrase
                    
                    label.text = word
                    
                    
                }
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
                
                
            }
            else if(n%2 == 0){
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "CaptionView", for: indexPath) as! ButtonCell
                
                if cell.buttonDelegate == nil {
                    cell.buttonDelegate = self
                }
                
                //cell style
                cell.layer.backgroundColor = UIColorFromRGB(rgbValue: 0xffffff).cgColor
                cell.layer.borderColor = UIColorFromRGB(rgbValue: 0xE6E7E8).cgColor
                cell.layer.borderWidth = 4.0
                
                let label = cell.viewWithTag(500) as! UILabel
                let userLabel1 = view.viewWithTag(9) as! UILabel
                var word: String?
               
                
                let votesLabel1 = view.viewWithTag(911) as! UILabel

                if (gameID != nil){
                    let wordTurn = self.turnsArray[n] as! NSObject
                    print(wordTurn)
                    

                    
                    word = wordTurn.value(forKey: "content")! as? String
                    label.text = word!
                    print(word!)
                    
                    userLabel1.text = wordTurn.value(forKey: "username")! as? String
                    let votes = wordTurn.value(forKey: "votes")! as? Int
                    
                    votesLabel1.text = "\(votes!)"
                
                    if n == 0 {
                        cell.captionButtonOutlet1.isHidden = true
                        votesLabel1.isHidden = true
                        
                    }
                    if n != 0 {
                        cell.captionButtonOutlet1.isHidden = false
                        votesLabel1.isHidden = false
                        
                    }
                    
                    
                    
                    //Hide Buttons if Voted
                    /*
                    if voted == true{
                       
                        userLabel1.isHidden = false
                        cell.captionButtonOutlet1.isHidden = true
                        if tableLoaded == false{
                        UIView.animate(withDuration: 0.25, delay: 2.0,
                                                   options: [],
                                                   animations: {
                                                    userLabel1.alpha = 1.0
                                                    cell.captionButtonOutlet1.alpha = 0
                                                    
                                                    self.tableLoaded = true

                            }, completion: nil)

                        }
                        else{
                            userLabel1.alpha = 1.0
                            cell.captionButtonOutlet1.alpha = 0
                        }
                    }
*/
                    
                }
                else{
                    
                    let caption = game.captions[(n/2)]
                    word = caption.phrase
                    
                    label.text = word
                    cell.captionButtonOutlet1.isHidden = true
                    cell.captionButtonOutlet0.isHidden = true
                    votesLabel1.isHidden = true

                    
                    
                }
                if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                    label.font = UIFont(name: "Bungee-Regular", size: 42)
                    votesLabel1.font = UIFont(name: "Rajdhani", size: 24)
                    userLabel1.font = UIFont(name: "Rajdhani", size: 18)
                
                
                }

                cell.selectionStyle = UITableViewCellSelectionStyle.none
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "ImageView", for: indexPath) as! ButtonCell
                
                if cell.buttonDelegate == nil {
                    cell.buttonDelegate = self
                }
                
                //cell style
                cell.layer.backgroundColor = UIColorFromRGB(rgbValue: 0xffffff).cgColor
                cell.layer.borderColor = UIColorFromRGB(rgbValue: 0xE6E7E8).cgColor
                cell.layer.borderWidth = 4.0

                
                let tempImage = self.view.viewWithTag(501) as! UIImageView
                tempImage.backgroundColor = UIColor.white
                
                let userLabel2 = view.viewWithTag(10) as! UILabel
                var gameImage: UIImage?
                
                let votesLabel2 = view.viewWithTag(912) as! UILabel

                if (gameID != nil){
                    let imageTurn = self.turnsArray[n] as! NSObject

                    
                    self.base64String = imageTurn.value(forKey: "content")! as! NSString
                    
                    
                    
                    let decodedData = NSData(base64Encoded: self.base64String as String, options: NSData.Base64DecodingOptions())
                    self.decodedImage = UIImage(data: decodedData! as Data)!
                    
                    gameImage = self.decodedImage!
                    tempImage.image = gameImage!
                    
                    userLabel2.text = (imageTurn.value(forKey: "username")! as! String)
                
                    
                    let votes = imageTurn.value(forKey: "votes")! as? Int
                    
                    
                        votesLabel2.text = "\(votes!)"
                        
                    
                    
                    // Hide Button if Voted
                    /*
                    if voted == true{
                        userLabel2.isHidden = false
                        cell.imageButtonOutlet1.isHidden = true
                        if tableLoaded == false{
                        UIView.animate(withDuration: 0.25, delay: 2.0,
                                       options: [],
                                       animations: {
                                        userLabel2.alpha = 1.0
                                        cell.imageButtonOutlet1.alpha = 0
                                        self.tableLoaded = true
                            }, completion: nil)
                        
                        }
                        else{
                            userLabel2.alpha = 1.0
                            cell.imageButtonOutlet1.isHidden = true
                        }
                    }
  */
       
                }
                else{
                    
                    
                    gameImage = images[((n-1)/2)]
                    
                    let tempImage = self.view.viewWithTag(501) as! UIImageView
                    let dividerLine = self.view.viewWithTag(44)!
                    dividerLine.isHidden = true
                    let dividerLine2 = self.view.viewWithTag(45)!
                    dividerLine2.isHidden = true
                    tempImage.backgroundColor = UIColor.white
                    tempImage.image = gameImage
                    cell.imageButtonOutlet1.isHidden = true
                    cell.imageButtonOutlet0.isHidden = true
                    votesLabel2.isHidden = true
                    
                    
                }

                cell.selectionStyle = UITableViewCellSelectionStyle.none
                if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                    votesLabel2.font = UIFont(name: "Rajdhani", size: 24)
                    userLabel2.font = UIFont(name: "Rajdhani", size: 18)
                    cell.imageButtonOutlet1.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
                    cell.imageButtonOutlet0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
                }

                return cell
                
            }
            
            
            
        }
            
            
            
            
            
        else{
            let cell2 = tableView.dequeueReusableCell(
                withIdentifier: "FullGameViewBottom", for: indexPath)
            let continueLabel = self.view.viewWithTag(503) as! UIButton
            continueLabel.setTitle("Continue", for: .normal)
            cell2.selectionStyle = UITableViewCellSelectionStyle.none
            //cell2.layer.borderColor = UIColorFromRGB(rgbValue: 0xffffff).cgColor
            cell2.layer.backgroundColor = UIColorFromRGB(rgbValue: 0xffffff).cgColor
            //cell2.layer.borderWidth = 4
            
            let playButton = self.view.viewWithTag(503) as! UIButton
            let quitButton = self.view.viewWithTag(504) as! UIButton
            let cameraButton = self.view.viewWithTag(505) as! UIButton
            
                
                playButton.isEnabled = true
                quitButton.isEnabled = true
                cameraButton.isEnabled = true

            
            return cell2
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, layoutSubviews indexPath: IndexPath){
        
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        let n = indexPath.row

        
        if(indexPath.row != (gameCount)){
            
            if(n%2 == 0){
               
                if (gameID != nil){
                 
                    
                }
                else{
                
                    
                }
              
            }
            else{
                
                if (gameID != nil){
              
                    
                    
                }
                else{
                    
               
                    
                    
                }
               
                
                
            }
            
            
            
        }
            
            
            
            
            
        else{
          
        }
        
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTeamView" {
            
            let controller = segue.destination as! TeamViewController
            if teamID != nil{
                controller.teamID = teamID
                self.ref?.removeAllObservers()
                
            }
            
        }
        if segue.identifier == "EndToBuffer" {
            
            let controller = segue.destination as! BufferScreenViewController
            if teamID != nil{
                controller.teamID = teamID
                self.ref?.removeAllObservers()
                
            }
            
        }
    }
   
    
    
    
    
}
