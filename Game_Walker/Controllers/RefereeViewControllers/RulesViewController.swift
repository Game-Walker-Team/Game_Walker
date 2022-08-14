//
//  RefereeFrame3_3.swift
//  Game_Walker
//
//  Created by 김현식 on 7/10/22.
//

import Foundation
import UIKit

class RulesViewController: UIViewController {
    
    @IBOutlet weak var gamenameLabel: UITextField!
    
    @IBOutlet weak var gamepointsLabel: UITextField!
    
    @IBOutlet weak var gamelocationLabel: UITextField!
    
    @IBOutlet weak var rulesLabel: UITextField!
    
    var station : Station = Station()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        gamenameLabel.text = station.name
        gamepointsLabel.text = String(station.points)
        gamelocationLabel.text = station.place
        rulesLabel.text = station.description
        // Do any additional setup after loading the view.
        
    }
}

//MARK: - UIUpdate
extension RulesViewController: DataUpdateListener {
    func onDataUpdate(_ host: Host) {
        for referee in host.referees {
            if referee.name == RegisterController().name {
                station = referee.station
            }
        }
        print("ondataupdate: \(host.gamecode)")
    }
}

