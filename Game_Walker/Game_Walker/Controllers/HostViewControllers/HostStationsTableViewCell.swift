//
//  HostStationsTableViewCell.swift
//  Game_Walker
//
//  Created by Jin Kim on 8/18/22.
//

import UIKit

class HostStationsTableViewCell: UITableViewCell {

    @IBOutlet weak var cellentireview: UIView!
    @IBOutlet weak var stationLabel: UILabel!
    
//    private lazy var cellEntireView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .clear
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.clipsToBounds = true
//        view.contentMode = .scaleAspectFill
//        return view
//    }()
//
//    var backgroundView: UIImageView = {
//        let view = UIImageView()
//        view.contentMode = .scaleAspectFill
//        view.clipsToBounds = true
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.image = UIImage(named: "name box fill 1")
//        view.alpha = 0.5
//        return view
//    }()
    
    func configureStationCell(stationName: String) {
        stationLabel.text = stationName
        cellentireview.heightAnchor.constraint(equalTo: cellentireview.widthAnchor, multiplier: 0.23).isActive = true
//        contentView.addSubview(containerView)
//        containerView.addSubview(backGroundView)
    }
    
    
}
