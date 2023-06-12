//
//  InfoViewController.swift
//  Game_Walker
//
//  Created by Noah Kim on 3/21/23.
//

import Foundation
import UIKit

class InfoViewController: UIViewController {
    
    private let fontColor: UIColor = UIColor.black
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 13
        
        ///for animation effect
        view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        
        return view
    }()
    
    private lazy var infoTextLbl: UILabel = {
        let label = UILabel()
        label.text = ""
        label.backgroundColor = .clear
        label.layer.borderColor = fontColor.cgColor
        label.layer.borderWidth = 3
        label.layer.cornerRadius = 8
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Regular", size: 17)
        label.textColor = fontColor
        label.numberOfLines = 0

        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(name: "Dosis-Bold", size: 17)
        button.layer.borderColor = fontColor.cgColor
        button.layer.borderWidth = 3
        button.layer.cornerRadius = 8

        // enable
        button.setTitle("Close", for: .normal)
        button.setTitleColor(fontColor, for: .normal)
        button.setBackgroundImage(UIColor.white.image(), for: .normal)

        // disable
        button.setTitleColor(.gray, for: .disabled)
        button.setBackgroundImage(UIColor.gray.image(), for: .disabled)

        // layer
        button.layer.cornerRadius = 10.0
        button.layer.masksToBounds = true
        
        return button
    }()
    
    public func addActionToButton(title: String? = nil, titleColor: UIColor, backgroundColor: UIColor = .white, completion: (() -> Void)? = nil) {
        self.closeButton.addAction(for: .touchUpInside) { _ in
            completion?()
        }
    }
    
    convenience init(select: Bool) {
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
        setUpViews()
        makeConstraints()
    }
    
    private func setUpViews() {
        self.view.addSubview(containerView)
        containerView.addSubview(infoTextLbl)
        containerView.addSubview(closeButton)
        self.view.backgroundColor = .black.withAlphaComponent(0.2)
    }
    
    private func makeConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        infoTextLbl.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 210),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -210),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            infoTextLbl.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            infoTextLbl.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            infoTextLbl.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            infoTextLbl.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -20),
            infoTextLbl.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            NSLayoutConstraint(item: closeButton, attribute: .bottom, relatedBy: .equal, toItem: self.containerView, attribute: .bottom, multiplier: 1, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 200),
            closeButton.heightAnchor.constraint(equalToConstant: 64.85),
            closeButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
    }
}
