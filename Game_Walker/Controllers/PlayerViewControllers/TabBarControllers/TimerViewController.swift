//
//  PlayerFrame4_3.swift
//  Game_Walker
//
//  Created by Noah Kim on 6/17/22.
//

import Foundation
import UIKit
import AVFoundation

class TimerViewController: UIViewController {
    
    @IBOutlet weak var gameInfoButton: UIButton!
    @IBOutlet weak var nextGameButton: UIButton!
    @IBOutlet weak var announcementButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    private var messages: [String] = []
    
    private let readAll = UIImage(named: "announcement")
    private let unreadSome = UIImage(named: "unreadMessage")
    
    private var host : Host = Host()
    private var team : Team = Team()
    private var stations : [Station] = [Station()]
    private var startTime : Int = 0
    private var pauseTime : Int = 0
    private var pausedTime : Int = 0
    private var timer = Timer()
    private var remainingTime: Int = 0
    private var totalTime: Int = 0
    private var time: Int?
    private var seconds: Int = 0
    private var moveSeconds: Int = 0
    private var moving: Bool = true
    private var tapped: Bool = false
    private var round: Int = 1
    private var rounds: Int?
    private var isPaused = true
    private var t : Int = 0
    
    private var gameCode: String = UserData.readGamecode("gamecode") ?? ""
    private var stationOrder : [Int] = []
    
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
    
    private let audioPlayerManager = AudioPlayerManager()
    
    private let timerCircle: UILabel = {
        var view = UILabel()
        view.clipsToBounds = true
        view.frame = CGRect(x: 0, y: 0, width: 256, height: 256)
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0.6
        view.layer.borderWidth = 15
        view.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        view.layer.cornerRadius = 0.68 * UIScreen.main.bounds.size.width / 2.0
        return view
    }()
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Regular", size: 55)
        label.numberOfLines = 0
        return label
    }()
    
    private let timeTypeLabel: UILabel = {
        let label = UILabel()
        label.text = "Moving Time"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Regular", size: 35)
        label.numberOfLines = 1
        return label
    }()
    
    private let roundLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Regular", size: 35)
        label.numberOfLines = 1
        label.alpha = 0.0
        return label
    }()
    
    private let totalTimeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.alpha = 0.0
        return label
    }()
    
    private lazy var gameCodeLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 127, height: 31)
        let attributedText = NSMutableAttributedString()
        let gameCodeAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 15) ?? UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.black
        ]
        let gameCodeAttributedString = NSAttributedString(string: "Game Code" + "\n", attributes: gameCodeAttributes)
        attributedText.append(gameCodeAttributedString)
        let numberAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 10) ?? UIFont.systemFont(ofSize: 25),
            .foregroundColor: UIColor.black
        ]
        let numberAttributedString = NSAttributedString(string: gameCode, attributes: numberAttributes)
        attributedText.append(numberAttributedString)
        label.backgroundColor = .white
        label.attributedText = attributedText
        label.textColor = UIColor(red: 0, green: 0, blue: 0 , alpha: 1)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
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
        Task {
            callProtocols()
            configureGamecodeLabel()
            host = try await H.getHost2(gameCode) ?? Host()
            team = try await T.getTeam2(gameCode, UserData.readTeam("team")?.name ?? "") ?? Team()
            stations = try await S.getStationList2(gameCode)
            setSettings()
            configureTimerLabel()
        }
    }
    
    @objc func readAll(notification: Notification) {
        guard let isRead = notification.userInfo?["isRead"] as? Bool else {
            return
        }
        if isRead {
            self.announcementButton.setImage(self.readAll, for: .normal)
        } else {
            self.announcementButton.setImage(self.unreadSome, for: .normal)
            self.audioPlayerManager.playAudioFile(named: "message", withExtension: "wav")
        }
    }
    
    @IBAction func gameInfoButtonPressed(_ sender: UIButton) {
        self.audioPlayerManager.playAudioFile(named: "blue", withExtension: "wav")
        findStation()
        showGameInfoPopUp(gameName: gameName, gameLocation: gameLocation, gamePoitns: gamePoints, refereeName: refereeName, gameRule: gameRule)
    }
    
    @IBAction func nextGameButtonPressed(_ sender: UIButton) {
        self.audioPlayerManager.playAudioFile(named: "blue", withExtension: "wav")
        findStation()
        showGameInfoPopUp(gameName: nextGameName, gameLocation: nextGameLocation, gamePoitns: nextGamePoints, refereeName: nextRefereeName, gameRule: nextGameRule)
    }
    
    @IBAction func announcementButtonPressed(_ sender: UIButton) {
        showMessagePopUp(messages: TeamViewController.messages)
    }
    
    @IBAction func settingButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func infoButtonPressed(_ sender: UIButton) {
        showOverlay()
    }
    
    private func showOverlay() {
        let overlayViewController = OverlayViewController()
        overlayViewController.modalPresentationStyle = .overFullScreen // Present it as overlay
        
        let explanationTexts = ["press the circle to see how it changes", "check to see the members in your team", "check to see the ranking", "check to see the timer"]
        var componentPositions: [CGPoint] = []
        let component1Frame = timerCircle.frame
        componentPositions.append(CGPoint(x: component1Frame.midX, y: component1Frame.minY))
        var tabBarTop: CGFloat = 0
        if let tabBarController = self.tabBarController {
            // Loop through each view controller in the tab bar controller
            for viewController in tabBarController.viewControllers ?? [] {
                if let tabItem = viewController.tabBarItem {
                    // Access the tab bar item of the current view controller
                    if let tabItemView = tabItem.value(forKey: "view") as? UIView {
                        let tabItemFrame = tabItemView.frame
                        // Calculate centerX position
                        let centerXPosition = tabItemFrame.midX
                        // Calculate topAnchor position based on tab bar's frame
                        let tabBarFrame = tabBarController.tabBar.frame
                        let topAnchorPosition = tabItemFrame.minY + tabBarFrame.origin.y
                        if (tabBarTop == 0) {
                            tabBarTop = topAnchorPosition
                        }
                        componentPositions.append(CGPoint(x: centerXPosition, y: topAnchorPosition))
                    }
                }
            }
        }
        print(componentPositions)
        overlayViewController.showExplanationLabels(explanationTexts: explanationTexts, componentPositions: componentPositions, numberOfLabels: 4, tabBarTop: tabBarTop)
        
        present(overlayViewController, animated: true, completion: nil)
    }

    
    private func configureAnnouncementbuttonImage(){
        announcementButton.setImage(readAll, for: .normal)
    }
    
    private func configureGamecodeLabel() {
        view.addSubview(gameCodeLabel)
        NSLayoutConstraint.activate([
            gameCodeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            gameCodeLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.058),
            gameCodeLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.04),
            gameCodeLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.2)
        ])
    }
    
// MARK: - Timer
    func findStation() {
        for station in self.stations {
            if station.number == self.team.stationOrder[round - 1] {
                self.gameName = station.name
                self.gameLocation = station.place
                self.gamePoints = String(station.points)
                self.refereeName = station.referee!.name
                self.gameRule = station.description
            }
            else if station.number == self.team.stationOrder[round] {
                self.nextGameName = station.name
                self.nextGameLocation = station.place
                self.nextGamePoints = String(station.points)
                self.nextRefereeName = station.referee!.name
                self.nextGameRule = station.description
            }
        }
    }
    
    func configureTimerLabel() {
        self.view.addSubview(timerCircle)
        self.view.addSubview(timerLabel)
        self.view.addSubview(timeTypeLabel)
        self.view.addSubview(roundLabel)
        self.view.addSubview(totalTimeLabel)
        NSLayoutConstraint.activate([
            timerCircle.centerXAnchor.constraint(equalTo: self.view.layoutMarginsGuide.centerXAnchor),
            timerCircle.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.18),
            timerCircle.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.68),
            timerCircle.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.68),
            
            timerLabel.centerXAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.centerXAnchor),
            timerLabel.topAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.topAnchor, constant: self.timerCircle.bounds.height * 0.39),
            timerLabel.widthAnchor.constraint(equalTo: self.timerCircle.widthAnchor, multiplier: 0.70),
            timerLabel.heightAnchor.constraint(equalTo: self.timerCircle.heightAnchor, multiplier: 0.36),
            
            timeTypeLabel.centerXAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.centerXAnchor),
            timeTypeLabel.topAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.topAnchor, constant: self.timerCircle.bounds.height * 0.29),
            timeTypeLabel.widthAnchor.constraint(equalTo: self.timerCircle.widthAnchor, multiplier: 0.656),
            timeTypeLabel.heightAnchor.constraint(equalTo: self.timerCircle.heightAnchor, multiplier: 0.17),
            
            roundLabel.centerXAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.centerXAnchor),
            roundLabel.topAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.topAnchor, constant: self.timerCircle.bounds.height * 0.32),
            roundLabel.widthAnchor.constraint(equalTo: self.timerCircle.widthAnchor, multiplier: 0.605),
            roundLabel.heightAnchor.constraint(equalTo: self.timerCircle.heightAnchor, multiplier: 0.17),
            
            totalTimeLabel.centerXAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.centerXAnchor),
            totalTimeLabel.topAnchor.constraint(equalTo: self.timerCircle.layoutMarginsGuide.topAnchor, constant: self.timerCircle.bounds.height * 0.547),
            totalTimeLabel.widthAnchor.constraint(equalTo: self.timerCircle.widthAnchor, multiplier: 0.38),
            totalTimeLabel.heightAnchor.constraint(equalTo: self.timerCircle.heightAnchor, multiplier: 0.19)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
        timerCircle.addGestureRecognizer(tapGesture)
        timerCircle.isUserInteractionEnabled = true
        calculateTime()
        runTimer()
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let strongSelf = self else {
                return
            }
            if !strongSelf.isPaused {
                if strongSelf.rounds! < 1 {
                    strongSelf.audioPlayerManager.stop()
                    timer.invalidate()
                }
                if strongSelf.remainingTime <= 5 {
                    strongSelf.audioPlayerManager.playAudioFile(named: "timer_end", withExtension: "wav")
                }
                if strongSelf.time! < 1 {
                    if strongSelf.moving {
                        strongSelf.time = strongSelf.seconds
                        strongSelf.moving = false
                        strongSelf.timeTypeLabel.text = "Game Time"
                    } else {
                        strongSelf.time = strongSelf.moveSeconds
                        strongSelf.moving = true
                        strongSelf.timeTypeLabel.text = "Moving Time"
                        strongSelf.roundLabel.text = "Round \(strongSelf.round)"
                        strongSelf.rounds! -= 1
                    }
                }
                strongSelf.time! -= 1
                let minute = strongSelf.time!/60
                let second = strongSelf.time! % 60
                strongSelf.timerLabel.text = String(format:"%02i : %02i", minute, second)
                strongSelf.totalTime += 1
                let totalMinute = strongSelf.totalTime/60
                let totalSecond = strongSelf.totalTime % 60
                let attributedString = NSMutableAttributedString(string: "Total time\n", attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 20) ?? UIFont(name: "Dosis-Regular", size: 20)!])
                attributedString.append(NSAttributedString(string: String(format:"%02i : %02i", totalMinute, totalSecond), attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 15) ?? UIFont(name: "Dosis-Regular", size: 15)!]))
                strongSelf.totalTimeLabel.attributedText = attributedString
            }
        }
        
    }
    
    func calculateTime() {
        if isPaused {
            t = pauseTime - startTime - pausedTime
        }
        else {
            if pausedTime != 0 {
                t = Int(Date().timeIntervalSince1970) - startTime - pausedTime
            }
            else {
                t = 0
            }
        }
        let remainder = t%(moveSeconds + seconds)
        if (remainder/moveSeconds) == 0 {
            self.timeTypeLabel.text = "Moving Time"
            self.time = (moveSeconds - remainder)
            self.moving = true
            let minute = (moveSeconds - remainder)/60
            let second = (moveSeconds - remainder) % 60
            self.timerLabel.text = String(format:"%02i : %02i", minute, second)
        }
        else {
            self.timeTypeLabel.text = "Game Time"
            self.time = (seconds - remainder)
            self.moving = false
            let minute = (seconds - remainder)/60
            let second = (seconds - remainder) % 60
            self.timerLabel.text = String(format:"%02i : %02i", minute, second)
        }
        self.totalTime = t
        let totalMinute = t/60
        let totalSecond = t % 60
        let attributedString = NSMutableAttributedString(string: "Total time\n", attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 20) ?? UIFont(name: "Dosis-Regular", size: 20)!])
        attributedString.append(NSAttributedString(string: String(format:"%02i : %02i", totalMinute, totalSecond), attributes: [NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 15) ?? UIFont(name: "Dosis-Regular", size: 15)!]))
        self.totalTimeLabel.attributedText = attributedString
        self.rounds! = self.rounds! - self.round
        self.roundLabel.text = "Round \(self.round)"
    }
    
    @objc func buttonTapped(_ gesture: UITapGestureRecognizer) {
        if !tapped {
            timerCircle.layer.borderColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1).cgColor
            timerLabel.alpha = 0.0
            timeTypeLabel.alpha = 0.0
            roundLabel.alpha = 1.0
            totalTimeLabel.alpha = 1.0
            tapped = true
        } else {
            timerCircle.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
            timerLabel.alpha = 1.0
            timeTypeLabel.alpha = 1.0
            roundLabel.alpha = 0.0
            totalTimeLabel.alpha = 0.0
            tapped = false
        }
    }
    
    func timeString(time:TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i : %02i", minutes, seconds)
    }
}
//MARK: - UIUpdate
extension TimerViewController: HostUpdateListener {
    func updateHost(_ host: Host) {
        self.round = host.currentRound
        self.pauseTime = host.pauseTimestamp
        self.pausedTime = host.pausedTime
    }
    
    func listen(_ _ : [String : Any]){
    }
    
    func callProtocols() {
        H.delegates.append(self)
        H.listenHost(gameCode, onListenerUpdate: listen(_:))
    }
    
    func setSettings() {
        self.seconds = host.gameTime
        self.moveSeconds = host.movingTime
        self.startTime = host.startTimestamp
        self.isPaused = host.paused
        self.pauseTime = host.pauseTimestamp
        self.pausedTime = host.pausedTime
        self.rounds = host.rounds
        self.remainingTime = host.rounds * (host.gameTime + host.movingTime)
        self.round = host.currentRound
        self.messages = host.announcements
    }
}
