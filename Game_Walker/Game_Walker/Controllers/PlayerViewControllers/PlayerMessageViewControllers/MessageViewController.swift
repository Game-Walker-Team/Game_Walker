//
//  MessageViewController.swift
//  Game_Walker
//
//  Created by Noah Kim on 1/25/23.
//

import Foundation
import UIKit

class MessageViewController: UIViewController {
    
    private let fontColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1)
    private var messages: [String] = []
    private let cellSpacingHeight: CGFloat = 0
    
    private let messageTableView: UITableView = {
        let tableview = UITableView()
        return tableview
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(cgColor: .init(red: 0.208, green: 0.671, blue: 0.953, alpha: 1))
        view.layer.cornerRadius = 13
        
        ///for animation effect
        view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        
        return view
    }()
    
    private lazy var  messageLabel: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "announcement 3")
        return imageView
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont(name: "Dosis-Bold", size: 17)

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
    
    convenience init(messages: [String]) {
        self.init()
        /// present 시 fullScreen (화면을 덮도록 설정) -> 설정 안하면 pageSheet 형태 (위가 좀 남아서 밑에 깔린 뷰가 보이는 형태)
        self.messages = messages
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
            
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 80),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -80),
            messageLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            messageLabel.heightAnchor.constraint(equalTo: messageLabel.widthAnchor, multiplier: 0.19),
            messageLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            messageTableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 40),
            messageTableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -40),
            messageTableView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 2),
            messageTableView.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -15),
            messageTableView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            NSLayoutConstraint(item: closeButton, attribute: .bottom, relatedBy: .equal, toItem: self.containerView, attribute: .bottom, multiplier: 1, constant: -30),
            closeButton.widthAnchor.constraint(equalToConstant: 200),
            closeButton.heightAnchor.constraint(equalToConstant: 64.85),
            closeButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
    }
}

// MARK: - TableView
extension MessageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messageTableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.identifier, for: indexPath) as! MessageTableViewCell
        let ind = indexPath.row + 1
        let announcement = messages[indexPath.row]
        if (TeamViewController.readMsgList.contains(announcement)) {
            cell.configureTableViewCell(name: "Announcement \(ind)", read: true)
        } else {
            cell.configureTableViewCell(name: "Announcement \(ind)", read: false)
        }
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
        let announcementText = messages[indexPath.row]
        if !TeamViewController.readMsgList.contains(announcementText) {
            TeamViewController.readMsgList.append(announcementText)
        }
        showAnnouncementPopUp(announcement: announcementText)
        messageTableView.deselectRow(at: indexPath, animated: true)
        messageTableView.reloadData()
    }
}
