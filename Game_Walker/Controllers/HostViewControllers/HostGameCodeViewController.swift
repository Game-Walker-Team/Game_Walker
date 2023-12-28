//
//  HostGameCodeViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 7/21/22.
//

import UIKit

class HostGameCodeViewController: UIViewController {

    @IBOutlet weak var gameCodeInput: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    var dontTriggerSegue = true
    private var storedgamecode = UserData.readGamecode("gamecode")
    private var gamecode = UserData.readGamecode("gamecode")
    
    private var usestoredcode = true
    private var gameDidEnd = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        gameCodeInput.delegate = self
        gameCodeInput.textAlignment = NSTextAlignment.center
        gameCodeInput.keyboardType = .asciiCapableNumberPad
//        H.delegate_getHost = self

        gameCodeInput.placeholder = storedgamecode
        configureSimpleNavBar()
    }
    
    func setGameCode() {
        let gameCodeText = gameCodeInput.text

        if (gameCodeText != storedgamecode && gameCodeText != "") {
            gamecode = gameCodeText
            usestoredcode = false
        } else {
            gamecode = storedgamecode
            usestoredcode = true
        }
    }
    
    @IBAction func joinButtonPressed(_ sender: UIButton) {
        setGameCode()
        guard let userGamecodeInput = gameCodeInput.text else {
            return
        }

        if gamecode == nil && userGamecodeInput.isEmpty && gameCodeInput.placeholder == "" {
            alert(title: "Warning",message:"You never created a game!")
        } else {
            if (!usestoredcode) {
                Task { @MainActor in
                    do {
                        let hostTemp = try await H.getHost(userGamecodeInput)
                        let isStandard = hostTemp?.standardStyle ?? true
                        gameDidEnd = hostTemp?.gameover ?? false
                        
                        if !isStandard {
                            UserData.writeGamecode(gamecode!, "gamecode")
                            performSegue(withIdentifier: "GameAlreadyStartedSegue", sender: self)
                            return
                        }
                        
                        if !(hostTemp?.confirmCreated ?? true) {
                            UserData.writeGamecode(gamecode!, "gamecode")
                            performSegue(withIdentifier: "HostJoinSegue", sender: self)
                            
                        } else {
                            if UserData.isHostConfirmed() ?? false {
                                UserData.writeGamecode(gamecode!, "gamecode")
                                if gameDidEnd { // host is confirmed and game has already ended
                                    self.showAwardPopUp("host")
                                    
                                } else {
                                    performSegue(withIdentifier: "GameAlreadyStartedSegue", sender: self)
                                }
                            } else{
                                alert(title: "", message: "Invalid Host!")
                            }
                        }
                    } catch GameWalkerError.invalidGamecode(let message) {
                        print(message)
                        gamecodeAlert(message)
                        return
                    } catch GameWalkerError.serverError(let message) {
                        print(message)
                        serverAlert(message)
                        return
                    }
                }
            } else {
                Task { @MainActor in
                    do {
                        guard let gamecode = gamecode else {
                            alert(title: "Warning",message:"You never created a game!")
                            return
                        }
                        let hostTemp = try await H.getHost(gamecode)
                        let isStandard = hostTemp?.standardStyle ?? true
                        gameDidEnd = hostTemp?.gameover ?? false
                        
                        if !isStandard {
                            UserData.writeGamecode(gamecode, "gamecode")
                            performSegue(withIdentifier: "GameAlreadyStartedSegue", sender: self)
                            return
                        }
                        if !(hostTemp?.confirmCreated ?? true) {
                            UserData.writeGamecode(gamecode, "gamecode")
                            performSegue(withIdentifier: "HostJoinSegue", sender: self)
                        } else {
                            if UserData.isHostConfirmed() ?? false {
                                UserData.writeGamecode(gamecode, "gamecode")
                                if gameDidEnd { // host is confirmed and game has already ended
                                    self.showAwardPopUp("host")
                                    
                                } else {
                                    performSegue(withIdentifier: "GameAlreadyStartedSegue", sender: self)
                                }
                            } else{
                                alert(title: "", message: "Invalid Host!")
                            }
                        }

                    } catch GameWalkerError.invalidGamecode(let message) {
                        print(message)
                        gamecodeAlert(message)
                        return
                    } catch GameWalkerError.serverError(let message) {
                        print(message)
                        serverAlert(message)
                        return
                    }
                }
            }
        }
    }
    
}

extension HostGameCodeViewController: UITextFieldDelegate {

}
