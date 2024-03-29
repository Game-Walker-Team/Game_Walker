//
//  SettingTimeHostViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 9/24/22.
//

import UIKit

class SettingTimeHostViewController: UIViewController {
    @IBOutlet weak var gameTimeButton: UIButton!
    @IBOutlet weak var moveTimeButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var gameMinutesLabel: UILabel!
    @IBOutlet weak var gameSecondsLabel: UILabel!
    @IBOutlet weak var movingMinutesLabel: UILabel!
    @IBOutlet weak var movingSecondsLabel: UILabel!
    @IBOutlet weak var roundsTextField: UITextField!
    @IBOutlet weak var teamcountTextField: UITextField!
    
    @IBOutlet weak var settingsStackview: UIStackView!
    @IBOutlet weak var settingsLabel: LocalizedFontLabel!
    private var stationList: [Station] = []
    
    var host: Host?
//    var team: Team?
    var gameminutes: Int = 0
    var gameseconds: Int = 0
    var moveminutes: Int = 0
    var moveseconds: Int = 0
    var teamcount: Int = 0
    var pickertype = 0
    var rounds : Int = 10
    
    private var gamecode = UserData.readGamecode("gamecode")!
    
    var manualAlgorithmViewController: ManualAlgorithmViewController?
    var pvpGameCount : Int = 0
    var pveGameCount : Int = 0
    var num_rounds : Int = 0
    var num_teams : Int = 0
    var num_stations : Int = 0

    //UIPickerView inside of UIView container
    var gametimePickerView: UIView!
    var gametimePicker: UIPickerView!
    var movetimePickerView: UIView!
    var movetimePicker: UIPickerView!
    
    var currentPickerView: UIView!
    var currentPicker: UIPickerView!
    
    var gameToolBar = UIToolbar(frame: CGRect(x: 0, y:0, width: UIScreen.main.bounds.width, height: 35))
    var moveToolBar = UIToolbar(frame: CGRect(x: 0, y:0, width: UIScreen.main.bounds.width, height: 35))
    var roundToolBar = UIToolbar(frame: CGRect(x: 0, y:0, width: UIScreen.main.bounds.width, height: 35))

    var navBarHidden = false
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let destinationVC = navigationController?.viewControllers.last as? StationsTableViewController {
            Task { @MainActor in
                do {
                    try await H.completeStations(gamecode, false)
                } catch GameWalkerError.serverError(let text){
                    print(text)
                    serverAlert(text)
                    return
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSimpleNavBar()
        Task {
            do {
                stationList = try await fetchStationsForAlgorithm()

            } catch {
                print( "Couldn't get data for stations")
            }
        }
        roundsTextField.keyboardType = .numberPad
        roundsTextField.textAlignment = .center
        roundsTextField.delegate = self
        roundsTextField.returnKeyType = .next
        teamcountTextField.keyboardType = .numberPad
        teamcountTextField.textAlignment = .center
        teamcountTextField.delegate = self

        gameMinutesLabel.text = changeTimeToString(timeInteger: gameminutes)
        movingMinutesLabel.text = changeTimeToString(timeInteger: moveminutes)
        
        gameToolBar.sizeToFit()
        moveToolBar.sizeToFit()

        let gamedoneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .done, target: self, action: #selector(self.applyDone))
        let movedoneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .done, target: self, action: #selector(self.applyDone))
        let gamenextButton = UIBarButtonItem(title: NSLocalizedString("Next", comment: ""), style: .plain, target: self, action: #selector(self.applyNext))
        gamenextButton.tag = 1
        let movenextButton = UIBarButtonItem(title: NSLocalizedString("Next", comment: ""), style: .plain, target: self, action: #selector(self.applyNext))
        movenextButton.tag = 2
        print("my move next tag: ", movenextButton.tag)
        
        let roundnextButton = UIBarButtonItem(title: NSLocalizedString("Next", comment: ""), style: .plain, target: self, action: #selector(self.applyNext))
        roundnextButton.tag = 3
        
        gameToolBar.setItems([gamenextButton, UIBarButtonItem.flexibleSpace(), gamedoneButton], animated: true)
        gameToolBar.isUserInteractionEnabled = true
        moveToolBar.setItems([movenextButton, UIBarButtonItem.flexibleSpace(), movedoneButton], animated: true)
        moveToolBar.isUserInteractionEnabled = true
        roundToolBar.items = [UIBarButtonItem.flexibleSpace(), roundnextButton]
        roundToolBar.sizeToFit()
        roundsTextField.inputAccessoryView = roundToolBar


        gametimePickerView = UIView(frame: CGRect(x:0, y: view.frame.height + 260, width: view.frame.width, height: 260))
        movetimePickerView = UIView(frame: CGRect(x:0, y: view.frame.height + 260, width: view.frame.width, height: 260))
        
        view.addSubview(gametimePickerView)
        view.addSubview(movetimePickerView)
        
        gametimePickerView.translatesAutoresizingMaskIntoConstraints = false
        movetimePickerView.translatesAutoresizingMaskIntoConstraints = false
        settingsLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            gametimePickerView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            gametimePickerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 260),
            gametimePickerView.heightAnchor.constraint(equalToConstant: 260),
            movetimePickerView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            movetimePickerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 260),
            movetimePickerView.heightAnchor.constraint(equalToConstant: 260)
        ])

        gametimePickerView.backgroundColor = .white
        movetimePickerView.backgroundColor = .white

        gametimePicker = UIPickerView(frame: CGRect(x: 0, y:0, width: UIScreen.main.bounds.size.width, height: 260))
        movetimePicker = UIPickerView(frame: CGRect(x: 0, y:0, width: UIScreen.main.bounds.size.width, height: 260))
        
        gametimePickerView.addSubview(gametimePicker)
        gametimePickerView.addSubview(gameToolBar)
        movetimePickerView.addSubview(movetimePicker)
        movetimePickerView.addSubview(moveToolBar)

        gametimePicker.isUserInteractionEnabled = true
        movetimePicker.isUserInteractionEnabled = true
        gametimePicker.delegate = self
        movetimePicker.delegate = self
        gametimePicker.dataSource = self
        movetimePicker.dataSource = self
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(dismissPicker))
        
        tapGesture1.require(toFail: tapGesture2)
        view.addGestureRecognizer(tapGesture1)
        view.addGestureRecognizer(tapGesture2)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        configureButtonVisuals()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        navBarHidden = true
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        navBarHidden = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToMatchingSegue" {
            if let destinationVC = segue.destination as? ManualAlgorithmViewController {
                destinationVC.host = self.host
                destinationVC.stationList = self.stationList
                destinationVC.pvpGameCount = self.pvpGameCount
                destinationVC.pveGameCount = self.pveGameCount
                destinationVC.num_rounds = self.rounds
                destinationVC.num_teams = self.teamcount
                destinationVC.num_stations = self.num_stations
            }
        }
    }
    

    @objc func dismissPicker() {
        print("dismissPicker - BEGIN")
        if pickertype == 0 {
            if gametimePickerView.frame.origin.y == view.bounds.height - gametimePickerView.bounds.size.height {
                // Dismiss the picker view
                UIView.animate(withDuration: 0.3, animations: {
                    self.gametimePickerView.frame = CGRect(x:0, y: self.view.bounds.height, width: self.gametimePickerView.bounds.size.width, height: self.gametimePickerView.bounds.size.height)
                })
            }
        } else {
            if movetimePickerView.frame.origin.y == view.bounds.height - movetimePickerView.bounds.size.height {
                // Dismiss the picker view
                UIView.animate(withDuration: 0.3, animations: {
                    self.movetimePickerView.frame = CGRect(x:0, y: self.view.bounds.height, width: self.movetimePickerView.bounds.size.width, height: self.movetimePickerView.bounds.size.height)
                })
            }
        }
        print("dismissPicker - END")
    }
    @IBAction func gametimePressed(_ sender: UIButton) {
        pickertype = 0
        pickerAppear()
    }
    
    @IBAction func movetimePressed(_ sender: UIButton) {
        pickertype = 1
        pickerAppear()
    }
    
    @objc func applyDone() {
        self.view.endEditing(true)
        self.gametimePickerView.endEditing(true)
        pickerDisappear()
        self.gameMinutesLabel.text = changeTimeToString(timeInteger: gameminutes )
        self.gameSecondsLabel.text = changeTimeToString(timeInteger: gameseconds )
        
        self.movetimePickerView.endEditing(true)
        pickerDisappear()
        self.movingMinutesLabel.text = changeTimeToString(timeInteger: moveminutes)
        self.movingSecondsLabel.text = changeTimeToString(timeInteger: moveseconds)
    }
    
    @objc func applyNext(_ sender: UIBarButtonItem) {
        print(sender.tag)
        if (sender.tag == 1) {
            print("in tag 1")
//            self.view.endEditing(true)
            self.gametimePickerView.endEditing(true)
            pickerDisappear()
            self.gameMinutesLabel.text = changeTimeToString(timeInteger: gameminutes )
            self.gameSecondsLabel.text = changeTimeToString(timeInteger: gameseconds )
            
            pickertype = 1
            pickerAppear()
            
        } else if sender.tag == 2 {
            print("in tag 2")
            pickertype = 1
            self.movetimePickerView.endEditing(true)
            pickerDisappear()
            self.movingMinutesLabel.text = changeTimeToString(timeInteger: moveminutes)
            self.movingSecondsLabel.text = changeTimeToString(timeInteger: moveseconds)
            roundsTextField.becomeFirstResponder()
            
        } else if  sender.tag == 3 {
            teamcountTextField.becomeFirstResponder()
        }
    }
    
    @objc func dismissKeyboard() {
        print("dismissKeyboard - BEGIN")
        view.endEditing(true)
        print("dismissKeyboard - End")
    }
    
    func changeTimeToString(timeInteger : Int) -> String{
        var timeString = ""
        if (timeInteger < 10) {
            timeString = "0" + String(timeInteger)
        } else {
            timeString = String(timeInteger)
        }
        return timeString
    }
    
    func pickerAppear() {
        if (pickertype == 0) {
            UIView.animate(withDuration: 0.3, animations: {
                self.gametimePickerView.frame = CGRect(x:0, y: self.view.bounds.height - self.gametimePickerView.bounds.size.height, width: self.gametimePickerView.bounds.size.width, height: self.gametimePickerView.bounds.size.height)
                self.gametimePickerView.addSubview(self.gameToolBar)
               
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.movetimePickerView.frame = CGRect(x:0, y: self.view.bounds.height - self.movetimePickerView.bounds.size.height, width: self.movetimePickerView.bounds.size.width, height: self.movetimePickerView.bounds.size.height)
                self.movetimePickerView.addSubview(self.gameToolBar)
            })
        }
    }
    
    func pickerDisappear() {
        if (pickertype == 0) {
            UIView.animate(withDuration: 0.3, animations:{
                self.gametimePickerView.frame = CGRect(x: 0, y: self.view.bounds.height, width: self.gametimePickerView.bounds.size.width, height: self.gametimePickerView.bounds.size.height)
                self.gameToolBar.removeFromSuperview()
            })
        } else {
            UIView.animate(withDuration: 0.3, animations:{
                self.movetimePickerView.frame = CGRect(x: 0, y: self.view.bounds.height, width: self.movetimePickerView.bounds.size.width, height: 0)
                self.moveToolBar.removeFromSuperview()
            })
        }
    }
    
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        //FIX:- have to get rid of automatic segue
        teamcountTextField.resignFirstResponder()
        roundsTextField.resignFirstResponder()

        var shouldPresentViewController = true  // Introduce a variable to track whether the view controller should be presented

        if let rounds = roundsTextField.text, !rounds.isEmpty, let teamcount = teamcountTextField.text, !teamcount.isEmpty {
            Task { @MainActor in
                guard let roundInt = Int(rounds),
                      let teamcountInt = Int(teamcount) else {
                    shouldPresentViewController = false  // Set to false if an error occurs
                    self.alert(title: NSLocalizedString("Enter a number", comment: ""), message: NSLocalizedString("Please enter a number for rounds and teams.", comment: ""))
                    return
                }
                self.rounds = roundInt
                self.teamcount = teamcountInt
                try await H.setSettings(gamecode,
                              timeConvert(min: gameminutes, sec: gameseconds),
                              timeConvert(min: moveminutes, sec: moveseconds),
                              Int(rounds) ?? 0,
                              Int(teamcount) ?? 0)
                print("rounds and teamcount", rounds, " , ", teamcount)
            }
        } else {
            shouldPresentViewController = false  // Set to false if an error occurs
            alert(title: NSLocalizedString("Woops!", comment: ""), message: NSLocalizedString("Please enter all information to set timer.", comment: ""))
        }

        H.listenHost(gamecode, onListenerUpdate: listen(_:))
        T.listenTeams(gamecode, onListenerUpdate: listen(_:))

        Task {
            await self.manualAlgorithmViewController?.fetchDataSimple(gamecode: gamecode)
            if shouldPresentViewController {
                performSegue(withIdentifier: "ToMatchingSegue", sender: self)
            } else {
                return
            }
        }
    }


    
    private func timeConvert(min : Int, sec : Int) -> Int {
        return (min * 60 + sec)
    }
    func listen(_ _ : [String : Any]){
    }

}


extension SettingTimeHostViewController: UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 61
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerView.frame.size.width/2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(row) \(NSLocalizedString("minutes", comment: ""))"
        case 1:
            return "\(row) \(NSLocalizedString("seconds", comment: ""))"
        default:
            return ""
        }    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if (pickertype == 0) {
            switch component {
            case 0:
                gameminutes = row
            case 1:
                gameseconds = row
            default:
                break
            }
        } else {
            switch component {
            case 0:
                moveminutes = row
            case 1:
                moveseconds = row
            default:
                break
            }
        }

    }
    
    func fetchStationsForAlgorithm() async throws -> [Station] {
        var tempStationList: [Station] = []
        do {
            tempStationList = try await S.getStationList(gamecode)
            num_stations = tempStationList.count
            var pvpCount = 0
                for station in tempStationList {
                    if station.pvp {
                        pvpCount += 1
                    }
                }
            pvpGameCount = pvpCount
            pveGameCount = num_stations - pvpGameCount
        } catch (let e) {
            print(e)
        }
        return tempStationList
    }

    private func configureButtonVisuals() {
        if let originalFont = nextButton.titleLabel?.font {
            nextButton.titleLabel?.font = getFontForLanguage(font: originalFont.fontName, size: originalFont.pointSize)
        }

        if let originalFont = moveTimeButton.titleLabel?.font {
            moveTimeButton.titleLabel?.font = getFontForLanguage(font: originalFont.fontName, size: originalFont.pointSize)
        }

        if let originalFont = gameTimeButton.titleLabel?.font {
            gameTimeButton.titleLabel?.font = getFontForLanguage(font: originalFont.fontName, size: originalFont.pointSize)
        }

        nextButton.layer.cornerRadius = 10.0
        teamcountTextField.layer.borderWidth = 3.0
        teamcountTextField.layer.cornerRadius = 10.0
        teamcountTextField.layer.borderColor = UIColor(red: 0.18, green: 0.18, blue: 0.21, alpha: 1.00).cgColor
        roundsTextField.layer.borderWidth = 3.0
        roundsTextField.layer.cornerRadius = 10.0
        roundsTextField.layer.borderColor = UIColor(red: 0.18, green: 0.18, blue: 0.21, alpha: 1.00).cgColor
        moveTimeButton.layer.borderWidth = 3.0
        moveTimeButton.layer.cornerRadius = 10.0
        moveTimeButton.layer.borderColor = UIColor(red: 0.18, green: 0.18, blue: 0.21, alpha: 1.00).cgColor
        gameTimeButton.layer.borderWidth = 3.0
        gameTimeButton.layer.cornerRadius = 10.0
        gameTimeButton.layer.borderColor = UIColor(red: 0.18, green: 0.18, blue: 0.21, alpha: 1.00).cgColor

    }
}


extension SettingTimeHostViewController: HostUpdateListener, TeamUpdateListener {
    func updateTeams(_ teams: [Team]) {
    }

    
    func updateHost(_ host: Host) {

    }
}
