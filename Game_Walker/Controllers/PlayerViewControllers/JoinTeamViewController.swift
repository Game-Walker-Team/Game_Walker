//
//  PlayerFrame3_2.swift
//  Game_Walker
//
//  Created by Noah Kim on 6/16/22.
//

import Foundation
import UIKit

class JoinTeamViewController: BaseViewController {
    
    @IBOutlet weak var joinTeamButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var selectedIndex: Int?
    private var teamList: [Team] = []
    private var currentPlayer: Player = UserData.readPlayer("player") ?? Player()
    private var gameCode: String = UserData.readGamecode("gamecode") ?? ""
    private let refreshController: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        T.delegate_teamList = self
        configureCollectionView()
        T.getTeamList(gameCode)
    }
    
    private func configureCollectionView() {
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        collectionView.register(TeamIconCollectionViewCell.self, forCellWithReuseIdentifier: TeamIconCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = false
        collectionView.refreshControl = refreshController
        settingRefreshControl()
    }

    private func settingRefreshControl() {
        refreshController.addTarget(self, action: #selector(self.refreshFunction), for: .valueChanged)
        refreshController.tintColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1)
        refreshController.attributedTitle = NSAttributedString(string: "reloading,,,", attributes: [ NSAttributedString.Key.foregroundColor: UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1) , NSAttributedString.Key.font: UIFont(name: "Dosis-Regular", size: 15)!])
    }
    
    @objc func refreshFunction() {
        T.getTeamList(gameCode)
        refreshController.endRefreshing()
        collectionView.reloadData()
    }

    @IBAction func joinTeamButtonPressed(_ sender: UIButton) {
        if let selectedIndex = selectedIndex {
            UserData.writeTeam(teamList[selectedIndex], "team")
            T.joinTeam(gameCode, teamList[selectedIndex].name, currentPlayer)
            Task {
                try await Task.sleep(nanoseconds: 250_000_000)
                performSegue(withIdentifier: "goToPF44", sender: self)
            }
        } else {
            alert(title: "No Team Selected", message: "Please select your team")
            return
        }
    }
}

// MARK: - UICollectionViewDelegate
extension JoinTeamViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TeamIconCollectionViewCell else { return }
            if selectedIndex == indexPath.row {
                collectionView.deselectItem(at: indexPath, animated: true)
                cell.layer.borderWidth = 0
                selectedIndex = nil
            } else {
                selectedIndex = indexPath.row
                cell.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
                cell.layer.borderWidth = 1
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TeamIconCollectionViewCell else { return }
        cell.layer.borderWidth = 0
        selectedIndex = nil
    }
}

// MARK: - UICollectionViewDataSource
extension JoinTeamViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return teamList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TeamIconCollectionViewCell.identifier , for: indexPath) as! TeamIconCollectionViewCell
        let team = teamList[indexPath.item]
        cell.configureJoinTeamCell(imageName: team.iconName, teamName: team.name)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension JoinTeamViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 110)
    }
}

//MARK: - TeamProtocols
extension JoinTeamViewController: TeamList {
    func listOfTeams(_ teams: [Team]) {
        self.teamList = teams
        self.collectionView?.reloadData()
    }
}

