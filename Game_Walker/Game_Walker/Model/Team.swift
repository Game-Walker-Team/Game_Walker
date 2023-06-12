//
//  Team.swift
//  Game_Walker
//
//  Created by Paul on 6/13/22.
//

import Foundation
import UIKit

struct Team : Codable, Equatable {
    var gamecode : String = ""
    var name : String = ""
    var number: Int = 0
    var players : [Player] = []
    var points : Int = 0
    var currentStation : String
    var nextStation : String
    var iconName: String

    
    enum CodingKeys: String, CodingKey {
        case gamecode
        case name
        case number
        case players
        case points
        case currentStation
        case nextStation
        case iconName
    }
}
