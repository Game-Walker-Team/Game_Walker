//
//  RefereeTeamTableViewCell.swift
//  Game_Walker
//
//  Created by 김현식 on 1/30/23.
//

import Foundation
import UIKit

class RefereeTableViewCell: UITableViewCell {
    
    static let identifier = "RefereeTableViewCell"
    private let blindImage = UIImage(named: "blindScore")
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var teamIconImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var teamNumLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-SemiBold", size: fontSize(size: 20))
        label.numberOfLines = 1
        return label
        
    }()
    
    private lazy var teamNameLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Regular", size: fontSize(size: 15))
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-SemiBold", size: fontSize(size: 22))
        label.numberOfLines = 0
        return label
    }()

    private let borderView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configureRankTableViewCell(imageName: String, teamNum: String, teamName: String, points: String, showScore: Bool) {
        contentView.addSubview(containerView)
        containerView.addSubview(borderView)
        containerView.addSubview(teamIconImage)
        containerView.addSubview(scoreLabel)
        containerView.addSubview(teamNumLabel)
        containerView.addSubview(teamNameLabel)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            teamIconImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            teamIconImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            teamIconImage.heightAnchor.constraint(equalToConstant: 70),
            teamIconImage.widthAnchor.constraint(equalToConstant: 70),
            
            NSLayoutConstraint(item: teamNumLabel, attribute: .leading, relatedBy: .equal, toItem: teamIconImage, attribute: .trailing, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: teamNumLabel, attribute: .trailing, relatedBy: .equal, toItem: scoreLabel, attribute: .leading, multiplier: 1, constant: 0),
            teamNumLabel.topAnchor.constraint(equalTo: teamIconImage.topAnchor, constant: 5),
            teamNumLabel.heightAnchor.constraint(equalTo: teamIconImage.heightAnchor, multiplier: 0.5),
            
            teamNameLabel.bottomAnchor.constraint(equalTo: teamIconImage.bottomAnchor, constant: -5),
            teamNameLabel.heightAnchor.constraint(equalTo: teamIconImage.heightAnchor, multiplier: 0.5),
            teamNameLabel.leadingAnchor.constraint(equalTo: teamNumLabel.leadingAnchor),
            teamNameLabel.trailingAnchor.constraint(equalTo: teamNumLabel.trailingAnchor),
            
            scoreLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            scoreLabel.centerYAnchor.constraint(equalTo: teamIconImage.centerYAnchor),
            scoreLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1),
            scoreLabel.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.8),
            
            borderView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            borderView.heightAnchor.constraint(equalToConstant: 3.0),
            borderView.topAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        teamIconImage.image = UIImage(named: imageName)
        teamNameLabel.text = teamName
        teamNumLabel.text = teamNum
        scoreLabel.text = points
        if (showScore) {
            scoreLabel.textColor = .black
        } else {
            scoreLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.35)
        }
    }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
}

