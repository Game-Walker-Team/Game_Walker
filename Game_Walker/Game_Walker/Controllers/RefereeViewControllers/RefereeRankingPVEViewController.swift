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
    @IBOutlet weak var announcementButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    
    private var teamList: [Team] = []
    
    static var readMsgList: [String] = []
    static var messages: [String] = []
    private let cellSpacingHeight: CGFloat = 1
    private var currentPlayer: Player = UserData.readPlayer("player") ?? Player()
    private var gameCode: String = UserData.readGamecode("gamecode") ?? ""
    private let refreshController: UIRefreshControl = UIRefreshControl()
    private var showScore = true
    
    private var timer = Timer()
    static var read: Bool = true
    private var diff: Int?
    
    static let notificationName = Notification.Name("readNotification")
    
    private let readAll = UIImage(named: "announcement")
    private let unreadSome = UIImage(named: "unreadMessage")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        T.delegates.append(self)
        H.delegates.append(self)
        configureTableView()
        T.listenTeams(gameCode, onListenerUpdate: listen(_:))
        H.listenHost(gameCode, onListenerUpdate: listen(_:))
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let strongSelf = self else {
                return
            }
            strongSelf.diff = RefereeRankingPVEViewController.messages.count - RefereeRankingPVEViewController.readMsgList.count
            if strongSelf.diff! < 1 {
                if RefereeRankingPVEViewController.read == false {
                    RefereeRankingPVEViewController.read = true
                    NotificationCenter.default.post(name: RefereeRankingPVEViewController.notificationName, object: nil, userInfo: ["isRead": RefereeRankingPVEViewController.read])
                    strongSelf.announcementButton.setImage(strongSelf.readAll, for: .normal)
                }
            } else {
                if RefereeRankingPVEViewController.read == true {
                    RefereeRankingPVEViewController.read = false
                    NotificationCenter.default.post(name: RefereeRankingPVEViewController.notificationName, object: nil, userInfo: ["isRead": RefereeRankingPVEViewController.read])
                    strongSelf.announcementButton.setImage(strongSelf.unreadSome, for: .normal)
                }
            }
        }
    }
    
    func listen(_ _ : [String : Any]){
    }
    
    @IBAction func announcementButtonPressed(_ sender: UIButton) {
        showRefereeMessagePopUp(messages: RefereeRankingPVEViewController.messages)
    }
    
    @IBAction func settingButtonPressed(_ sender: UIButton) {
    }
    
    private func configureTableView() {
        leaderBoard.delegate = self
        leaderBoard.dataSource = self
        leaderBoard.register(RefereeTableViewCell.self, forCellReuseIdentifier: RefereeTableViewCell.identifier)
        leaderBoard.backgroundColor = .white
        leaderBoard.allowsSelection = false
        leaderBoard.separatorStyle = .none
        leaderBoard.refreshControl = refreshController
        settingRefreshControl()
    }
    
    private func settingRefreshControl() {
        refreshController.addTarget(self, action: #selector(self.refreshFunction), for: .valueChanged)
        refreshController.tintColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1)
        refreshController.attributedTitle = NSAttributedString(string: "reloading,,,", attributes: [ NSAttributedString.Key.foregroundColor: UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1) , NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 15)!])
    }
    
    @objc func refreshFunction() {
        T.getTeamList(gameCode)
        refreshController.endRefreshing()
        leaderBoard.reloadData()
    }
}
// MARK: - TableView
extension RefereeRankingPVEViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = leaderBoard.dequeueReusableCell(withIdentifier: RefereeTableViewCell.identifier, for: indexPath) as! RefereeTableViewCell
        let team = teamList[indexPath.section]
        let teamNum = String(team.number)
        let points = String(team.points)
        cell.configureRankTableViewCell(imageName: team.iconName, teamNum: "Team \(teamNum)", teamName: team.name, points: points, showScore: self.showScore)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return teamList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return 1
     }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
}
// MARK: - TeamProtocol
extension RefereeRankingPVEViewController: TeamUpdateListener {
    func updateTeams(_ teams: [Team]) {
        self.teamList = teams
        leaderBoard.reloadData()
    }
}
// MARK: - HostProtocol
extension RefereeRankingPVEViewController: HostUpdateListener {
    func updateHost(_ host: Host) {
        self.showScore = host.showScoreboard
        leaderBoard.reloadData()
        let msgList = RefereeRankingPVEViewController.messages
        if (msgList.count >= host.announcements.count) {
            var count = 0
            for ind in msgList.indices {
                if (ind - count >= host.announcements.count) {
                  break;
                }
                let text = msgList[ind]
                if ((text != host.announcements[ind - count]) && RefereeRankingPVEViewController.readMsgList.contains(text)) {
                    if let index = RefereeRankingPVEViewController.readMsgList.firstIndex(of: text) {
                        RefereeRankingPVEViewController.readMsgList.remove(at: index)
                    }
                    if (msgList.count > host.announcements.count) {
                        count += 1
                    }
                }
            }
            RefereeRankingPVEViewController.messages = host.announcements
        } else {
            RefereeRankingPVEViewController.messages = host.announcements
        }
    }
}
