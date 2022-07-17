//
//  RefereeFrame3_1.swift
//  Game_Walker
//
//  Created by 김현식 on 7/10/22.
//

import Foundation
import UIKit
import GMStepper

class RefereeFrame3_1: UIViewController {
    
    @IBOutlet weak var roundLabel: UILabel!
    
    @IBOutlet weak var scoreButton: UIButton!
    
    @IBOutlet weak var teamnameLabel: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var ruleButton: UIButton!
    
    @IBOutlet weak var nextgameButton: UIButton!
    
    @IBOutlet weak var scoreStepper: GMStepper!
    
    @IBOutlet weak var confirmButton: UIButton!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func ruleButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func nextgameButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func scoreStepperPressed(_ sender: GMStepper) {
    }
    
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
    }
    
}
