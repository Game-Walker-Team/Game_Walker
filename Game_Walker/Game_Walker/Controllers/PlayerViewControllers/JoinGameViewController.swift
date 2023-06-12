//
//  PlayerFrame1.swift
//  Game_Walker
//
//  Created by Paul on 6/7/22.
//

import Foundation
import UIKit
import PromiseKit

class JoinGameViewController: BaseViewController {
    
    @IBOutlet weak var gamecodeTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    private var storedGameCode = UserData.readGamecode("gamecode") ?? ""
    private var storedUsername = UserData.readUsername("username") ?? ""
    private var storedPlayer = UserData.readPlayer("player") ?? Player()
    private var storedTeamName = UserData.readTeam("team")?.name ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        setUpTextFields()
        configureNavItem()
    }
    
    private func setDelegates() {
        H.delegates.append(self)
        T.delegates.append(self)
    }
    
    private func setUpTextFields() {
        gamecodeTextField.delegate = self
        usernameTextField.delegate = self
        gamecodeTextField.keyboardType = .asciiCapableNumberPad
        gamecodeTextField.placeholder = storedGameCode != "" ? storedGameCode : "gamecode"
        usernameTextField.placeholder = storedUsername != "" ? storedUsername : "username"
        self.hideKeyboardWhenTappedAround()
    }
    
    private func configureNavItem() {
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(image: UIImage(named: "back button 1"), style: .plain, target: self, action: #selector(CreateOrJoinTeamViewController.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    @objc func back(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "ToMainVC", sender: self)
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        let savedGameCode = UserData.readGamecode("gamecode") ?? ""
        let savedUserName = UserData.readUsername("username") ?? ""
        var player = UserData.readPlayer("player") ?? Player(gamecode: savedGameCode, name: savedUserName)
        
        guard let gamecode = gamecodeTextField.text else { return }
        guard let username = usernameTextField.text else { return }
        
        if (gamecode.isEmpty || gamecode == savedGameCode) && (username.isEmpty || username == savedUserName) {
            
            if (UserData.readTeam("team") != nil) {
                // User wants to join the game with the stored game code, username, and player object
                performSegue(withIdentifier: "ResumeGameSegue", sender: self)
            } else {
                // User gets to choose to create or join a team
                performSegue(withIdentifier: "goToPF2VC", sender: self)
            }
        } else if savedGameCode.isEmpty && savedUserName.isEmpty {
            
            // User is joining a new game
            if !gamecode.isEmpty && !username.isEmpty {
                // Save the game code and username to user defaults
                UserData.writeGamecode(gamecode, "gamecode")
                UserData.writeUsername(username, "username")

                // Create a new player object for the new game
                player = Player(gamecode: gamecode, name: username)
                UserData.writePlayer(player, "player")
                
                // Join the game
                P.addPlayer(gamecode, player)
                performSegue(withIdentifier: "goToPF2VC", sender: self)
            } else {
                // Invalid input
                alert(title: "", message: "Please enter both game code and username.")
            }
            
        } else if (gamecode != savedGameCode) && (username.isEmpty || username == savedUserName) {
            
            // User leave the existing game
            firstly { () -> Promise<Void> in
                return Promise<Void> { seal in
                    // Leave team to reflect the gamecode change
                    leaveTeam(gamecode: savedGameCode, teamName: savedUserName, storedPlayer: player) {
                        print("leaving team")
                        seal.fulfill(())
                    }
                }
            }.then {
                return Promise<Void> { seal in
                    // Remove original player object to reflect the gamecode change
                    self.removePlayer(gamecode: savedGameCode, storedPlayer: player) {
                        print("removing player")
                        // Create new player object with new username
                        seal.fulfill(())
                    }
                }
            }.then {
                return Promise<Void> { seal in
                    //User joins the new game and team with new gamecode
                    UserData.writeGamecode(gamecode, "gamecode")
                    player = Player(gamecode: gamecode, name: savedUserName)
                    UserData.writePlayer(player, "player")
                    print("created new player")
                    self.addPlayer(gamecode: gamecode, player: player) {
                        print("adding player")
                        seal.fulfill(())
                    }
                }
            }.done {
                print("All works with the server are done")
                self.performSegue(withIdentifier: "goToPF2VC", sender: self)
            }.catch { error in
                print("An error occurred: \(error)")
                self.alert(title: "", message: "Error occurred while communicating with the server. Try again few seconds later!")
            }
            
        } else if (gamecode.isEmpty || gamecode == savedGameCode) && username != savedUserName {
            
            if (UserData.readTeam("team") != nil) {
                // User wants to join the game with the stored game code with new player object
                // Remove original player object to reflect the username change
                firstly { () -> Promise<Void> in
                    return Promise<Void> { seal in
                        // Leave team to reflect the username change
                        leaveTeam(gamecode: storedGameCode, teamName: storedTeamName, storedPlayer: storedPlayer) {
                            print("leaving team")
                            seal.fulfill(())
                        }
                    }
                }.then {
                    return Promise<Void> { seal in
                        // Remove original player object to reflect the username change
                        self.removePlayer(gamecode: gamecode, storedPlayer: self.storedPlayer) {
                            print("removing player")
                            // Create new player object with new username
                            seal.fulfill(())
                        }
                    }
                }.then {
                    return Promise<Void> { seal in
                        //User joins the existing game and team with new user name
                        UserData.writeUsername(username, "username")
                        player = Player(gamecode: savedGameCode, name: username)
                        UserData.writePlayer(player, "player")
                        print("created new player")
                        self.addPlayer(gamecode: savedGameCode, player: player) {
                            print("adding player")
                            seal.fulfill(())
                        }
                    }
                }.then { [self] in
                    return Promise<Void> { seal in
                        //User joins the existing game and team with new user name
                        self.joinTeam(gamecode: savedGameCode, teamName: storedTeamName, player: player) {
                            print("joining team")
                            seal.fulfill(())
                        }
                    }
                }.done {
                    print("All works with the server are done")
                    self.performSegue(withIdentifier: "ResumeGameSegue", sender: self)
                }.catch { error in
                    print("An error occurred: \(error)")
                    self.alert(title: "", message: "Error occurred while communicating with the server. Try again few seconds later!")
                }
            } else {
                // User gets to choose to create or join a team
                firstly { () -> Promise<Void> in
                    return Promise<Void> { seal in
                        // Remove original player object to reflect the username change
                        self.removePlayer(gamecode: gamecode, storedPlayer: self.storedPlayer) {
                            print("removing player")
                            // Create new player object with new username
                            seal.fulfill(())
                        }
                    }
                }.then {
                    return Promise<Void> { seal in
                        //User joins the existing game and team with new user name
                        UserData.writeUsername(username, "username")
                        player = Player(gamecode: savedGameCode, name: username)
                        UserData.writePlayer(player, "player")
                        print("created new player")
                        self.addPlayer(gamecode: savedGameCode, player: player) {
                            print("adding player")
                            seal.fulfill(())
                        }
                    }
                }.done {
                    print("All works with the server are done")
                    self.performSegue(withIdentifier: "goToPF2VC", sender: self)
                }.catch { error in
                    print("An error occurred: \(error)")
                    self.alert(title: "", message: "Error occurred while communicating with the server. Try again few seconds later!")
                }
            }
        } else if gamecode != savedGameCode && username != savedUserName {
            // User leave the existing game
            firstly { () -> Promise<Void> in
                return Promise<Void> { seal in
                    // Leave team to reflect the gamecode and username change
                    leaveTeam(gamecode: savedGameCode, teamName: savedUserName, storedPlayer: player) {
                        print("leaving team")
                        seal.fulfill(())
                    }
                }
            }.then {
                return Promise<Void> { seal in
                    // Remove original player object to reflect the gamecode and username change
                    self.removePlayer(gamecode: savedGameCode, storedPlayer: player) {
                        print("removing player")
                        // Create new player object with new username
                        seal.fulfill(())
                    }
                }
            }.then {
                return Promise<Void> { seal in
                    //User joins the new game and team with new gamecode and username
                    UserData.writeGamecode(gamecode, "gamecode")
                    UserData.writeUsername(username, "username")
                    player = Player(gamecode: gamecode, name: username)
                    UserData.writePlayer(player, "player")
                    print("created new player")
                    self.addPlayer(gamecode: gamecode, player: player) {
                        print("adding player")
                        seal.fulfill(())
                    }
                }
            }.done {
                print("All works with the server are done")
                self.performSegue(withIdentifier: "goToPF2VC", sender: self)
            }.catch { error in
                print("An error occurred: \(error)")
                self.alert(title: "", message: "Error occurred while communicating with the server. Try again few seconds later!")
            }
        } else {
            alert(title: "", message: "Invalid Input!")
        }
    }

    func listen(_ _ : [String : Any]){
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

// MARK: - listener
extension JoinGameViewController: HostUpdateListener, TeamUpdateListener {
    func updateTeams(_ teams: [Team]) {
        
    }
    
    func updateHost(_ host: Host) {
        
    }
}

// MARK: - Promise
extension JoinGameViewController {
    func leaveTeam(gamecode: String, teamName: String, storedPlayer: Player, completion: @escaping () -> Void) {
        T.leaveTeam(gamecode, teamName, storedPlayer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Simulate asynchronous task completion after 0.4 seconds
            completion()
        }
    }
    
    func removePlayer(gamecode: String, storedPlayer: Player, completion: @escaping () -> Void) {
        P.removePlayer(gamecode, storedPlayer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            // Simulate asynchronous task completion after 0.4 seconds
            completion()
        }
    }
    
    func addPlayer(gamecode: String, player: Player, completion: @escaping () -> Void) {
        P.addPlayer(gamecode, player)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Simulate asynchronous task completion after 0.4 seconds
            completion()
        }
    }
    
    func joinTeam(gamecode: String, teamName: String, player: Player, completion: @escaping () -> Void) {
        T.joinTeam(gamecode, teamName, player)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Simulate asynchronous task completion after 0.4 seconds
            completion()
        }
    }
}
