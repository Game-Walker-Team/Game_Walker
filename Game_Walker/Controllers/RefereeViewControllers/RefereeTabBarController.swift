//
//  RefereeTabBarPVEController.swift
//  Game_Walker
//
//  Created by 김현식 on 1/27/23.
//

import UIKit

class RefereeTabBarPVEController: UITabBarController, RefereeUpdateListener, HostUpdateListener, TeamUpdateListener {
    
    private var gameCode = UserData.readGamecode("gamecode") ?? ""
    
    static var localMessages: [Announcement] = []
    
    private var timer = Timer()
    static var unread: Bool = false
    
    private let audioPlayerManager = AudioPlayerManager()

    private var soundEnabled: Bool = UserData.getUserSoundPreference() ?? true

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.navigationController?.isNavigationBarHidden = true
        
        Task {@MainActor in
            do {
                guard let host = try await H.getHost(gameCode) else { return }
                RefereeTabBarPVEController.localMessages = host.announcements
            } catch GameWalkerError.serverError(let e) {
                print(e)
                serverAlert(e)
                return
            }
        }
        
        print("tabbar prints: \(H.delegates.count)")
        
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
            guard let strongSelf = self else {
                return
            }
            let unread = strongSelf.checkUnreadAnnouncements(announcements: RefereeTabBarPVEController.localMessages)
            RefereeTabBarPVEController.unread = unread
            if unread{
                NotificationCenter.default.post(name: .readNotification, object: nil, userInfo: ["unread":unread])
                NotificationCenter.default.post(name: .newDataNotif, object: nil)
            } else {
                NotificationCenter.default.post(name: .readNotification, object: nil, userInfo: ["unread":unread])
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationController?.isNavigationBarHidden = true
        H.delegates.append(WeakHostUpdateListener(value: self))
        T.delegates.append(WeakTeamUpdateListener(value: self))
        R.delegates.append(WeakRefereeUpdateListener(value: self))
        addListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        timer.invalidate()
        H.delegates = H.delegates.filter { $0.value != nil }
        T.delegates = T.delegates.filter { $0.value != nil }
        R.delegates = R.delegates.filter { $0.value != nil }
    }
    
    private func addListener(){
        guard let referee = UserData.readReferee("referee") else { return }
        
        H.listenHost(gameCode, onListenerUpdate: listen(_:))
        T.listenTeams(gameCode, onListenerUpdate: listen(_:))
        R.listenReferee(gameCode, referee.uuid , onListenerUpdate: listen(_:))
    }
    
    func updateReferee(_ referee: Referee) {
        let data: [String:Referee] = ["referee":referee]
        if (!referee.assigned) {
            print("popToWaiting treggered")
            navigationController?.popToWaitingViewController(animated: true)
        }
        NotificationCenter.default.post(name: .refereeUpdate, object: nil, userInfo: data)
    }
    
    func updateHost(_ host: Host) {
        if host.gameover {
            showAwardPopUp("referee")
        } else {
            let data: [String:Host] = ["host":host]
            NotificationCenter.default.post(name: .hostUpdate, object: nil, userInfo: data)
            
            if RefereeTabBarPVEController.localMessages.count > host.announcements.count {
                removeAnnouncementsNotInHost(from: &RefereeTabBarPVEController.localMessages, targetArray: host.announcements)
                NotificationCenter.default.post(name: .newDataNotif, object: nil, userInfo: nil)
            } else {
                // compare server announcements and local announcements
                for announcement in host.announcements {
                    let ids: [String] = RefereeTabBarPVEController.localMessages.map({ $0.uuid })
                    // new announcements
                    if !ids.contains(announcement.uuid) {
                        RefereeTabBarPVEController.localMessages.append(announcement)
                        if soundEnabled {
                            self.audioPlayerManager.playAudioFile(named: "message", withExtension: "wav")
                        }
                        NotificationCenter.default.post(name: .announceNoti, object: nil, userInfo: nil)
                    } else {
                        // modified announcements
                        if let localIndex = RefereeTabBarPVEController.localMessages.firstIndex(where: {$0.uuid == announcement.uuid}) {
                            if RefereeTabBarPVEController.localMessages[localIndex].content != announcement.content {
                                RefereeTabBarPVEController.localMessages[localIndex].content = announcement.content
                                RefereeTabBarPVEController.localMessages[localIndex].readStatus = false
                                if soundEnabled {
                                    self.audioPlayerManager.playAudioFile(named: "message", withExtension: "wav")
                                }
                                NotificationCenter.default.post(name: .announceNoti, object: nil, userInfo: nil)
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    func updateTeams(_ teams: [Team]) {
        let data: [String:[Team]] = ["teams":teams]
        NotificationCenter.default.post(name: .teamsUpdate, object: nil, userInfo: data)
    }
    
    func listen(_ _ : [String : Any]){
    }
}
