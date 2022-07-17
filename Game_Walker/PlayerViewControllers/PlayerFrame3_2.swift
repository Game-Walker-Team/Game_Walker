//
//  PlayerFrame3_2.swift
//  Game_Walker
//
//  Created by Noah Kim on 6/16/22.
//

import Foundation
import UIKit

class PlayerFrame3_2: UIViewController {
    
    @IBOutlet weak var joinTeamButton: UIButton!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
        
    }
    

    @IBAction func joinTeamButtonPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "goToPF44", sender: self)
        
    }
}
