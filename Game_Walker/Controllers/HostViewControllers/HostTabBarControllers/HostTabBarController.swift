//
//  HostTabBarController.swift
//  Game_Walker
//
//  Created by Noah Kim on 2/1/23.
//

import Foundation
import UIKit

class HostTabBarController: UITabBarController, HostUpdateListener, TeamUpdateListener {
    
    let gameCode = UserData.readGamecode("gamecode") ?? ""
    private var gameOverCalled = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        H.delegates.append(WeakHostUpdateListener(value: self))
        T.delegates.append(WeakTeamUpdateListener(value: self))
        addListener()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        H.delegates = H.delegates.filter { $0.value != nil }
        T.delegates = T.delegates.filter { $0.value != nil}
        H.detatchHost()
    }
    
    private func addListener(){
        H.listenHost(gameCode, onListenerUpdate: listen(_:))
        T.listenTeams(gameCode, onListenerUpdate: listen(_:))
    }
    
    func updateHost(_ host: Host) {
        if host.gameover && !gameOverCalled {
            gameOverCalled = true
            showAwardPopUp("host")
        }
        
        let data: [String:Host] = ["host":host]
        NotificationCenter.default.post(name: .hostUpdate, object: nil, userInfo: data)
    }
    
    func updateTeams(_ teams: [Team]) {
        let data: [String:[Team]] = ["teams":teams]
        NotificationCenter.default.post(name: .teamsUpdate, object: nil, userInfo: data)
    }
    
    func listen(_ _ : [String : Any]){
    }
}
