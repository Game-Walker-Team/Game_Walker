//
//  RefereeFrame3_2.swift
//  Game_Walker
//
//  Created by 김현식 on 7/10/22.
//

import Foundation
import UIKit
import GMStepper

class PVPGivePointsController: UIViewController {
    
    @IBOutlet weak var roundLabel: UILabel!
    @IBOutlet weak var scoreButton1: UIButton!
    @IBOutlet weak var teamnameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var scoreButton2: UIButton!
    @IBOutlet weak var teamnameLabel2: UILabel!
    @IBOutlet weak var scoreLabel2: UILabel!
    @IBOutlet weak var ruleButton: UIButton!
    @IBOutlet weak var nextgameButton: UIButton!
    @IBOutlet weak var scoreStepper: GMStepper!
    @IBOutlet weak var confirmButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
    }
    
    @IBAction func scoreStepperPressed(_ sender: GMStepper) {
    }
    
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
    }
    
}
