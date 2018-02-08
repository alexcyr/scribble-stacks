//
//  NewGameViewController.swift
//  ScribbleStack
//
//  Created by Alex Cyr on 11/15/16.
//  Copyright © 2016 Alex Cyr. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseInvites
import FirebaseAuth
import FirebaseDynamicLinks


class InviteViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate, InviteDelegate, UINavigationControllerDelegate {
   
    var teamID: String?
    var teamName: String?
    var customUrl = ""
    var encodedURL = ""
    var coins: Int?
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var startOutlet: UIButton!
  
    @IBOutlet weak var statusText: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signInSilently()
        toggleAuthUI()
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillAppear(animated)
    }
    @IBAction func startGame(_ sender: AnyObject) {
        performSegue(withIdentifier: "inviteToWord", sender: self)
        
    }
    // [END viewdidload]
    // [START signin_handler]
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // User Successfully signed in.
            if let name = user.profile.name {
                statusText.text = "Signed in as \(name)"
            } else {
                statusText.text = "Signed in, profile name is not set"
            }
        }
        toggleAuthUI()
    }
   
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        toggleAuthUI()
    }
    
    @IBAction func inviteButton(_ sender: AnyObject) {
    statusText.text = "To start game you must invite at least one person."
        if let invite = Invites.inviteDialog() {
            invite.setInviteDelegate(self)
            
            // NOTE: You must have the App Store ID set in your developer console project
            // in order for invitations to successfully be sent.
            
            // A message hint for the dialog. Note this manifests differently depending on the
            // received invation type. For example, in an email invite this appears as the subject.
            invite.setMessage("You've been invited to join team \(self.teamName!) in Scribble Stacks!")
            // Title for the dialog, this is what the user sees before sending the invites.
            invite.setTitle("Invite Friends")
            invite.setDeepLink("\(encodedURL)")
            invite.setCallToActionText("Install!")
            invite.setCustomImage("scribble-logo-light.png")
            invite.open()
        }
       
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.backgroundColor = UIColorFromRGB(rgbValue: 0xE6E7E8)

        navigationController?.delegate = self
        startOutlet.isEnabled = false
        startOutlet.layer.backgroundColor = UIColorFromRGB(rgbValue: 0xe5e5e5).cgColor

        customUrl = "http://scribblestack.com/teamID=\(teamID!)"
        encodedURL = customUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        print(encodedURL)
        
        //navbar logo
        let image = UIImage(named: "scribble-logo-light.png")
        let logoView = UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
        let imageView = UIImageView(frame: CGRect(x: -45, y: -8, width: 90, height: 46))
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        logoView.addSubview(imageView)
        self.navigationItem.titleView = logoView
        
        let attachment = NSTextAttachment()
        attachment.bounds = CGRect(x: 0, y: -8,width: 30,height: 30);
        attachment.image = UIImage(named: "bobCoin.png")
        let attachmentString = NSAttributedString(attachment: attachment)
        var attributes = [NSAttributedStringKey: AnyObject]()
        attributes[NSAttributedStringKey.foregroundColor] = UIColorFromRGB(rgbValue: 0xF9A919)
        let myString = NSMutableAttributedString(string: "\(self.coins!) ", attributes: attributes)
        myString.append(attachmentString)
        
        let label = UILabel()
        label.attributedText = myString
        label.sizeToFit()
        let newBackButton = UIBarButtonItem(customView: label)
        self.navigationItem.rightBarButtonItem = newBackButton

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)

        super.viewWillDisappear(animated)
        
        
    }
    
    func toggleAuthUI() {
        GIDSignIn.sharedInstance().delegate = self
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            // Signed in
            
            inviteButton.isEnabled = true
        } else {
           
            inviteButton.isEnabled = false
        }
    }
    // [END toggle_auth]
    // [START invite_finished]
  
    func inviteFinished(withInvitations invitationIds: [String], error: Error?) {
        if let error = error {
            print("Failed: " + error.localizedDescription)
        } else {
            let inviteCount = invitationIds.count
            if inviteCount > 0 {
                startOutlet.isEnabled = true
                startOutlet.setTitleColor(UIColor.white, for: .normal)
                startOutlet.backgroundColor = UIColorFromRGB(rgbValue: 0x01A7B9)

                statusText.text = "\(inviteCount) friends invited. Click 'Start Game' to begin!"
                

            }
            print("Invitations sent")
        }
    }
    // [END invite_finished]
    // Sets the status bar to white.
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "inviteToWord" {
            let controller = segue.destination as! WordSelectViewController
            controller.teamID = teamID
        }
    }
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let controller = viewController as? TeamNameViewController {
            controller.teamID = teamID    // Here you pass the data back to your original view controller
        }
    }
}
