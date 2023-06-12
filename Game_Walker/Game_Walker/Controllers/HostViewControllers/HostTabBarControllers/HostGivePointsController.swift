//
//  HostGivePointsController.swift
//  Game_Walker
//
//  Created by 김현식 on 2/6/23.
//

import Foundation
import UIKit
import GMStepper

class HostGivePointsController : UIViewController {
    
    var currentStationName: String
    var currentPoints: Int
    let gameCode: String
    let team: Team
    
    init(team: Team, gameCode: String) {
        self.team = team
        self.currentStationName = team.currentStation
        self.currentPoints = team.points
        self.gameCode = gameCode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.view.addSubview(containerView)
        self.view.addSubview(givepointsLabel)
        self.view.bringSubviewToFront(givepointsLabel)
        self.view.addSubview(closeButton)
        self.view.addSubview(stepper)
        self.view.addSubview(confirmButton)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.widthAnchor.constraint(equalToConstant: 338).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 338).isActive = true
        containerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 220).isActive = true
        givepointsLabel.translatesAutoresizingMaskIntoConstraints = false
        givepointsLabel.widthAnchor.constraint(equalToConstant: 267.74).isActive = true
        givepointsLabel.heightAnchor.constraint(equalToConstant: 61).isActive = true
        givepointsLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        givepointsLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 55).isActive = true
        stepper.translatesAutoresizingMaskIntoConstraints = false
        stepper.widthAnchor.constraint(equalToConstant: 265).isActive = true
        stepper.heightAnchor.constraint(equalToConstant: 134).isActive = true
        stepper.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stepper.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 116).isActive = true
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 284).isActive = true
        closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive = true
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.widthAnchor.constraint(equalToConstant: 175.8).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 57).isActive = true
        confirmButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        confirmButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 265).isActive = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(popupClosed))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    private lazy var containerView: UIView = {
        var view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 338, height: 338)
        view.layer.cornerRadius = 15
        view.backgroundColor = .white
        view.layer.backgroundColor = UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1).cgColor
        return view
    }()
    
    private lazy var givepointsLabel: UILabel = {
        var view = UILabel()
        view.frame = CGRect(x: 0, y: 0, width: 267.74, height: 61)
        let image0 = UIImage(named: "white!give points 1.png")?.cgImage
        let layer0 = CALayer()
        layer0.contents = image0
        layer0.bounds = view.bounds
        layer0.position = view.center
        view.layer.addSublayer(layer0)
        return view
    }()
    
    private lazy var stepper: GMStepper = {
        var view = GMStepper()
        view.frame = CGRect(x: 0, y: 0, width: 265, height: 134)
        view.buttonsBackgroundColor = UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1)
        view.buttonsFont = UIFont(name: "Dosis-Regular", size: 100) ?? UIFont(name: "AvenirNext-Bold", size: 20.0)!
        view.labelBackgroundColor = UIColor(red: 0.843, green: 0.502, blue: 0.976, alpha: 1)
        view.labelFont = UIFont(name: "Dosis-Bold", size: 100) ?? UIFont(name: "AvenirNext-Bold", size: 25.0)!
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        var button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "icon _close_"), for: .normal)
        button.addTarget(self, action: #selector(popupClosed), for: .touchUpInside)
        return button
    }()
    
    private lazy var confirmButton: UIButton = {
        var button = UIButton(frame: CGRect(x: 0, y: 0, width: 175.8, height: 57))
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "confirm button purple 1"), for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func buttonTapped() {
        T.givePoints(gameCode, team.name, Int(stepper.value))
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @objc func popupClosed() {
        self.presentingViewController?.dismiss(animated: true)
    }
}
