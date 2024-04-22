//
//  RefereePVEController.swift
//  Game_Walker
//
//  Created by 김현식 on 1/27/23.
//

import Foundation
import UIKit
import AVFoundation

class RefereePVEController: UIViewController {
    
    private let readAll = UIImage(named: "messageIcon")
    private let unreadSome = UIImage(named: "unreadMessage")
    
    private var gameStart: Bool = false
    private var teamOrderSet: Bool = false
    
    private var max : String = ""
    private var team : Team = Team()
    private var maxA : String = ""
    private var maxB : String = ""
    private var teamA : Team = Team()
    private var teamB : Team = Team()

    private var station : Station = Station()
    private var algorithm : [[Int]] = []
    
    private var teamOrder : [Team] = [Team(), Team()]
    private var round : Int = 1
    private var points : Int = 0
    private var number : Int = -1
    private var count : Int = -2
    
    private var pvp: Bool = false
    
    private var gameCode = UserData.readGamecode("gamecode")!
    private var referee = UserData.readReferee("referee")!
    private var stations : [Station] = [Station(), Station()]
    private var teams : [Team] = []
    private var host: Host = Host()
    
    //MARK: - View Life Cycle Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
        guard let items = self.navigationItem.rightBarButtonItems else {return}
        let unread = RefereeTabBarController.unread
        if unread {
            for barButtonItem in items {
                if let btn = barButtonItem.customView as? UIButton, btn.tag == 120 {
                    btn.setImage(self.unreadSome, for: .normal)
                    break
                }
            }
        } else {
            for barButtonItem in items {
                if let btn = barButtonItem.customView as? UIButton, btn.tag == 120 {
                    btn.setImage(self.readAll, for: .normal)
                    break
                }
            }
        }
    }
    
    override func viewDidLoad() {
        Task { @MainActor in
            do {
                stations = try await S.getStationList(gameCode)
                teams = try await T.getTeamList(gameCode)
                host = try await H.getHost(gameCode) ?? Host()
                round = host.currentRound
            } catch GameWalkerError.serverError(let message) {
                serverAlert(message)
                return
            }
            for station in stations {
                if station.name == referee.stationName {
                    pvp = station.pvp
                }
            }
            if pvp {
                maxA = UserData.readMax("maxA") ?? ""
                maxB = UserData.readMax("maxB") ?? ""
                if maxA == "true" {
                    leftWinButton.layer.backgroundColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1).cgColor
                    leftLoseButton.layer.backgroundColor = UIColor(red: 0.721, green: 0.721, blue: 0.721, alpha: 1).cgColor
                } else if maxA == "false" {
                    leftWinButton.layer.backgroundColor = UIColor(red: 0.721, green: 0.721, blue: 0.721, alpha: 1).cgColor
                    leftLoseButton.layer.backgroundColor = UIColor(red: 0.942, green: 0.71, blue: 0.114, alpha: 1).cgColor
                } else {
                    leftWinButton.layer.backgroundColor = UIColor(red: 0.721, green: 0.721, blue: 0.721, alpha: 1).cgColor
                    leftLoseButton.layer.backgroundColor = UIColor(red: 0.721, green: 0.721, blue: 0.721, alpha: 1).cgColor
                }
                if maxB == "true" {
                    rightWinButton.layer.backgroundColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1).cgColor
                    rightLoseButton.layer.backgroundColor = UIColor(red: 0.721, green: 0.721, blue: 0.721, alpha: 1).cgColor
                } else if maxB == "false" {
                    rightWinButton.layer.backgroundColor = UIColor(red: 0.721, green: 0.721, blue: 0.721, alpha: 1).cgColor
                    rightLoseButton.layer.backgroundColor = UIColor(red: 0.942, green: 0.71, blue: 0.114, alpha: 1).cgColor
                } else {
                    rightWinButton.layer.backgroundColor = UIColor(red: 0.721, green: 0.721, blue: 0.721, alpha: 1).cgColor
                    rightLoseButton.layer.backgroundColor = UIColor(red: 0.721, green: 0.721, blue: 0.721, alpha: 1).cgColor
                }
            } else {
                max = UserData.readMax("max") ?? ""
                if max == "true" {
                    winButton.layer.backgroundColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1).cgColor
                    loseButton.layer.backgroundColor = UIColor(red: 0.721, green: 0.721, blue: 0.721, alpha: 1).cgColor
                } else if max == "false" {
                    winButton.layer.backgroundColor = UIColor(red: 0.721, green: 0.721, blue: 0.721, alpha: 1).cgColor
                    loseButton.layer.backgroundColor = UIColor(red: 0.942, green: 0.71, blue: 0.114, alpha: 1).cgColor
                } else {
                    winButton.layer.backgroundColor = UIColor(red: 0.721, green: 0.721, blue: 0.721, alpha: 1).cgColor
                    loseButton.layer.backgroundColor = UIColor(red: 0.721, green: 0.721, blue: 0.721, alpha: 1).cgColor
                }
            }
            if host.algorithm != [] && host.teams == teams.count && host.gameStart && !host.gameover {
                setTeamOrder()
                if pvp {
                    combineSubviewsPVP()
                    combineConstraintsPVP()
                } else {
                    combineSubviewsPVE()
                    combineConstraintsPVE()
                }
            } else {
                if pvp {
                    addSubviewsPVP()
                    addConstraintsPVP()
                } else {
                    addSubviewsPVE()
                    addConstraintsPVE()
                }
            }
        }
        super.viewDidLoad()
        tabBarController?.navigationController?.isNavigationBarHidden = true
        configureNavigationBar()
        configureLeaveBtn()
    }
// MARK: - ETC
    
    func configureLeaveBtn() {
        let leaveBtn = UIButton()
        leaveBtn.setTitle(NSLocalizedString("LEAVE", comment: ""), for: .normal)
        leaveBtn.titleLabel?.font = UIFont(name: "GemunuLibre-Bold", size: 25)
        leaveBtn.setTitleColor(UIColor(red: 1, green: 0.046, blue: 0.046, alpha: 1), for: .normal)
        leaveBtn.addTarget(self, action: #selector(leaveAction), for: .touchUpInside)
        let leave = UIBarButtonItem(customView: leaveBtn)
        self.navigationItem.leftBarButtonItem = leave
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(hostUpdate), name: .hostUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(teamsUpdate), name: .teamsUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(readAll(notification:)), name: .readNotification, object: nil)
    }
//MARK: - Team Order
    func setTeamOrder() {
        var pvp_count : Int = 0
        var column_number_index : Int = 0
        var teamNumOrder : [Int] = []
        var teamOrder : [Team] = []
        Task {
            let stationList = try await S.getStationList(gameCode)
            let teams = try await T.getTeamList(gameCode)
            for station in stationList {
                if referee.name == station.referee?.name {
                    self.station = station
                    self.points = station.points
                }
                if station.pvp == true {
                    pvp_count += 1
                }
            }
            if self.station.pvp {
                column_number_index = 2 * station.number - 2
                let left = self.algorithm.map({ $0[column_number_index] })
                let right = self.algorithm.map({ $0[column_number_index + 1] })
                var right_index : Int = 0
                for left_index in left {
                    teamNumOrder.append(left_index)
                    teamNumOrder.append(right[right_index])
                    right_index += 1
                }
            }
            else {
                column_number_index = 2 * pvp_count + station.number - pvp_count - 1
                teamNumOrder = self.algorithm.map({ $0[column_number_index] })
            }
            for team_num in teamNumOrder {
                if team_num == 0 {
                    teamOrder.append(Team())
                }
                for team in teams {
                    if team_num == team.number {
                        teamOrder.append(team)
                    }
                }
            }
            self.teamOrder = teamOrder
            do {
                try await S.updateTeamOrder(gameCode, self.station.uuid, self.teamOrder)
            }
            catch GameWalkerError.serverError(let message) {
                print(message)
                serverAlert(message)
                return
            }
            updateScore()
            if pvp {
                modifyViewsPVP()
                newConstraintsPVP()
            } else {
                modifyViewsPVE()
                newConstraintsPVE()
            }
        }
    }
    
//MARK: - Overlay
    private func showOverlay(pvp: Bool, components: [UIView]) {
        let overlayViewController = RefereeGuideViewController(pvp: pvp)
        overlayViewController.modalPresentationStyle = .overFullScreen
        let explanationTexts = [
            NSLocalizedString("Station\nStatus", comment: ""),
            NSLocalizedString("Ranking\nStatus", comment: ""),
            NSLocalizedString("Timer &\nStation Info", comment: "")
        ]

        var componentPositions: [CGPoint] = []
        var componentFrames: [CGRect] = []
        var tabBarTop: CGFloat = 0
        if let tabBarController = self.tabBarController {
            for viewController in tabBarController.viewControllers ?? [] {
                if let tabItem = viewController.tabBarItem {
                    if let tabItemView = tabItem.value(forKey: "view") as? UIView {
                        let tabItemFrame = tabItemView.frame
                        let centerXPosition = tabItemFrame.midX
                        let tabBarFrame = tabBarController.tabBar.frame
                        let topAnchorPosition = tabItemFrame.minY + tabBarFrame.origin.y
                        tabBarTop = tabBarFrame.minY
                        componentFrames.append(tabItemFrame)
                        componentPositions.append(CGPoint(x: centerXPosition, y: topAnchorPosition))
                    }
                }
            }
        }
        for component in components {
            let frame = CGRect(x: component.frame.minX, y: component.frame.minY, width: component.frame.width, height: component.frame.height)
            let position = CGPoint(x: component.frame.minX, y: component.frame.minY)

            componentFrames.append(frame)
            componentPositions.append(position)
        }
        if pvp {
            overlayViewController.configureGuidePVP(componentFrames, componentPositions, explanationTexts, tabBarTop)
        } else {
            overlayViewController.configureGuidePVE(componentFrames, componentPositions, explanationTexts, tabBarTop)
        }
        present(overlayViewController, animated: true, completion: nil)
    }
    

//MARK: - UI elements - PVE
    
    private lazy var roundLabel: UILabel = {
        var view = UILabel(frame: CGRect())
        view.backgroundColor = .white
        view.textColor = UIColor(red: 0.176, green: 0.176, blue: 0.208 , alpha: 1)
        view.font = UIFontMetrics.default.scaledFont(for: getFontForLanguage(font: "GemunuLibre-SemiBold", size: fontSize(size: 50)))
        view.textAlignment = .center
        view.text = NSLocalizedString("Round", comment: "") + " 0"
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    private lazy var iconButton: UIImageView = {
        var view = UIImageView(frame: CGRect())
        view.image = UIImage(named: self.teamOrder[self.round - 1].iconName)
        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private lazy var teamNumLabel: UILabel = {
        let label = UILabel(frame: CGRect())
        label.backgroundColor = .white
        label.textColor = UIColor(red: 0.176, green: 0.176, blue: 0.208 , alpha: 1)
        label.font = getFontForLanguage(font: "Dosis-SemiBold", size: fontSize(size: 25))
        label.text = "Team \(self.teamOrder[self.round - 1].number)"
        label.numberOfLines = 1
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private lazy var teamNameLabel: UILabel = {
        let label = UILabel(frame: CGRect())
        label.backgroundColor = .white
        label.font = UIFont(name: "Dosis-Regular", size: fontSize(size: 25))
        label.text = "\(self.teamOrder[self.round - 1].name)"
        label.textColor = UIColor(red: 0.176, green: 0.176, blue: 0.208 , alpha: 1)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private lazy var scoreLabel: UILabel = {
        let label = UILabel(frame: CGRect())
        label.font = UIFont(name: "Dosis-Bold", size: fontSize(size: 50))
        label.text = "\(self.teamOrder[self.round - 1].points)"
        label.textColor = UIColor(red: 0.176, green: 0.176, blue: 0.208 , alpha: 1)
        label.backgroundColor = .white
        label.numberOfLines = 1
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private lazy var winButton: UIButton = {
        var button = UIButton()
        button.setTitle(NSLocalizedString("WIN", comment: ""), for: .normal)
        button.titleLabel?.font = getFontForLanguage(font: "GemunuLibre-Bold", size: 13)
        button.setTitleColor(UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1), for: .normal)
        button.layer.backgroundColor = UIColor(red: 0.721, green: 0.721, blue: 0.721, alpha: 1).cgColor
        button.layer.cornerRadius = 6.0
        button.addTarget(self, action: #selector(winButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var loseButton: UIButton = {
        var button = UIButton()
        button.setTitle(NSLocalizedString("LOSE", comment: ""), for: .normal)
        button.titleLabel?.font = getFontForLanguage(font: "GemunuLibre-Bold", size: 13)
        button.setTitleColor(UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1), for: .normal)
        button.layer.backgroundColor = UIColor(red: 0.721, green: 0.721, blue: 0.721, alpha: 1).cgColor
        button.layer.cornerRadius = 6.0
        button.addTarget(self, action: #selector(loseButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var borderView: UIView = {
        var view = UIView()
        view.frame = CGRect()
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 5
        view.layer.borderColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1).cgColor
        var label = UILabel()
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("TO BE\nDETERMINED", comment: "")
        label.numberOfLines = 2
        label.textColor = .black
        label.textAlignment = .center
        label.font = getFontForLanguage(font: "GemunuLibre-Bold", size: fontSize(size: 30))
        label.lineBreakMode = .byWordWrapping
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 55).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
        return view
    }()
    
    private lazy var explanationLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Remember to choose 'WIN' or 'LOSE' before the round ends!", comment: "")
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Bold", size: fontSize(size: 13))
        return label
    }()
    
    func modifyViewsPVE() {
        borderView.removeFromSuperview()
        self.view.addSubview(teamNumLabel)
        self.view.addSubview(iconButton)
        self.view.addSubview(teamNameLabel)
    }
    
    func addSubviewsPVE() {
        self.view.addSubview(roundLabel)
        self.view.addSubview(borderView)
        self.view.addSubview(scoreLabel)
        self.view.addSubview(winButton)
        self.view.addSubview(loseButton)
        self.view.addSubview(explanationLabel)
    }
    
    func combineSubviewsPVE() {
        self.view.addSubview(roundLabel)
        self.view.addSubview(teamNumLabel)
        self.view.addSubview(iconButton)
        self.view.addSubview(teamNameLabel)
        self.view.addSubview(scoreLabel)
        self.view.addSubview(winButton)
        self.view.addSubview(loseButton)
        self.view.addSubview(explanationLabel)
    }
    
    func addConstraintsPVE() {
        roundLabel.translatesAutoresizingMaskIntoConstraints = false
        borderView.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        winButton.translatesAutoresizingMaskIntoConstraints = false
        loseButton.translatesAutoresizingMaskIntoConstraints = false
        explanationLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            
            roundLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            roundLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: UIScreen.main.bounds.size.height * 0.15),
            roundLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.579),
            roundLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.0751),
            
            borderView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            borderView.topAnchor.constraint(equalTo: roundLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.067),
            borderView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.467),
            borderView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.33),
            
            scoreLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.370),
            scoreLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.0604),
            scoreLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            scoreLabel.topAnchor.constraint(equalTo: borderView.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.05),
            
            winButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.176),
            winButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.032),
            winButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: UIScreen.main.bounds.size.width * 0.315),
            winButton.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 5),
            
            loseButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.176),
            loseButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.032),
            loseButton.leadingAnchor.constraint(equalTo: winButton.trailingAnchor, constant: 5),
            loseButton.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 5),
            
            explanationLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8),
            explanationLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.025),
            explanationLabel.topAnchor.constraint(equalTo: winButton.bottomAnchor, constant: self.view.bounds.height * 0.04),
            explanationLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
    }
    
    func newConstraintsPVE() {
        teamNumLabel.translatesAutoresizingMaskIntoConstraints = false
        iconButton.translatesAutoresizingMaskIntoConstraints = false
        teamNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            teamNumLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            teamNumLabel.topAnchor.constraint(equalTo: roundLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.01),
            teamNumLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.295),
            teamNumLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.045),

            iconButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            iconButton.topAnchor.constraint(equalTo: teamNumLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.03),
            iconButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.467),
            iconButton.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.467),

            teamNameLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            teamNameLabel.topAnchor.constraint(equalTo: iconButton.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.005),
            teamNameLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.492),
            teamNameLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.12),
        
            scoreLabel.topAnchor.constraint(equalTo: teamNameLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.02),
        ])
    }
    
    func combineConstraintsPVE() {
        roundLabel.translatesAutoresizingMaskIntoConstraints = false
        teamNumLabel.translatesAutoresizingMaskIntoConstraints = false
        iconButton.translatesAutoresizingMaskIntoConstraints = false
        teamNameLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        winButton.translatesAutoresizingMaskIntoConstraints = false
        loseButton.translatesAutoresizingMaskIntoConstraints = false
        explanationLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            
            roundLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            roundLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: UIScreen.main.bounds.size.height * 0.15),
            roundLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.579),
            roundLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.0751),
            
            teamNumLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            teamNumLabel.topAnchor.constraint(equalTo: roundLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.01),
            teamNumLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.295),
            teamNumLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.045),

            iconButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            iconButton.topAnchor.constraint(equalTo: teamNumLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.03),
            iconButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.467),
            iconButton.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.467),

            teamNameLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            teamNameLabel.topAnchor.constraint(equalTo: iconButton.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.005),
            teamNameLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.492),
            teamNameLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.12),
            
            scoreLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.370),
            scoreLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.0604),
            scoreLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            scoreLabel.topAnchor.constraint(equalTo: teamNameLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.02),
            
            winButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.176),
            winButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.032),
            winButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: UIScreen.main.bounds.size.width * 0.315),
            winButton.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 5),
            
            loseButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.176),
            loseButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.032),
            loseButton.leadingAnchor.constraint(equalTo: winButton.trailingAnchor, constant: 5),
            loseButton.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 5),
            
            explanationLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8),
            explanationLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.025),
            explanationLabel.topAnchor.constraint(equalTo: winButton.bottomAnchor, constant: self.view.bounds.height * 0.04),
            explanationLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
    }
    //MARK: - UI Elements - PVP
    
    private lazy var leftIconButton: UIImageView = {
        var view = UIImageView(frame: CGRect(x: 0, y: 0, width: 175, height: 175))
        view.image = UIImage(named: teamOrder[2 * self.round - 2].iconName)
        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(leftButtonTapped))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private lazy var leftTeamNumLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.textColor = UIColor(red: 0.176, green: 0.176, blue: 0.208 , alpha: 1)
        label.font = getFontForLanguage(font: "Dosis-SemiBold", size: fontSize(size: 25))
        label.text = "Team \(self.teamOrder[2 * self.round - 2].number)"
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    private lazy var leftTeamNameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.font = UIFont(name: "Dosis-Regular", size: fontSize(size: 18))
        label.text = "\(self.teamOrder[2 * self.round - 2].name)"
        label.textColor = UIColor(red: 0.176, green: 0.176, blue: 0.208 , alpha: 1)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private lazy var leftWinButton: UIButton = {
        var button = UIButton()
        button.setTitle(NSLocalizedString("WIN", comment: ""), for: .normal)
        button.titleLabel?.font = getFontForLanguage(font: "GemunuLibre-Bold", size: 13)
        button.setTitleColor(UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1), for: .normal)
        button.layer.backgroundColor = UIColor(red: 0.721, green: 0.721, blue: 0.721, alpha: 1).cgColor
        button.layer.cornerRadius = 6.0
        button.addTarget(self, action: #selector(leftWinButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var leftLoseButton: UIButton = {
        var button = UIButton()
        button.setTitle(NSLocalizedString("LOSE", comment: ""), for: .normal)
        button.titleLabel?.font = getFontForLanguage(font: "GemunuLibre-Bold", size: 13)
        button.setTitleColor(UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1), for: .normal)
        button.layer.backgroundColor = UIColor(red: 0.721, green: 0.721, blue: 0.721, alpha: 1).cgColor
        button.layer.cornerRadius = 6.0
        button.addTarget(self, action: #selector(leftLoseButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var leftScoreLabel: UILabel = {
        let attributedText = NSMutableAttributedString()
        let score = "\(self.teamOrder[2 * self.round - 2].points)"
        let scoreAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 35) ?? UIFont.boldSystemFont(ofSize: 35),
            .foregroundColor: UIColor(red: 0.176, green: 0.176, blue: 0.208 , alpha: 1)
        ]
        let scoreAttributedString = NSAttributedString(string: score, attributes: scoreAttributes)
        attributedText.append(scoreAttributedString)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 109.01, height: 40.12))
        label.backgroundColor = .white
        label.attributedText = attributedText
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    private lazy var rightIconButton: UIImageView = {
        var view = UIImageView(frame: CGRect(x: 0, y: 0, width: 175, height: 175))
        view.image = UIImage(named: teamOrder[2 * self.round - 1].iconName)
        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(rightButtonTapped))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private lazy var rightTeamNumLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 115, height: 38))
        label.backgroundColor = .white
        label.textColor = UIColor(red: 0.176, green: 0.176, blue: 0.208 , alpha: 1)
        label.font = getFontForLanguage(font: "Dosis-SemiBold", size: fontSize(size: 25))
        label.text = "Team \(self.teamOrder[2 * self.round - 1].number)"
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    private lazy var rightTeamNameLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 45))
        label.backgroundColor = .white
        label.font = UIFont(name: "Dosis-Regular", size: fontSize(size: 18))
        label.text = "\(self.teamOrder[2 * self.round - 1].name)"
        label.textColor = UIColor(red: 0.176, green: 0.176, blue: 0.208 , alpha: 1)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private lazy var rightWinButton: UIButton = {
        var button = UIButton()
        button.setTitle(NSLocalizedString("WIN", comment: ""), for: .normal)
        button.titleLabel?.font = getFontForLanguage(font: "GemunuLibre-Bold", size: 13)
        button.setTitleColor(UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1), for: .normal)
        button.layer.backgroundColor = UIColor(red: 0.721, green: 0.721, blue: 0.721, alpha: 1).cgColor
        button.layer.cornerRadius = 6.0
        button.addTarget(self, action: #selector(rightWinButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var rightLoseButton: UIButton = {
        var button = UIButton()
        button.setTitle(NSLocalizedString("LOSE", comment: ""), for: .normal)
        button.titleLabel?.font = getFontForLanguage(font: "GemunuLibre-Bold", size: 13)
        button.setTitleColor(UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1), for: .normal)
        button.layer.backgroundColor = UIColor(red: 0.721, green: 0.721, blue: 0.721, alpha: 1).cgColor
        button.layer.cornerRadius = 6.0
        button.addTarget(self, action: #selector(rightLoseButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var rightScoreLabel: UILabel = {
        let attributedText = NSMutableAttributedString()
        let score = "\(self.teamOrder[self.round].points)"
        let scoreAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 35) ?? UIFont.boldSystemFont(ofSize: 35),
            .foregroundColor: UIColor(red: 0.176, green: 0.176, blue: 0.208 , alpha: 1)
        ]
        let scoreAttributedString = NSAttributedString(string: score, attributes: scoreAttributes)
        attributedText.append(scoreAttributedString)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 109.01, height: 40.12))
        label.backgroundColor = .white
        label.attributedText = attributedText
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    private lazy var leftBorderView: UIView = {
        var view = UIView()
        view.frame = CGRect()
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1).cgColor
        var label = UILabel()
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("TO BE\nDETERMINED", comment: "")
        label.numberOfLines = 2
        label.textColor = .black
        label.textAlignment = .center
        label.font = getFontForLanguage(font: "GemunuLibre-Bold", size: fontSize(size: 22))
        label.lineBreakMode = .byWordWrapping
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: UIScreen.main.bounds.height * 0.11).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
        return view
    }()
    
    private lazy var rightBorderView: UIView = {
        var view = UIView()
        view.frame = CGRect()
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1).cgColor
        var label = UILabel()
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("TO BE\nDETERMINED", comment: "")
        label.numberOfLines = 2
        label.textColor = .black
        label.textAlignment = .center
        label.font = getFontForLanguage(font: "GemunuLibre-Bold", size: fontSize(size: 22))
        label.lineBreakMode = .byWordWrapping
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: UIScreen.main.bounds.height * 0.11).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
        return view
    }()
    
    func modifyViewsPVP() {
        leftBorderView.removeFromSuperview()
        rightBorderView.removeFromSuperview()
        self.view.addSubview(leftTeamNumLabel)
        self.view.addSubview(leftIconButton)
        self.view.addSubview(leftTeamNameLabel)
        self.view.addSubview(rightTeamNumLabel)
        self.view.addSubview(rightIconButton)
        self.view.addSubview(rightTeamNameLabel)
    }
    
    func addSubviewsPVP() {
        self.view.addSubview(roundLabel)
        self.view.addSubview(leftBorderView)
        self.view.addSubview(leftWinButton)
        self.view.addSubview(leftLoseButton)
        self.view.addSubview(leftScoreLabel)
        self.view.addSubview(rightBorderView)
        self.view.addSubview(rightWinButton)
        self.view.addSubview(rightLoseButton)
        self.view.addSubview(rightScoreLabel)
        self.view.addSubview(explanationLabel)
    }
    
    func combineSubviewsPVP() {
        self.view.addSubview(roundLabel)
        self.view.addSubview(leftWinButton)
        self.view.addSubview(leftLoseButton)
        self.view.addSubview(leftScoreLabel)
        self.view.addSubview(leftTeamNumLabel)
        self.view.addSubview(leftIconButton)
        self.view.addSubview(leftTeamNameLabel)
        self.view.addSubview(rightWinButton)
        self.view.addSubview(rightLoseButton)
        self.view.addSubview(rightScoreLabel)
        self.view.addSubview(rightTeamNumLabel)
        self.view.addSubview(rightIconButton)
        self.view.addSubview(rightTeamNameLabel)
        self.view.addSubview(explanationLabel)
    }
    
    func addConstraintsPVP() {
        roundLabel.translatesAutoresizingMaskIntoConstraints = false
        leftBorderView.translatesAutoresizingMaskIntoConstraints = false
        leftWinButton.translatesAutoresizingMaskIntoConstraints = false
        leftLoseButton.translatesAutoresizingMaskIntoConstraints = false
        leftScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        rightBorderView.translatesAutoresizingMaskIntoConstraints = false
        rightWinButton.translatesAutoresizingMaskIntoConstraints = false
        rightLoseButton.translatesAutoresizingMaskIntoConstraints = false
        rightScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        explanationLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            
            roundLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            roundLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: UIScreen.main.bounds.size.height * 0.15),
            roundLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.579),
            roundLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.0751),
            
            leftBorderView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: UIScreen.main.bounds.size.width * 0.10),
            leftBorderView.topAnchor.constraint(equalTo: roundLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.04),
            leftBorderView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.39),
            leftBorderView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.33),
            
            leftScoreLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.291),
            leftScoreLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.0493),
            leftScoreLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: UIScreen.main.bounds.size.width * 0.156),
            leftScoreLabel.topAnchor.constraint(equalTo: leftBorderView.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.06),
            
            leftWinButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.156),
            leftWinButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.032),
            leftWinButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: UIScreen.main.bounds.size.width * 0.13),
            leftWinButton.topAnchor.constraint(equalTo: leftScoreLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.0001),
            
            leftLoseButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.156),
            leftLoseButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.032),
            leftLoseButton.leadingAnchor.constraint(equalTo: leftWinButton.trailingAnchor, constant: UIScreen.main.bounds.size.width * 0.026),
            leftLoseButton.topAnchor.constraint(equalTo: leftScoreLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.0001),
            
            rightBorderView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -UIScreen.main.bounds.size.width * 0.10),
            rightBorderView.topAnchor.constraint(equalTo: roundLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.04),
            rightBorderView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.39),
            rightBorderView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.33),
            
            rightScoreLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.291),
            rightScoreLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.0493),
            rightScoreLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -UIScreen.main.bounds.size.width * 0.156),
            rightScoreLabel.topAnchor.constraint(equalTo: rightBorderView.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.06),
            
            rightWinButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.156),
            rightWinButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.032),
            rightWinButton.trailingAnchor.constraint(equalTo: rightLoseButton.leadingAnchor, constant: -UIScreen.main.bounds.size.width * 0.026),
            rightWinButton.topAnchor.constraint(equalTo: rightScoreLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.0001),
            
            rightLoseButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.156),
            rightLoseButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.032),
            rightLoseButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -UIScreen.main.bounds.size.width * 0.13),
            rightLoseButton.topAnchor.constraint(equalTo: rightScoreLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.0001),
            
            explanationLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8),
            explanationLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.025),
            explanationLabel.topAnchor.constraint(equalTo: leftWinButton.bottomAnchor, constant: self.view.bounds.height * 0.04),
            explanationLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
    }
    
    func newConstraintsPVP() {
        leftTeamNumLabel.translatesAutoresizingMaskIntoConstraints = false
        leftIconButton.translatesAutoresizingMaskIntoConstraints = false
        leftTeamNameLabel.translatesAutoresizingMaskIntoConstraints = false
        rightTeamNumLabel.translatesAutoresizingMaskIntoConstraints = false
        rightIconButton.translatesAutoresizingMaskIntoConstraints = false
        rightTeamNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftTeamNumLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: UIScreen.main.bounds.size.width * 0.153),
            leftTeamNumLabel.topAnchor.constraint(equalTo: roundLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.04),
            leftTeamNumLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.295),
            leftTeamNumLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.045),
            
            leftIconButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.36),
            leftIconButton.heightAnchor.constraint(equalTo: leftIconButton.widthAnchor, multiplier: 1),
            leftIconButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: UIScreen.main.bounds.size.width * 0.125),
            leftIconButton.topAnchor.constraint(equalTo: leftTeamNumLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.02),
            
            leftTeamNameLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.37),
            leftTeamNameLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.06),
            leftTeamNameLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: UIScreen.main.bounds.size.width * 0.116),
            leftTeamNameLabel.topAnchor.constraint(equalTo: leftIconButton.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.03),
            
            rightTeamNumLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -UIScreen.main.bounds.size.width * 0.153),
            rightTeamNumLabel.topAnchor.constraint(equalTo: roundLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.04),
            rightTeamNumLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.295),
            rightTeamNumLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.045),
            
            rightIconButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.36),
            rightIconButton.heightAnchor.constraint(equalTo: rightIconButton.widthAnchor, multiplier: 1),
            rightIconButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -UIScreen.main.bounds.size.width * 0.125),
            rightIconButton.topAnchor.constraint(equalTo: rightTeamNumLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.02),
            
            rightTeamNameLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.37),
            rightTeamNameLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.06),
            rightTeamNameLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -UIScreen.main.bounds.size.width * 0.116),
            rightTeamNameLabel.topAnchor.constraint(equalTo: rightIconButton.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.03),
            
            leftScoreLabel.topAnchor.constraint(equalTo: leftTeamNameLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.075),
            rightScoreLabel.topAnchor.constraint(equalTo: rightTeamNameLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.075),
        ])
    }
    
    func combineConstraintsPVP() {
        roundLabel.translatesAutoresizingMaskIntoConstraints = false
        leftTeamNumLabel.translatesAutoresizingMaskIntoConstraints = false
        leftIconButton.translatesAutoresizingMaskIntoConstraints = false
        leftTeamNameLabel.translatesAutoresizingMaskIntoConstraints = false
        leftScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        leftWinButton.translatesAutoresizingMaskIntoConstraints = false
        leftLoseButton.translatesAutoresizingMaskIntoConstraints = false
        rightTeamNumLabel.translatesAutoresizingMaskIntoConstraints = false
        rightIconButton.translatesAutoresizingMaskIntoConstraints = false
        rightTeamNameLabel.translatesAutoresizingMaskIntoConstraints = false
        rightScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        rightWinButton.translatesAutoresizingMaskIntoConstraints = false
        rightLoseButton.translatesAutoresizingMaskIntoConstraints = false
        explanationLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            
            roundLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            roundLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: UIScreen.main.bounds.size.height * 0.15),
            roundLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.579),
            roundLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.0751),
            
            leftTeamNumLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: UIScreen.main.bounds.size.width * 0.152),
            leftTeamNumLabel.topAnchor.constraint(equalTo: roundLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.04),
            leftTeamNumLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.295),
            leftTeamNumLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.045),
            
            leftIconButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.36),
            leftIconButton.heightAnchor.constraint(equalTo: leftIconButton.widthAnchor, multiplier: 1),
            leftIconButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: UIScreen.main.bounds.size.width * 0.125),
            leftIconButton.topAnchor.constraint(equalTo: leftTeamNumLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.02),
            
            leftTeamNameLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.37),
            leftTeamNameLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.06),
            leftTeamNameLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: UIScreen.main.bounds.size.width * 0.116),
            leftTeamNameLabel.topAnchor.constraint(equalTo: leftIconButton.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.03),
            
            leftScoreLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.291),
            leftScoreLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.0493),
            leftScoreLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: UIScreen.main.bounds.size.width * 0.156),
            leftScoreLabel.topAnchor.constraint(equalTo: leftTeamNameLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.06),
            
            leftWinButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.156),
            leftWinButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.032),
            leftWinButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: UIScreen.main.bounds.size.width * 0.13),
            leftWinButton.topAnchor.constraint(equalTo: leftScoreLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.0001),
            
            leftLoseButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.156),
            leftLoseButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.032),
            leftLoseButton.leadingAnchor.constraint(equalTo: leftWinButton.trailingAnchor, constant: UIScreen.main.bounds.size.width * 0.026),
            leftLoseButton.topAnchor.constraint(equalTo: leftScoreLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.0001),
            
            rightTeamNumLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -UIScreen.main.bounds.size.width * 0.152),
            rightTeamNumLabel.topAnchor.constraint(equalTo: roundLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.04),
            rightTeamNumLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.295),
            rightTeamNumLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.045),
            
            rightIconButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.36),
            rightIconButton.heightAnchor.constraint(equalTo: rightIconButton.widthAnchor, multiplier: 1),
            rightIconButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -UIScreen.main.bounds.size.width * 0.125),
            rightIconButton.topAnchor.constraint(equalTo: rightTeamNumLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.02),
            
            rightTeamNameLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.37),
            rightTeamNameLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.06),
            rightTeamNameLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -UIScreen.main.bounds.size.width * 0.116),
            rightTeamNameLabel.topAnchor.constraint(equalTo: rightIconButton.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.03),
            
            rightScoreLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.291),
            rightScoreLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.0493),
            rightScoreLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -UIScreen.main.bounds.size.width * 0.156),
            rightScoreLabel.topAnchor.constraint(equalTo: rightTeamNameLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.06),
            
            rightWinButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.156),
            rightWinButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.032),
            rightWinButton.trailingAnchor.constraint(equalTo: rightLoseButton.leadingAnchor, constant: -UIScreen.main.bounds.size.width * 0.026),
            rightWinButton.topAnchor.constraint(equalTo: rightScoreLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.0001),
            
            rightLoseButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.156),
            rightLoseButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.032),
            rightLoseButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -UIScreen.main.bounds.size.width * 0.13),
            rightLoseButton.topAnchor.constraint(equalTo: rightScoreLabel.bottomAnchor, constant: UIScreen.main.bounds.size.height * 0.0001),
            
            explanationLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8),
            explanationLabel.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.025),
            explanationLabel.topAnchor.constraint(equalTo: leftWinButton.bottomAnchor, constant: self.view.bounds.height * 0.04),
            explanationLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
    }
    
    //MARK: - Update Score
    func updateScore() {
        for old_team in self.teamOrder {
            for updated_team in self.teams {
                if old_team.number == updated_team.number && old_team.points != updated_team.points {
                    if let index = self.teamOrder.firstIndex(where: { $0.number == old_team.number }) {
                        self.teamOrder[index] = updated_team
                    }
                    break;
                }
            }
        }
        roundLabel.text = NSLocalizedString("Round", comment: "") + " \(self.round)"
        if pvp {
            self.teamA = self.teamOrder[2 * self.round - 2]
            leftTeamNumLabel.text = "Team \(self.teamA.number)"
            leftIconButton.image = UIImage(named: self.teamA.iconName)
            leftTeamNameLabel.text = "\(self.teamA.name)"
            leftScoreLabel.text = "\(self.teamA.points)"
            self.teamB = self.teamOrder[2 * self.round - 1]
            rightTeamNumLabel.text = "Team \(self.teamB.number)"
            rightIconButton.image = UIImage(named: self.teamB.iconName)
            rightTeamNameLabel.text = "\(self.teamB.name)"
            rightScoreLabel.text = "\(self.teamB.points)"
        } else {
            self.team = self.teamOrder[self.round - 1]
            teamNumLabel.text = "Team \(self.team.number)"
            iconButton.image = UIImage(named: self.team.iconName)
            teamNameLabel.text = "\(self.team.name)"
            scoreLabel.text = "\(self.team.points)"
        }
    }
    
    //MARK: - Get TeamOrder
    func getTeamOrder() {
        for station in stations {
            if station.name == referee.stationName {
                self.teamOrder = station.teamOrder
                self.points = station.points
                break;
            }
        }
    }
}

// MARK: - @objc
extension RefereePVEController {
    
    @objc func hostUpdate(notification: Notification) {
        guard let host = notification.userInfo?["host"] as? Host else { return }
        
        if host.confirmStations {
            Task { @MainActor in
                let stations = try await S.getStationList(gameCode)
                for station in stations {
                    if referee.stationName == station.name {
                        self.station = station
                        self.pvp = station.pvp
                    }
                }
                if algorithm == [] {
                    if pvp  {
                        borderView.removeFromSuperview()
                        scoreLabel.removeFromSuperview()
                        winButton.removeFromSuperview()
                        loseButton.removeFromSuperview()
                        addSubviewsPVP()
                        addConstraintsPVP()
                    } else {
                        leftBorderView.removeFromSuperview()
                        leftScoreLabel.removeFromSuperview()
                        leftWinButton.removeFromSuperview()
                        leftLoseButton.removeFromSuperview()
                        rightBorderView.removeFromSuperview()
                        rightScoreLabel.removeFromSuperview()
                        rightWinButton.removeFromSuperview()
                        rightLoseButton.removeFromSuperview()
                        addSubviewsPVE()
                        addConstraintsPVE()
                    }
                }
            }
        }
        if host.gameTime + host.movingTime == 0 {
            if let tabBarController = self.tabBarController {
                if let tabBarItems = tabBarController.tabBar.items, tabBarItems.indices.contains(2) {
                    let tabBarItem = tabBarItems[2]
                    tabBarItem.isEnabled = false
                }
            }
        } else {
            if let tabBarController = self.tabBarController {
                if let tabBarItems = tabBarController.tabBar.items, tabBarItems.indices.contains(2) {
                    let tabBarItem = tabBarItems[2]
                    tabBarItem.isEnabled = true
                }
            }
        }
        if host.algorithm != [] {
            self.algorithm = convert1DArrayTo2D(host.algorithm)
            self.number = host.teams
        }
        if !self.gameStart && !host.gameover {
            if host.gameStart {
                setTeamOrder()
                self.teamOrderSet = true
                self.gameStart = true
            }
        }
        if (self.round != host.currentRound) && (host.currentRound <= host.rounds) {
            roundLabel.text = NSLocalizedString("Round", comment: "") + " \(host.currentRound)"
            if pvp {
                leftTeamNumLabel.text = "Team \(self.teamOrder[2 * host.currentRound - 2].number)"
                leftIconButton.image = UIImage(named: self.teamOrder[2 * host.currentRound - 2].iconName)
                leftTeamNameLabel.text = "\(self.teamOrder[2 * host.currentRound - 2].name)"
                leftScoreLabel.text = "\(self.teamOrder[2 * host.currentRound - 2].points)"
                rightTeamNumLabel.text = "Team \(self.teamOrder[2 * host.currentRound - 1].number)"
                rightIconButton.image = UIImage(named: self.teamOrder[2 * host.currentRound - 1].iconName)
                rightTeamNameLabel.text = "\(self.teamOrder[2 * host.currentRound - 1].name)"
                rightScoreLabel.text = "\(self.teamOrder[2 * host.currentRound - 1].points)"
                self.round = host.currentRound
                self.teamA = self.teamOrder[2 * host.currentRound - 2]
                self.teamB = self.teamOrder[2 * host.currentRound - 1]
                if self.host.algorithm != [] {
                    leftWinButton.gestureRecognizers?.forEach { gestureRecognizer in
                        gestureRecognizer.isEnabled = true
                    }
                    leftWinButton.layer.backgroundColor = UIColor(red: 0.721, green: 0.721, blue: 0.721, alpha: 1).cgColor
                    leftLoseButton.gestureRecognizers?.forEach { gestureRecognizer in
                        gestureRecognizer.isEnabled = true
                    }
                    leftLoseButton.layer.backgroundColor = UIColor(red: 0.721, green: 0.721, blue: 0.721, alpha: 1).cgColor
                    rightWinButton.gestureRecognizers?.forEach { gestureRecognizer in
                        gestureRecognizer.isEnabled = true
                    }
                    rightWinButton.layer.backgroundColor = UIColor(red: 0.721, green: 0.721, blue: 0.721, alpha: 1).cgColor
                    rightLoseButton.gestureRecognizers?.forEach { gestureRecognizer in
                        gestureRecognizer.isEnabled = true
                    }
                    rightLoseButton.layer.backgroundColor = UIColor(red: 0.721, green: 0.721, blue: 0.721, alpha: 1).cgColor
                    UserData.writeMax("", "maxA")
                    maxA = UserData.readMax("maxA")!
                    UserData.writeMax("", "maxB")
                    maxB = UserData.readMax("maxB")!
                }
            } else {
                teamNumLabel.text = "Team \(self.teamOrder[host.currentRound - 1].number)"
                iconButton.image = UIImage(named: self.teamOrder[host.currentRound - 1].iconName)
                teamNameLabel.text = "\(self.teamOrder[host.currentRound - 1].name)"
                scoreLabel.text = "\(self.teamOrder[host.currentRound - 1].points)"
                self.round = host.currentRound
                self.team = self.teamOrder[host.currentRound - 1]
                if self.host.algorithm != [] {
                    winButton.gestureRecognizers?.forEach { gestureRecognizer in
                        gestureRecognizer.isEnabled = true
                    }
                    winButton.layer.backgroundColor = UIColor(red: 0.721, green: 0.721, blue: 0.721, alpha: 1).cgColor
                    loseButton.gestureRecognizers?.forEach { gestureRecognizer in
                        gestureRecognizer.isEnabled = true
                    }
                    loseButton.layer.backgroundColor = UIColor(red: 0.721, green: 0.721, blue: 0.721, alpha: 1).cgColor
                    UserData.writeMax("", "max")
                    max = UserData.readMax("max")!
                }
            }
        }
    }
    
    @objc func teamsUpdate(notification: Notification) {
        guard let teams = notification.userInfo?["teams"] as? [Team] else { return }
        
        count = teams.count
        for old_team in self.teamOrder {
            for team in teams {
                if old_team.number == team.number && old_team.points != team.points {
                    if let index = self.teamOrder.firstIndex(where: { $0.number == old_team.number }) {
                        self.teamOrder[index] = team
                    }
                    break;
                }
            }
        }
        for team in teams {
            if pvp {
                if self.teamA.name == team.name {
                    self.teamA = team
                    leftScoreLabel.text = "\(self.teamA.points)"
                }
                if self.teamB.name == team.name {
                    self.teamB = team
                    rightScoreLabel.text = "\(self.teamB.points)"
                }
            } else {
                if self.team.name == team.name {
                    self.team = team
                }
                scoreLabel.text = "\(self.team.points)"
            }
        }
    }
    
    @objc func readAll(notification: Notification) {
        guard let unread = notification.userInfo?["unread"] as? Bool else {
            return
        }
        guard let items = self.navigationItem.rightBarButtonItems else { return }
        if unread {
            for barButtonItem in items {
                if let btn = barButtonItem.customView as? UIButton, btn.tag == 120 {
                    // 이미지 변경
                    btn.setImage(self.unreadSome, for: .normal)
                    break
                }
            }
        } else {
            for barButtonItem in items {
                if let btn = barButtonItem.customView as? UIButton, btn.tag == 120 {
                    // 이미지 변경
                    btn.setImage(self.readAll, for: .normal)
                    break
                }
            }
        }
    }
    
    @objc func buttonTapped() {
        if self.team.number == 0 {
            alert(title: NSLocalizedString("The Team doesn't exist", comment: ""), message: NSLocalizedString("This is an invalid team.", comment: ""))
        } else {
            UserData.writeTeam(self.team, "Team")
            let popUpWindow = GivePointsController(team: UserData.readTeam("Team")!, gameCode: UserData.readGamecode("gamecode")!)
            self.present(popUpWindow, animated: true, completion: nil)
        }
    }
    
    @objc func winButtonTapped() {
        if self.team.number == 0 {
            alert(title: "", message: NSLocalizedString("There is no Team yet.", comment: ""))
        } else {
            if max != "true" {
                Task {
                    do {
                        try await T.givePoints(gameCode, self.team.name, self.points)
                    } catch GameWalkerError.serverError(let text){
                        print(text)
                        serverAlert(text)
                        return
                    }
                }
                UserData.writeMax("true", "max")
                max = UserData.readMax("max")!
            }
            winButton.gestureRecognizers?.forEach { gestureRecognizer in
                gestureRecognizer.isEnabled = false
            }
            winButton.layer.backgroundColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1).cgColor
            loseButton.gestureRecognizers?.forEach { gestureRecognizer in
                gestureRecognizer.isEnabled = true
            }
            loseButton.layer.backgroundColor = UIColor(red: 0.721, green: 0.721, blue: 0.721, alpha: 1).cgColor
        }
    }
    
    @objc func loseButtonTapped() {
        if self.team.number == 0 {
            alert(title: "", message: NSLocalizedString("There is no Team yet.", comment: ""))
        } else {
            if max == "true" {
                Task {
                    do {
                        try await T.givePoints(gameCode, self.team.name, -self.points)
                    } catch GameWalkerError.serverError(let text){
                        print(text)
                        serverAlert(text)
                        return
                    }
                }
                UserData.writeMax("false", "max")
                max = UserData.readMax("max")!
            }
            winButton.gestureRecognizers?.forEach { gestureRecognizer in
                gestureRecognizer.isEnabled = true
            }
            winButton.layer.backgroundColor = UIColor(red: 0.721, green: 0.721, blue: 0.721, alpha: 1).cgColor
            loseButton.gestureRecognizers?.forEach { gestureRecognizer in
                gestureRecognizer.isEnabled = false
            }
            loseButton.layer.backgroundColor = UIColor(red: 0.942, green: 0.71, blue: 0.114, alpha: 1).cgColor
        }
    }
    
    @objc func leftButtonTapped() {
        if self.teamA.number == 0 {
            alert(title: "", message: NSLocalizedString("There is no Team yet.", comment: ""))
        } else {
            UserData.writeTeam(self.teamA, "Team")
            let popUpWindow = GivePointsController(team: UserData.readTeam("Team")!, gameCode: UserData.readGamecode("gamecode")!)
            self.present(popUpWindow, animated: true, completion: nil)
        }
    }
    
    @objc func rightButtonTapped() {
        if self.teamB.number == 0 {
            alert(title: "", message: NSLocalizedString("There is no Team yet.", comment: ""))
        } else {
            UserData.writeTeam(self.teamB, "Team")
            let popUpWindow = GivePointsController(team: UserData.readTeam("Team")!, gameCode: UserData.readGamecode("gamecode")!)
            self.present(popUpWindow, animated: true, completion: nil)
        }
    }
    
    @objc func leftWinButtonTapped() {
        if self.teamA.number == 0 {
            alert(title: NSLocalizedString("The Team doesn't exist", comment: ""), message: NSLocalizedString("This is an invalid team.", comment: ""))
        } else {
            if maxA != "true" {
                Task {
                    do {
                        try await T.givePoints(gameCode, self.teamA.name, self.points)
                    } catch GameWalkerError.serverError(let text){
                        print(text)
                        serverAlert(text)
                        return
                    }
                }
                UserData.writeMax("true", "maxA")
                maxA = UserData.readMax("maxA")!
            }
            leftWinButton.gestureRecognizers?.forEach { gestureRecognizer in
                gestureRecognizer.isEnabled = false
            }
            leftWinButton.layer.backgroundColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1).cgColor
            leftLoseButton.gestureRecognizers?.forEach { gestureRecognizer in
                gestureRecognizer.isEnabled = true
            }
            leftLoseButton.layer.backgroundColor = UIColor(red: 0.721, green: 0.721, blue: 0.721, alpha: 1).cgColor
        }
    }
    
    @objc func rightWinButtonTapped() {
        if self.teamB.number == 0 {
            alert(title: "", message: NSLocalizedString("There is no Team yet.", comment: ""))
        } else {
            if maxB != "true" {
                Task {
                    do {
                        try await T.givePoints(gameCode, self.teamB.name, self.points)
                    } catch GameWalkerError.serverError(let text){
                        print(text)
                        serverAlert(text)
                        return
                    }
                }
                UserData.writeMax("true", "maxB")
                maxB = UserData.readMax("maxB")!
            }
            rightWinButton.gestureRecognizers?.forEach { gestureRecognizer in
                gestureRecognizer.isEnabled = false
            }
            rightWinButton.layer.backgroundColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1).cgColor
            rightLoseButton.gestureRecognizers?.forEach { gestureRecognizer in
                gestureRecognizer.isEnabled = true
            }
            rightLoseButton.layer.backgroundColor = UIColor(red: 0.721, green: 0.721, blue: 0.721, alpha: 1).cgColor
        }
    }
    
    @objc func leftLoseButtonTapped() {
        if self.teamA.number == 0 {
            alert(title: "", message: NSLocalizedString("There is no Team yet.", comment: ""))
        } else {
            if maxA == "true" {
                Task {
                    do {
                        try await T.givePoints(gameCode, self.teamA.name, -self.points)
                    } catch GameWalkerError.serverError(let text){
                        print(text)
                        serverAlert(text)
                        return
                    }
                }
                UserData.writeMax("false", "maxA")
                maxA = UserData.readMax("maxA")!
            }
            leftWinButton.gestureRecognizers?.forEach { gestureRecognizer in
                gestureRecognizer.isEnabled = true
            }
            leftWinButton.layer.backgroundColor = UIColor(red: 0.721, green: 0.721, blue: 0.721, alpha: 1).cgColor
            leftLoseButton.gestureRecognizers?.forEach { gestureRecognizer in
                gestureRecognizer.isEnabled = false
            }
            leftLoseButton.layer.backgroundColor = UIColor(red: 0.942, green: 0.71, blue: 0.114, alpha: 1).cgColor
        }
    }
    
    @objc func rightLoseButtonTapped() {
        if self.teamB.number == 0 {
            alert(title: "", message: NSLocalizedString("There is no Team yet.", comment: ""))
        } else {
            if maxB == "true" {
                Task {
                    do {
                        try await T.givePoints(gameCode, self.teamB.name, -self.points)
                    } catch GameWalkerError.serverError(let text){
                        print(text)
                        serverAlert(text)
                        return
                    }
                }
                UserData.writeMax("false", "maxB")
                maxB = UserData.readMax("maxB")!
            }
            rightWinButton.gestureRecognizers?.forEach { gestureRecognizer in
                gestureRecognizer.isEnabled = true
            }
            rightWinButton.layer.backgroundColor = UIColor(red: 0.721, green: 0.721, blue: 0.721, alpha: 1).cgColor
            rightLoseButton.gestureRecognizers?.forEach { gestureRecognizer in
                gestureRecognizer.isEnabled = false
            }
            rightLoseButton.layer.backgroundColor = UIColor(red: 0.942, green: 0.71, blue: 0.114, alpha: 1).cgColor
        }
    }
    
    @objc func leaveAction() {
        self.navigationController?.popToRegisterViewController(animated: true)
    }
    
    @objc override func infoAction() {
        if !teamOrderSet {
            if pvp {
                leftIconButton.frame = CGRect(x: UIScreen.main.bounds.size.width * 0.105, y: UIScreen.main.bounds.size.height * 0.315, width: UIScreen.main.bounds.size.width * 0.38, height: UIScreen.main.bounds.size.width * 0.38)
                rightIconButton.frame = CGRect(x: UIScreen.main.bounds.size.width * 0.515, y: UIScreen.main.bounds.size.height * 0.315, width: UIScreen.main.bounds.size.width * 0.38, height: UIScreen.main.bounds.size.width * 0.38)
                showOverlay(pvp: pvp, components: [leftIconButton, leftWinButton, leftLoseButton, leftScoreLabel, rightIconButton, rightWinButton, rightLoseButton, rightScoreLabel])
            } else {
                iconButton.frame = CGRect(x: UIScreen.main.bounds.size.width * 0.2665, y: UIScreen.main.bounds.size.height * 0.31, width: UIScreen.main.bounds.size.width * 0.467, height: UIScreen.main.bounds.size.width * 0.467)
                showOverlay(pvp: pvp, components: [iconButton, scoreLabel, winButton, loseButton])
            }
        } else {
            if pvp {
                showOverlay(pvp: pvp, components: [leftIconButton, leftWinButton, leftLoseButton, leftScoreLabel, rightIconButton, rightWinButton, rightLoseButton, rightScoreLabel])
            } else {
                showOverlay(pvp: pvp, components: [iconButton, scoreLabel, winButton, loseButton])
            }
        }
    }
    
    @objc override func announceAction() {
        showMessagePopUp(messages: RefereeTabBarController.localMessages, role: "referee")
    }
}
