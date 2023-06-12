//
//  RefereeMessageTableViewCell.swift
//  Game_Walker
//
//  Created by 김현식 on 2/13/23.
//

import Foundation
import UIKit

class RefereeMessageTableViewCell: UITableViewCell {
    
    static let identifier = "RefereeMessageTableViewCell"

    lazy var messageNameLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    func configureTableViewCell(name: String, read: Bool) {
        contentView.addSubview(containerView)
        containerView.addSubview(messageNameLabel)
        
        contentView.backgroundColor = UIColor(cgColor: .init(red: 0.333, green: 0.745, blue: 0.459, alpha: 1))
        
        if (read) {
            containerView.layer.borderColor = UIColor.lightText.cgColor
            messageNameLabel.textColor = .lightText
        } else {
            containerView.layer.borderColor = .init(red: 1, green: 1, blue: 1, alpha: 1)
            messageNameLabel.textColor = .white
        }
        containerView.layer.borderWidth = 3
        containerView.layer.cornerRadius = 10
        containerView.backgroundColor = .clear
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        messageNameLabel.backgroundColor = .clear
        messageNameLabel.textAlignment = .center
        messageNameLabel.font = UIFont(name: "Dosis-Regular", size: 18)
        messageNameLabel.numberOfLines = 0
        messageNameLabel.translatesAutoresizingMaskIntoConstraints = false
        messageNameLabel.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -9),
            containerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            messageNameLabel.widthAnchor.constraint(equalTo: containerView.layoutMarginsGuide.widthAnchor),
            messageNameLabel.heightAnchor.constraint(equalTo: containerView.layoutMarginsGuide.heightAnchor),
            messageNameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            messageNameLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        messageNameLabel.text = name
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
