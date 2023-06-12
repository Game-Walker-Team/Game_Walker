//
//  endGameViewController.swift
//  Game_Walker
//
//  Created by Noah Kim on 4/19/23.
//

import Foundation
import UIKit

class endGameViewController: UIViewController {
    
    private let fontColor: UIColor = UIColor(red: 0.98, green: 0.204, blue: 0, alpha: 1)
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = fontColor
        view.layer.cornerRadius = 13
        
        ///for animation effect
        view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        
        return view
    }()
    
    private lazy var  warningLbl: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "warning 1")
        return imageView
    }()
    
    private lazy var warningTextLbl: UILabel = {
        let label = UILabel()
        label.text = "Do you really want to end this game?"
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Bold", size: 25)
        label.numberOfLines = 2
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)

        return label
    }()
    
    private lazy var noButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(name: "Dosis-Bold", size: 17)
        // enable
        button.setTitle("NO", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setBackgroundImage(UIColor.clear.image(), for: .normal)

        // disable
        button.setTitleColor(fontColor, for: .disabled)
        button.setBackgroundImage(UIColor.white.image(), for: .disabled)

        // layer
        button.layer.cornerRadius = 10.0
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 3.0
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        return button
    }()
    
    private lazy var yesButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(name: "Dosis-Bold", size: 17)
        // enable
        button.setTitle("YES", for: .normal)
        button.setTitleColor(fontColor, for: .normal)
        button.setBackgroundImage(UIColor.white.image(), for: .normal)

        // disable
        button.setTitleColor(.gray, for: .disabled)
        button.setBackgroundImage(UIColor.gray.image(), for: .disabled)

        // layer
        button.layer.cornerRadius = 10.0
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(endGame), for: .touchUpInside)
        return button
    }()
    
    @objc func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func endGame() {
        //TODO- End Game and post it to the firebase and move to the awardViewController
    }
    
    private lazy var buttonStackView: UIStackView = {
        let view = UIStackView()
        view.spacing = 14.0
        view.distribution = .fillEqually
        return view
    }()
    
    convenience init(announcement: String, source: String) {
        self.init()
        /// present 시 fullScreen (화면을 덮도록 설정) -> 설정 안하면 pageSheet 형태 (위가 좀 남아서 밑에 깔린 뷰가 보이는 형태)
        self.modalPresentationStyle = .overFullScreen
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //curveEaseOut: 시작은 천천히, 끝날 땐 빠르게
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut) { [weak self] in
            self?.containerView.transform = .identity
            self?.containerView.isHidden = false
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        //curveEaseIn: 시작은 빠르게, 끝날 땐 천천히
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn) { [weak self] in
            self?.containerView.transform = .identity
            self?.containerView.isHidden = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureButtons()
        setUpViews()
        makeConstraints()
        hideKeyboardWhenTappedAround()
    }
    
    private func configureButtons() {
        buttonStackView.addArrangedSubview(noButton)
        buttonStackView.addArrangedSubview(yesButton)
    }
    
    private func setUpViews() {
        self.view.addSubview(containerView)
        containerView.addSubview(warningLbl)
        containerView.addSubview(warningTextLbl)
        containerView.addSubview(buttonStackView)
        self.view.backgroundColor = .black.withAlphaComponent(0.2)
    }
    
    private func makeConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        warningLbl.translatesAutoresizingMaskIntoConstraints = false
        warningTextLbl.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 230),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -270),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            warningLbl.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            warningLbl.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            warningLbl.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 25),
            warningLbl.heightAnchor.constraint(equalTo: warningLbl.widthAnchor, multiplier: 0.178),
            warningLbl.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            warningTextLbl.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            warningTextLbl.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            warningTextLbl.topAnchor.constraint(equalTo: warningLbl.bottomAnchor),
            warningTextLbl.heightAnchor.constraint(equalTo: warningTextLbl.widthAnchor, multiplier: 0.53),
            warningTextLbl.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            buttonStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            buttonStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            NSLayoutConstraint(item: buttonStackView, attribute: .bottom, relatedBy: .equal, toItem: self.containerView, attribute: .bottom, multiplier: 1, constant: -10),
            buttonStackView.heightAnchor.constraint(equalTo: buttonStackView.widthAnchor, multiplier: 0.2),
            buttonStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
    }
}
