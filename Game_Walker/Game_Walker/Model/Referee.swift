//
//  Referee.swift
//  Game_Walker
//
//  Created by Paul on 6/13/22.
//

import Foundation

struct Referee: Codable, Equatable {
    var gamecode: String = ""
    var name: String = ""
    var stationName: String = ""
    var assigned = false
    
    enum CodingKeys: String, CodingKey {
        case gamecode
        case name
        case stationName
        case assigned
    }
}
