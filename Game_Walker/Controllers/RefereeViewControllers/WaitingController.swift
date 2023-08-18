//
//  WaitingController.swift
//  Game_Walker
//
//  Created by 김현식 on 9/17/22.
//

import Foundation
import UIKit
import PromiseKit

class WaitingController: BaseViewController {
    
    private var gameCode = UserData.readGamecode("refereeGamecode")!
    private var referee = UserData.readReferee("Referee")!
    private var timer: Timer?
    
    private var isGetStationCalled = false
    private var currentIndex: Int = 0
    private var index : Int = 0
    let waitingImagesArray = ["waiting 1.png", "waiting 2.png", "waiting 3.png"]
    private var waitingImageViewWidthConstraint: NSLayoutConstraint?
    
    private var algorithm : [[Int]] = []
    private var stationList : [Station] = []
    private var station : Station = Station()
    private var pvp : Bool = true
    private var number : Int = 0
    private var teams : [Team] = []
    private var updatedTeamOrder : [Team] = []
    
    override func viewDidLoad() {
        callProtocols()
        //testing1()
        //testing2()
        //testing3()
        //testing4()
        setTeamOrder()
        Task {
//            T.getTeamList(gameCode)
//            S.getStationList(gameCode)
//            await S.addStation(gameCode, Station(name: "UpdateTesting", number : 11, pvp : false))
//            await S.updateTeamOrder(gameCode, "UpdateTesting", self.updatedTeamOrder)
//            await S.updateTeamOrder(gameCode, self.station.name, self.updatedTeamOrder)
        }
        addSubviews()
        makeConstraints()
        animateWaitingScreen()
        super.viewDidLoad()
    }
    
// MARK: - SetTeamOrder
    func setTeamOrder() {
        //Function is being called after S.getStation(referee.stationName) called and that referee is assigned.
        var pvp_count : Int = 0
        var column_number_index : Int = 0
        var left : [Int] = []
        var right : [Int] = []
        var teamNumOrder : [Int] = []
        var teamOrder : [Team] = []
        print(self.stationList)
        for station in self.stationList {
            if station.pvp == true {
                pvp_count += 1
            }
        }
        print(pvp_count)
        if self.station.pvp {
            column_number_index = 2 * station.number - 2
            var left = self.algorithm.map({ $0[column_number_index] })
            var right = self.algorithm.map({ $0[column_number_index + 1] })
            var right_index : Int = 0
            for left_index in left {
                teamNumOrder.append(left_index)
                teamNumOrder.append(right[right_index])
                right_index += 1
            }
        }
        else {
            column_number_index = 2 * pvp_count + station.number - pvp_count - 1
            print(column_number_index)
            print(self.algorithm)
            teamNumOrder = self.algorithm.map({ $0[column_number_index] })
            print(teamNumOrder)
        }
        print(teamNumOrder)
        for team_num in teamNumOrder {
            if team_num == 0 {
                teamOrder.append(Team())
            }
            for team in self.teams {
                if team_num == team.number {
                    teamOrder.append(team)
                }
            }
        }
        print(teamOrder)
        self.updatedTeamOrder = teamOrder
    }
    
    
    // Testing Case # 1
    func testing1() {
        self.algorithm = [[1, 2, 3, 4, 5, 6, 7, 8],
                          [2, 3, 4, 5, 6, 7, 8, 1],
                          [3, 4, 5, 6, 7, 8, 1, 2],
                          [4, 5, 6, 7, 8, 1, 2, 3],
                          [5, 6, 7, 8, 1, 2, 3, 4],
                          [6, 7, 8, 1, 2, 3, 4, 5],
                          [7, 8, 1, 2, 3, 4, 5, 6],
                          [8, 1, 2, 3, 4, 5, 6, 7]]
        self.stationList = [Station(number : 1, pvp : true), Station(number : 2, pvp : true), Station(number : 3, pvp : true), Station(number : 4, pvp : false), Station(number : 5, pvp : false)]
        self.station = Station(number : 5, pvp : false)
    }
    
    // Testing Case # 2
    func testing2() {
        self.algorithm = [[2, 3, 4, 5, 6, 7, 8, 1],
                          [3, 4, 5, 6, 7, 8, 1, 2],
                          [4, 5, 6, 7, 8, 1, 2, 3],
                          [5, 6, 7, 8, 1, 2, 3, 4],
                          [6, 7, 8, 1, 2, 3, 4, 5],
                          [7, 8, 1, 2, 3, 4, 5, 6],
                          [8, 1, 2, 3, 4, 5, 6, 7],
                          [1, 2, 3, 4, 5, 6, 7, 8]]
        self.stationList = [Station(number : 1, pvp : true), Station(number : 2, pvp : true), Station(number : 3, pvp : true), Station(number : 4, pvp : false), Station(number : 5, pvp : false)]
        self.station = Station(number : 2, pvp : true)
    }
    
    // Testing Case # 3
    func testing3() {
        self.algorithm = [[1, 2, 3, 4, 5, 6, 7, 8],
                          [2, 3, 4, 5, 6, 7, 8, 1],
                          [3, 4, 5, 6, 7, 8, 1, 2],
                          [6, 7, 8, 1, 2, 3, 4, 5],
                          [7, 8, 1, 2, 3, 4, 5, 6],
                          [8, 1, 2, 3, 4, 5, 6, 7],
                          [4, 5, 6, 7, 8, 1, 2, 3],
                          [5, 6, 7, 8, 1, 2, 3, 4]]
        self.stationList = [Station(number : 1, pvp : true), Station(number : 2, pvp : true), Station(number : 3, pvp : true), Station(number : 4, pvp : false), Station(number : 5, pvp : false)]
        self.station = Station(number : 4, pvp : false)
    }
    
    // Testing Case # 4
    func testing4() {
        self.algorithm = [[1, 2, 3, 4, 5, 6, 7, 8],
                          [2, 3, 4, 5, 6, 7, 8, 1],
                          [3, 4, 5, 6, 7, 8, 1, 2],
                          [6, 7, 8, 1, 2, 0, 4, 5],
                          [7, 8, 1, 2, 3, 4, 5, 6],
                          [8, 1, 2, 3, 4, 0, 6, 7],
                          [4, 5, 6, 7, 8, 1, 2, 3],
                          [5, 6, 7, 8, 1, 2, 3, 4]]
        self.stationList = [Station(number : 1, pvp : true), Station(number : 2, pvp : true), Station(number : 3, pvp : true), Station(number : 4, pvp : false), Station(number : 5, pvp : false)]
        self.station = Station(number : 4, pvp : false)
        self.teams = [Team(number: 1), Team(number: 2), Team(number: 3), Team(number: 4), Team(number: 5), Team(number: 6), Team(number: 7), Team(number: 8)]
    }
    
    //MARK: - Animating Screen
    func animateWaitingScreen() {
        if timer != nil {
            return
        }
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if self.currentIndex == 2 {
                self.waitingImageViewWidthConstraint?.isActive = false
                self.waitingImageViewWidthConstraint = self.waitingImageView.widthAnchor.constraint(equalTo: self.view.widthAnchor,multiplier: 0.47)
                self.waitingImageViewWidthConstraint?.isActive = true
                self.currentIndex = 0
                self.performSegue(withIdentifier: "goToPVE", sender: self)
            }
            else {
                self.currentIndex += 1
                if self.currentIndex == 1 {
                    self.waitingImageViewWidthConstraint?.isActive = false
                    self.waitingImageViewWidthConstraint = self.waitingImageView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.50)
                    self.waitingImageViewWidthConstraint?.isActive = true
                }
                else {
                    self.waitingImageViewWidthConstraint?.isActive = false
                    self.waitingImageViewWidthConstraint = self.waitingImageView.widthAnchor.constraint(equalTo: self.view.widthAnchor,multiplier: 0.53)
                    self.waitingImageViewWidthConstraint?.isActive = true
                }
            }
            self.waitingImageView.image = UIImage(named: self.waitingImagesArray[self.currentIndex])
            if self.referee.assigned && !self.isGetStationCalled {
                if self.pvp {
                    self.performSegue(withIdentifier: "goToPVP", sender: self)
                }
                else {
                    self.performSegue(withIdentifier: "goToPVE", sender: self)
                }
            }
            if self.referee.assigned && self.isGetStationCalled {
                self.timer?.invalidate()
            }
            self.view.layoutIfNeeded() 
        }
    }
    
//MARK: - UI elements
    private lazy var gameIconView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 311, height: 146.46))
        imageView.image = UIImage(named: "game 1")
        return imageView
    }()
    
    private lazy var waitingImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 174.4, height: 57))
        imageView.image = UIImage(named: "waiting 1")
        return imageView
    }()
    
    func makeConstraints() {
        gameIconView.translatesAutoresizingMaskIntoConstraints = false
        gameIconView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        gameIconView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.36).isActive = true
        gameIconView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.18).isActive = true
        gameIconView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.83).isActive = true
        waitingImageView.translatesAutoresizingMaskIntoConstraints = false
        waitingImageView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.07).isActive = true
        waitingImageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: self.view.bounds.height * 0.567).isActive = true
        waitingImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: self.view.bounds.width * 0.24).isActive = true
        waitingImageViewWidthConstraint = waitingImageView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.47)
        waitingImageViewWidthConstraint?.isActive = true
    }
    
    func addSubviews() {
        self.view.addSubview(gameIconView)
        self.view.addSubview(waitingImageView)
    }
}

// MARK: - Protocols
extension WaitingController: RefereeUpdateListener, StationList, HostUpdateListener, TeamList {
    func updateReferee(_ referee: Referee) {
        UserData.writeReferee(referee, "Referee")
        self.referee = UserData.readReferee("Referee")!
        for station in self.stationList {
            if self.referee.stationName == station.name {
                self.station = station
            }
        }
    }
    
    func listOfStations(_ stations: [Station]) {
        self.stationList = stations
        self.isGetStationCalled = true
    }
    
    func updateHost(_ host: Host) {
        self.algorithm = host.algorithm
        if self.algorithm != [] {
            setTeamOrder()
        }
    }
    
    func listOfTeams(_ teams: [Team]) {
        self.teams = teams
    }
    
    func listen(_ _ : [String : Any]){
    }
    
    func callProtocols() {
        R.delegates.append(self)
        R.listenReferee(self.gameCode, UserData.readUUID()!, onListenerUpdate: listen(_:))
        S.delegate_stationList = self
        H.delegates.append(self)
        H.listenHost(self.gameCode, onListenerUpdate: listen(_:))
        T.delegate_teamList = self
    }
}


