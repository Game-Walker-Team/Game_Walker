//
//  HostGameCodeViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 7/21/22.
//

import UIKit

class HostGameCodeViewController: BaseViewController {

    @IBOutlet weak var gameCodeInput: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    
    private var storedgamecode = UserData.readGamecode("gamecodestring")
    private var gamecode = UserData.readGamecode("gamecodestring")
//    var host : Host?
    
    // This will be the game code entered by the user.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        gameCodeInput.delegate = self
        gameCodeInput.textAlignment = NSTextAlignment.center
        gameCodeInput.keyboardType = .asciiCapableNumberPad
//        H.delegate_getHost = self

        gameCodeInput.placeholder = storedgamecode
        self.hideKeyboardWhenTappedAround()
    }
    
    func setGameCode() {
        let gameCodeText = gameCodeInput.text
        if (gameCodeText != storedgamecode) {
            gamecode = gameCodeText
        }
    }
    
    @IBAction func joinButtonPressed(_ sender: UIButton) {
        setGameCode()
        if storedgamecode!.isEmpty {
            alert(title: "No Input",message:"You never created a game!")
        } else {
            UserData.writeGamecode(gamecode!, "gamecodestring")
//            H.getHost(storedgamecode!)
            self.performSegue(withIdentifier: "HostJoinSegue", sender: self)
        }
    }
    
}

extension HostGameCodeViewController: UITextFieldDelegate {

}

//extension HostGameCodeViewController: GetHost {
//    func getHost(_ host: Host) {
//        self.host = host
//        print("host protocol: could get host")
//    }
//}
