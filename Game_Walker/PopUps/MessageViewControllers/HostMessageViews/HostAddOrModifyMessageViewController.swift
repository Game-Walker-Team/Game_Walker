//
//  HostAddOrModifyMessageViewController.swift
//  Game_Walker
//
//  Created by Noah Kim on 3/7/23.
//

import Foundation
import UIKit

class HostAddOrModifyMessageViewController: UIViewController {
    private var announcement: Announcement?
    private let fontColor: UIColor = UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1)
    private let gameCode = UserData.readGamecode("gamecode") ?? ""
    private var source = ""
    private var ind: Int?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(cgColor: .init(red: 0.843, green: 0.502, blue: 0.976, alpha: 1))
        view.layer.cornerRadius = 13
        
        ///for animation effect
        view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        
        return view
    }()
    
    private lazy var announcementTextView: UITextView = {
        let textView = UITextView()
        textView.text = announcement?.content
        textView.backgroundColor = .clear
        textView.layer.borderColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1)
        textView.layer.borderWidth = 3
        textView.layer.cornerRadius = 10
        textView.textAlignment = .left
        textView.font = UIFont(name: "Dosis-Regular", size: 18)
        textView.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)

        return textView
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = getFontForLanguage(font: "GemunuLibre-Bold", size: 20)
        // enable
        button.setTitle(NSLocalizedString("Close", comment: ""), for: .normal)
        button.setTitleColor(fontColor, for: .normal)
        button.setBackgroundImage(UIColor.white.image(), for: .normal)

        // disable
        button.setTitleColor(.gray, for: .disabled)
        button.setBackgroundImage(UIColor.gray.image(), for: .disabled)

        // layer
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        return button
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = getFontForLanguage(font: "GemunuLibre-Bold", size: 20)
        // enable
        button.setTitle(NSLocalizedString("Send", comment: ""), for: .normal)
        button.setTitleColor(fontColor, for: .normal)
        button.setBackgroundImage(UIColor.white.image(), for: .normal)

        // disable
        button.setTitleColor(.gray, for: .disabled)
        button.setBackgroundImage(UIColor.gray.image(), for: .disabled)

        // layer
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        return button
    }()
    
    private lazy var modifyButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = getFontForLanguage(font: "GemunuLibre-Bold", size: 20)
        // enable
        button.setTitle(NSLocalizedString("Edit", comment: ""), for: .normal)
        button.setTitleColor(fontColor, for: .normal)
        button.setBackgroundImage(UIColor.white.image(), for: .normal)

        // disable
        button.setTitleColor(.gray, for: .disabled)
        button.setBackgroundImage(UIColor.gray.image(), for: .disabled)

        // layer
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(modifyMessage), for: .touchUpInside)
        return button
    }()
    
    @objc func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func sendMessage() {
        Task { @MainActor in
            do {
                let newAnnouncement = Announcement(uuid: UUID().uuidString, content: announcementTextView.text, timestamp: getCurrentDateTime(), readStatus: false)
                HostRankingViewcontroller.messages.append(newAnnouncement)
                try await H.addAnnouncement(gameCode, newAnnouncement)
                NotificationCenter.default.post(name: .newDataNotif, object: nil)
                self.dismiss(animated: false, completion: nil)
            }  catch GameWalkerError.serverError(let text){
                print(text)
                serverAlert(text)
                return
            }
        }
    }
    
    @objc func modifyMessage() {
        Task { @MainActor in
            do {
                guard let announcement = self.announcement, let index = self.ind else { return }
                let newAnnouncement = Announcement(uuid: announcement.uuid, content: announcementTextView.text, timestamp: getCurrentDateTime(), readStatus: false)
                try await H.modifyAnnouncement(gameCode, newAnnouncement, index)
                HostRankingViewcontroller.messages[index] = newAnnouncement
                NotificationCenter.default.post(name: .newDataNotif, object: nil)
                self.dismiss(animated: false, completion: nil)
            } catch GameWalkerError.serverError(let text){
                print(text)
                serverAlert(text)
                return
            }            
        }
    }
    
    private lazy var buttonStackView: UIStackView = {
        let view = UIStackView()
        view.spacing = 14.0
        view.distribution = .fillEqually
        return view
    }()
    
    convenience init(announcement: Announcement, source: String) {
        self.init()
        /// present 시 fullScreen (화면을 덮도록 설정) -> 설정 안하면 pageSheet 형태 (위가 좀 남아서 밑에 깔린 뷰가 보이는 형태)
        self.announcement = announcement
        self.source = source
        self.modalPresentationStyle = .overFullScreen
    }
    
    convenience init(announcement: Announcement, index: Int, source: String) {
        self.init()
        /// present 시 fullScreen (화면을 덮도록 설정) -> 설정 안하면 pageSheet 형태 (위가 좀 남아서 밑에 깔린 뷰가 보이는 형태)
        self.announcement = announcement
        self.ind = index
        self.source = source
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
    }
    
    private func configureButtons() {
        buttonStackView.addArrangedSubview(closeButton)
        if self.source == "btn" {
            buttonStackView.addArrangedSubview(sendButton)
        } else {
            buttonStackView.addArrangedSubview(modifyButton)
        }
    }
    
    private func setUpViews() {
        self.view.addSubview(containerView)
        containerView.addSubview(announcementTextView)
        containerView.addSubview(buttonStackView)
        self.view.backgroundColor = .black.withAlphaComponent(0.2)
    }
    
    private func makeConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        announcementTextView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 210),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -210),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            announcementTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            announcementTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            announcementTextView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 25),
            announcementTextView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -25),
            announcementTextView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            buttonStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            buttonStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            NSLayoutConstraint(item: buttonStackView, attribute: .bottom, relatedBy: .equal, toItem: self.containerView, attribute: .bottom, multiplier: 1, constant: -10),
            buttonStackView.heightAnchor.constraint(equalTo: buttonStackView.widthAnchor, multiplier: 0.15),
            buttonStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
    }
}
