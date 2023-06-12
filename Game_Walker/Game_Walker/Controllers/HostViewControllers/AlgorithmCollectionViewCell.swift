//
//  AlgorithmCollectionViewCell.swift
//  Game_Walker
//
//  Created by Jin Kim on 1/11/23.
//

import UIKit

class AlgorithmCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var algorithmCellBox: UIImageView!
    @IBOutlet weak var teamnumLabel: UILabel!
    
    static let identifier = "AlgorithmCollectionViewCell"
    
    func configureAlgorithmNormalCell(cellteamnum : Int) {
        teamnumLabel.text = String(cellteamnum)
    }
    
    func configureAlgorithmSpecialCell1() {
        teamnumLabel.text = ""
        algorithmCellBox.backgroundColor = UIColor.red
    }
    
    func configureAlgorithmSpecialCell2(cellteamnum : Int) {
        teamnumLabel.text = String(cellteamnum)
        algorithmCellBox.backgroundColor = UIColor.blue
    }
    
    func changeRed() {
        teamnumLabel.textColor = UIColor.red
    }
}
