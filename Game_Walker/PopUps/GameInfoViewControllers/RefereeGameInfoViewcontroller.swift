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
    
    private lazy var gameInfoLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Station Info", comment: "")
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = getFontForLanguage(font: "GemunuLibre-Semibold", size: fontSize(size: 40))
        return label
    }()
    
    private lazy var gameNameLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Station Name", comment: "")
        label.textColor = .white
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = getFontForLanguage(font: "GemunuLibre-Semibold", size: fontSize(size: 23))
        return label
    }()
    
    private lazy var gameLocationLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Station Location", comment: "")
        label.textColor = .white
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = getFontForLanguage(font: "GemunuLibre-Semibold", size: fontSize(size: 23))
        return label
    }()
    
    private lazy var gamePointsLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Station Points", comment: "")
        label.textColor = .white
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = getFontForLanguage(font: "GemunuLibre-Semibold", size: fontSize(size: 23))
        return label
    }()
    
    private lazy var gameRuleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Rules", comment: "")
        label.textColor = .white
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = getFontForLanguage(font: "GemunuLibre-Semibold", size: fontSize(size: 23))
        return label
    }()
    
    private lazy var gameNameLabel1: UILabel = {
        let label = UILabel()
        label.text = self.gameName
        label.backgroundColor = .clear
        label.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        label.layer.borderWidth = 3
        label.layer.cornerRadius = 8
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Regular", size: fontSize(size: 17))
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
        label.font = UIFont(name: "Dosis-Regular", size: fontSize(size: 17))
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
        label.font = UIFont(name: "Dosis-Regular", size: fontSize(size: 17))
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var gameRuleTextView: UITextView = {
        let textView = UITextView()
        textView.text = self.gameRule
        textView.backgroundColor = .clear
        textView.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        textView.layer.borderWidth = 3
        textView.layer.cornerRadius = 8
        textView.textAlignment = .center
        textView.font = UIFont(name: "Dosis-Regular", size: fontSize(size: 17))
        textView.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        textView.isScrollEnabled = true
        textView.isEditable = false
        return textView
    }()
    
    private lazy var buttonView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    public func addActionToButton(title: String? = nil, titleColor: UIColor, backgroundColor: UIColor = .white, completion: (() -> Void)? = nil) {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = getFontForLanguage(font: "GemunuLibre-Bold", size: fontSize(size: 20))

        // enable
        button.setTitle(title, for: .normal)
        button.setTitleColor(fontColor, for: .normal)
        button.setBackgroundImage(UIColor.white.image(), for: .normal)

        // disable
        button.setTitleColor(.gray, for: .disabled)
        button.setBackgroundImage(UIColor.gray.image(), for: .disabled)

        // layer
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true

        button.addAction(for: .touchUpInside) { _ in
            completion?()
        }
        buttonView.addSubview(button)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor),
            button.topAnchor.constraint(equalTo: buttonView.topAnchor),
            button.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor)
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
        containerView.addSubview(gameRuleTextView)
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
        gameRuleTextView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8666666667),
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6650246305),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            gameInfoLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.65),
            gameInfoLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            gameInfoLabel.heightAnchor.constraint(equalTo: gameInfoLabel.widthAnchor, multiplier: 0.232),
            gameInfoLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            gameNameLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.38),
            gameNameLabel.topAnchor.constraint(equalTo: gameInfoLabel.bottomAnchor, constant: 15.0),
            gameNameLabel.heightAnchor.constraint(equalTo: gameNameLabel.widthAnchor, multiplier: 0.2049180328),
            gameNameLabel.leadingAnchor.constraint(equalTo: gameNameLabel1.leadingAnchor),
            
            gameNameLabel1.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.82),
            gameNameLabel1.topAnchor.constraint(equalTo: gameNameLabel.bottomAnchor),
            gameNameLabel1.heightAnchor.constraint(equalTo: gameNameLabel1.widthAnchor, multiplier: 0.12),
            gameNameLabel1.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            gameLocationLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.4492307692),
            gameLocationLabel.topAnchor.constraint(equalTo: gameNameLabel1.bottomAnchor, constant: 15.0),
            gameLocationLabel.heightAnchor.constraint(equalTo: gameLocationLabel.widthAnchor, multiplier: 0.1712328767),
            gameLocationLabel.leadingAnchor.constraint(equalTo: gameNameLabel1.leadingAnchor),
            
            gameLocationLabel1.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.82),
            gameLocationLabel1.topAnchor.constraint(equalTo: gameLocationLabel.bottomAnchor),
            gameLocationLabel1.heightAnchor.constraint(equalTo: gameNameLabel1.widthAnchor, multiplier: 0.12),
            gameLocationLabel1.leadingAnchor.constraint(equalTo: gameNameLabel1.leadingAnchor),
            
            gamePointsLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.3938461538),
            gamePointsLabel.topAnchor.constraint(equalTo: gameLocationLabel1.bottomAnchor, constant: 15.0),
            gamePointsLabel.heightAnchor.constraint(equalTo: gamePointsLabel.widthAnchor, multiplier: 0.1953125),
            gamePointsLabel.leadingAnchor.constraint(equalTo: gameNameLabel1.leadingAnchor),
            
            gamePointsLabel1.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.82),
            gamePointsLabel1.topAnchor.constraint(equalTo: gamePointsLabel.bottomAnchor),
            gamePointsLabel1.heightAnchor.constraint(equalTo: gamePointsLabel1.widthAnchor, multiplier: 0.12),
            gamePointsLabel1.leadingAnchor.constraint(equalTo: gameNameLabel1.leadingAnchor),
            
            gameRuleLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.1538461538),
            gameRuleLabel.topAnchor.constraint(equalTo: gamePointsLabel1.bottomAnchor, constant: 12.0),
            gameRuleLabel.heightAnchor.constraint(equalTo: gameRuleLabel.widthAnchor, multiplier: 0.5),
            gameRuleLabel.leadingAnchor.constraint(equalTo: gameNameLabel1.leadingAnchor),
            
            gameRuleTextView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.82),
            gameRuleTextView.topAnchor.constraint(equalTo: gameRuleLabel.bottomAnchor),
            gameRuleTextView.bottomAnchor.constraint(equalTo: buttonView.topAnchor, constant: -15),
            gameRuleTextView.leadingAnchor.constraint(equalTo: gameNameLabel1.leadingAnchor),
            
            buttonView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.3876923077),
            buttonView.heightAnchor.constraint(equalTo: buttonView.widthAnchor, multiplier: 0.3253968254),
            buttonView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            buttonView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
    }
}
