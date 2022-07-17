//
//  RefereeFrame1.swift
//  Game_Walker
//
//  Created by Paul on 6/7/22.
//

import Foundation
import UIKit

class RefereeFrame1: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var gamecodeTextField: UITextField!
    
    @IBOutlet weak var nextButton: UIButton!
    
    var pvp : Bool = true
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
        
    }
    

    @IBAction func nextButtonPressed(_ sender: UIButton) {
        if let gamecode = gamecodeTextField.text, let name = usernameTextField.text {
            let newReferee = Referee(gamecode: gamecode, name: name, station: Station())
            K.Database.setupRequest(gamecode: newReferee.gamecode, player: nil, referee: newReferee, team: nil, station: nil, gameTime: nil, movingTime: nil, rounds: nil, request: .addReferee)
        }
        if pvp {
            performSegue(withIdentifier: "goToPVP", sender: self)
        }
        else {
            performSegue(withIdentifier: "goToPVE", sender: self)
        }
    }
}

//MARK: - UIUpdate
extension RefereeFrame1: DataUpdateListener {
    func onDataUpdate(_ host: Host) {
        for referee in host.referees {
            if referee.name == usernameTextField.text && referee.gamecode == gamecodeTextField.text {
                pvp = referee.station.pvp
            }
        }
        print("ondataupdate: \(host.gamecode)")
    }
}
