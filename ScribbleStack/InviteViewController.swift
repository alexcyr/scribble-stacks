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


class InviteViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate, FIRInviteDelegate, UINavigationControllerDelegate {
   
    var teamID: String?
    var customUrl = ""
    var encodedURL = ""
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var teamName: UITextField!
    @IBOutlet weak var textLabel: UILabel!
  
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
    
        if let invite = FIRInvites.inviteDialog() {
            invite.setInviteDelegate(self)
            
            // NOTE: You must have the App Store ID set in your developer console project
            // in order for invitations to successfully be sent.
            
            // A message hint for the dialog. Note this manifests differently depending on the
            // received invation type. For example, in an email invite this appears as the subject.
            invite.setMessage("Try this out!\n -\(GIDSignIn.sharedInstance().currentUser.profile.name!)")
            // Title for the dialog, this is what the user sees before sending the invites.
            invite.setTitle("Invite Friends")
            invite.setDeepLink("\(encodedURL)")
            invite.setCallToActionText("Install!")
            invite.setCustomImage("https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png")
            invite.open()
        }
       
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColorFromRGB(rgbValue: 0xE6E7E8)

        navigationController?.delegate = self
        
        customUrl = "http://scribblestack.com/teamID=\(teamID!)"
        encodedURL = customUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        print(encodedURL)
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
    func inviteFinished(withInvitations invitationIds: [Any], error: Error?) {
        if let error = error {
            print("Failed: " + error.localizedDescription)
        } else {
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
