//
//  RefereeRankingPVEViewController.swift
//  Game_Walker
//
//  Created by 김현식 on 1/30/23.
//

import Foundation
import UIKit

class RefereeRankingPVEViewController: UIViewController {
    
    @IBOutlet weak var leaderBoard: UITableView!
    
    private var teamList: [Team] = []

    private var gameCode: String = UserData.readGamecode("gamecode") ?? ""
    private let refreshController: UIRefreshControl = UIRefreshControl()
    private var showScore = true
    
    private let readAll = UIImage(named: "messageIcon")
    private let unreadSome = UIImage(named: "unreadMessage")
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
        
        if RefereeTabBarController.unread {
            if let items = self.navigationItem.rightBarButtonItems {
                for barButtonItem in items {
                    if let btn = barButtonItem.customView as? UIButton, btn.tag == 120 {
                        // 이미지 변경
                        btn.setImage(self.unreadSome, for: .normal)
                        break
                    }
                }
            }
        } else {
            if let items = self.navigationItem.rightBarButtonItems {
                for barButtonItem in items {
                    if let btn = barButtonItem.customView as? UIButton, btn.tag == 120 {
                        // 이미지 변경
                        btn.setImage(self.readAll, for: .normal)
                        break
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.navigationController?.isNavigationBarHidden = true
        configureTableView()
        configureNavigationBar()
        
        Task {@MainActor in
            do {
                self.teamList = try await T.getTeamList(gameCode)
                guard let host = try await H.getHost(gameCode) else { return }
                self.showScore = host.showScoreboard
                self.leaderBoard.reloadData()
            } catch GameWalkerError.serverError(let e) {
                print(e)
                serverAlert(e)
                return
            }
        }
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(hostUpdate), name: .hostUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(teamsUpdate), name: .teamsUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(readAll(notification:)), name: .readNotification, object: nil)
    }
    
    private func configureTableView() {
        leaderBoard.delegate = self
        leaderBoard.dataSource = self
        leaderBoard.register(RefereeTableViewCell.self, forCellReuseIdentifier: RefereeTableViewCell.identifier)
        leaderBoard.backgroundColor = .white
        leaderBoard.allowsSelection = true
        leaderBoard.separatorStyle = .none
        leaderBoard.allowsMultipleSelection = false
    }
    
}
// MARK: - TableView
extension RefereeRankingPVEViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = leaderBoard.dequeueReusableCell(withIdentifier: RefereeTableViewCell.identifier, for: indexPath) as! RefereeTableViewCell
        let team = teamList[indexPath.row]
        let teamNum = String(team.number)
        let points = String(team.points)
        cell.configureRankTableViewCell(imageName: team.iconName, teamNum: "Team \(teamNum)", teamName: team.name, points: points, showScore: self.showScore)
        cell.selectionStyle = .none
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamList.count
     }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return fontSize(size: 85)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.section)
        let team = teamList[indexPath.row]
        let svc = GivePointsController(team: team, gameCode: self.gameCode)
        svc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        self.present(svc, animated: true)
        leaderBoard.deselectRow(at: indexPath, animated: true)
    }
}
// MARK: - overlay guide
extension RefereeRankingPVEViewController {
    private func showOverlay() {
        let overlayViewController = RorTOverlayViewController()
        overlayViewController.modalPresentationStyle = .overFullScreen // Present it as overlay
        
        let explanationTexts = [
            NSLocalizedString("Station\nStatus", comment: ""),
            NSLocalizedString("Ranking\nStatus", comment: ""),
            NSLocalizedString("Timer &\nStation Info", comment: ""),
            NSLocalizedString("Points can be hidden.", comment: "")
        ]
        var componentPositions: [CGPoint] = []
        var componentFrames: [CGRect] = []
        let component1Frame = CGRect(x: Int(self.leaderBoard.frame.maxX - 85), y: Int(self.leaderBoard.frame.minY + 42.5), width: 85, height: 17)
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
                        tabBarTop = tabBarFrame.minY
                        componentFrames.append(tabItemFrame)
                        componentPositions.append(CGPoint(x: centerXPosition, y: topAnchorPosition))
                    }
                }
            }
        }
        componentFrames.append(component1Frame)
        print(componentFrames)
        print(componentPositions)
        overlayViewController.configureGuide(componentFrames, componentPositions, UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1).cgColor, explanationTexts, tabBarTop, "Ranking", "referee")
        
        present(overlayViewController, animated: true, completion: nil)
    }
}
// MARK: - @objc
extension RefereeRankingPVEViewController {
    
    @objc override func announceAction() {
        showMessagePopUp(messages: RefereeTabBarController.localMessages, role: "referee")
    }
    
    @objc override func infoAction() {
        self.showOverlay()
    }
    
    @objc func hostUpdate (notification: Notification) {
        guard let host = notification.userInfo?["host"] as? Host else { return }
        
        self.showScore = host.showScoreboard
        if showScore {
            Task {@MainActor in
                do {
                    self.teamList = try await T.getTeamList(gameCode)
                    self.leaderBoard.reloadData()
                } catch GameWalkerError.serverError(let e) {
                    print(e)
                    serverAlert(e)
                    return
                }
            }
        } else {
            self.leaderBoard.reloadData()
        }
    }
    
    @objc func teamsUpdate (notification: Notification) {
        guard var teams = notification.userInfo?["teams"] as? [Team] else { return }
        teams.sort { (team1, team2) -> Bool in
            if team1.points == team2.points {
                return team1.number < team2.number
            } else {
                return team1.points > team2.points
            }
        }
        if self.showScore {
            self.teamList = teams
            self.leaderBoard.reloadData()
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
}

