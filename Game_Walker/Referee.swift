//
//  Referee.swift
//  Game_Walker
//
//  Created by Paul on 6/13/22.
//

import Foundation

struct Referee : Codable, Equatable {
    var gamecode : String = ""
    var name : String = ""
    var station : Station
    
    enum CodingKeys: String, CodingKey {
        case gamecode
        case name
        case station
    }
    
    mutating func joinGame(name: String, gamecode : String) {
        self.name = name
        self.gamecode = gamecode
    }
    
    mutating func givePoints(team: Team, points: Int) {
        var temp = team
        temp.points += points
    }
}
