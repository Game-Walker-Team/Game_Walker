//
//  PlayerFrame1.swift
//  Game_Walker
//
//  Created by Paul on 6/7/22.
//

import Foundation
import UIKit

class JoinGameViewController: UIViewController {
    
    @IBOutlet weak var gamecodeLbl: UILabel!
    @IBOutlet weak var gamecodeTextField: UITextField!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    private let audioPlayerManager = AudioPlayerManager()
    
    private var storedGameCode = UserData.readGamecode("gamecode") ?? ""
    private var storedUsername = UserData.readUsername("username") ?? ""
    private var storedPlayer = UserData.readPlayer("player") ?? nil
    private var storedTeamName = UserData.readTeam("team")?.name ?? ""
    private let standardStyle = UserData.isStandardStyle()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureSimpleNavBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
    }

    private func setUp() {
        gamecodeTextField.delegate = self
        usernameTextField.delegate = self
        gamecodeTextField.translatesAutoresizingMaskIntoConstraints = false
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        gamecodeTextField.keyboardType = .asciiCapableNumberPad
        gamecodeTextField.placeholder = storedGameCode != "" ? storedGameCode : NSLocalizedString("gamecode", comment: "")
        usernameTextField.placeholder = storedUsername != "" ? storedUsername : NSLocalizedString("username", comment: "")
        gamecodeTextField.layer.borderWidth = 3
        gamecodeTextField.layer.borderColor = UIColor.black.cgColor
        gamecodeTextField.layer.cornerRadius = 10
        usernameTextField.layer.borderWidth = 3
        usernameTextField.layer.borderColor = UIColor.black.cgColor
        usernameTextField.layer.cornerRadius = 10
        gamecodeLbl.font = getFontForLanguage(font: "GemunuLibre-SemiBold", size: fontSize(size: 40))
        usernameLbl.font = getFontForLanguage(font: "GemunuLibre-SemiBold", size: fontSize(size: 40))
                
        nextButton.backgroundColor = UIColor(red: 0.21, green: 0.67, blue: 0.95, alpha: 1)
        nextButton.layer.cornerRadius = 8
    }
    
    
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        self.audioPlayerManager.playAudioFile(named: "blue", withExtension: "wav")

        let savedGameCode = UserData.readGamecode("gamecode") ?? ""
        let savedUserName = UserData.readUsername("username") ?? ""
        let player = UserData.readPlayer("player") ?? Player(gamecode: "", name: "")
        
        guard let gamecode = gamecodeTextField.text else { return }
        guard let username = usernameTextField.text else { return }
        guard let uuid = UserData.readUUID() else { return }
        
        if (UserData.getUserRole() == nil || UserData.getUserRole() == "player")
        {
            if gamecode.isEmpty && username.isEmpty
            {
                if !savedGameCode.isEmpty && !savedUserName.isEmpty
                {
                    joinExistingGameWithSavedUserInfo()
                }
                else
                {
                    alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("Please enter both gamecode and username.", comment: ""))
                    return
                }
            }
            else if gamecode == savedGameCode && username == savedUserName
            {
                joinExistingGameWithSavedUserInfo()
            }
            else if savedGameCode.isEmpty && savedUserName.isEmpty
            {
                createNewPlayerAndJoinNewGameWithUserInput(gamecode, username, uuid)
            }
            else if (gamecode != savedGameCode) && (username.isEmpty || username == savedUserName)
            {
                joinNewGameWithSavedUsername(savedGameCode, player, uuid, gamecode, savedUserName)
            }
            else if (gamecode.isEmpty || gamecode == savedGameCode) && username != savedUserName
            {
                modifyUsername(savedGameCode, uuid, username)
            }
            else if gamecode != savedGameCode && username != savedUserName
            {
                transitionToNewGameWithNewUsername(savedGameCode, gamecode, player, uuid, username)
            }
            else
            {
                alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("Invalid Input.", comment: ""))
                return
            }
        }
        else if UserData.getUserRole() == "referee"
        {
            Task { @MainActor in
                do {
                    guard let confirmCreated = try await H.getHost(storedGameCode)?.confirmCreated else { return }
                    
                    // user switching from referee
                    
                    if gamecode.isEmpty && username.isEmpty
                    {
                        if !savedGameCode.isEmpty && !savedUserName.isEmpty
                        {
                            if !confirmCreated {
                                createPlayerAndJoinGame(savedGameCode, savedUserName, uuid)
                            } else {
                                alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("You cannot change roles while the game is in progress.", comment: ""))
                                return
                            }
                        }
                        else
                        {
                            alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("Please enter both gamecode and username.", comment: ""))
                            return
                        }
                    }
                    else if gamecode == savedGameCode && username == savedUserName
                    {
                        if !confirmCreated {
                            createPlayerAndJoinGame(savedGameCode, savedUserName, uuid)
                        } else {
                            alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("You cannot change roles while the game is in progress.", comment: ""))
                            return
                        }
                    }
                    else if (!savedGameCode.isEmpty || gamecode == savedGameCode) && savedUserName.isEmpty
                    {
                        if !confirmCreated {
                            switchToPlayerFromOtherRoles(savedGameCode, gamecode, savedUserName, username, uuid)
                        } else {
                            alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("You cannot change roles while the game is in progress.", comment: ""))
                            return
                        }
                    }
                    else if (gamecode.isEmpty || gamecode == savedGameCode) && username != savedUserName
                    {
                        if !confirmCreated {
                            createPlayerAndJoinGame(savedGameCode, username, uuid)
                        } else {
                            alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("You cannot change roles while the game is in progress.", comment: ""))
                            return
                        }
                    }
                    else if savedGameCode.isEmpty && savedUserName.isEmpty
                    {
                        createNewPlayerAndJoinNewGameWithUserInput(gamecode, username, uuid)
                    }
                    else if (gamecode != savedGameCode) && (username.isEmpty || username == savedUserName)
                    {
                        createPlayerAndJoinGame(gamecode, savedUserName, uuid)
                    }
                    else if gamecode != savedGameCode && username != savedUserName
                    {
                        createPlayerAndJoinGame(gamecode, username, uuid)
                    }
                    else
                    {
                        alert(title: "Woops!", message: NSLocalizedString("Invalid Input.", comment: ""))
                        return
                    }
                    
                } catch GameWalkerError.serverError(let e) {
                    print(e)
                    serverAlert(e)
                    return
                }
            }
        } else if UserData.getUserRole() == "host" {
            // when host tries to make player object using previous gamecode => deny access
            if (gamecode.isEmpty && !savedGameCode.isEmpty) || gamecode == savedGameCode
            {
                alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("You should manage your game as a host.", comment: ""))
                return
            }
            // can make and join the game as a player with new gamecode
            else
            {
                UserData.setUserRole("player")
                
                if username.isEmpty
                {
                    alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("Please enter username.", comment: ""))
                    return
                }
                else if gamecode.isEmpty
                {
                    alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("Please enter gamecode.", comment: ""))
                    return
                }
                else
                {
                    createPlayerAndJoinGame(gamecode, username, uuid)
                }
            }
        }
    }
   // MARK: - modulize functions for joining game
    
    private func joinExistingGameWithSavedUserInfo(){
        if (UserData.readTeam("team") != nil) {
            // User wants to join the game with the stored game code, username, and player object
            performSegue(withIdentifier: "ResumeGameSegue", sender: self)
        } else {
            // User chooses between creating or joining a team
            performSegue(withIdentifier: "goToPF2VC", sender: self)
        }
    }
    
    private func createPlayerAndJoinGame(_ gamecode: String, _ username: String, _ uuid: String) {
        let player = Player(gamecode: gamecode, name: username)
        if UserData.getUserRole() == "referee" {
            UserData.removeReferee()
        }
        UserData.writePlayer(player, "player")
        UserData.writeGamecode(gamecode, "gamecode")
        UserData.writeUsername(username, "username")
        UserData.setUserRole("player")
        Task {@MainActor in
            do {
                try await P.addPlayer(gamecode, player, uuid)
                performSegue(withIdentifier: "goToPF2VC", sender: self)
            } catch GameWalkerError.serverError(let e) {
                print(e)
                serverAlert(e)
                return
            }
        }
    }
    
    private func createNewPlayerAndJoinNewGameWithUserInput(_ gamecode: String, _ username: String, _ uuid: String) {
        // User is joining a new game
        if !gamecode.isEmpty && !username.isEmpty {
        // Create a new player object for the new game
            let player = Player(gamecode: gamecode, name: username)
            
            // Join the game
            Task { @MainActor in
                // Try await P.addPlayer(gamecode, player, uuid)
                do {
                    try await P.addPlayer(gamecode, player, uuid)
                    UserData.writeGamecode(gamecode, "gamecode")
                    UserData.writeUsername(username, "username")
                    UserData.writePlayer(player, "player")
                    if UserData.getUserRole() == "referee" {
                        UserData.removeReferee()
                    }
                    UserData.setUserRole("player")
                    performSegue(withIdentifier: "goToPF2VC", sender: self)
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
            // Invalid input
            alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("Please enter both gamecode and username.", comment: ""))
            return
        }
    }
    
    private func joinNewGameWithSavedUsername(_ savedGameCode: String, _ player: Player, _ uuid: String, _ gamecode:String, _ savedUserName: String) {
        Task { @MainActor in
            if let team = UserData.readTeam("team") {
                print(team)
                UserData.clearMyTeam("team")
            }
            P.removePlayer(savedGameCode, uuid)
            let newPlayer = Player(gamecode: gamecode, name: savedUserName)
            do{
                try await P.addPlayer(gamecode, newPlayer, uuid)
                UserData.writeGamecode(gamecode, "gamecode")
                UserData.writePlayer(newPlayer, "player")
                UserData.setUserRole("player")
                self.performSegue(withIdentifier: "goToPF2VC", sender: self)
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
    
    private func modifyUsername(_ savedGameCode: String, _ uuid: String, _ username: String) {
        Task { @MainActor in
            do {
                try await P.modifyName(savedGameCode, uuid, username)
                let player = Player(gamecode: savedGameCode, name: username)
                UserData.writePlayer(player, "player")
                UserData.writeUsername(username, "username")
            } catch GameWalkerError.invalidGamecode(let message) {
                print(message)
                gamecodeAlert(message)
                return
            } catch GameWalkerError.serverError(let message) {
                print(message)
                serverAlert(message)
                return
            }
            if (UserData.readTeam("team") != nil) {
                self.performSegue(withIdentifier: "ResumeGameSegue", sender: self)
            } else {
                self.performSegue(withIdentifier: "goToPF2VC", sender: self)
            }
        }
    }
    
    private func switchToPlayerFromOtherRoles(_ savedGameCode: String, _ gamecode: String, _ savedUserName: String, _ username: String, _ uuid: String){
        if let username = usernameTextField.text {
            Task {@MainActor in
                let player = Player(gamecode: savedGameCode, name: username)
                if UserData.getUserRole() == "referee" {
                    UserData.removeReferee()
                }
                UserData.writePlayer(player, "player")
                UserData.writeUsername(username, "username")
                UserData.writeGamecode(savedGameCode, "gamecode")
                do {
                    try await P.addPlayer(savedGameCode, player, uuid)
                    self.performSegue(withIdentifier: "goToPF2VC", sender: self)
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
            alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("Please enter username.", comment: ""))
            return
        }
    }
    
    private func transitionToNewGameWithNewUsername(_ savedGameCode: String, _ gamecode: String, _ player: Player, _ uuid: String, _ username: String ) {
        Task {@MainActor in
            if let team = UserData.readTeam("team") {
                UserData.clearMyTeam("team")
            }
            P.removePlayer(savedGameCode, uuid)
            let newPlayer = Player(gamecode: gamecode, name: username)
            do {
                try await P.addPlayer(gamecode, newPlayer, uuid)
                UserData.writeGamecode(gamecode, "gamecode")
                UserData.writeUsername(username, "username")
                UserData.writePlayer(newPlayer, "player")
                UserData.setUserRole("player")
                self.performSegue(withIdentifier: "goToPF2VC", sender: self)
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
    // MARK: - prepare
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tabBarController = segue.destination as? PlayerTabBarController {
            // Determine the value of "standardStyle" (true or false)

            // Pass the "standardStyle" value to the tab bar controller
            tabBarController.standardStyle = self.standardStyle
        }
    }
}

// MARK: - UITextFieldDelegate
extension JoinGameViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == gamecodeTextField {
            usernameTextField.becomeFirstResponder()
        } else if textField == usernameTextField {
            nextButtonPressed(nextButton)
        }
        return true
    }
}
