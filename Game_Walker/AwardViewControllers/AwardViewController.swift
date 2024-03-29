//
//  AwardViewController.swift
//  Game_Walker
//
//  Created by Noah Kim on 2/20/23.
//

import Foundation
import UIKit

class AwardViewController: UIViewController {
    
    private let gameCode = UserData.readGamecode("gamecode") ?? ""
    private var newTeamList: [Team] = []
    
    public var from: String?
    
    private let leaderBoard = UITableView(frame: .zero)
    private let cellSpacingHeight: CGFloat = 3
    private let audioPlayerManager = AudioPlayerManager()
    private var soundEnabled: Bool = UserData.getUserSoundPreference() ?? true
    private let role = UserData.getUserRole()
    
    private var firstReveal: Bool = false
    private var secondReveal: Bool = false
    private var thirdReveal: Bool = false

    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(patternImage: UIImage(named: "AwardBackground") ?? UIColor.white.image())
        view.contentMode = .scaleAspectFit
        return view
    }()

    private lazy var congratulationLabel: UILabel = {
        var view = UILabel()
        view.textColor = UIColor(red: 0.942, green: 0.71, blue: 0.114, alpha: 1)
        view.font = getFontForLanguage(font: "GemunuLibre-SemiBold", size: 40)
        view.text = NSLocalizedString("CONGRATULATIONS", comment: "")
        view.textAlignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var firstPlaceImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var firstPlaceTeamNum: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-SemiBold", size: 20)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var firstPlaceTeamName: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Regular", size: 18)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var firstPlacePoints: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Bold", size: 23)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var firstPlaceCoverView: UIView = {
        let view = UIView()
        setView(view: view, place: 1)
        return view
    }()
    
    private lazy var firstPlaceView: UIView = {
        let view = UIView()
        view.addSubview(firstPlaceImage)
        view.addSubview(firstPlaceTeamNum)
        view.addSubview(firstPlaceTeamName)
        view.addSubview(firstPlacePoints)
        view.addSubview(firstPlaceCoverView)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            firstPlaceCoverView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            firstPlaceCoverView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            firstPlaceCoverView.topAnchor.constraint(equalTo: view.topAnchor),
            firstPlaceCoverView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            firstPlaceImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            firstPlaceImage.widthAnchor.constraint(equalTo: firstPlaceImage.heightAnchor, multiplier: 1),
            firstPlaceImage.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.55),
            NSLayoutConstraint(item: firstPlaceImage, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            
            firstPlaceTeamNum.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            firstPlaceTeamNum.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            firstPlaceTeamNum.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.122642),
            NSLayoutConstraint(item: firstPlaceTeamNum, attribute: .top, relatedBy: .equal, toItem: firstPlaceImage, attribute: .bottom, multiplier: 1, constant: 0),
            
            firstPlaceTeamName.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            firstPlaceTeamName.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            firstPlaceTeamName.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.122642),
            NSLayoutConstraint(item: firstPlaceTeamName, attribute: .top, relatedBy: .equal, toItem: firstPlaceTeamNum, attribute: .bottom, multiplier: 1, constant: 0),
            
            firstPlacePoints.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            firstPlacePoints.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            firstPlacePoints.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.122642),
            NSLayoutConstraint(item: firstPlacePoints, attribute: .top, relatedBy: .equal, toItem: firstPlaceTeamName, attribute: .bottom, multiplier: 1, constant: 0)
        ])
        return view
    }()
    
    private lazy var secondPlaceCoverView: UIView = {
        let view = UIView()
        setView(view: view, place: 2)
        return view
    }()
    
    private lazy var secondPlaceImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var secondPlaceTeamNum: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-SemiBold", size: 15)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var secondPlaceTeamName: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Regular", size: 13)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var secondPlacePoints: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Bold", size: 18)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var secondPlaceView: UIView = {
        let view = UIView()
        view.addSubview(secondPlaceImage)
        view.addSubview(secondPlaceTeamNum)
        view.addSubview(secondPlaceTeamName)
        view.addSubview(secondPlacePoints)
        view.addSubview(secondPlaceCoverView)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            secondPlaceCoverView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            secondPlaceCoverView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            secondPlaceCoverView.topAnchor.constraint(equalTo: view.topAnchor),
            secondPlaceCoverView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            secondPlaceImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            secondPlaceImage.widthAnchor.constraint(equalTo: secondPlaceImage.heightAnchor, multiplier: 1),
            secondPlaceImage.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.613208),
            NSLayoutConstraint(item: secondPlaceImage, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            
            secondPlaceTeamNum.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            secondPlaceTeamNum.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            secondPlaceTeamNum.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.122642),
            NSLayoutConstraint(item: secondPlaceTeamNum, attribute: .top, relatedBy: .equal, toItem: secondPlaceImage, attribute: .bottom, multiplier: 1, constant: 0),
            
            secondPlaceTeamName.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            secondPlaceTeamName.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            secondPlaceTeamName.heightAnchor.constraint(equalTo: secondPlaceImage.heightAnchor, multiplier: 0.176923),
            NSLayoutConstraint(item: secondPlaceTeamName, attribute: .top, relatedBy: .equal, toItem: secondPlaceTeamNum, attribute: .bottom, multiplier: 1, constant: 0),
            
            secondPlacePoints.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            secondPlacePoints.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            secondPlacePoints.heightAnchor.constraint(equalTo: secondPlaceImage.heightAnchor, multiplier: 0.230769),
            NSLayoutConstraint(item: secondPlacePoints, attribute: .top, relatedBy: .equal, toItem: secondPlaceTeamName, attribute: .bottom, multiplier: 1, constant: 0)
        ])
        return view
    }()
    
    private lazy var thirdPlaceCoverView: UIView = {
        let view = UIView()
        setView(view: view, place: 3)
        return view
    }()
    
    private lazy var thirdPlaceImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var thirdPlaceTeamNum: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-SemiBold", size: 15)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var thirdPlaceTeamName: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Regular", size: 13)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var thirdPlacePoints: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(name: "Dosis-Bold", size: 18)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var thirdPlaceView: UIView = {
        let view = UIView()
        view.addSubview(thirdPlaceImage)
        view.addSubview(thirdPlaceTeamNum)
        view.addSubview(thirdPlaceTeamName)
        view.addSubview(thirdPlacePoints)
        view.addSubview(thirdPlaceCoverView)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            thirdPlaceCoverView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            thirdPlaceCoverView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            thirdPlaceCoverView.topAnchor.constraint(equalTo: view.topAnchor),
            thirdPlaceCoverView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            thirdPlaceImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            thirdPlaceImage.widthAnchor.constraint(equalTo: thirdPlaceImage.heightAnchor, multiplier: 1),
            thirdPlaceImage.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.613208),
            NSLayoutConstraint(item: thirdPlaceImage, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            
            thirdPlaceTeamNum.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            thirdPlaceTeamNum.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            thirdPlaceTeamNum.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.122642),
            NSLayoutConstraint(item: thirdPlaceTeamNum, attribute: .top, relatedBy: .equal, toItem: thirdPlaceImage, attribute: .bottom, multiplier: 1, constant: 0),
            
            thirdPlaceTeamName.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            thirdPlaceTeamName.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            thirdPlaceTeamName.heightAnchor.constraint(equalTo: thirdPlaceImage.heightAnchor, multiplier: 0.176923),
            NSLayoutConstraint(item: thirdPlaceTeamName, attribute: .top, relatedBy: .equal, toItem: thirdPlaceTeamNum, attribute: .bottom, multiplier: 1, constant: 0),
            
            thirdPlacePoints.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            thirdPlacePoints.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            thirdPlacePoints.heightAnchor.constraint(equalTo: thirdPlaceImage.heightAnchor, multiplier: 0.230769),
            NSLayoutConstraint(item: thirdPlacePoints, attribute: .top, relatedBy: .equal, toItem: thirdPlaceTeamName, attribute: .bottom, multiplier: 1, constant: 0)
        ])
        return view
    }()
    
    private lazy var secondAndThirdPlaceStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.addArrangedSubview(secondPlaceView)
        stackView.addArrangedSubview(thirdPlaceView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var gameCodeLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 127, height: 31)
        let attributedText = NSMutableAttributedString()
        let gameCodeAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 15) ?? UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.black
        ]
        let gameCodeAttributedString = NSAttributedString(string: NSLocalizedString("Game Code", comment: "") + "\n", attributes: gameCodeAttributes)
        attributedText.append(gameCodeAttributedString)
        let numberAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Dosis-Bold", size: 10) ?? UIFont.systemFont(ofSize: 25),
            .foregroundColor: UIColor.black
        ]
        let numberAttributedString = NSAttributedString(string: gameCode, attributes: numberAttributes)
        attributedText.append(numberAttributedString)
        label.backgroundColor = .white
        label.attributedText = attributedText
        label.textColor = UIColor(red: 0, green: 0, blue: 0 , alpha: 1)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var logoImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: "logo")
        
        return view
    }()

    private lazy var homeBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "homeBtn"), for: .normal)
        button.addTarget(self, action: #selector(callMainVC), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var soundButton: UIButton = {
        let button = UIButton()
        let soundImage = UIImage(named: "sound-icon-on")
        let soundImageOff = UIImage(named: "sound-icon-off")

        if soundEnabled {
            button.setImage(soundImage, for: .normal)
        } else {
            button.setImage(soundImageOff, for: .normal)
        }
        button.addTarget(self, action: #selector(soundButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var homeandSoundStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 5
        stackView.addArrangedSubview(soundButton)
        stackView.addArrangedSubview(homeBtn)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var navStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .equalSpacing
        view.spacing = 0
        view.addArrangedSubview(logoImage)
        view.addArrangedSubview(gameCodeLabel)
        view.addArrangedSubview(homeandSoundStack)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        print(H.delegates)
        if !(role == "host") {
            H.delegates.append(WeakHostUpdateListener(value: self))
            H.listenHost(gameCode, onListenerUpdate: listen(_:))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        if !(role == "host") {
            H.delegates = H.delegates.filter { $0.value != nil }
            H.detatchHost()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureSound()
        getTeamList(gameCode)
        if soundEnabled {
            self.audioPlayerManager.playAudioFile(named: "congrats_ending", withExtension: "wav")
        }
        setIsRevealed()
    }
    
    private func setView(view: UIView, place: Int) {
        switch place {
        case 1:
            view.tag = 100
            break
        case 2:
            view.tag = 200
            break
        default:
            view.tag = 300
        }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        if role == "host" {
            addDoubleTapGestureRecognizer(view: view)
        }
        generateLabelAndImageView(parentView: view, place: place)
    }
    
    private func generateLabelAndImageView(parentView: UIView, place: Int) {
        let label = UILabel()
        let imageView = UIImageView()
        
        if role == "host" {
            label.text = NSLocalizedString("Double-tap\nto reveal!", comment: "")
        } else {
            label.text = NSLocalizedString("Host will\nreveal soon!", comment: "")
        }
        label.textAlignment = .center
        label.font = getFontForLanguage(font: "GemunuLibre-SemiBold", size: fontSize(size: 15))
        label.numberOfLines = 2
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        
        switch place {
        case 1:
            imageView.image = UIImage(named: "1st-hidden")
            break
        case 2:
            imageView.image = UIImage(named: "2nd-hidden")
            break
        default:
            imageView.image = UIImage(named: "3rd-hidden")
        }
        
        parentView.addSubview(imageView)
        parentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: parentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
            
            label.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            label.heightAnchor.constraint(equalTo: parentView.heightAnchor, multiplier: 0.5),
            label.centerYAnchor.constraint(equalTo: parentView.centerYAnchor)
        ])
    }
    
    private func addDoubleTapGestureRecognizer(view: UIView) {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
    }

    @objc private func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        print("double tapped!")
        if let view = recognizer.view {
            if !view.isHidden {
                view.isHidden = true
                if role == "host" {
                    reveal(tag: view.tag)
                }
            }
        }
    }
    
    private func reveal(tag: Int) {
        switch tag {
        case 100:
            firstReveal = true
            break
        case 200:
            secondReveal = true
            break
        default:
            thirdReveal = true
        }
        Task { @MainActor in
            do {
                try await H.award_reveal(gameCode, firstReveal, secondReveal, thirdReveal)
                print("revealed view with tag \(tag)")
            } catch GameWalkerError.serverError(let e) {
                print(e)
                alert(title: "", message: e)
                return
            }
        }
    }

    private func configureSound() {
        if UserData.getUserSoundPreference() == nil {
            UserData.setUserSoundPreference(true)
            soundEnabled = true
        }
    }

    @objc func soundButtonTapped(_ sender: UIButton) {
        soundEnabled = !soundEnabled
        UserData.setUserSoundPreference(soundEnabled)
        if !soundEnabled{
            sender.setImage(UIImage(named: "sound-icon-off"), for: .normal)
            if audioPlayerManager.isPlaying() {
                self.audioPlayerManager.stop()
            }
        } else {
            sender.setImage(UIImage(named: "sound-icon-on"), for: .normal)
            if !audioPlayerManager.isPlaying() {
                self.audioPlayerManager.playAudioFile(named: "congrats_ending", withExtension: "wav")
            }
        }
    }
    
    private func setIsRevealed() {
        Task { @MainActor in
            do {
                guard let host = try await H.getHost(gameCode) else { return }
                firstPlaceCoverView.isHidden = host.firstReveal
                secondPlaceCoverView.isHidden = host.secondReveal
                thirdPlaceCoverView.isHidden = host.thirdReveal
            } catch GameWalkerError.serverError(let e) {
                print(e)
                serverAlert(e)
                return
            }
        }
    }

    private func getTeamList(_ gamecode: String) {
        Task { @MainActor in
            do {
                var teamList = try await T.getTeamList(gamecode)
                let order: (Team, Team) -> Bool = {(lhs, rhs) in
                    return lhs.points > rhs.points
                }
                
                teamList.sort(by: order)
                
                if teamList.count > 3 {
                    configureTopThree(teamList.first, teamList[1], teamList[2])
                } else if teamList.count > 2 {
                    configureTopThree(teamList.first, teamList[1], teamList[2])
                } else if teamList.count > 1 {
                    configureTopThree(teamList.first, teamList[1], nil)
                } else {
                    configureTopThree(teamList.first, nil, nil)
                }
                
                if teamList.count > 3 {
                    newTeamList = getNewTeamList(teamList)
                }
                
                if newTeamList.count >= 1 {
                    configureLeaderboard()
                }
            } catch GameWalkerError.invalidGamecode(let message) {
                print(message)
                gamecodeAlert(message)
                return
            } catch GameWalkerError.serverError(let message) {
                print(message)
                serverAlert(message)
                return
            }
        }
    }
    
    
    
    private func configureViews() {
        view.addSubview(containerView)
        containerView.addSubview(congratulationLabel)
        containerView.addSubview(firstPlaceView)
        containerView.addSubview(secondAndThirdPlaceStackView)
        containerView.addSubview(leaderBoard)
        containerView.addSubview(navStackView)
        leaderBoard.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            navStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            navStackView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.780322),
            navStackView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.04),
            navStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: self.view.bounds.height * 0.063),
            
            congratulationLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            congratulationLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.780322),
            congratulationLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.0658762),
            congratulationLabel.topAnchor.constraint(equalTo: navStackView.bottomAnchor, constant: 10),
            
            firstPlaceView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            firstPlaceView.widthAnchor.constraint(equalTo: congratulationLabel.widthAnchor, multiplier: 0.47),
            firstPlaceView.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.25),
            firstPlaceView.topAnchor.constraint(equalTo: congratulationLabel.bottomAnchor, constant: 5),
            
            secondAndThirdPlaceStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            secondAndThirdPlaceStackView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.64),
            secondAndThirdPlaceStackView.heightAnchor.constraint(equalTo: firstPlaceView.heightAnchor, multiplier: 0.7),
            secondAndThirdPlaceStackView.topAnchor.constraint(equalTo: firstPlaceView.bottomAnchor, constant: 15),
            
            leaderBoard.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            leaderBoard.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.712468),
            leaderBoard.topAnchor.constraint(equalTo: secondAndThirdPlaceStackView.bottomAnchor, constant: 15),
            leaderBoard.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0)
        ])
    }
    
    private func configureLeaderboard() {
        leaderBoard.delegate = self
        leaderBoard.dataSource = self
        leaderBoard.register(AwardTableViewCell.self, forCellReuseIdentifier: AwardTableViewCell.identifier)
        leaderBoard.backgroundColor = UIColor.white
        leaderBoard.allowsSelection = false
        leaderBoard.separatorStyle = .none
    }
    
    private func configureTopThree( _ first: Team?, _ second: Team?, _ third: Team?) {
        if let firstPlace = first {
            firstPlaceImage.image = UIImage(named: firstPlace.iconName)
            firstPlaceTeamNum.text = "Team \(firstPlace.number)"
            firstPlaceTeamName.text = firstPlace.name
            firstPlacePoints.text = String(firstPlace.points)
        }
        
        if let secondPlace = second {
            secondPlaceImage.image = UIImage(named: secondPlace.iconName)
            secondPlaceTeamNum.text = "Team \(secondPlace.number)"
            secondPlaceTeamName.text = secondPlace.name
            secondPlacePoints.text = String(secondPlace.points)
        }
        
        if let thirdPlace = third {
            thirdPlaceImage.image = UIImage(named: thirdPlace.iconName)
            thirdPlaceTeamNum.text = "Team \(thirdPlace.number)"
            thirdPlaceTeamName.text = thirdPlace.name
            thirdPlacePoints.text = String(thirdPlace.points)
        }
    }
    
    private func getNewTeamList(_ teamList: [Team]) -> [Team] {
        var i = 0
        var newList = teamList
        while (i <= 2) {
            newList.remove(at: 0)
            i += 1
        }
        let order: (Team, Team) -> Bool = {(lhs, rhs) in
            return lhs.points > rhs.points
        }
        newList.sort(by: order)
        return newList
    }
    
    @objc func callMainVC() {
        guard let from = self.from else { return }
        print("tapped")
        self.navigationController?.popToMainViewController(from, animated: true)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        // Additional initialization if needed
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func listen(_ _ : [String : Any]){
    }
}
// MARK: - tableView
extension AwardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = leaderBoard.dequeueReusableCell(withIdentifier: AwardTableViewCell.identifier, for: indexPath) as! AwardTableViewCell
        let team = newTeamList[indexPath.row]
        cell.configureRankTableViewCell(imageName: team.iconName, teamNum: "Team \(String(team.number))", teamName: team.name, points: team.points)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newTeamList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
// MARK: - Host listener
extension AwardViewController: HostUpdateListener {
    func updateHost(_ host: Host) {
        firstReveal = host.firstReveal
        secondReveal = host.secondReveal
        thirdReveal = host.thirdReveal
        
        if firstReveal {
            firstPlaceCoverView.isHidden = true
        }
        
        if secondReveal {
            secondPlaceCoverView.isHidden = true
        }
        
        if thirdReveal {
            thirdPlaceCoverView.isHidden = true
        }
    }
}
