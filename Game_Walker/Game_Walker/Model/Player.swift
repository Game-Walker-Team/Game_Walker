//
//  Player.swift
//  Game_Walker
//
//  Created by Paul on 6/13/22.
//

import Foundation

struct Player: Codable, Equatable {
    var gamecode: String = ""
    var name: String = ""
    
    enum CodingKeys: String, CodingKey {
        case gamecode
        case name
    }
    
}
