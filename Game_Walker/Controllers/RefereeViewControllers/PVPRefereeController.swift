//
//  RefereeFrame2_2.swift
//  Game_Walker
//
//  Created by 김현식 on 7/6/22.
//

import Foundation
import UIKit

class PVPRefereeController: UIViewController {
    @IBOutlet weak var roundLabel: UILabel!
    
    @IBOutlet weak var scoreButton1: UIButton!
    
    @IBOutlet weak var teamnameLabel: UILabel!
    
    @IBOutlet weak var scoreLabel1: UILabel!
    
    @IBOutlet weak var scoreButton2: UIButton!
    
    @IBOutlet weak var teamnameLabel2: UILabel!
    
    @IBOutlet weak var scoreLabel2: UILabel!
    
    @IBOutlet weak var ruleButton: UIButton!
    
    @IBOutlet weak var nextgameButton: UIButton!
    
    var round = 1
    
    var station : Station = Station()
    
    var index = 0
    
    var algorithm : [[String]] = []
    
    var teams : [Team] = []
    
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
        round += 1
        roundLabel.text = "Round " + "\(round)"
        let integervariable = Int(algorithm[round][index]) ?? 0
        scoreButton1.setImage(UIImage(named: teams[integervariable].iconName), for: .normal)
        teamnameLabel.text = teams[integervariable].name
        scoreLabel1.text = String(teams[integervariable].points)
        scoreButton2.setImage(UIImage(named: teams[integervariable + 1].iconName), for: .normal)
        teamnameLabel2.text = teams[integervariable + 1].name
        scoreLabel2.text = String(teams[integervariable + 1].points)
    }
}
//MARK: - UIUpdate
extension PVPRefereeController: DataUpdateListener {
    func onDataUpdate(_ host: Host) {
        for referee in host.referees {
            if referee.name == RegisterController().name {
                station = referee.station
            }
        }
        for item in host.stations {
            index += 1
            if station == item {
                break
            }
        }
        algorithm = host.algorithm
        print("ondataupdate: \(host.gamecode)")
    }
}
