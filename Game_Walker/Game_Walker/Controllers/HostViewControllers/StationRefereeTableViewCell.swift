//
//  StationRefereeTableViewCell.swift
//  Game_Walker
//
//  Created by Jin Kim on 8/27/22.
//

import UIKit

class StationRefereeTableViewCell: UITableViewCell {

    @IBOutlet weak var refereenameLabel: UILabel!
    
    func configureRefereeCell(refereeName: String) {
        refereenameLabel.text = refereeName
    }
}
