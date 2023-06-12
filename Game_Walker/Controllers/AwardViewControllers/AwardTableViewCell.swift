//
//  AwardTableViewCell.swift
//  Game_Walker
//
//  Created by Noah Kim on 2/20/23.
//

import Foundation
import UIKit

class AwardTableViewCell: UITableViewCell {
    
    static let identifier = "AwardTableViewCell"
    
    private let teamNumLabel: UILabel = {
        let label = UILabel()
        label.clipsToBounds = true
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-SemiBold", size: 15)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private var teamIconImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var teamNameLabel: UILabel = {
       let label = UILabel()
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Regular", size: 13)
        label.numberOfLines = 0
        return label
    }()
    
    private var scoreLabel: UILabel = {
        let label = UILabel()
        label.clipsToBounds = true
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Bold", size: 18)
        label.numberOfLines = 0
        return label
    }()

    public let borderView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 85, width: 255, height: 2))
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 0.98, green: 0.204, blue: 0, alpha: 1).cgColor
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    
    func configureRankTableViewCell(imageName: String, teamNum: String, teamName: String, points: Int) {
        contentView.addSubview(containerView)
        containerView.addSubview(teamIconImage)
        containerView.addSubview(teamNameLabel)
        containerView.addSubview(scoreLabel)
        containerView.addSubview(borderView)
        containerView.addSubview(teamNumLabel)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 270),
            containerView.heightAnchor.constraint(equalToConstant: 100),
            
            teamNumLabel.centerYAnchor.constraint(equalTo: containerView.layoutMarginsGuide.centerYAnchor),
            teamNumLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: teamIconImage.layoutMarginsGuide.trailingAnchor, multiplier: 1),
            teamNumLabel.widthAnchor.constraint(equalToConstant: 65),
            teamNumLabel.heightAnchor.constraint(equalToConstant: 25),
            
            teamNameLabel.leadingAnchor.constraint(equalTo: teamNumLabel.layoutMarginsGuide.trailingAnchor, constant: 15),
            teamNameLabel.trailingAnchor.constraint(equalTo: scoreLabel.layoutMarginsGuide.leadingAnchor, constant: -15),
            teamNameLabel.widthAnchor.constraint(equalToConstant: 85),
            teamNameLabel.centerYAnchor.constraint(equalTo: containerView.layoutMarginsGuide.centerYAnchor),
            teamNameLabel.heightAnchor.constraint(equalToConstant: 25),
            
            scoreLabel.trailingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.trailingAnchor, constant: 0),
            scoreLabel.centerYAnchor.constraint(equalTo: containerView.layoutMarginsGuide.centerYAnchor),
            scoreLabel.widthAnchor.constraint(equalToConstant: 35),
            scoreLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        teamIconImage.leadingAnchor.constraint(equalTo: containerView.layoutMarginsGuide.leadingAnchor).isActive = true
        teamIconImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        teamIconImage.widthAnchor.constraint(equalToConstant: 60).isActive = true
        teamIconImage.heightAnchor.constraint(equalToConstant: 60).isActive = true
        teamIconImage.image = UIImage(named: imageName)
        teamNameLabel.text = teamName
        teamNumLabel.text = teamNum
        scoreLabel.text = String(points)
    }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
}
