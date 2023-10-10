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
    
    static var localMessages: [Announcement] = []
    private var gameCode: String = UserData.readGamecode("gamecode") ?? ""
    private let refreshController: UIRefreshControl = UIRefreshControl()
    private var showScore = true
    
    private var timer = Timer()
    static var unread: Bool = false
    private var diff: Int?
    
    private let audioPlayerManager = AudioPlayerManager()
    
    static let notificationName = Notification.Name("readNotification")
    
    private let readAll = UIImage(named: "messageIcon")
    private let unreadSome = UIImage(named: "unreadMessage")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureGamecodeLabel()
        configureListeners()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
            guard let strongSelf = self else {
                return
            }
            let unread = strongSelf.checkUnreadAnnouncements(announcements: RefereeRankingPVEViewController.localMessages)
            RefereeRankingPVEViewController.unread = unread
            if unread{
                NotificationCenter.default.post(name: RefereeRankingPVEViewController.notificationName, object: nil, userInfo: ["unread":unread])
                strongSelf.announcementButton.setImage(strongSelf.unreadSome, for: .normal)
                strongSelf.audioPlayerManager.playAudioFile(named: "message", withExtension: "wav")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newDataNotif"), object: nil)
            } else {
                NotificationCenter.default.post(name: RefereeRankingPVEViewController.notificationName, object: nil, userInfo: ["unread":unread])
                strongSelf.announcementButton.setImage(strongSelf.readAll, for: .normal)
            }
        }
    }
    
    private func configureListeners(){
        T.delegates.append(self)
        H.delegates.append(self)
        T.listenTeams(gameCode, onListenerUpdate: listen(_:))
        H.listenHost(gameCode, onListenerUpdate: listen(_:))
    }
    
    private lazy var gameCodeLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 127, height: 42)
        let attributedText = NSMutableAttributedString()
        let gameCodeAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "GemunuLibre-Bold", size: 13) ?? UIFont.systemFont(ofSize: 13),
            .foregroundColor: UIColor.black
        ]
        let gameCodeAttributedString = NSAttributedString(string: "Game Code\n", attributes: gameCodeAttributes)
        attributedText.append(gameCodeAttributedString)
        let numberAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20),
            .foregroundColor: UIColor.black
        ]
        let numberAttributedString = NSAttributedString(string: gameCode, attributes: numberAttributes)
        attributedText.append(numberAttributedString)
        label.backgroundColor = .white
        label.attributedText = attributedText
        label.textColor = UIColor(red: 0, green: 0, blue: 0 , alpha: 1)
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = false
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func listen(_ _ : [String : Any]){
    }
    
    @IBAction func announcementButtonPressed(_ sender: UIButton) {
        showRefereeMessagePopUp(messages: RefereeRankingPVEViewController.localMessages)
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
    }
    
    private func configureGamecodeLabel() {
        view.addSubview(gameCodeLabel)
        NSLayoutConstraint.activate([
            gameCodeLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            gameCodeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: (self.navigationController?.navigationBar.frame.minY)!)
        ])
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
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamList.count
     }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85.0
    }
}
// MARK: - TeamProtocol
extension RefereeRankingPVEViewController: TeamUpdateListener {
    func updateTeams(_ teams: [Team]) {
        self.teamList = teams
        if self.showScore {
            leaderBoard.reloadData()
        }
    }
}
// MARK: - HostProtocol
extension RefereeRankingPVEViewController: HostUpdateListener {
    func updateHost(_ host: Host) {
        self.showScore = host.showScoreboard
        leaderBoard.reloadData()
        var hostAnnouncements = Array(host.announcements)
        if RefereeRankingPVEViewController.localMessages.count > hostAnnouncements.count {
            removeAnnouncementsNotInHost(from: &RefereeRankingPVEViewController.localMessages, targetArray: hostAnnouncements)
            NotificationCenter.default.post(name: RefereeRankingPVEViewController.notificationName, object: nil, userInfo: ["unread":RefereeRankingPVEViewController.unread])
        } else {
            for announcement in hostAnnouncements {
                if !RefereeRankingPVEViewController.localMessages.contains(announcement) {
                    RefereeRankingPVEViewController.localMessages.append(announcement)
                } else {
                    if let localIndex = RefereeRankingPVEViewController.localMessages.firstIndex(where: {$0.uuid == announcement.uuid}) {
                        if RefereeRankingPVEViewController.localMessages[localIndex].content != announcement.content {
                            RefereeRankingPVEViewController.localMessages[localIndex].content = announcement.content
                            RefereeRankingPVEViewController.localMessages[localIndex].readStatus = false
                        }
                    }
                }
            }
        }
    }
}
