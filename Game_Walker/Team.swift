//
//  Team.swift
//  Game_Walker
//
//  Created by Paul on 6/13/22.
//

import Foundation

struct Team : Codable, Equatable {
    var name : String = ""
    var players : [Player] = []
    var points : Int
    var currentStation : String
    var nextStation : String
    
    enum CodingKeys: String, CodingKey {
        case name
        case players
        case points
        case currentStation
        case nextStation
    }
    
    
    mutating func getPoints(points: Int) {
        self.points += points
    }
    
    mutating func addPlayer(player: Player) {
        players.append(player)
    }
    
    mutating func removePlayer(player: Player) {
        if let index = self.players.firstIndex(of: player) {
            players.remove(at: index)
        }
    }
}
