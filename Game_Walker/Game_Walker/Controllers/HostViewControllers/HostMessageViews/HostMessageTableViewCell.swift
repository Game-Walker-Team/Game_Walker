//
//  HostMessageTableViewCell.swift
//  Game_Walker
//
//  Created by Noah Kim on 3/7/23.
//

import Foundation
import UIKit

class HostMessageTableViewCell: UITableViewCell {
    static let identifier = "HostMessageTableViewCell"

    lazy var messageNameLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 3
        view.layer.borderColor = .init(red: 1, green: 1, blue: 1, alpha: 1)
        view.layer.cornerRadius = 10
        return view
    }()
    
    func configureTableViewCell(name: String) {
        contentView.addSubview(containerView)
        containerView.addSubview(messageNameLabel)
        
        contentView.backgroundColor = UIColor(cgColor: .init(red: 0.843, green: 0.502, blue: 0.976, alpha: 1))
        
        containerView.backgroundColor = .clear
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        messageNameLabel.backgroundColor = .clear
        messageNameLabel.textAlignment = .center
        messageNameLabel.font = UIFont(name: "Dosis-Regular", size: 18)
        messageNameLabel.textColor = .white
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
