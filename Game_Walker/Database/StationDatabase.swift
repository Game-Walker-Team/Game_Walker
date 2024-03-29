//
//  Station_Database.swift
//  Game_Walker
//
//  Created by Paul on 7/27/22.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift
import SwiftUI

struct S {
    
    static let db = Firestore.firestore()
    
    //MARK: - Station Control Functions
    
    static func saveStation(_ gamecode: String, _ station: Station) async throws {
        let docRef = db.collection("Servers").document("Gamecode : \(gamecode)")
        do {
            let document = try await docRef.getDocument()
            if document.exists {
                updateStation(gamecode, station)
                print("Station added")
            } else {
                print("Gamecode does not exist")
                let errorMessage = NSLocalizedString("%@ is not an existing gamecode.\nPlease check again!", comment: "")
                let formattedErrorMessage = String.localizedStringWithFormat(errorMessage, gamecode)
                throw GameWalkerError.invalidGamecode(formattedErrorMessage)
            }
        } catch {
            print("Error adding Station: \(error).")
            throw GameWalkerError.serverError(NSLocalizedString("Something went wrong while adding Station.", comment: ""))
        }
    }
    
    static func removeStation(_ gamecode: String, _ station: Station) {
        db.collection("\(gamecode) : Stations").document(station.uuid).delete() { err in
            if let err = err {
                print("Error removing Station: \(err).")
            } else {
                print("Station removed.")
            }
        }
    }
    
    static func assignReferee(_ gamecode: String, _ stationto: Station, _ referee: Referee) async throws{
        let docRef = db.collection("\(gamecode) : Stations").document(stationto.uuid)
        do {
            let document = try await docRef.getDocument()
            if document.exists {
                guard let data = document.data() else { return }
                var station = convertDataToStation(data)
                station.referee = referee
                updateStation(gamecode, station)
            } else {
                print("Station assigned Referee.")
            }
        } catch {
            print("Error assigning Referee: \(error).")
            throw GameWalkerError.serverError(NSLocalizedString("Something went wrong while assigning Station.", comment: ""))
        }
    }
    
    static func updateTeamOrder(_ gamecode: String, _ uuid: String, _ teamOrder: [Team]) async throws {
        let docRef = db.collection("\(gamecode) : Stations").document(uuid)
        do {
            let document = try await docRef.getDocument()
            if document.exists {
                guard let data = document.data() else { return }
                var station = convertDataToStation(data)
                station.teamOrder = teamOrder
                updateStation(gamecode, station)
            } else {
                print("Updated Team order.")
            }
        } catch {
            print("Error updating team order: \(error).")
            throw GameWalkerError.serverError(NSLocalizedString("Something went wrong while updating Team Order of Station.", comment: ""))
        }
    }
    
    //MARK: - Database Functions
    
    static func getStation(_ gamecode: String, _ uuid: String) async throws -> Station? {
        let docRef = db.collection("\(gamecode) : Stations").document(uuid)
        let document = try await docRef.getDocument()
        if document.exists {
            guard let data = document.data() else { return nil }
            let station = convertDataToStation(data)
            return station
        } else {
            print("Error getting Station")
            throw GameWalkerError.serverError(NSLocalizedString("Something went wrong while getting Station.", comment: ""))
        }
    }
    
    static func getStationList(_ gamecode: String) async throws -> [Station] {
        //sorted by station number and station is numbered priority to pvp
        do{
            let querySnapshot = try await db.collection("\(gamecode) : Stations").getDocuments()
            var stations: [Station] = []
            
            for document in querySnapshot.documents {
                let data = document.data()
                let station = convertDataToStation(data)
                stations.append(station)
            }
            
            stations.sort {
                if $0.pvp == $1.pvp { return $0.name < $1.name }
                return $0.pvp && !$1.pvp
            }
            
            if stations.first?.number == 0 {
                for index in stations.indices {
                    stations[index].number = index + 1
                }
            }
            
            return stations
        }
        catch{
            print("Error getting StationList")
            throw GameWalkerError.serverError(NSLocalizedString("Something went wrong while getting StationList.", comment: ""))
        }
    }
    
    
    static func updateStation(_ gamecode: String, _ station: Station) {
        do {
            try db.collection("\(gamecode) : Stations").document("\(station.uuid)").setData(from: station)
            print("Station successfully saved.")
        } catch {
            print("Error updating Team: \(error).")
        }
    }
    
    static func convertDataToStation(_ data : [String : Any]) -> Station {
        do {
            //convert Dictionary data to JSON data first
            let json = try JSONSerialization.data(withJSONObject: data)
            //decode the JSON data to object
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decoded = try decoder.decode(Station.self, from: json)
            return decoded
        } catch {
            print("Converting json data to Station \(error).")
        }
        //blank station
        return Station()
    }
}
