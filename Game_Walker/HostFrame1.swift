//
//  HostFrame1.swift
//  Game_Walker
//
//  Created by Paul on 6/27/22.
//

import Foundation
import UIKit

class HostFrame1 : UIViewController{


   
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        K.Database.delegates.append(self)
       
    }
    

    @IBAction func test(_ sender: UIButton) {
        
        K.Database.setupRequest(gamecode: K.gamecode, player: nil, referee: nil, team: nil, station: nil, gameTime: 15, movingTime: 12, rounds: 5, request: .timer)
        
    }
    

}



//MARK: - UIUpdate
extension HostFrame1: DataUpdateListener {
    func onDataUpdate(_ host: Host) {
        //host로 하고 싶은거 하셈
//        scoreLabel.text = host.score
//        nextPlaceLabel.text = host.nextPlaceLabel
        print("Host Frame On Data Update gametime: \(host.gameTime)")
        
    }
    
}
