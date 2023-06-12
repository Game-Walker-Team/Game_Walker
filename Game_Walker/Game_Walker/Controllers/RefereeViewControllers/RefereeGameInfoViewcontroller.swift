//
//  RefereeGameInfoViewcontroller.swift
//  Game_Walker
//
//  Created by Noah Kim on 1/25/23.
//

import Foundation
import UIKit

class RefereeGameInfoViewcontroller: UIViewController {
    private var gameName: String?
    private var gameLocation: String?
    private var gamePoints: String?
    private var gameRule: String?
    private let fontColor: UIColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1)
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = fontColor
        view.layer.cornerRadius = 13
        
        ///for animation effect
        view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        
        return view
    }()
    
    private lazy var  gameInfoLabel: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Station Info 2")
        return imageView
    }()
    
    private lazy var gameNameLabel: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "station name 1")
        return imageView
    }()
    
    private lazy var gameLocationLabel: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Station location 1")
        return imageView
    }()
    
    private lazy var gamePointsLabel: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "station points 3")
        return imageView
    }()
    
    private lazy var gameRuleLabel: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "rules 2")
        return imageView
    }()
    
    private lazy var gameNameLabel1: UILabel = {
        let label = UILabel()
        label.text = self.gameName
        label.backgroundColor = .clear
        label.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        label.layer.borderWidth = 3
        label.layer.cornerRadius = 8
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Regular", size: 17)
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        label.numberOfLines = 0

        return label
    }()
    
    private lazy var gameLocationLabel1: UILabel = {
        let label = UILabel()
        label.text = self.gameLocation
        label.backgroundColor = .clear
        label.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        label.layer.borderWidth = 3
        label.layer.cornerRadius = 8
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Regular", size: 17)
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        label.numberOfLines = 0

        return label
    }()
    
    private lazy var gamePointsLabel1: UILabel = {
        let label = UILabel()
        label.text = self.gamePoints
        label.backgroundColor = .clear
        label.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        label.layer.borderWidth = 3
        label.layer.cornerRadius = 8
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Regular", size: 17)
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        label.numberOfLines = 0

        return label
    }()
    
    private lazy var gameRuleLabel1: UILabel = {
        let label = UILabel()
        label.text = self.gameRule
        label.backgroundColor = .clear
        label.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        label.layer.borderWidth = 3
        label.layer.cornerRadius = 8
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Regular", size: 15)
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        label.numberOfLines = .max
        return label
    }()
    
    private lazy var buttonView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    public func addActionToButton(title: String? = nil, titleColor: UIColor, backgroundColor: UIColor = .white, completion: (() -> Void)? = nil) {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(name: "Dosis-Regular", size: 17)

        // enable
        button.setTitle(title, for: .normal)
        button.setTitleColor(fontColor, for: .normal)
        button.setBackgroundImage(UIColor.white.image(), for: .normal)

        // disable
        button.setTitleColor(.gray, for: .disabled)
        button.setBackgroundImage(UIColor.gray.image(), for: .disabled)

        // layer
        button.layer.cornerRadius = 10.0
        button.layer.masksToBounds = true

        button.addAction(for: .touchUpInside) { _ in
            completion?()
        }
        buttonView.addSubview(button)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant: 73),
            button.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor, constant: -73),
            button.heightAnchor.constraint(equalTo: button.widthAnchor, multiplier: 0.3),
            button.centerXAnchor.constraint(equalTo: buttonView.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: buttonView.centerYAnchor)
        ])
    }
    
    convenience init(gameName: String,
                     gameLocation: String, gamePoints: String, gameRule: String) {
        self.init()
        self.gameName = gameName
        self.gameLocation = gameLocation
        self.gamePoints = gamePoints
        self.gameRule = gameRule
        /// present 시 fullScreen (화면을 덮도록 설정) -> 설정 안하면 pageSheet 형태 (위가 좀 남아서 밑에 깔린 뷰가 보이는 형태)
        self.modalPresentationStyle = .overFullScreen
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // curveEaseOut: 시작은 천천히, 끝날 땐 빠르게
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut) { [weak self] in
            self?.containerView.transform = .identity
            self?.containerView.isHidden = false
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // curveEaseIn: 시작은 빠르게, 끝날 땐 천천히
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn) { [weak self] in
            self?.containerView.transform = .identity
            self?.containerView.isHidden = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        makeConstraints()
    }

    private func setupViews() {
        self.view.addSubview(containerView)
        containerView.addSubview(gameInfoLabel)
        containerView.addSubview(gameNameLabel)
        containerView.addSubview(gameNameLabel1)
        containerView.addSubview(gameLocationLabel)
        containerView.addSubview(gameLocationLabel1)
        containerView.addSubview(gamePointsLabel)
        containerView.addSubview(gamePointsLabel1)
        containerView.addSubview(gameRuleLabel)
        containerView.addSubview(gameRuleLabel1)
        containerView.addSubview(buttonView)
        self.view.backgroundColor = .black.withAlphaComponent(0.2)
    }

    private func makeConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        gameInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        gameNameLabel.translatesAutoresizingMaskIntoConstraints = false
        gameNameLabel1.translatesAutoresizingMaskIntoConstraints = false
        gameLocationLabel.translatesAutoresizingMaskIntoConstraints = false
        gameLocationLabel1.translatesAutoresizingMaskIntoConstraints = false
        gamePointsLabel.translatesAutoresizingMaskIntoConstraints = false
        gamePointsLabel1.translatesAutoresizingMaskIntoConstraints = false
        gameRuleLabel.translatesAutoresizingMaskIntoConstraints = false
        gameRuleLabel1.translatesAutoresizingMaskIntoConstraints = false
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 135),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -135),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            gameInfoLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 66.0),
            gameInfoLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -66.0),
            gameInfoLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10.0),
            gameInfoLabel.bottomAnchor.constraint(equalTo: gameNameLabel.topAnchor, constant: 10.0),
            gameInfoLabel.heightAnchor.constraint(equalTo: gameInfoLabel.widthAnchor, multiplier: 0.25),
            gameInfoLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            gameNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 22.0),
            gameNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -190.2),
            gameNameLabel.topAnchor.constraint(equalTo: gameInfoLabel.bottomAnchor, constant: 10.0),
            gameNameLabel.heightAnchor.constraint(equalTo: gameNameLabel.widthAnchor, multiplier: 0.21),
            gameNameLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            gameNameLabel1.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 22),
            gameNameLabel1.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant:  -22),
            gameNameLabel1.topAnchor.constraint(equalTo: gameNameLabel.bottomAnchor, constant: 5.0),
            gameNameLabel1.heightAnchor.constraint(equalTo: gameNameLabel1.widthAnchor, multiplier: 0.12),
            gameNameLabel1.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            gameLocationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 22.0),
            gameLocationLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -165.2),
            gameLocationLabel.topAnchor.constraint(equalTo: gameNameLabel1.bottomAnchor, constant: 10.0),
            gameLocationLabel.heightAnchor.constraint(equalTo: gameLocationLabel.widthAnchor, multiplier: 0.16),
            gameLocationLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            gameLocationLabel1.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 22.0),
            gameLocationLabel1.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant:  -22.0),
            gameLocationLabel1.topAnchor.constraint(equalTo: gameLocationLabel.bottomAnchor, constant: 5.0),
            gameLocationLabel1.heightAnchor.constraint(equalTo: gameNameLabel1.widthAnchor, multiplier: 0.12),
            gameLocationLabel1.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            gamePointsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 22.0),
            gamePointsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -181.0),
            gamePointsLabel.topAnchor.constraint(equalTo: gameLocationLabel1.bottomAnchor, constant: 10.0),
            gamePointsLabel.heightAnchor.constraint(equalTo: gamePointsLabel.widthAnchor, multiplier: 0.19),
            gamePointsLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            gamePointsLabel1.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 22.0),
            gamePointsLabel1.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant:  -22.0),
            gamePointsLabel1.topAnchor.constraint(equalTo: gamePointsLabel.bottomAnchor, constant: 5.0),
            gamePointsLabel1.heightAnchor.constraint(equalTo: gamePointsLabel1.widthAnchor, multiplier: 0.12),
            gamePointsLabel1.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            gameRuleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 22),
            gameRuleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -245),
            gameRuleLabel.topAnchor.constraint(equalTo: gamePointsLabel1.bottomAnchor, constant: 10.0),
            gameRuleLabel.heightAnchor.constraint(equalTo: gameRuleLabel.widthAnchor, multiplier: 0.4),
            gameRuleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            gameRuleLabel1.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 22.0),
            gameRuleLabel1.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -22.0),
            gameRuleLabel1.topAnchor.constraint(equalTo: gameRuleLabel.bottomAnchor, constant: 5.0),
            gameRuleLabel1.heightAnchor.constraint(equalTo: gameRuleLabel1.widthAnchor, multiplier: 0.25),
            gameRuleLabel1.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            buttonView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 1.0),
            buttonView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -1.0),
            buttonView.topAnchor.constraint(equalTo: gameRuleLabel1.bottomAnchor, constant: 10.0),
            buttonView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5.0),
            buttonView.heightAnchor.constraint(equalTo: buttonView.widthAnchor, multiplier: 0.27),
            buttonView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
    }
}
