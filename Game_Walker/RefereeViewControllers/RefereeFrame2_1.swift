//
//  RefereeFrame2_1.swift
//  Game_Walker
//
//  Created by 김현식 on 7/6/22.
//

import Foundation
import UIKit

class RefereeFrame2_1: UIViewController {
    
    @IBOutlet weak var roundLabel: UILabel!
    
    @IBOutlet weak var scoreButton: UIButton!
    
    @IBOutlet weak var teamnameLabel: UILabel!
    
    @IBOutlet weak var teamscoreLabel: UILabel!
    
    @IBOutlet weak var ruleButton: UIButton!
    
    @IBOutlet weak var nextgameButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
    }
    
    @IBAction func scoreButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToPVEScore", sender: self)
    }
    
    @IBAction func ruleButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToPVERule", sender: self)
    }
    
    @IBAction func nextgameButtonPressed(_ sender: UIButton) {
        
    }
}
