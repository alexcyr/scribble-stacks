//
//  WordSelectViewController.swift
//  ScribbleStack
//
//  Created by Alex Cyr on 10/9/16.
//  Copyright © 2016 Alex Cyr. All rights reserved.
//

import UIKit

class WordSelectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let game = Game(captions: [], images: [])
    var getRandomWord: [String] = []
    var sent: String?
    
    let words = ["WALK THE DOG","BRUSHING TEETH","POTATO","SKYDIVING","HOTDOG","CATDOG","PINATA","SUPERMAN","PIG IN A BLANKET","BANANA", "TACO","STAIRWAY TO HEAVEN","TURTLE SOUP","BASEBALL","BEACH"]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

            // Do any additional setup after loading the view, typically from a nib.
            let wordsLength = words.count
            let getRandom = randomSequenceGenerator(min: 1, max: wordsLength)
            for _ in 1...5 {
                print(getRandom())
                getRandomWord.append(words[getRandom()-1])
            }
        
        
        tableView.delegate = self
        tableView.dataSource = self
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
    
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getRandomWord.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "WordSelect", for: indexPath)
        
        let label = cell.viewWithTag(1000) as! UILabel
        
        
            label.text = getRandomWord[indexPath.row]
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        if let cell = tableView.cellForRow(at: indexPath) {

        let label = cell.viewWithTag(1000) as! UILabel
        
        
            if sent != nil{
                
            }
            
        game.captions.append(Caption(phrase: label.text!))
        performSegue(withIdentifier: "ShowWordToDraw", sender: self)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowWordToDraw" {
            let controller = segue.destination as! DrawWordViewController
            controller.game = game
        }
    }


}
