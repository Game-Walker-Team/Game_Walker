//
//  WarningScreenController.swift
//  Game_Walker
//
//  Created by 김현식 on 2/6/23.
//

import Foundation
import UIKit

class WarningScreenController : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(containerView)
        self.view.addSubview(warningLabel)
        self.view.addSubview(statementLabel)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.widthAnchor.constraint(equalToConstant: 338).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 338).isActive = true
        containerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 220).isActive = true
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        warningLabel.widthAnchor.constraint(equalToConstant: 254.12).isActive = true
        warningLabel.heightAnchor.constraint(equalToConstant: 61).isActive = true
        warningLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        warningLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 23).isActive = true
        statementLabel.translatesAutoresizingMaskIntoConstraints = false
        statementLabel.widthAnchor.constraint(equalToConstant: 254.12).isActive = true
        statementLabel.heightAnchor.constraint(equalToConstant: 61).isActive = true
        statementLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        statementLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 120).isActive = true
        
    }
    private lazy var containerView: UIView = {
        var view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 338, height: 338)
        view.layer.cornerRadius = 15
        view.backgroundColor = .white
        view.layer.backgroundColor = UIColor(red: 0.98, green: 0.204, blue: 0, alpha: 1).cgColor
        return view
    }()
    
    private lazy var warningLabel: UIView = {
        var view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 254.12, height: 61)
        view.backgroundColor = .white
        view.layer.backgroundColor = UIColor(red: 0.98, green: 0.204, blue: 0, alpha: 1).cgColor
        let image0 = UIImage(named: "warning 1")
        let layer0 = CALayer()
        layer0.contents = image0
        layer0.bounds = view.bounds
        layer0.position = view.center
        view.layer.addSublayer(layer0)
        return view
    }()
    
    private lazy var statementLabel: UIView = {
        var view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 258, height: 66)
        view.backgroundColor = .white
        view.layer.backgroundColor = UIColor(red: 0.98, green: 0.204, blue: 0, alpha: 1).cgColor
        let image0 = UIImage(named: "Frame 6")
        let layer0 = CALayer()
        layer0.contents = image0
        layer0.bounds = view.bounds
        layer0.position = view.center
        view.layer.addSublayer(layer0)
        return view
    }()
    
    private lazy var yesButton: UIButton = {
        var button = UIButton(frame: CGRect(x: 0, y: 0, width: 135.7, height: 44))
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "yes red button"), for: .normal)
        button.addTarget(self, action: #selector(yesbuttonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var noButton: UIButton = {
        var button = UIButton(frame: CGRect(x: 0, y: 0, width: 135.7, height: 44))
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "no red button"), for: .normal)
        button.addTarget(self, action: #selector(nobuttonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func yesbuttonTapped() {
        //performSegue(withIdentifier: "", sender: self)
    }
    
    @objc func nobuttonTapped() {
        //performSegue(withIdentifier: "", sender: self)
    }
}
