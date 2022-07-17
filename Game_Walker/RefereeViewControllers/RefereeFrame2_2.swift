//
//  RefereeFrame2_2.swift
//  Game_Walker
//
//  Created by 김현식 on 7/6/22.
//

import Foundation
import UIKit

class RefereeFrame2_2: UIViewController {
    @IBOutlet weak var roundLabel: UILabel!
    
    @IBOutlet weak var scoreButton1: UIButton!
    
    @IBOutlet weak var teamnameLabel: UILabel!
    
    @IBOutlet weak var scoreLabel1: UILabel!
    
    @IBOutlet weak var scoreButton2: UIButton!
    
    @IBOutlet weak var teamnameLabel2: UILabel!
    
    @IBOutlet weak var scoreLabel2: UILabel!
    
    @IBOutlet weak var ruleButton: UIButton!
    
    @IBOutlet weak var nextgameButton: UIButton!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
    }
    
    
    @IBAction func scoreButton1Pressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToPVPScore", sender: self)
    }
    
    @IBAction func scoreButton2Pressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToPVPScore", sender: self)
    }
    
    @IBAction func ruleButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToPVPRule", sender: self)
    }
    
    @IBAction func nextGamePressed(_ sender: UIButton) {
        
    }
}
