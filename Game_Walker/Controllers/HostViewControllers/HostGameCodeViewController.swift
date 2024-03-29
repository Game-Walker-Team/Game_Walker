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
    
    private var gameCodeError = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        gameCodeInput.delegate = self
        gameCodeInput.textAlignment = NSTextAlignment.center
        gameCodeInput.keyboardType = .asciiCapableNumberPad
        gameCodeInput.placeholder = storedgamecode
        configureSimpleNavBar()
        configureButtonVisuals()
    }
    
    func setGameCode() {
        let gameCodeText = gameCodeInput.text
        print(gameCodeText , " this is what is entered")

        if (gameCodeText != storedgamecode && gameCodeText != "") {
            gamecode = gameCodeText
            usestoredcode = false
        } else {
            gamecode = storedgamecode
            usestoredcode = true
            if let gamecode = gamecode {
                gameCodeError = false
                print("Game code error is false")
            } else {
                gameCodeError = true
                print("Game code error is true")
            }
        }
    }
    @IBAction func joinButtonPressed(_ sender: UIButton) {
        setGameCode()

        guard let userGamecodeInput = gameCodeInput.text else {
            return
        }
        var isHost = false

        if UserData.getUserRole() == "host" {
            isHost = true
        }

        // Check if storedgamecode is nil or empty
        if let storedGamecode = gamecode, !storedGamecode.isEmpty || !usestoredcode {
            Task { @MainActor in
                do {
                    let hostTemp = try await H.getHost(usestoredcode ? storedGamecode : userGamecodeInput)
                    let isStandard = hostTemp?.standardStyle ?? true
                    gameDidEnd = hostTemp?.gameover ?? false

                    if !isStandard {
                        if isHost {
                            UserData.writeGamecode(storedGamecode, "gamecode")
                            performSegue(withIdentifier: "GameAlreadyStartedSegue", sender: self)
                            return
                        } else {
                            alert(title: "", message: NSLocalizedString("Invalid Host.", comment: ""))
                        }
                    }

                    if !(hostTemp?.confirmCreated ?? true) {
                        if isHost {
                            UserData.writeGamecode(storedGamecode, "gamecode")
                            performSegue(withIdentifier: "HostJoinSegue", sender: self)
                        } else{
                            alert(title: "", message: NSLocalizedString("Invalid Host.", comment: ""))
                        }
                    } else {
                        if (UserData.isHostConfirmed() ?? false) && isHost {
                            UserData.writeGamecode(storedGamecode, "gamecode")
                            if gameDidEnd {
                                self.showAwardPopUp("host")
                            } else {
                                performSegue(withIdentifier: "GameAlreadyStartedSegue", sender: self)
                            }
                        } else {
                            alert(title: "", message: NSLocalizedString("Invalid Host.", comment: ""))
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
            // Storedgamecode is nil or empty and usestoredcode is false
            guard let gamecode = gamecode else {
                alert(title: NSLocalizedString("No game exists.", comment: ""), message: "")
                return
            }
            UserData.writeGamecode(gamecode, "gamecode")
        }
    }

    private func configureButtonVisuals() {
        if let originalFont = joinButton.titleLabel?.font {
            joinButton.titleLabel?.font = getFontForLanguage(font: originalFont.fontName, size: originalFont.pointSize)
        }

        joinButton.layer.cornerRadius = 10.0

    }

}

extension HostGameCodeViewController: UITextFieldDelegate {

}
