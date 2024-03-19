//
//  IconCollectionViewCell.swift
//  Game_Walker
//
//  Created by Noah Kim on 6/17/22.
//

import UIKit

class TeamIconCollectionViewCell: UICollectionViewCell {
    
    private var imageName: String?

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private lazy var teamNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.font = UIFont(name: "Dosis-Regular", size: 10)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    private lazy var teamNumLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.font = UIFont(name: "Dosis-SemiBold", size: 13)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private let borderView = UIView(frame: CGRect(x: -5, y: 0, width: 70, height: 70))
    
    static let identifier = "IconCollectionViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCreateTeamCell(_ imageName: String) {
        contentView.addSubview(containerView)
        containerView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
        
        self.imageName = imageName
        imageView.image = UIImage(named: imageName)
    }
    
    func configureJoinTeamCell(imageName: String, teamName: String, teamNum: String) {
        self.imageName = imageName
        
        contentView.addSubview(imageView)
        contentView.addSubview(teamNameLabel)
        //contentView.addSubview(borderView)
        contentView.addSubview(teamNumLabel)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentView.frame.height * 0.04),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1),
            
            teamNumLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            teamNumLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 0),
            teamNumLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            teamNumLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            teamNumLabel.heightAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 0.15),
            
            teamNameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            teamNameLabel.topAnchor.constraint(equalTo: teamNumLabel.bottomAnchor, constant: 2),
            teamNameLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: 2),
            teamNameLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: -2),
            teamNameLabel.heightAnchor.constraint(equalTo: teamNumLabel.heightAnchor, multiplier: 2.5)
        ])
        
        imageView.image = UIImage(named: imageName)
        teamNameLabel.text = teamName
        teamNumLabel.text = teamNum
    }
//    func showBorder() {
//        containerView.layer.borderColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1).cgColor
//        containerView.layer.borderWidth = 3
//        containerView.layer.cornerRadius = containerView.frame.width / 2
//    }
//    
//    func hideBorder() {
//        containerView.layer.borderWidth = 0
//    }
}
