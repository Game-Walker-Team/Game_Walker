//
//  MessageViewController.swift
//  Game_Walker
//
//  Created by Noah Kim on 1/25/23.
//

import Foundation
import UIKit

class MessageViewController: UIViewController {
    
    private var role: String = ""
    private var roleColor: UIColor = UIColor.clear
    private var messages: [Announcement] = []
    private let cellSpacingHeight: CGFloat = 0
    
    private let messageTableView: UITableView = {
        let tableview = UITableView()
        return tableview
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = roleColor
        view.layer.cornerRadius = 20
        
        ///for animation effect
        view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        
        return view
    }()
    
    private lazy var  messageLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Announcement", comment: "")
        label.font = getFontForLanguage(font: "GemunuLibre-Bold", size: 40)
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = getFontForLanguage(font: "GemunuLibre-Bold", size: 20)
        
        // enable
        button.setTitle(NSLocalizedString("Close", comment: ""), for: .normal)
        button.setTitleColor(roleColor, for: .normal)
        button.setBackgroundImage(UIColor.white.image(), for: .normal)
        
        // disable
        button.setTitleColor(.gray, for: .disabled)
        button.setBackgroundImage(UIColor.gray.image(), for: .disabled)
        
        // layer
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        
        return button
    }()
    
    public func addActionToButton(title: String? = nil, titleColor: UIColor, backgroundColor: UIColor = .white, completion: (() -> Void)? = nil) {
        self.closeButton.addAction(for: .touchUpInside) { _ in
            completion?()
        }
    }
    
    convenience init(messages: [Announcement], role: String) {
        self.init()
        /// present 시 fullScreen (화면을 덮도록 설정) -> 설정 안하면 pageSheet 형태 (위가 좀 남아서 밑에 깔린 뷰가 보이는 형태)
        self.messages = messages
        self.role = role
        if role == "player" {
            roleColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1)
        } else {
            roleColor = UIColor(red: 0.333, green: 0.745, blue: 0.459, alpha: 1)
        }
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
        configureTableView()
        setUpViews()
        makeConstraints()
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: .newDataNotif, object: nil)
    }
    
    @objc func refresh() {
        Task {
            try await Task.sleep(nanoseconds: 250_000_000)
            if (self.role == "player") {
                self.messages = PlayerTabBarController.localMessages
            } else {
                self.messages = RefereeTabBarController.localMessages
            }
            messageTableView.reloadData()
        }
    }
    
    private func configureTableView() {
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTableView.register(MessageTableViewCell.self, forCellReuseIdentifier: MessageTableViewCell.identifier)
        messageTableView.backgroundColor = .clear
        messageTableView.allowsSelection = false
        messageTableView.separatorStyle = .none
        messageTableView.allowsSelection = true
        messageTableView.allowsMultipleSelection = false
    }
    
    private func setUpViews() {
        self.view.addSubview(containerView)
        containerView.addSubview(messageLabel)
        containerView.addSubview(messageTableView)
        containerView.addSubview(closeButton)
        self.view.backgroundColor = .black.withAlphaComponent(0.2)
    }
    
    private func makeConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageTableView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            containerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 210),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -210),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            messageLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            messageLabel.widthAnchor.constraint(equalToConstant: 250),
            messageLabel.heightAnchor.constraint(equalToConstant: 45),
            messageLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            messageTableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            messageTableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40),
            messageTableView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 5),
            messageTableView.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -15),
            messageTableView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            closeButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.3877),
            closeButton.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.12424),
            closeButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
    }
}

// MARK: - TableView
extension MessageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messageTableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.identifier, for: indexPath) as! MessageTableViewCell
        let ind = indexPath.row + 1
        let announcement: Announcement
        if role == "player" {
            announcement = PlayerTabBarController.localMessages[indexPath.row]
        } else {
            announcement = RefereeTabBarController.localMessages[indexPath.row]
        }
        cell.configureTableViewCell(name: NSLocalizedString("Announcement", comment: "") + " \(ind)", read: announcement.readStatus, role: self.role)
        cell.selectionStyle = .none
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if role == "player" {
            PlayerTabBarController.localMessages[indexPath.row].readStatus = true
            showAnnouncementPopUp(announcement: PlayerTabBarController.localMessages[indexPath.row], role: "player")
        } else {
            RefereeTabBarController.localMessages[indexPath.row].readStatus = true
            showAnnouncementPopUp(announcement: RefereeTabBarController.localMessages[indexPath.row], role: "referee")
        }
        messageTableView.deselectRow(at: indexPath, animated: true)
        messageTableView.reloadData()
    }
}
