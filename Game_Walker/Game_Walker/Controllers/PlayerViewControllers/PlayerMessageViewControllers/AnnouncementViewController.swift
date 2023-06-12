//
//  AnnouncementViewController.swift
//  Game_Walker
//
//  Created by Noah Kim on 1/29/23.
//

import Foundation
import UIKit

class AnnouncementViewController: UIViewController {
    private var announcement: String?
    private let fontColor: UIColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1)
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(cgColor: .init(red: 0.208, green: 0.671, blue: 0.953, alpha: 1))
        view.layer.cornerRadius = 13
        
        ///for animation effect
        view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        
        return view
    }()
    
    private lazy var announcmentScrollView: UIScrollView = {
       let view = UIScrollView()
        view.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        view.layer.borderWidth = 3
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var  announcementLabel: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "announcement 3")
        return imageView
    }()
    
    private lazy var announcementTextLabel: UILabel = {
        let label = UILabel()
        label.text = self.announcement
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Regular", size: 17)
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        label.numberOfLines = 0
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
        button.titleLabel?.font = UIFont(name: "Dosis-Bold", size: 17)

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
    
    convenience init(announcement: String?) {
        self.init()
        /// present 시 fullScreen (화면을 덮도록 설정) -> 설정 안하면 pageSheet 형태 (위가 좀 남아서 밑에 깔린 뷰가 보이는 형태)
        self.announcement = announcement
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
        containerView.addSubview(announcementLabel)
        containerView.addSubview(announcmentScrollView)
        announcmentScrollView.addSubview(announcementTextLabel)
        containerView.addSubview(buttonView)
        self.view.backgroundColor = .black.withAlphaComponent(0.2)
    }
    
    private func makeConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        announcementLabel.translatesAutoresizingMaskIntoConstraints = false
        announcmentScrollView.translatesAutoresizingMaskIntoConstraints = false
        announcementTextLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 210),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -210),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            announcementLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            announcementLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            announcementLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 25),
            announcementLabel.heightAnchor.constraint(equalTo: announcementLabel.widthAnchor, multiplier: 0.178),
            announcementLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            announcmentScrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            announcmentScrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            announcmentScrollView.topAnchor.constraint(equalTo: announcementLabel.bottomAnchor, constant: 2),
            announcmentScrollView.bottomAnchor.constraint(equalTo: buttonView.topAnchor, constant: -5),
            announcmentScrollView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            announcementTextLabel.topAnchor.constraint(equalTo: announcmentScrollView.topAnchor),
            announcementTextLabel.bottomAnchor.constraint(equalTo: announcmentScrollView.bottomAnchor),
            announcementTextLabel.centerXAnchor.constraint(equalTo: announcmentScrollView.centerXAnchor),
            announcementTextLabel.widthAnchor.constraint(equalTo: announcmentScrollView.widthAnchor),

            buttonView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 1.0),
            buttonView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -1.0),
            buttonView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5.0),
            buttonView.heightAnchor.constraint(equalTo: buttonView.widthAnchor, multiplier: 0.27),
            buttonView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
    }
}
