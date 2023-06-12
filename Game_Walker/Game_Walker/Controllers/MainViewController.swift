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

class MainViewController: BaseViewController {
   
    @IBOutlet weak var playerButton: UIButton!
    @IBOutlet weak var refereeButton: UIButton!
    @IBOutlet weak var hostButton: UIButton!
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var settingBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func infoBtnPressed(_ sender: UIButton) {
        showInfoPopUp()
    }
    
    @IBAction func settingBtnPressed(_ sender: UIButton) {
    }
}


