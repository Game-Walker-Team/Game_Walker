//
//  ViewController.swift
//  Game_Walker
//
//  Created by Paul on 6/7/22.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift

class MainViewController: UIViewController {
    
    @IBOutlet weak var playerButton: UIButton!
    @IBOutlet weak var refereeButton: UIButton!
    @IBOutlet weak var hostButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        K.Database.delegates.append(self)
        playerButton.imageView?.contentMode = .scaleToFill
    }
    
    
    @IBAction func hostButtonPressed(_ sender: Any) {
        K.gamecode = String(Int.random(in: 100000 ... 999999))
        let host = Host(gamecode: K.gamecode)
        print(K.gamecode)
        K.Database.updateHost(host)
        K.Database.readHost(gamecode: K.gamecode, onListenerUpdate: listen(_:))
    }
    
    func listen(_ _ : [String : Any]){
    }

}

//MARK: - UIUpdate
extension MainViewController: DataUpdateListener {
    func onDataUpdate(_ host: Host) {
        //host로 하고 싶은거 하셈
//        scoreLabel.text = host.score
//        nextPlaceLabel.text = host.nextPlaceLabel
        print("Gamecode: \(host.gamecode)")
        
    }
    
}

