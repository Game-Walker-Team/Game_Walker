//
//  PlayerFrame4_3.swift
//  Game_Walker
//
//  Created by Noah Kim on 6/17/22.
//

import Foundation
import UIKit

class TimerViewController: UIViewController {
    
    @IBOutlet weak var gameInfoButton: UIButton!
    @IBOutlet weak var nextGameButton: UIButton!
    @IBOutlet weak var announcementButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    
    private let readAll = UIImage(named: "announcement")
    private let unreadSome = UIImage(named: "unreadMessage")
    
    private var timer = Timer()
    var time : Int = 0
    var movingTime : Int = 0
    var gameTime : Int = 0
    var paused : Bool = false
    var moving : Bool = true
    
    private var gameCode: String = UserData.readGamecode("gamecode") ?? ""
    private var stationName: String = UserData.readTeam("team")?.currentStation ?? ""
    
    private var gameName: String?
    private var gameLocation: String?
    private var gamePoints: String?
    private var refereeName: String?
    private var gameRule: String?
    
    private var nextGameName: String?
    private var nextGameLocation: String?
    private var nextGamePoints: String?
    private var nextRefereeName: String?
    private var nextGameRule: String?
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Regular", size: 55)
        label.numberOfLines = 0
        label.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        label.layer.borderWidth = 4
        label.layer.cornerRadius = 130
        return label
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(readAll(notification:)), name: TeamViewController.notificationName, object: nil)
        if TeamViewController.read {
            self.announcementButton.setImage(readAll, for: .normal)
        } else {
            self.announcementButton.setImage(unreadSome, for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        S.delegate_getStation = self
        //S.getStation(gameCode, stationName)
        H.delegates.append(self)
        H.listenHost(gameCode, onListenerUpdate: listen(_:))
        Task {
            try await Task.sleep(nanoseconds: 280_000_000)
            print(gameTime)
            configureTimerLabel()
        }
        runTimer()
    }
    
    @objc func readAll(notification: Notification) {
        guard let isRead = notification.userInfo?["isRead"] as? Bool else {
            return
        }
        if isRead {
            self.announcementButton.setImage(self.readAll, for: .normal)
        } else {
            self.announcementButton.setImage(self.unreadSome, for: .normal)
        }
    }
    
    @IBAction func gameInfoButtonPressed(_ sender: UIButton) {
        showGameInfoPopUp(gameName: gameName, gameLocation: gameLocation, gamePoitns: gamePoints, refereeName: refereeName, gameRule: gameRule)
    }
    
    @IBAction func nextGameButtonPressed(_ sender: UIButton) {
//        showGameInfoPopUp(gameName: nextGameName, gameLocation: nextGameLocation, gamePoitns: nextGamePoints, refereeName: nextRefereeName, gameRule: nextGameRule)
    }
    
    @IBAction func announcementButtonPressed(_ sender: UIButton) {
        H.getHost(gameCode)
        showMessagePopUp(messages: TeamViewController.messages)
    }
    
    @IBAction func settingButtonPressed(_ sender: UIButton) {
    }
    
    func configureAnnouncementbuttonImage(){
            announcementButton.setImage(readAll, for: .normal)
    }
    
    func configureTimerLabel(){
        self.view.addSubview(timerLabel)
        NSLayoutConstraint.activate([
            timerLabel.centerXAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerYAnchor, constant: -120),
            timerLabel.widthAnchor.constraint(equalToConstant: 260),
            timerLabel.heightAnchor.constraint(equalToConstant: 260)
        ])
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(TimerViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if time < 1 {
            if moving {
                time = gameTime
                moving = false
            } else {
                time = movingTime
                moving = true
                
            }
        } else {
            if !paused {
                time -= 1
            }
            timerLabel.text = timeString(time: TimeInterval(time))
        }
    }
    
    func timeString(time:TimeInterval) -> String {
            let minutes = Int(time) / 60 % 60
            let seconds = Int(time) % 60
            return String(format:"%02i : %02i", minutes, seconds)
    }
    
    func listen(_ _ : [String : Any]){
    }
}
//MARK: - UIUpdate
extension TimerViewController: GetStation, HostUpdateListener {
    func updateHost(_ host: Host) {
        self.gameTime = host.gameTime
        self.movingTime = host.movingTime
        self.paused = host.paused
    }
    
    func getStation(_ station: Station) {
        self.gameName = station.name
        self.gameLocation = station.place
        self.gamePoints = String(station.points)
        self.refereeName = station.referee?.name
        self.gameRule = station.description
    }
}
