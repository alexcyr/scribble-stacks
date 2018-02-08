//
//  AppDelegate.swift
//  ScribbleStack
//
//  Created by Alex Cyr on 10/9/16.
//  Copyright © 2016 Alex Cyr. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FirebaseDatabase
import FirebaseInvites
import FirebaseDynamicLinks
import FirebaseAuth


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    
    var ref: DatabaseReference!
    var teamID = ""
    var userID: String = ""
    var first = false
    
    
    var window: UIWindow?
    var window2: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        let userDefaults = UserDefaults.standard

        if !(UserDefaults.standard.bool(forKey: "hasLaunched")){
            
            let userDefaults = UserDefaults.standard
            userDefaults.setValue(0, forKey: "earnedCoins")
            userDefaults.setValue(true, forKey: "hasLaunched")
            let ownedWords: NSDictionary = ["Base": true]
            userDefaults.setValue(ownedWords, forKey: "ownedWords")
            
        }
        let ownedWords: NSDictionary = ["Base": true]
        userDefaults.setValue(ownedWords, forKey: "ownedWords")
       
        window2 = UIWindow(frame: UIScreen.main.bounds)
        if #available(iOS 11.0, *) {
            if (window2?.safeAreaInsets.top)! > CGFloat(0.0) || window2?.safeAreaInsets != .zero {
                print("iPhone X")
                application.isStatusBarHidden = false
                //or UIApplication.shared.isStatusBarHidden = true
            }
            else {
                print("Not iPhone X")
                application.isStatusBarHidden = true
            }
        }
        if (launchOptions?[UIApplicationLaunchOptionsKey.url] as? NSURL) != nil {
            //App opened from invite url
            self.handleFirebaseInviteDeeplink()
        }
        
        
        
        return true
    }
    
    func returnFirst()->Bool{
        return first
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let err = error{
            print("Failed to log into Google", err)
        }
        
        
        print("Successfully logged into Google", user)
        guard let idToken = user.authentication.idToken else{return}
        guard let accessToken = user.authentication.accessToken else {return}
        let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        Auth.auth().signIn(with: credentials, completion: {(user, error) in
            if let err = error{
                print("Failed to create Firebase User with Google account: ", err)
            }
            guard let uid = user?.uid else {return}
            print("Successfully logged into Firebase with Google", uid)
            
            self.ref = Database.database().reference()
            
            
            
            if let user = Auth.auth().currentUser {
                for profile in user.providerData {
                    
                    var name: String = profile.displayName!
                    self.userID = uid
                    let stringInputArr = name.components(separatedBy: " ")
                    name = stringInputArr[0] + " " + String(stringInputArr[1].prefix(1))
                    
                    print(name)
                    print(uid)
                    if self.teamID != ""{
                        
                        self.handleFirebaseInviteDeeplink()
                      
                    }
                    
                    self.ref?.child("Users/\(self.userID)").observeSingleEvent(of: .value, with: { (snapshot) in
                        print(snapshot)
                        if snapshot.hasChildren(){
                            var wordDictionary = UserDefaults.standard.dictionary(forKey: "ownedWords")!
                            let ownedWords = Array(wordDictionary.keys)
                            self.first = false
                            let snap = snapshot.value! as! NSDictionary
                            let wordData = (snap["Words"] as! NSDictionary)
                            let dbWords = Array(wordData.allKeys) as! [String]
                            for word in dbWords{
                                var owned = false
                                for localWord in ownedWords{
                                    if word == localWord{
                                        owned = true
                                    }
                                    
                                }
                                if owned == false{
                                    wordDictionary["\(word)"] = true
                                }
                            }
                            UserDefaults.standard.setValue(wordDictionary, forKey: "ownedWords")
                            


                        }
                        else{
                            self.first = true
                            
                            self.ref?.child("Teams").child("000000").child("teamInfo/users").child("\(self.userID)").setValue(["activeGame" : false])
                            
                            //dog names
                            let names : NSArray = [
                                "Acorn",
                                "Afro",
                                "Alfie",
                                "Alvin",
                                "Apollo",
                                "Appu",
                                "Archibald",
                                "Aretha",
                                "A-Rod",
                                "Asia",
                                "Askher",
                                "Asta",
                                "Astro",
                                "Attila",
                                "Audi",
                                "Babe",
                                "bacha",
                                "Bacon",
                                "Badamo",
                                "Bagel",
                                "Bakri",
                                "Balou",
                                "Bander",
                                "Bangi",
                                "Banjo",
                                "Barclay",
                                "Barfolomew",
                                "Barfy",
                                "Barkley",
                                "Barnaby",
                                "Barney",
                                "Bear",
                                "Beck",
                                "Beethoven",
                                "Bellatrix",
                                "Benji",
                                "Bettsy",
                                "Betty",
                                "Bianca",
                                "Big Guy",
                                "Big Red",
                                "Biggie Smalls",
                                "Bilbo",
                                "Bili",
                                "Billy the Kid",
                                "Biloxi",
                                "Bimmer",
                                "Bingo",
                                "Birdie",
                                "Biscuit",
                                "Bisojo",
                                "Blanca",
                                "Blinker",
                                "Blondie",
                                "Blood",
                                "Blue",
                                "Bobbafett",
                                "Bobby Mcgee",
                                "Bodie",
                                "Bon Bon",
                                "Bond",
                                "Bones",
                                "Bonga",
                                "Bongo",
                                "Bono",
                                "Booboo",
                                "Boomer",
                                "Bootsie",
                                "Bordeaux",
                                "Boss",
                                "Brain",
                                "Brandy",
                                "Bren",
                                "Brinkley",
                                "Bronco",
                                "Brownie",
                                "Bruin",
                                "Bubba",
                                "Bubbles",
                                "Buck",
                                "Buckaroo",
                                "Buckley",
                                "Buddy",
                                "Buffalo Bill",
                                "Buffy",
                                "Bullet",
                                "Bullseye",
                                "Burger",
                                "Burrito",
                                "Burt",
                                "Busch",
                                "Buster",
                                "Butler",
                                "Button",
                                "Buzz",
                                "Byte",
                                "Cabbie",
                                "Caesar",
                                "Calvin",
                                "CamPayne",
                                "Candy",
                                "Captain Crunch",
                                "Carter",
                                "Cato",
                                "Cece",
                                "Cessa",
                                "Chainsaw",
                                "Chali",
                                "Chanbaili",
                                "Chance",
                                "Chauncer",
                                "Cheecheechee",
                                "Cheerio",
                                "Cheeta",
                                "CheriPitts",
                                "Chevy",
                                "Chewie",
                                "Chex",
                                "Cho-Cho",
                                "Choochoo",
                                "Chopin",
                                "Chopper",
                                "Griswold",
                                "Cletus",
                                "Cloe",
                                "Clooney",
                                "Clumsy",
                                "Coco",
                                "Cookie Monster",
                                "Copernicus",
                                "Cosmo",
                                "Crunch E.",
                                "Cujo",
                                "Cupcake",
                                "Czar",
                                "Daisy",
                                "Dallas",
                                "Demon",
                                "Deputy Dawg",
                                "Dew",
                                "Diesel",
                                "Dino",
                                "Diva",
                                "Dobo",
                                "Doc",
                                "Dolce",
                                "Dollar",
                                "Domino",
                                "Donald",
                                "Donna",
                                "Doomsbury",
                                "Doozer",
                                "Dowser",
                                "Draula",
                                "Duchess",
                                "Dude",
                                "Dudi",
                                "Duster",
                                "Dutch",
                                "Dynamite",
                                "Einstein",
                                "Elf",
                                "Elmo",
                                "Elton",
                                "Elvis",
                                "Ernie",
                                "Ewok",
                                "Fabio",
                                "Faith",
                                "Farley",
                                "Faya",
                                "Felix",
                                "Fig",
                                "Fiona",
                                "Fitch",
                                "Foxy",
                                "Frank",
                                "Fresca",
                                "Fritz",
                                "Furbulous",
                                "Fuse",
                                "Fuzzy",
                                "Gala",
                                "Genie",
                                "George",
                                "Giblet",
                                "Giggles",
                                "Ginger",
                                "Git-er-don",
                                "Glamour",
                                "Gnasher",
                                "Gobler",
                                "Goldilocks",
                                "Goliath",
                                "Gonzo",
                                "Goofus",
                                "Goofy",
                                "Gordo",
                                "Gort",
                                "Grandma",
                                "Grandpa",
                                "Gravy",
                                "Greystoke",
                                "Grimmy",
                                "Grumpus Maximus",
                                "Grunt",
                                "Gulabo",
                                "Gumball",
                                "Harry",
                                "Hercules",
                                "Hershey",
                                "Hobbit",
                                "Homer",
                                "Honey",
                                "Hopalong",
                                "Hoser",
                                "Hot Dog",
                                "Ike",
                                "Indira",
                                "Iris",
                                "Inaha",
                                "Imu",
                                "Ijaba",
                                "Istari",
                                "Iscoli",
                                "Irish",
                                "Icecream",
                                "Jabbers",
                                "Jade",
                                "Jasmine",
                                "Jasper",
                                "Jay Jay",
                                "Jazu",
                                "Jazzy",
                                "Jeckyll",
                                "Jeeves",
                                "Jingle Bells",
                                "Juty",
                                "K-9",
                                "Kai",
                                "Kaka",
                                "Kalikaloti",
                                "Kankan",
                                "Kashi",
                                "Kaya",
                                "Keanu",
                                "Keesha",
                                "Keiko",
                                "Khota",
                                "Khotida",
                                "Kibbles",
                                "Killer",
                                "King Edward",
                                "Kingston",
                                "Kissy",
                                "Koby",
                                "Kodu",
                                "Ko-Ko",
                                "Kona",
                                "Kootie Bear",
                                "Kramer",
                                "Krypton",
                                "Kuki",
                                "Kutayda",
                                "Kutt",
                                "Lady",
                                "Laggar bggar",
                                "Laguna",
                                "Laker",
                                "Lassie",
                                "Lazy Daisy",
                                "Lefty",
                                "Leia",
                                "Lexi",
                                "Liberty",
                                "Lil’bit",
                                "Lilypie",
                                "Lime",
                                "Linus",
                                "Lola",
                                "Lou",
                                "Luca",
                                "Lucky",
                                "Lucky Charms",
                                "Lunchbox",
                                "Macbeth",
                                "Macgyver",
                                "Madam X",
                                "Mademoiselle",
                                "Majaha",
                                "Major",
                                "Makhyu",
                                "Marble",
                                "Mama Mia",
                                "Mangu",
                                "Marasi",
                                "Marco Polo",
                                "Margo",
                                "Marky Mark",
                                "Marmaduke",
                                "Marshmellow",
                                "Matisse",
                                "Matsuhisa",
                                "McGruff",
                                "Meadow",
                                "Meatball",
                                "Meeda",
                                "Meraku",
                                "Mercedes",
                                "Merlot",
                                "Mezzaluna",
                                "Michelangelo",
                                "Michelobe",
                                "Midnight",
                                "Midori",
                                "Mika",
                                "Milo",
                                "Mimmo",
                                "Mira",
                                "Mischa",
                                "Missingno",
                                "Missy",
                                "Mitzi",
                                "Moby",
                                "Mochi",
                                "Monet",
                                "Monkey",
                                "Moo",
                                "Mooshie",
                                "Momo",
                                "Mopsy",
                                "Moreno",
                                "Moti",
                                "Motor",
                                "Mowgli",
                                "Mozart",
                                "Mr Big",
                                "Mr. Lovva",
                                "Mr. Muggles",
                                "Mr. Pants",
                                "Mrs. Chewy",
                                "Ms. Barbra",
                                "Ms. Lulu",
                                "Muggles",
                                "Mulligan",
                                "Mylo",
                                "Nana",
                                "Nanda",
                                "Nani",
                                "Nico",
                                "Nikki",
                                "Ninja",
                                "Noodle",
                                "Nosykins",
                                "Nugget",
                                "Odie",
                                "OJ",
                                "Old Jack",
                                "Old Yellar",
                                "Olive",
                                "Onyx",
                                "Oreo",
                                "Otis",
                                "Ozzie",
                                "Paddington",
                                "Paisley",
                                "Pampa",
                                "Panapan",
                                "Pappi",
                                "Pappu",
                                "Paris",
                                "Parro",
                                "Patina",
                                "Paw-Paw",
                                "Pazzo",
                                "Peanut",
                                "Peanut Butter",
                                "Pearl",
                                "Pee Wee",
                                "Peety",
                                "Pepper",
                                "Pepperoni",
                                "Peppy",
                                "Phoenix",
                                "Pinkie",
                                "Pinot",
                                "Pistol",
                                "Piston",
                                "Pixie",
                                "Pluto",
                                "Polka",
                                "Pom-Pom",
                                "Pongo",
                                "Porkchop",
                                "Precious",
                                "Puck",
                                "Pugsley",
                                "Punch",
                                "Pussycat",
                                "Putt-Putt",
                                "Queen",
                                "Quixote",
                                "Ramona",
                                "Red Rose",
                                "Ricky Bobby",
                                "Rico",
                                "Rin Tin",
                                "Road Runner",
                                "Robin Hood",
                                "Rocco",
                                "Rocky",
                                "Rogue",
                                "Romeo",
                                "Rorschach",
                                "Rosy",
                                "Roxie",
                                "Ruff",
                                "Rufus",
                                "Rugby",
                                "Rusty",
                                "Scamp",
                                "Scooby",
                                "Scooper",
                                "Scotty",
                                "Scout",
                                "Seismic",
                                "Sephora",
                                "Seuss",
                                "Shadow",
                                "Shaggy",
                                "Shamsky",
                                "Shiloh",
                                "Shorty",
                                "Sinatra",
                                "Sirius",
                                "Skip",
                                "Sleepy",
                                "Slink",
                                "Slobber",
                                "Smitty",
                                "Smoochy",
                                "Sniff",
                                "Snooky",
                                "Snoopy",
                                "Snowy",
                                "Cookie",
                                "Spark",
                                "Sparky",
                                "Spike",
                                "Spirit",
                                "Spud",
                                "Squirt",
                                "Steeler",
                                "Stinky",
                                "Stitch",
                                "Strsky",
                                "Sugar",
                                "Superdog",
                                "Sushi",
                                "Su-Su",
                                "Sven",
                                "Sweet Tooth",
                                "Sweetpea",
                                "Sweety",
                                "Sweaty",
                                "Taco",
                                "Tagalong",
                                "Talli",
                                "Tallulah",
                                "Tanboori",
                                "Tango",
                                "Tank",
                                "Tanner",
                                "Target",
                                "Tatertot",
                                "T-Bone",
                                "Tibbs",
                                "Tiger",
                                "Timber",
                                "Ting Ting",
                                "Tink",
                                "Tinko",
                                "Toad",
                                "Toast",
                                "Toffee",
                                "Tonka",
                                "Toota",
                                "Tooter",
                                "Toothpick",
                                "Toto",
                                "Tres",
                                "T-Rex",
                                "Tripawd",
                                "Trix",
                                "Twinkie",
                                "Twinkle",
                                "Wacko",
                                "Waffles",
                                "Wednesday",
                                "Wheaties",
                                "Whoopi",
                                "Wilbur",
                                "Willow",
                                "Wonka",
                                "Winnie",
                                "Wolfie",
                                "Woofy",
                                "Yankee",
                                "Yo Yo Ma",
                                "Yodel",
                                "Yoshiko",
                                "Zakoota",
                                "Zara",
                                "Zeke",
                                "Zelda",
                                "Zeus",
                                "ZsaZsa"
                            ]
                            
                            // Do stuff
                            
                            let getRandom = self.randomSequenceGenerator(min: 1, max: names.count)
                            
                            name = names[getRandom()-1] as! String
                            
                            let changeRequest = user.createProfileChangeRequest()
                            
                            changeRequest.displayName = "\(name)"
                            
                            changeRequest.commitChanges { error in
                                if error != nil {
                                    // An error happened.
                                    print("failed")
                                } else {
                                    // Profile updated.
                                    print("sucess")
                                }
                            }
                            self.ref.child("Users").child(self.userID).setValue(["username": name, "currency": 0,"sound": true,"Words": ["Base": true]])
                            
                            
                            
                            
                            
                        }
                    })
                    
                    
                }
            }
            
            
            print("Successfully logged in with our user: ", user ?? "")
            
        })
    }
    
    func randomSequenceGenerator(min: Int , max: Int) -> () -> Int {
        var numbers: [Int] = []
        return {
            if numbers.count == 0 {
                numbers = Array(min ... max)
            }
            
            let index = Int(arc4random_uniform(UInt32(numbers.count)))
            return numbers.remove(at: index)
        }
        
    }
    /*
     @available(iOS 9.0, *)
     func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
     return application(app, open: url,
     sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
     annotation: "")
     }
     
     func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
     if let dynamicLink = DynamicLinks.dynamicLinks()?.dynamicLink(fromCustomSchemeURL: url) {
     // Handle the deep link. For example, show the deep-linked content or
     // apply a promotional offer to the user's account.
     // ...
     
     let urlString = dynamicLink.url
     
     let deepLink = url.absoluteString
     let teamArray = deepLink.components(separatedBy: "teamID=")
     teamID = teamArray[1]
     print(teamID)
     self.ref = Database.database().reference()
     
     
     var teamName: String = ""
     print("tintin")
     
     self.ref.child("Teams/\(self.teamID!)/teamInfo/users").child("\(self.userID)").setValue(["activeGame": false])
     self.ref.child("Users").child(self.userID).child("Teams").child("\(self.teamID!)").setValue([true])
     let topWindow: UIWindow = UIWindow(frame: UIScreen.main.bounds)
     topWindow.rootViewController = UIViewController()
     topWindow.windowLevel = UIWindowLevelAlert + 1
     let alert = UIAlertController(title: "Alert", message: "Added to team \(teamName))", preferredStyle: UIAlertControllerStyle.alert)
     alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction) -> Void in
     // continue your work
     // important to hide the window after work completed.
     // this also keeps a reference to the window until the action is invoked.
     
     topWindow.isHidden = true
     }))
     
     topWindow.makeKeyAndVisible()
     topWindow.rootViewController?.present(alert, animated: true, completion: nil)
     
     
     
     
     
     
     return true
     }
     return false
     }
     
     
     func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
     
     if let dynamicLink = DynamicLinks.dynamicLinks()?.dynamicLink(fromCustomSchemeURL: url){
     self.handleIncomingDynamicLink(dynamicLink: dynamicLink)
     
     return true
     
     }
     else{
     let handled = GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
     
     return handled
     }
     }
     
     @available(iOS 8.0, *)
     func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
     if let incomingURL = userActivity.webpageURL{
     let linkHandled = DynamicLinks.dynamicLinks()!.handleUniversalLink(incomingURL, completion:{ [weak self] (dynamiclink, error) in
     guard let strongSelf = self else{ return }
     if let dynamiclink = dynamiclink, let _ = dynamiclink.url {
     strongSelf.handleIncomingDynamicLink(dynamicLink: dynamiclink)
     }
     })
     return linkHandled
     }
     return false
     }
     
     func handleIncomingDynamicLink(dynamicLink: DynamicLink) {
     
     if dynamicLink.matchConfidence == .weak{
     }else {
     guard let pathComponents = dynamicLink.url?.pathComponents else { return }
     for nextPiece in pathComponents{
     
     }
     }
     print("incoming link \(dynamicLink.url)")
     }
     
     @available(iOS 9.0, *)
     func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
     
     if(GIDSignIn.sharedInstance().handle(url,
     sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!,
     annotation: options[UIApplicationOpenURLOptionsKey.annotation])){
     return true
     }
     else if (self.application(application, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: "")){
     return true
     }
     
     return false
     }
     
     
     func application(_ application: UIApplication,
     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
     if let invite = Invites.handle(url, sourceApplication:sourceApplication, annotation:annotation) as? ReceivedInvite {
     if let user = Auth.auth().currentUser {
     for profile in user.providerData {
     let uid = user.uid
     print("Successfully logged into Firebase with Google", uid)
     
     self.userID = uid
     
     let matchType =
     (invite.matchType == .weak) ? "Weak" : "Strong"
     print("Invite received from: \(sourceApplication) Deeplink: \(invite.deepLink)," +
     "Id: \(invite.inviteId), Type: \(matchType)")
     let url = invite.deepLink
     let deeplinkTeamArray = url.components(separatedBy: "teamID=")
     teamID = deeplinkTeamArray[1]
     print(teamID)
     self.ref = Database.database().reference()
     
     
     var teamName: String = ""
     print("tintin")
     
     self.ref.child("Teams/\(self.teamID!)/teamInfo/users").child("\(self.userID)").setValue(["activeGame": false])
     self.ref.child("Users").child(self.userID).child("Teams").child("\(self.teamID!)").setValue([true])
     let topWindow: UIWindow = UIWindow(frame: UIScreen.main.bounds)
     topWindow.rootViewController = UIViewController()
     topWindow.windowLevel = UIWindowLevelAlert + 1
     let alert = UIAlertController(title: "Alert", message: "Added to team \(teamName))", preferredStyle: UIAlertControllerStyle.alert)
     alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction) -> Void in
     // continue your work
     // important to hide the window after work completed.
     // this also keeps a reference to the window until the action is invoked.
     
     topWindow.isHidden = true
     }))
     
     topWindow.makeKeyAndVisible()
     topWindow.rootViewController?.present(alert, animated: true, completion: nil)
     
     
     }}
     
     
     
     return true
     }
     
     return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
     }
     
     func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler:([AnyObject]?)-> Void) -> Bool{
     if let incomingURL = userActivity.webpageURL{
     let linkHandled = DynamicLinks.dynamicLinks()!.handleUniversalLink(incomingURL, completion: {
     (dynamiclink, error) in
     if let dynamiclink = dynamiclink, let _ = dynamiclink.url{
     self.handleIncomingDynamicLink(dynamiclink: dynamiclink)
     }
     })
     return linkHandled
     }
     return false
     }
     func handleIncomingDynamicLink(dynamiclink: DynamicLink){
     print("incoming link: \(dynamiclink.url)")
     }
     
     @available(iOS 9.0, *)
     func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
     -> Bool {
     return self.application(application, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: "")
     }
     
     func application(_ application: UIApplication,
     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
     if GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation) {
     return true
     }
     
     return DynamicLinks.dynamicLinks()!.handleUniversalLink(url) { invite, error in
     // ...
     print("incoming link: \(url)")
     }
     }
     
     @available(iOS 9.0, *)
     func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
     -> Bool {
     print("woop woop")
     return self.application(application, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: "")
     }
     
     func application(_ application: UIApplication,
     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
     print("hmph")
     if GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation) {
     print("google signed in woop")
     
     return true
     }
     
     return Invites.handleUniversalLink(url) { invite, error in
     // [START_EXCLUDE]
     print("we have invites!")
     if let error = error {
     print(error.localizedDescription)
     return
     }
     if let invite = invite {
     self.showAlertView(withInvite: invite)
     }
     // [END_EXCLUDE]
     }
     }
     // [END openurl]
     // [START continueuseractivity]
     func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
     return Invites.handleUniversalLink(userActivity.webpageURL!) { invite, error in
     print("rada rada")
     // [START_EXCLUDE]
     if let error = error {
     print(error.localizedDescription)
     return
     }
     if let invite = invite {
     self.showAlertView(withInvite: invite)
     }
     // [END_EXCLUDE]
     }
     }
     // [END continueuseractivity]
     func showAlertView(withInvite invite: ReceivedInvite) {
     let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
     let matchType = invite.matchType == .weak ? "weak" : "strong"
     let message = "Invite ID: \(invite.inviteId)\nDeep-link: \(invite.deepLink)\nMatch Type: \(matchType)"
     let alertController = UIAlertController(title: "Invite", message: message, preferredStyle: .alert)
     alertController.addAction(okAction)
     self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
     }
     
     
     
     @available(iOS 9.0, *)
     func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
     -> Bool {
     return self.application(application, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: "")
     }
     
     func application(_ application: UIApplication,
     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
     print("hello there")
     if GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation) {
     return true
     }
     
     return Invites.handleUniversalLink(url) { invite, error in
     // ...
     print("did it work? \(url)")
     
     }
     }
     */
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            return self.application(application, open: (url as NSURL) as URL, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: "" as AnyObject)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        print("hey a url!",url)
        if Invites.handleUniversalLink(url, completion: { (invite, error) in
            
            let matchType = (invite?.matchType == ReceivedInviteMatchType.weak) ? "Weak" : "Strong"
            print("\n------------------Invite received from: \(String(describing: sourceApplication)) Deeplink: \(String(describing: invite?.deepLink))," + "Id: \(String(describing: invite?.inviteId)), Type: \(matchType)")
            /*
             if (matchType == "Strong") {
             print("\n-------------- Invite Deep Link = \(invite.deepLink)")
             if !invite.deepLink.isEmpty {
             let url = NSURL(string: invite.deepLink)
             self.handleFirebaseInviteDeeplink(inviteUrl: url! as URL)
             }
             }
             
             */
            let url = invite?.deepLink
            let deeplinkTeamArray = url?.components(separatedBy: "teamID=")
            self.teamID = deeplinkTeamArray![1]
            print(self.teamID)
            self.ref = Database.database().reference()
            
            self.handleFirebaseInviteDeeplink()
            
        }) {
            return true
        }
        return GIDSignIn.sharedInstance().handle(url as URL!, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        
        if userActivity.webpageURL != nil{
            let url = userActivity.webpageURL
            userActivity.webpageURL = nil
            print("hey a url!",url!)
            if Invites.handleUniversalLink(url!, completion: { (invite, error) in
                
                let matchType = (invite?.matchType == ReceivedInviteMatchType.weak) ? "Weak" : "Strong"
                print("\n------------------Invite received from:  Deeplink: \(String(describing: invite?.deepLink))," + "Id: \(String(describing: invite?.inviteId)), Type: \(matchType)")
                /*
                 if (matchType == "Strong") {
                 print("\n-------------- Invite Deep Link = \(invite.deepLink)")
                 if !invite.deepLink.isEmpty {
                 let url = NSURL(string: invite.deepLink)
                 self.handleFirebaseInviteDeeplink(inviteUrl: url! as URL)
                 }
                 }
                 
                 */
                let url = invite?.deepLink
                let deeplinkTeamArray = url?.components(separatedBy: "teamID=")
                self.teamID = deeplinkTeamArray![1]
                print(self.teamID)
                self.ref = Database.database().reference()
                
                self.handleFirebaseInviteDeeplink()
                
                
            }) {
                return true
            }
            return GIDSignIn.sharedInstance().handle(url as URL!, sourceApplication: "", annotation: "")
        }
        return true
    }
    func handleFirebaseInviteDeeplink(){
        var teamName: String = ""
        print("tintin")
        if let user = Auth.auth().currentUser {
            for _ in user.providerData {
                let uid = user.uid
                print("Successfully logged into Firebase with Google", uid)
                
                self.userID = uid
                self.ref?.child("Users/\(self.userID)/Teams/\(self.teamID)").observeSingleEvent(of: .value, with: { (snapshot) in
                    print(snapshot)
                    if snapshot.hasChildren(){
                    }
                    else{
                        let group = DispatchGroup()
                        group.enter()
                        self.ref?.child("Teams/\(self.teamID)/teamInfo/").observeSingleEvent(of: .value, with: { (snapshot) in
                            let nameData = snapshot.value as? NSDictionary
                            teamName = (nameData?["team"]! as? String)!
                            print(teamName)
                            group.leave()
                        })
                        
                        group.notify(queue: DispatchQueue.main, execute: {

                        self.ref.child("Teams/\(self.teamID)/teamInfo/users").child("\(self.userID)").setValue(["activeGame": false])
                        self.ref.child("Users").child(self.userID).child("Teams").child("\(self.teamID)").setValue([true])
                        let topWindow: UIWindow = UIWindow(frame: UIScreen.main.bounds)
                        topWindow.rootViewController = UIViewController()
                        topWindow.windowLevel = UIWindowLevelAlert + 1
                        let alert = UIAlertController(title: "Alert", message: "Added to team \(teamName)!", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: {(action: UIAlertAction) -> Void in
                            // continue your work
                            // important to hide the window after work completed.
                            // this also keeps a reference to the window until the action is invoked.
                            
                            topWindow.isHidden = true
                            
                        }))
                            topWindow.makeKeyAndVisible()
                            topWindow.rootViewController?.present(alert, animated: true, completion: nil)
                            })
                        
                       
                    }
                })
                
                
            }
            
        }
    }
    
    func showAlertAppDelegate(title : String,message : String,buttonTitle : String,window: UIWindow){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.default, handler: nil))
        window.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "LoginToHome" {
            let DestViewController = segue.destination as! UINavigationController
            let targetController = DestViewController.topViewController as! TabBarViewController
            
            targetController.data = teamID
            targetController.first = self.first
        }
    }
    
}

