//
//  HostRankingTableViewCell.swift
//  Game_Walker
//
//  Created by Noah Kim on 2/2/23.
//

import Foundation
import UIKit

class HostRankingTableViewCell: UITableViewCell {
    
    static let identifier = "HostRankingTableViewCell"
    
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
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Bold", size: 20)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var teamNameLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Regular", size: 15)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Dosis-Bold", size: 20)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var stationNameLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Regular", size: 15)
        label.numberOfLines = 1
//        label.adjustsFontSizeToFitWidth = true
//        label.minimumScaleFactor = 0.5
        return label
    }()

    private lazy var borderView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 85, width: 330, height: 2))
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configureRankTableViewCell(imageName: String, teamNum: String, teamName: String, stationName: String, points: Int, showScore: Bool) {
        contentView.addSubview(containerView)
        containerView.addSubview(teamIconImage)
        containerView.addSubview(teamNumLabel)
        containerView.addSubview(teamNameLabel)
        containerView.addSubview(stationNameLabel)
        containerView.addSubview(scoreLabel)
        containerView.addSubview(borderView)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            teamIconImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            teamIconImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            teamIconImage.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1),
            teamIconImage.widthAnchor.constraint(equalTo: teamIconImage.heightAnchor),
            
            teamNumLabel.leadingAnchor.constraint(equalTo: teamIconImage.layoutMarginsGuide.trailingAnchor, constant: 5),
            teamNumLabel.topAnchor.constraint(equalTo: teamIconImage.topAnchor, constant: 5),
            teamNumLabel.heightAnchor.constraint(equalTo: teamIconImage.heightAnchor, multiplier: 0.5),
            teamNumLabel.widthAnchor.constraint(equalToConstant: 120),
            
            teamNameLabel.leadingAnchor.constraint(equalTo: teamIconImage.layoutMarginsGuide.trailingAnchor, constant: 5),
            teamNameLabel.bottomAnchor.constraint(equalTo: teamIconImage.bottomAnchor, constant: -5),
            teamNameLabel.heightAnchor.constraint(equalTo: teamIconImage.heightAnchor, multiplier: 0.5),
            teamNameLabel.widthAnchor.constraint(equalToConstant: 120),
            
            stationNameLabel.leadingAnchor.constraint(equalTo: teamNumLabel.layoutMarginsGuide.trailingAnchor),
            stationNameLabel.trailingAnchor.constraint(equalTo: scoreLabel.layoutMarginsGuide.leadingAnchor, constant: -5),
            stationNameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            stationNameLabel.heightAnchor.constraint(equalTo: teamNameLabel.heightAnchor, multiplier: 1),
            
            scoreLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            scoreLabel.centerYAnchor.constraint(equalTo: teamIconImage.centerYAnchor),
            scoreLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1),
            scoreLabel.widthAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.8),
            
            borderView.widthAnchor.constraint(equalTo: containerView.layoutMarginsGuide.widthAnchor),
            borderView.heightAnchor.constraint(equalToConstant: 2.0),
            borderView.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
            borderView.topAnchor.constraint(equalTo: teamIconImage.bottomAnchor, constant: 10)
        ])
        
        teamIconImage.image = UIImage(named: imageName)
        teamNameLabel.text = teamName
        teamNumLabel.text = teamNum
        stationNameLabel.text = stationName
        scoreLabel.text = String(points)
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
