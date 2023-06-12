//
//  AwardViewController.swift
//  Game_Walker
//
//  Created by Noah Kim on 2/20/23.
//

import Foundation
import UIKit

class AwardViewController: UIViewController {
    
    @IBOutlet weak var firstPlaceImage: UIImageView!
    @IBOutlet weak var firstPlaceTeamNum: UILabel!
    @IBOutlet weak var firstPlaceTeamName: UILabel!
    @IBOutlet weak var firstPlacePoints: UILabel!
    
    @IBOutlet weak var secondPlaceImage: UIImageView!
    @IBOutlet weak var secondPlaceTeamNum: UILabel!
    @IBOutlet weak var secondPlaceTeamName: UILabel!
    @IBOutlet weak var secondPlacePoints: UILabel!
    
    @IBOutlet weak var thirdPlaceImage: UIImageView!
    @IBOutlet weak var thirdPlaceTeamNum: UILabel!
    @IBOutlet weak var thirdPlaceTeamName: UILabel!
    @IBOutlet weak var thirdPlacePoints: UILabel!
    
    @IBOutlet weak var leaderBoard: UITableView!
    private let cellSpacingHeight: CGFloat = 3
    
    private let gameCode = UserData.readGamecode("gamecode") ?? ""
    private var teamList: [Team] = []
    private var newTeamList: [Team] = []
    private var firstPlace: Team?
    private var secondPlace: Team?
    private var thirdPlace: Team?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        T.delegate_teamList = self
        T.getTeamList(gameCode)
        Task {
            try await Task.sleep(nanoseconds: 280_000_000)
            self.firstPlace = teamList.first
            self.secondPlace = teamList[1]
            self.thirdPlace = teamList[2]
            configureTopThree()
            newTeamList = getNewTeamList(teamList)
            configureLeaderboard()
        }
    }
    
    func configureLeaderboard() {
        leaderBoard.delegate = self
        leaderBoard.dataSource = self
        leaderBoard.register(AwardTableViewCell.self, forCellReuseIdentifier: AwardTableViewCell.identifier)
        leaderBoard.backgroundColor = .white
        leaderBoard.allowsSelection = false
        leaderBoard.separatorStyle = .none
    }
    
    func configureTopThree() {
        guard let firstPlace = firstPlace, let secondPlace = secondPlace, let thirdPlace = thirdPlace else { return }
        firstPlaceImage.image = UIImage(named: firstPlace.iconName)
        firstPlaceTeamNum.text = "Team \(firstPlace.number)"
        firstPlaceTeamName.text = firstPlace.name
        firstPlacePoints.text = String(firstPlace.points)
        
        secondPlaceImage.image = UIImage(named: secondPlace.iconName)
        secondPlaceTeamNum.text = "Team \(secondPlace.number)"
        secondPlaceTeamName.text = secondPlace.name
        secondPlacePoints.text = String(secondPlace.points)
        
        thirdPlaceImage.image = UIImage(named: thirdPlace.iconName)
        thirdPlaceTeamNum.text = "Team \(thirdPlace.number)"
        thirdPlaceTeamName.text = thirdPlace.name
        thirdPlacePoints.text = String(thirdPlace.points)
    }
    
    func getNewTeamList(_ teamList: [Team]) -> [Team] {
        var i = 0
        var newList = teamList
        while (i <= 2) {
            newList.remove(at: 0)
            i += 1
        }
        let order: (Team, Team) -> Bool = {(lhs, rhs) in
            return lhs.points > rhs.points
        }
        newList.sort(by: order)
        return newList
    }
}
// MARK: - teamList
extension AwardViewController: TeamList {
    func listOfTeams(_ teams: [Team]) {
        self.teamList = teams
        leaderBoard.reloadData()
    }
}
// MARK: - tableView
extension AwardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = leaderBoard.dequeueReusableCell(withIdentifier: AwardTableViewCell.identifier, for: indexPath) as! AwardTableViewCell
        let teamNum = String(newTeamList[indexPath.section].number)
        cell.configureRankTableViewCell(imageName: newTeamList[indexPath.section].iconName, teamNum: "Team \(teamNum)", teamName: newTeamList[indexPath.section].name, points: newTeamList[indexPath.section].points)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return newTeamList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
}
