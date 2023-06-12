//
//  StationsTableViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 8/18/22.
//

import UIKit

class StationsTableViewController: BaseViewController {
    
    var currentStations: [Station] = []

    var curr_gamecode = UserData.readGamecode("gamecode")
    
    @IBOutlet weak var stationTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stationTable.register(UINib(nibName: "HostStationsTableViewCell", bundle: nil), forCellReuseIdentifier: "HostStationsTableViewCell")
        stationTable.delegate = self
        stationTable.dataSource = self
        stationTable.separatorStyle = UITableViewCell.SeparatorStyle.none
        S.delegate_stationList = self
        S.getStationList(curr_gamecode!)
    }
    
    func reloadStationTable() {
        S.getStationList(curr_gamecode!)
        self.stationTable.reloadData()
    }
    

}

extension StationsTableViewController: UITableViewDelegate {
    
}

extension StationsTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentStations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = stationTable.dequeueReusableCell(withIdentifier: "HostStationsTableViewCell", for: indexPath) as! HostStationsTableViewCell
        let curr_cellname = currentStations[indexPath.row].name
        cell.configureStationCell(stationName: curr_cellname)
        cell.backgroundView = UIImageView(image: UIImage(named: "cell-with-transparent"))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "AddStationViewController") as? AddStationViewController {
            vc.stationExists = true
            vc.station = currentStations[indexPath.row]
            
            
            self.navigationController?.present(vc, animated: true)
            
        }
    }
    
    
}

extension StationsTableViewController: StationList {
    func listOfStations(_ stations: [Station]) {
        currentStations = stations
        reloadStationTable()
    }
    
}
