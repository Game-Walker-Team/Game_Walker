//
//  RefereePVEController.swift
//  Game_Walker
//
//  Created by 김현식 on 1/27/23.
//

import Foundation
import UIKit

class RefereePVEController: BaseViewController {
    
    @IBOutlet weak var stationinfoButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    var stationName = ""
    var time : Int = 0
    var movingTime : Int = 0
    var gameTime : Int = 0
    var gameCode = UserData.readGamecode("refereeGamecode")!
    var referee = UserData.readReferee("Referee")!
    var paused : Bool = false
    var moving : Bool = true
    var timer : Timer?
    var index = 0
    var team : Team = Team(gamecode: UserData.readReferee("Referee")!.gamecode, name: "Simon Dominic", number: 4, players: [], points: 0, currentStation: "testingPVE", nextStation: "", iconName: "iconAir")
    var teamOrder : [Team] = [Team(gamecode: UserData.readReferee("Referee")!.gamecode, name: "Simon Dominic", number: 4, players: [], points: 0, currentStation: "testingPVE", nextStation: "", iconName: "iconAir")]
    
    private let readAll = UIImage(named: "announcement")
    private let unreadSome = UIImage(named: "unreadMessage")
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(readAll(notification:)), name: RefereeRankingPVEViewController.notificationName, object: nil)
        if RefereeRankingPVEViewController.read {
            self.messageButton.setImage(readAll, for: .normal)
        } else {
            self.messageButton.setImage(unreadSome, for: .normal)
        }
    }
    
    @objc func readAll(notification: Notification) {
        guard let isRead = notification.userInfo?["isRead"] as? Bool else {
            return
        }
        if isRead {
            //self.announcementButton.setImage(self.readAll, for: .normal)
        } else {
            //self.announcementButton.setImage(self.unreadSome, for: .normal)
        }
    }
    
    override func viewDidLoad() {
        
        H.delegate_getHost = self
        H.delegates.append(self)
        S.delegate_getStation = self
        T.delegates.append(self)
        H.getHost(gameCode)
        H.listenHost(gameCode, onListenerUpdate: listen(_:))
        S.getStation(gameCode, "testingPVE")
        T.listenTeams(gameCode, onListenerUpdate: listen(_:))
        
        Task {
            try await Task.sleep(nanoseconds: 350_000_000)
            self.team = self.teamOrder[index]
            super.viewDidLoad()
            self.view.addSubview(roundLabel)
            self.view.addSubview(borderView)
            self.view.addSubview(iconButton)
            self.view.addSubview(teamNumber)
            self.view.addSubview(teamName)
            self.view.addSubview(timerLabel)
            self.view.addSubview(scoreLabel)
            self.view.addSubview(timetypeLabel)
            
            borderView.translatesAutoresizingMaskIntoConstraints = false
            borderView.widthAnchor.constraint(equalToConstant: 211).isActive = true
            borderView.heightAnchor.constraint(equalToConstant: 306).isActive = true
            borderView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            borderView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 187).isActive = true
            iconButton.translatesAutoresizingMaskIntoConstraints = false
            iconButton.widthAnchor.constraint(equalToConstant: 175).isActive = true
            iconButton.heightAnchor.constraint(equalToConstant: 175).isActive = true
            iconButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            iconButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 200).isActive = true
            teamNumber.translatesAutoresizingMaskIntoConstraints = false
            teamNumber.widthAnchor.constraint(equalToConstant: 115).isActive = true
            teamNumber.heightAnchor.constraint(equalToConstant: 38).isActive = true
            teamNumber.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            teamNumber.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 382).isActive = true
            teamName.translatesAutoresizingMaskIntoConstraints = false
            teamName.widthAnchor.constraint(equalToConstant: 174).isActive = true
            teamName.heightAnchor.constraint(equalToConstant: 38).isActive = true
            teamName.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            teamName.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 411).isActive = true
            roundLabel.translatesAutoresizingMaskIntoConstraints = false
            roundLabel.widthAnchor.constraint(equalToConstant: 149.17).isActive = true
            roundLabel.heightAnchor.constraint(equalToConstant: 61).isActive = true
            roundLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            roundLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 101).isActive = true
            timerLabel.translatesAutoresizingMaskIntoConstraints = false
            timerLabel.widthAnchor.constraint(equalToConstant: 179).isActive = true
            timerLabel.heightAnchor.constraint(equalToConstant: 73).isActive = true
            timerLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            timerLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 575).isActive = true
            scoreLabel.translatesAutoresizingMaskIntoConstraints = false
            scoreLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
            scoreLabel.heightAnchor.constraint(equalToConstant: 53).isActive = true
            scoreLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            scoreLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 440).isActive = true
            timetypeLabel.translatesAutoresizingMaskIntoConstraints = false
            timetypeLabel.widthAnchor.constraint(equalToConstant: 168).isActive = true
            timetypeLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
            timetypeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            timetypeLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 520).isActive = true
            
            runTimer()
        }
    }
//MARK: - UI elements
    private lazy var borderView: UIView = {
        var view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 211, height: 306)
        view.backgroundColor = .white
        var border = UIView()
        border.bounds = view.bounds.insetBy(dx: -5, dy: -5)
        border.center = view.center
        view.addSubview(border)
        view.bounds = view.bounds.insetBy(dx: -5, dy: -5)
        border.layer.borderWidth = 5
        border.layer.borderColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 0.5).cgColor
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
        border.addGestureRecognizer(tapGesture)
        border.isUserInteractionEnabled = true
        return view
    }()

    private lazy var iconButton: UIButton = {
        var button = UIButton(frame: CGRect(x: 0, y: 0, width: 175, height: 175))
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: teamOrder[index].iconName), for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var teamNumber: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 115, height: 38)
        view.backgroundColor = .white
        view.textColor = .black
        view.font = UIFont(name: "Dosis-SemiBold", size: 25)
        view.textAlignment = .center
        view.text = "Team " + "\(self.teamOrder[index].number)"
        return view
    }()
    
    private lazy var teamName: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 174, height: 38)
        view.backgroundColor = .white
        view.textColor = .black
        view.font = UIFont(name: "Dosis-Regular", size: 25)
        view.textAlignment = .center
        view.text = teamOrder[index].name
        return view
    }()
    
    private lazy var scoreLabel: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 150, height: 53)
        view.backgroundColor = .white
        view.textColor = .black
        view.font = UIFont(name: "Dosis-Bold", size: 50)
        view.textAlignment = .center
        view.text = "\(teamOrder[index].points)"
        return view
    }()
    
    private lazy var roundLabel: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 149.17, height: 61)
        view.backgroundColor = .white
        view.textColor = .black
        view.font = UIFont(name: "Dosis-SemiBold", size: 45)
        view.textAlignment = .center
        view.text = "Round " + "\(index + 1)"
        return view
    }()
    
    private lazy var timerLabel: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 179, height: 53)
        view.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        view.font = UIFont(name: "Dosis-Regular", size: 55)
        view.textAlignment = .center
        return view
    }()
    
    private lazy var timetypeLabel: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 151, height: 44)
        view.backgroundColor = .white
        view.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        view.font = UIFont(name: "Dosis-Regular", size: 35)
        view.textAlignment = .center
        view.text = "Moving Time"
        return view
    }()
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(RefereePVEController.updateTimer)), userInfo: nil, repeats: true)
    }
        
    @objc func updateTimer() {
        if time < 1 {
            if moving {
                time = gameTime
                moving = false
            } else {
                time = movingTime
                moving = true
                index += 1
                teamNumber.text = "Team " + "\(self.teamOrder[index].number)"
                teamName.text = teamOrder[index].name
                roundLabel.text = "Round " + "\(index + 1)"
                iconButton.setImage(UIImage(named: teamOrder[index].iconName), for: .normal)
                self.team = self.teamOrder[index]
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
    
    @IBAction func stationinfoButtonPressed(_ sender: Any) {
        showRefereeGameInfoPopUp()
    }
    
    @IBAction func messageButtonPressed(_ sender: Any) {
        showRefereeMessagePopUp(messages: RefereeRankingPVEViewController.messages)
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        
    }
        
    @objc func buttonTapped() {
        UserData.writeTeam(team, "Team")
        let popUpWindow = GivePointsController(team: UserData.readTeam("Team")!, gameCode: UserData.readGamecode("refereeGamecode")!)
        self.present(popUpWindow, animated: true, completion: nil)
    }
    
    func listen(_ _ : [String : Any]){
    }
}

//MARK: - GetStation
extension RefereePVEController: GetStation {
    func getStation(_ station: Station) {
        self.stationName = station.name
        self.teamOrder = station.teamOrder
    }
}
//MARK: - GetHost
extension RefereePVEController: GetHost {
    func getHost(_ host: Host) {
        self.time = host.movingTime
        self.movingTime = host.movingTime
        self.gameTime = host.gameTime
    }
}
// MARK: - TeamUpdateListener
extension RefereePVEController: TeamUpdateListener {
    func updateTeams(_ teams: [Team]) {
        for team in teams {
            if team.name == self.team.name {
                self.team = team
            }
        }
        scoreLabel.text = "\(self.team.points)"
    }
}
// MARK: - HostUpdateListener
extension RefereePVEController: HostUpdateListener {
    func updateHost(_ host: Host) {
        self.paused = host.paused
    }
}
