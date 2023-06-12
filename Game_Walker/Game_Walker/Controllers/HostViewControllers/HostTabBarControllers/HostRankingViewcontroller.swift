//
//  HostRankingViewcontroller.swift
//  Game_Walker
//
//  Created by Noah Kim on 2/1/23.
//

import Foundation
import UIKit

class HostRankingViewcontroller: UIViewController {
    
    @IBOutlet weak var leaderBoard: UITableView!
    @IBOutlet weak var announcementBtn: UIButton!
    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet weak var switchBtn: CustomSwitchButton!
    @IBOutlet weak var endGameBtn: UIButton!
    
    private var messages: [String]?
    private var teamList: [Team] = []
    private var selectedIndex: Int?
    private let cellSpacingHeight: CGFloat = 1
    private var gameCode: String = UserData.readGamecode("gamecode") ?? ""
    private let refreshController: UIRefreshControl = UIRefreshControl()
    private var showScore = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        configureTableView()
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "newDataNotif"), object: nil)
    }
    
    @objc func refresh() {
        H.getHost(gameCode)
        Task {
            try await Task.sleep(nanoseconds: 180_000_000)
            HostMessageViewController.messages = self.messages
        }
    }
    
    func listen(_ _ : [String : Any]){
    }
    
    @IBAction func announcementButtonPressed(_ sender: UIButton) {
        H.getHost(gameCode)
        showHostMessagePopUp(messages: messages)
    }
    
    @IBAction func settingButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func switchBtnPressed(_ sender: CustomSwitchButton) {
        //Update showScoreBoard of host on the server
        //leaderBoard.reloadData()
    }
    
    @IBAction func endGameBtnPressed(_ sender: UIButton) {
        //present end game warning popup
        showWarningPopUp(announcement: "", source: "")
    }
    
    private func setDelegates() {
        T.delegates.append(self)
        H.delegate_getHost = self
        switchBtn.delegate = self
        T.listenTeams(gameCode, onListenerUpdate: listen(_:))
        H.getHost(gameCode)
        self.showScore = switchBtn.isOn
    }
    
    private func configureTableView() {
        leaderBoard.delegate = self
        leaderBoard.dataSource = self
        leaderBoard.register(HostRankingTableViewCell.self, forCellReuseIdentifier: HostRankingTableViewCell.identifier)
        leaderBoard.backgroundColor = .white
        leaderBoard.allowsSelection = true
        leaderBoard.separatorStyle = .none
        leaderBoard.allowsMultipleSelection = false
    }
}
// MARK: - tableView
extension HostRankingViewcontroller: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = leaderBoard.dequeueReusableCell(withIdentifier: HostRankingTableViewCell.identifier, for: indexPath) as! HostRankingTableViewCell
        let teamNum = String(teamList[indexPath.section].number)
        let team = teamList[indexPath.section]
        cell.configureRankTableViewCell(imageName: team.iconName, teamNum: "Team \(teamNum)", teamName: team.name, stationName: team.currentStation, points: team.points, showScore: self.showScore)
        cell.selectionStyle = .none
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.section)
        let team = teamList[indexPath.section]
        let svc = HostGivePointsController(team: team, gameCode: self.gameCode)
        svc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        self.present(svc, animated: true)
        leaderBoard.deselectRow(at: indexPath, animated: true)
    }
}
// MARK: - TeamProtocol
extension HostRankingViewcontroller: TeamUpdateListener, GetHost {
    func updateTeams(_ teams: [Team]) {
        self.teamList = teams
        leaderBoard.reloadData()
    }
    
    func getHost(_ host: Host) {
        self.messages = host.announcements
    }
}
// MARK: - SwitchBtn
extension HostRankingViewcontroller: CustomSwitchButtonDelegate {
  func isOnValueChange(isOn: Bool) {
      self.showScore = isOn
      H.hide_show_score(gameCode, self.showScore)
      leaderBoard.reloadData()
  }
}
// MARK: - WarningViewPopUp
extension HostRankingViewcontroller {
    func showWarningPopUp(announcement: String, source: String) {
        let popUpViewController = endGameViewController(announcement: announcement, source: source)
        showWarningPopUp(popUpViewController: popUpViewController)
    }
    
    private func showWarningPopUp(popUpViewController: endGameViewController) {
        present(popUpViewController, animated: false, completion: nil)
    }
}
