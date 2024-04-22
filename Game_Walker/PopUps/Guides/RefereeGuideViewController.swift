//
//  RefereePVEGuideView.swift
//  Game_Walker
//
//  Created by 김현식 on 10/14/23.
//

import Foundation
import UIKit

class RefereeGuideViewController : UIViewController {
    var pvp: Bool
    
    init(pvp: Bool) {
        self.pvp = pvp
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if pvp {
            setupOverlayViewPVP()
        } else {
            setupOverlayViewPVE()
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissOverlay))
        overlayView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissOverlay() {
        dismiss(animated: true, completion: nil)
    }
    
    let colorList = [UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1).cgColor, UIColor(red: 0.942, green: 0.71, blue: 0.114, alpha: 1).cgColor, UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1).cgColor]
    
    private let overlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.176, green: 0.176, blue: 0.208, alpha: 0.9)
        return view
    }()
    
    private lazy var explanationLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Remember to choose 'WIN' or 'LOSE' before the round ends!", comment: "")
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Bold", size: fontSize(size: 13))
        return label
    }()
    
    //MARK: - PVE
    
    private lazy var buttonBorder: UIView = {
        var view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 5.0
        view.layer.borderColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1).cgColor
        view.layer.cornerRadius = 10.0
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Tap to give points to the Team", comment: "")
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Bold", size: fontSize(size: 13))
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
        return view
    }()

    private lazy var teamPointsLabel: UILabel = {
        var label = UILabel()
        label.text = NSLocalizedString("Team's total points", comment: "")
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Bold", size: fontSize(size: 13))
        return label
    }()
    
    private lazy var winButton: UIButton = {
        var button = UIButton()
        button.setTitle(NSLocalizedString("WIN", comment: ""), for: .normal)
        button.titleLabel?.font = getFontForLanguage(font: "GemunuLibre-Bold", size: 13)
        button.setTitleColor(UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1), for: .normal)
        button.layer.backgroundColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1).cgColor
        button.layer.cornerRadius = 6.0
        return button
    }()
    
    private lazy var loseButton: UIButton = {
        var button = UIButton()
        button.setTitle(NSLocalizedString("LOSE", comment: ""), for: .normal)
        button.titleLabel?.font = getFontForLanguage(font: "GemunuLibre-Bold", size: 13)
        button.setTitleColor(UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1), for: .normal)
        button.layer.backgroundColor = UIColor(red: 0.942, green: 0.71, blue: 0.114, alpha: 1).cgColor
        button.layer.cornerRadius = 6.0
        return button
    }()
    
    func setupOverlayViewPVE() {
        view.addSubview(overlayView)
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func configureGuidePVE(_ frameList: [CGRect], _ positionList: [CGPoint], _ textList: [String], _ tabBarTop: CGFloat){
        let count = frameList.count - 4
        for i in 0..<count {
            let explanationLbl = UILabel()
            explanationLbl.translatesAutoresizingMaskIntoConstraints = false
            explanationLbl.text = textList[i]
            explanationLbl.numberOfLines = 0
            explanationLbl.textAlignment = .center
            explanationLbl.textColor = .white
            explanationLbl.font = UIFont(name: "Dosis-Bold", size: 15)
            overlayView.addSubview(explanationLbl)
            
            if positionList[i].y >= tabBarTop {
                if textList[i] == "Timer &\nStart/End Game" || textList[i] == "Timer & \n Station Info" {
                    explanationLbl.widthAnchor.constraint(equalToConstant: 150).isActive = true
                } else {
                    explanationLbl.widthAnchor.constraint(equalToConstant: 90).isActive = true
                }
            } else {
                explanationLbl.widthAnchor.constraint(equalToConstant: 200).isActive = true
            }
            
            let circleView = UIView()
            circleView.translatesAutoresizingMaskIntoConstraints = false
            circleView.clipsToBounds = true
            circleView.layer.cornerRadius = frameList[i].height*1.55 / 2
            circleView.layer.borderColor = colorList[i]
            circleView.layer.borderWidth = 3
            overlayView.addSubview(circleView)
            
            NSLayoutConstraint.activate([
                explanationLbl.centerXAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: positionList[i].x),
                explanationLbl.bottomAnchor.constraint(equalTo: overlayView.topAnchor, constant: tabBarTop - 17),
                
                circleView.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: positionList[i].y*0.981),
                circleView.centerXAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: positionList[i].x),
                circleView.widthAnchor.constraint(equalToConstant: frameList[i].height * 1.6),
                circleView.heightAnchor.constraint(equalTo: circleView.widthAnchor)
            ])
        }
            
        overlayView.addSubview(buttonBorder)
        overlayView.addSubview(teamPointsLabel)
        overlayView.addSubview(explanationLabel)
        overlayView.addSubview(winButton)
        overlayView.addSubview(loseButton)
        buttonBorder.translatesAutoresizingMaskIntoConstraints = false
        teamPointsLabel.translatesAutoresizingMaskIntoConstraints = false
        explanationLabel.translatesAutoresizingMaskIntoConstraints = false
        winButton.translatesAutoresizingMaskIntoConstraints = false
        loseButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            buttonBorder.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant:frameList[count].minX),
            buttonBorder.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: frameList[count].minY),
            buttonBorder.widthAnchor.constraint(equalToConstant: frameList[count].width),
            buttonBorder.heightAnchor.constraint(equalToConstant: frameList[count].height),

            teamPointsLabel.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: frameList[count + 1].minX),
            teamPointsLabel.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: frameList[count + 1].minY - frameList[count + 1].height/2),
            teamPointsLabel.widthAnchor.constraint(equalToConstant: frameList[count + 1].width),
            teamPointsLabel.heightAnchor.constraint(equalToConstant: frameList[count + 1].height),
            
            explanationLabel.widthAnchor.constraint(equalTo: overlayView.widthAnchor, multiplier: 0.8),
            explanationLabel.heightAnchor.constraint(equalTo: overlayView.heightAnchor, multiplier: 0.025),
            explanationLabel.topAnchor.constraint(equalTo: winButton.bottomAnchor, constant: self.view.bounds.height * 0.04),
            explanationLabel.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),

            winButton.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: frameList[count + 2].minX),
            winButton.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: frameList[count + 2].minY),
            winButton.widthAnchor.constraint(equalToConstant: frameList[count + 2].width),
            winButton.heightAnchor.constraint(equalToConstant: frameList[count + 2].height),

            loseButton.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: frameList[count + 3].minX),
            loseButton.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: frameList[count + 3].minY),
            loseButton.widthAnchor.constraint(equalToConstant: frameList[count + 3].width),
            loseButton.heightAnchor.constraint(equalToConstant: frameList[count + 3].height),
        ])
    }
    //MARK: - PVP
    private lazy var buttonLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Tap to give points to the Team", comment: "")
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Bold", size: 13)
        return label
    }()
    
    private lazy var leftButtonBorder: UIView = {
        var view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 5.0
        view.layer.borderColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1).cgColor
        view.layer.cornerRadius = 10.0
        return view
    }()
    
    private lazy var rightButtonBorder: UIView = {
        var view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 5.0
        view.layer.borderColor = UIColor(red: 0.157, green: 0.82, blue: 0.443, alpha: 1).cgColor
        view.layer.cornerRadius = 10.0
        return view
    }()
    
    private lazy var leftTeamPointsLabel: UILabel = {
        var label = UILabel()
        label.text = NSLocalizedString("Team's total points", comment: "")
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Bold", size: fontSize(size: 13))
        return label
    }()
    
    private lazy var rightTeamPointsLabel: UILabel = {
        var label = UILabel()
        label.text = NSLocalizedString("Team's total points", comment: "")
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Bold", size: fontSize(size: 13))
        return label
    }()
    
    private lazy var leftWinButton: UIButton = {
        var button = UIButton()
        button.setTitle(NSLocalizedString("WIN", comment: ""), for: .normal)
        button.titleLabel?.font = getFontForLanguage(font: "GemunuLibre-Bold", size: 13)
        button.setTitleColor(UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1), for: .normal)
        button.layer.backgroundColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1).cgColor
        button.layer.cornerRadius = 6.0
        return button
    }()
    
    private lazy var leftLoseButton: UIButton = {
        var button = UIButton()
        button.setTitle(NSLocalizedString("LOSE", comment: ""), for: .normal)
        button.titleLabel?.font = getFontForLanguage(font: "GemunuLibre-Bold", size: 13)
        button.setTitleColor(UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1), for: .normal)
        button.layer.backgroundColor = UIColor(red: 0.942, green: 0.71, blue: 0.114, alpha: 1).cgColor
        button.layer.cornerRadius = 6.0
        return button
    }()
    
    private lazy var rightWinButton: UIButton = {
        var button = UIButton()
        button.setTitle(NSLocalizedString("WIN", comment: ""), for: .normal)
        button.titleLabel?.font = getFontForLanguage(font: "GemunuLibre-Bold", size: 13)
        button.setTitleColor(UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1), for: .normal)
        button.layer.backgroundColor = UIColor(red: 0.208, green: 0.671, blue: 0.953, alpha: 1).cgColor
        button.layer.cornerRadius = 6.0
        return button
    }()
    
    private lazy var rightLoseButton: UIButton = {
        var button = UIButton()
        button.setTitle(NSLocalizedString("LOSE", comment: ""), for: .normal)
        button.titleLabel?.font = getFontForLanguage(font: "GemunuLibre-Bold", size: 13)
        button.setTitleColor(UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1), for: .normal)
        button.layer.backgroundColor = UIColor(red: 0.942, green: 0.71, blue: 0.114, alpha: 1).cgColor
        button.layer.cornerRadius = 6.0
        return button
    }()
    
    func setupOverlayViewPVP() {
        view.addSubview(overlayView)
        overlayView.addSubview(buttonLabel)
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            buttonLabel.widthAnchor.constraint(equalTo: overlayView.widthAnchor, multiplier: 0.8),
            buttonLabel.heightAnchor.constraint(equalTo: overlayView.heightAnchor, multiplier: 0.045),
            buttonLabel.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: self.view.bounds.height * 0.230),
            buttonLabel.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
        ])
    }
    
    func configureGuidePVP(_ frameList: [CGRect], _ positionList: [CGPoint], _ textList: [String], _ tabBarTop: CGFloat){
        let count = frameList.count - 8
        for i in 0..<count {
            let explanationLbl = UILabel()
            explanationLbl.translatesAutoresizingMaskIntoConstraints = false
            explanationLbl.text = textList[i]
            explanationLbl.numberOfLines = 0
            explanationLbl.textAlignment = .center
            explanationLbl.textColor = .white
            explanationLbl.font = UIFont(name: "Dosis-Bold", size: 15)
            overlayView.addSubview(explanationLbl)
            
            if positionList[i].y >= tabBarTop {
                if textList[i] == "Timer &\nStart/End Game" || textList[i] == "Timer & \n Station Info" {
                    explanationLbl.widthAnchor.constraint(equalToConstant: 150).isActive = true
                } else {
                    explanationLbl.widthAnchor.constraint(equalToConstant: 90).isActive = true
                }
            } else {
                explanationLbl.widthAnchor.constraint(equalToConstant: 200).isActive = true
            }
            
            let circleView = UIView()
            circleView.translatesAutoresizingMaskIntoConstraints = false
            circleView.clipsToBounds = true
            circleView.layer.cornerRadius = frameList[i].height * 1.55 / 2
            circleView.layer.borderColor = colorList[i]
            circleView.layer.borderWidth = 3
            overlayView.addSubview(circleView)
            
            NSLayoutConstraint.activate([
                explanationLbl.centerXAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: positionList[i].x),
                explanationLbl.bottomAnchor.constraint(equalTo: overlayView.topAnchor, constant: tabBarTop - 17),
                
                circleView.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: positionList[i].y*0.981),
                circleView.centerXAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: positionList[i].x),
                circleView.widthAnchor.constraint(equalToConstant: frameList[i].height * 1.6),
                circleView.heightAnchor.constraint(equalTo: circleView.widthAnchor)
            ])
            
            overlayView.addSubview(leftButtonBorder)
            overlayView.addSubview(rightButtonBorder)
            overlayView.addSubview(leftTeamPointsLabel)
            overlayView.addSubview(rightTeamPointsLabel)
            overlayView.addSubview(leftWinButton)
            overlayView.addSubview(leftLoseButton)
            overlayView.addSubview(rightWinButton)
            overlayView.addSubview(rightLoseButton)
            overlayView.addSubview(explanationLabel)
            leftButtonBorder.translatesAutoresizingMaskIntoConstraints = false
            rightButtonBorder.translatesAutoresizingMaskIntoConstraints = false
            leftTeamPointsLabel.translatesAutoresizingMaskIntoConstraints = false
            rightTeamPointsLabel.translatesAutoresizingMaskIntoConstraints = false
            leftWinButton.translatesAutoresizingMaskIntoConstraints = false
            leftLoseButton.translatesAutoresizingMaskIntoConstraints = false
            rightWinButton.translatesAutoresizingMaskIntoConstraints = false
            rightLoseButton.translatesAutoresizingMaskIntoConstraints = false
            explanationLabel.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                leftButtonBorder.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: frameList[count].minX),
                leftButtonBorder.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: frameList[count].minY),
                leftButtonBorder.widthAnchor.constraint(equalToConstant: frameList[count].width),
                leftButtonBorder.heightAnchor.constraint(equalToConstant: frameList[count].height),
                
                leftWinButton.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: frameList[count + 1].minX),
                leftWinButton.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: frameList[count + 1].minY),
                leftWinButton.widthAnchor.constraint(equalToConstant: frameList[count + 1].width),
                leftWinButton.heightAnchor.constraint(equalToConstant: frameList[count + 1].height),
                
                leftLoseButton.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: frameList[count + 2].minX),
                leftLoseButton.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: frameList[count + 2].minY),
                leftLoseButton.widthAnchor.constraint(equalToConstant: frameList[count + 2].width),
                leftLoseButton.heightAnchor.constraint(equalToConstant: frameList[count + 2].height),
                
                leftTeamPointsLabel.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: frameList[count + 3].minX),
                leftTeamPointsLabel.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: frameList[count + 3].minY - frameList[count + 3].height/2),
                leftTeamPointsLabel.widthAnchor.constraint(equalToConstant: frameList[count + 3].width),
                leftTeamPointsLabel.heightAnchor.constraint(equalToConstant: frameList[count + 3].height),
                
                rightButtonBorder.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: frameList[count + 4].minX),
                rightButtonBorder.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: frameList[count + 4].minY),
                rightButtonBorder.widthAnchor.constraint(equalToConstant: frameList[count + 4].width),
                rightButtonBorder.heightAnchor.constraint(equalToConstant: frameList[count + 4].height),
                
                rightWinButton.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: frameList[count + 5].minX),
                rightWinButton.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: frameList[count + 5].minY),
                rightWinButton.widthAnchor.constraint(equalToConstant: frameList[count + 5].width),
                rightWinButton.heightAnchor.constraint(equalToConstant: frameList[count + 5].height),
                
                rightLoseButton.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: frameList[count + 6].minX),
                rightLoseButton.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: frameList[count + 6].minY),
                rightLoseButton.widthAnchor.constraint(equalToConstant: frameList[count + 6].width),
                rightLoseButton.heightAnchor.constraint(equalToConstant: frameList[count + 6].height),
                
                rightTeamPointsLabel.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: frameList[count + 7].minX),
                rightTeamPointsLabel.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: frameList[count + 7].minY - frameList[count + 7].height/2),
                rightTeamPointsLabel.widthAnchor.constraint(equalToConstant: frameList[count + 7].width),
                rightTeamPointsLabel.heightAnchor.constraint(equalToConstant: frameList[count + 7].height),
                
                explanationLabel.widthAnchor.constraint(equalTo: overlayView.widthAnchor, multiplier: 0.8),
                explanationLabel.heightAnchor.constraint(equalTo: overlayView.heightAnchor, multiplier: 0.025),
                explanationLabel.topAnchor.constraint(equalTo: leftWinButton.bottomAnchor, constant: self.view.bounds.height * 0.04),
                explanationLabel.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            ])
        }
    }
}
