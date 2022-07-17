//
//  PlayerFrame1.swift
//  Game_Walker
//
//  Created by Paul on 6/7/22.
//

import Foundation
import UIKit

class PlayerFrame1: UIViewController {
    
    
    @IBOutlet weak var gamecodeTextField: UITextField!
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        K.Database.delegates.append(self)
        
    }
    

    @IBAction func nextButtonPressed(_ sender: UIButton) {

        if let gamecode: String = gamecodeTextField.text, let username: String = usernameTextField.text {
            K.Database.readHost(gamecode: gamecode, onListenerUpdate: listen(_:))
            let newPlayer = Player(gamecode: gamecode, name: username)
            K.Database.setupRequest(gamecode: newPlayer.gamecode, player: newPlayer, referee: nil, team: nil, station: nil, gameTime: nil, movingTime: nil, rounds: nil, request: .addPlayer)
        }
        performSegue(withIdentifier: "goToPF2VC", sender: self)
    }
    
    func listen(_ _ : [String : Any]){
    }


}

//MARK: - UIUpdate
extension PlayerFrame1: DataUpdateListener {
    func onDataUpdate(_ host: Host) {
        //host로 하고 싶은거 하셈
//        scoreLabel.text = host.score
//        nextPlaceLabel.text = host.nextPlaceLabel
        print("Size of Players \(host.players.count)")
        
    }
    
}
