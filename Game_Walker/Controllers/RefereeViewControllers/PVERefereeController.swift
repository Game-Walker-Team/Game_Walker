//
//  RefereeFrame2_1.swift
//  Game_Walker
//
//  Created by 김현식 on 7/6/22.
//

import Foundation
import UIKit

class PVERefereeController: UIViewController {
    
    @IBOutlet weak var roundLabel: UILabel!
    @IBOutlet weak var scoreButton: UIButton!
    @IBOutlet weak var teamnameLabel: UILabel!
    @IBOutlet weak var teamscoreLabel: UILabel!
    @IBOutlet weak var ruleButton: UIButton!
    @IBOutlet weak var nextgameButton: UIButton!
    var round = 1
    var station : Station = Station()
    var index = 0
    var algorithm : [[String]] = []
    var teams : [Team] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roundLabel.text = "Round 1"
        scoreButton.setImage(UIImage(named: station.teams[0].iconName), for: .normal)
        teamnameLabel.text = station.teams[0].name
        teamscoreLabel.text = String(station.teams[0].points)
    
    }
    
    @IBAction func scoreButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToPVEScore", sender: self)
    }
    
    @IBAction func ruleButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToPVERule", sender: self)
    }
    
    @IBAction func nextgameButtonPressed(_ sender: UIButton) {
        round += 1
        roundLabel.text = "Round " + "\(round)"
        let integervariable = Int(algorithm[round][index]) ?? 0
        scoreButton.setImage(UIImage(named: teams[integervariable].iconName), for: .normal)
        teamnameLabel.text = teams[integervariable].name
        teamscoreLabel.text = String(teams[integervariable].points)
    }
}

//MARK: - UIUpdate
extension PVERefereeController: DataUpdateListener {
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
        teams = host.teams
        algorithm = host.algorithm
        print("ondataupdate: \(host.gamecode)")
    }
}
