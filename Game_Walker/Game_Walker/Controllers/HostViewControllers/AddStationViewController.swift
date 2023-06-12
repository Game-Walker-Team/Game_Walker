//
//  AddStationViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 7/22/22.
//

import UIKit
import SwiftUI
import PromiseKit

class AddStationViewController: BaseViewController {

    @IBOutlet var fullview: UIView!
    @IBOutlet weak var gamenameTextfield: UITextField!
    @IBOutlet weak var gamelocationTextfield: UITextField!
    @IBOutlet weak var gamepointsTextfield: UITextField!
    @IBOutlet weak var rulesTextfield: UITextView!
    
    @IBOutlet weak var pvpButton: UIButton!
    @IBOutlet weak var pveButton: UIButton!
    @IBOutlet weak var refereeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var refereeLabel: UILabel!
    
    weak var stationsTableViewController: StationsTableViewController?

    var gamecode = UserData.readGamecode("gamecode")!
    
    var stationExists = false
    var modified = false
    var station : Station?
    
    var pvpnotchosen = true
    var isPvp = false
    var availableReferees : [Referee] = []
    var gamename = ""
    var gamelocation = ""
    var gamepoints = 0
    var refereename = ""
    var isdropped = false
    var rules = ""
    
    let refereeTableView = UITableView()
    let transparentView = UIView()
    
    var refereeBefore : Referee?
    var newReferee : Referee?
    var stationToReplace : Station?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gamenameTextfield.delegate = self
        gamelocationTextfield.delegate = self
        gamepointsTextfield.delegate = self
        rulesTextfield.delegate = self
        gamepointsTextfield.keyboardType = .numberPad
        
        refereeTableView.register(UINib(nibName: "StationRefereeTableViewCell", bundle: nil), forCellReuseIdentifier: "StationRefereeTableViewCell")
        refereeTableView.delegate = self
        refereeTableView.dataSource = self
        


        if stationExists {
            gamenameTextfield.attributedPlaceholder = NSAttributedString(string: station!.name, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
            gamename = station!.name
            
            gamelocationTextfield.attributedPlaceholder = NSAttributedString(string: station!.place, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
            gamelocation = station!.place
            
            gamepointsTextfield.attributedPlaceholder = NSAttributedString(string: String(station!.points), attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
            rulesTextfield.text = station?.description
            gamepoints = station!.points
            
            pvpnotchosen = false
            if ((station?.pvp) != nil) {
                pvpButton.sendActions(for: .touchUpInside)
                isPvp = true
                modified = true
            } else {
                pveButton.sendActions(for: .touchUpInside)
                isPvp = false
                modified = true
            }
            refereename = (station?.referee!.name)!
            R.delegate_getReferee = self
            R.getReferee(gamecode, refereename)
        }
        
        R.delegate_refereeList = self
        R.getRefereeList(gamecode)
        checkReferee()
        setPaddings()

        
        self.hideKeyboardWhenTappedAround()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let sender = sender as? StationsTableViewController else { return }
        stationsTableViewController = sender
    }

    func addRefereeTable() {

        transparentView.frame = self.view.frame
        self.view.addSubview(transparentView)
        self.view.addSubview(refereeTableView)
        refereeTableView.layer.cornerRadius = 15

        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(removeRefereeTable))
        transparentView.addGestureRecognizer(tapgesture)
//        transparentView.alpha = 0
        
        //create anmiation
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            self.refereeTableView.alpha = 0.8
            
            self.giveConstraints()
        }, completion: nil)
         
    }
    
    func giveConstraints() {
//        transparentView.translatesAutoresizingMaskIntoConstraints = false
        refereeTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            refereeTableView.centerXAnchor.constraint(equalTo: refereeButton.centerXAnchor),
            refereeTableView.topAnchor.constraint(equalTo: refereeButton.bottomAnchor),
            refereeTableView.widthAnchor.constraint(equalTo: refereeButton.widthAnchor),
            refereeTableView.heightAnchor.constraint(equalTo: refereeButton.heightAnchor, multiplier: 6)
        ])
//        refereeTableView.layer.borderColor = .init(red: 25, green: 225, blue: 15, alpha: 1)
//        refereeTableView.layer.borderWidth = 4
//        refereeTableView.layer.cornerRadius = 15
    }
    
    @objc func removeRefereeTable() {
        if (isdropped) {
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
                self.transparentView.alpha = 0
                self.refereeTableView.alpha = 0
            }, completion: nil)
            isdropped = false
        }

    }
    



//    func updateStation(gamecode: String, refereeBefore: Referee?, gamename: String, refereename: String, isPvp: Bool, gamepoints: Int, gamelocation: String, rules: String) -> Promise<Void> {
//        return Promise<Void> { resolver in
//            // Call unassignStation
//            R.unassignStation(gamecode, refereeBefore!)
//                .then { () -> Promise<Referee> in
//                    // Create new referee object
//                    let newReferee = Referee(gamecode: UserData.readGamecode("gamecode")!, name: refereename, stationName: gamename, assigned: true)
//                    // Call assignStation
//                    return R.assignStation(UserData.readGamecode("gamecode")!, newReferee, gamename)
//                }
//                .then { (newReferee: Referee) -> Promise<Station> in
//                    // Create station object
//                    let stationToReplace = Station(name: gamename, pvp: isPvp, points: gamepoints, place: gamelocation, referee: newReferee, description: rules)
//                    // Call removeStation
//                    return S.removeStation(gamecode, gamename).then { () -> Promise<Station> in
//                        // Call addStation
//                        return S.addStation(gamecode, stationToReplace)
//                    }
//                }
//                .done { _ in
//                    // Resolve promise when all functions complete successfully
//                    resolver.fulfill(())
//                }
//                .catch { (error) in
//                    // Reject promise if any function throws an error
//                    resolver.reject(error)
//                }
//        }
//    }
//
//


    
    func checkReferee() {
        if refereename == "" && !stationExists{
            refereeLabel.text = "Choose Referee"
        } else{
            refereeLabel.text = refereename
        }
        refereeLabel.font = UIFont(name:"Dosis", size: 20.0)
    }
    
    func setPaddings() {
        let padding: CGFloat = 10.0
        gamenameTextfield.setPadding(left: padding, right: padding)
        gamelocationTextfield.setPadding(left: padding, right: padding)
        gamepointsTextfield.setPadding(left: padding, right: padding)
        rulesTextfield.textContainerInset = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
    }
    
    @IBAction func pvpChosen(_ sender: UIButton) {
        pvpnotchosen = false
        
        if pveButton.currentBackgroundImage == UIImage(named:"pve selected 1") {
            pveButton.setBackgroundImage(UIImage(named:"pve 1"), for:.normal)
        }
        pvpButton.setBackgroundImage(UIImage(named:"pvp selected 1"), for: .normal)
        isPvp = true
    }
    
    @IBAction func pveChosen(_ sender: UIButton) {
        pvpnotchosen = false
        if pvpButton.currentBackgroundImage == UIImage(named:"pvp selected 1") {
            pvpButton.setBackgroundImage(UIImage(named:"pvp 1"), for:.normal)
        }
        pveButton.setBackgroundImage(UIImage(named:"pve selected 1"), for: .normal)
        isPvp = false
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if !stationExists {
            if (gamenameTextfield.text!.isEmpty) {
                alert(title:"No Game Name",message:"Please enter the game name.")
            } else {
                gamename = gamenameTextfield.text!
            }
            if (gamelocationTextfield.text!.isEmpty) {
                alert(title:"No Game Location",message:"Please enter the game location.")
            } else {
                gamelocation = gamelocationTextfield.text!
            }
            if (gamepointsTextfield.text!.isEmpty) {
                alert(title:"No Game Points",message:"Please set the game points.")
            } else {
                gamepoints = Int(gamepointsTextfield.text!)!
            }
            if (rulesTextfield.text!.isEmpty) {
                alert(title:"No Game Rules",message:"Please enter the game rules.")
            } else {
                rules = rulesTextfield.text!
            }
            if (pvpnotchosen) {
                alert(title:"Game Type Not Specified", message: "Please select either PVP or PVE")
            }
        }
        
        
        if (stationExists && !modified) {
            self.dismiss(animated: true, completion: nil)
        } else if (stationExists && modified) {

            firstly { () -> Promise<Void> in
                return Promise<Void> { seal in
                    //unassigns referee object's station
                    unassignStation(gamecode: gamecode, refereetounassign: refereeBefore!) { [self] in
                        print("Unassigning referee object's station")
                        newReferee = Referee(gamecode: gamecode, name: refereename, stationName: gamename, assigned: true)
                        seal.fulfill(())
                    }
                }
            }.then { [self] in
                return Promise<Void> { seal in
                    assignStation(gamecode: gamecode, refereetoassign: newReferee!, stationName: gamename) {
                        seal.fulfill(())
                    }
                }
            }.then { [self] () -> Promise<Void> in
                return Promise<Void> { seal in
                    // removes station
                    removeStation(gamecode: gamecode, stationtoremove: station!) {
                        seal.fulfill(())
                    }
                }
            }.then { [self] () -> Promise<Void> in
                return Promise<Void> { seal in
                    //creates new station with new referee
                    stationToReplace = Station(name: gamename, pvp: isPvp, points: gamepoints, place: gamelocation, referee: newReferee, description: rules)
                    addStation(gamecode: gamecode, stationtoadd: stationToReplace!) {
                        seal.fulfill(())
                    }
                }
            }.done {
                print("All works with the server are done")
            }.catch { error in
                print("An error occurred: \(error)")
                self.alert(title: "", message: "Error occurred while communicating with the server. Try again few seconds later!")
            }

        } else if (!stationExists) {
            let selectedReferee = Referee(gamecode:UserData.readGamecode("gamecode")!, name: refereename, stationName: gamename,assigned: true)
            R.assignStation(UserData.readGamecode("gamecode")!, selectedReferee, gamename)
            let stationToAdd = Station(name:gamename, pvp: isPvp, points: gamepoints, place: gamelocation, referee : selectedReferee, description: rules)
            S.addStation(UserData.readGamecode("gamecode")!, stationToAdd)
        }
        

        
        stationsTableViewController?.reloadStationTable()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func refereeButtonPressed(_ sender: UIButton) {
//        dropRefereeList(dropped: isdropped)
//        self.refereeTableView.reloadData()
        if (!isdropped) {
            addRefereeTable()
            isdropped = true
        } else {
            removeRefereeTable()
            isdropped = false
        }
    }
    
    
    
}


extension AddStationViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // check if content changed
        if stationExists {
            modified = true
        }
        return true
    }
}

extension AddStationViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if stationExists {
            modified = true
        }
        return true
    }

}


extension AddStationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableReferees.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = refereeTableView.dequeueReusableCell(withIdentifier: "StationRefereeTableViewCell", for: indexPath) as! StationRefereeTableViewCell
        let curr_cellname = availableReferees[indexPath.row].name
        cell.configureRefereeCell(refereeName: curr_cellname)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(availableReferees[indexPath.row])

        refereename = availableReferees[indexPath.row].name
        
        if stationExists && refereename != refereeBefore!.name {
            //NEED SOME CODE THAT UNASSIGNS ORIGINAL REFEREE ("refereename")
//            R.unassignStation(gamecode, refereeBefore!)
            //AND REASSIGNS NEW REFEREE ("selectedRefereeName")
            modified = true
        }
//        print(refereename)
        checkReferee()
        refereeButton.setTitle(refereename, for: .normal)
        removeRefereeTable()
    }

}



extension AddStationViewController: RefereeList {
    func listOfReferees(_ referees: [Referee]) {
        for referee in referees {
            if (!referee.assigned) {
                availableReferees.append(referee)
                print(availableReferees)
            }
        }
    }
}

extension AddStationViewController : GetReferee {
    func getReferee(_ referee: Referee) {
        refereeBefore = referee
    }
}

extension AddStationViewController : GetStation {
    func getStation(_ station: Station) {
        if stationExists {
            self.station = station
        }
    }
    
    
}


extension AddStationViewController {
    func addStation(gamecode: String, stationtoadd: Station, completion: @escaping () -> Void) {
        S.addStation(gamecode, stationtoadd)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Simulate asynchronous task completion after 0.4 seconds
            completion()
        }
    }
    
    func removeStation(gamecode: String, stationtoremove: Station, completion: @escaping () -> Void) {
        S.removeStation(gamecode,stationtoremove)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            // Simulate asynchronous task completion after 0.4 seconds
            completion()
        }
    }
    
    func assignStation(gamecode: String, refereetoassign: Referee, stationName: String, completion: @escaping () -> Void) {
        R.assignStation(gamecode, refereetoassign, stationName)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Simulate asynchronous task completion after 0.4 seconds
            completion()
        }
    }
    
    func unassignStation(gamecode: String, refereetounassign: Referee, completion: @escaping () -> Void) {
        R.unassignStation(gamecode, refereetounassign)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Simulate asynchronous task completion after 0.4 seconds
            completion()
        }
    }
}
