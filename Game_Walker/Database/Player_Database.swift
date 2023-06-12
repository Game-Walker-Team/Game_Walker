//
//  Constants_New.swift
//  Game_Walker
//
//  Created by Paul on 7/25/22.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift
import SwiftUI

struct P {
        static let db = Firestore.firestore()
    
        static func addPlayer(_ gamecode: String, _ player: Player){
            let docRef = db.collection("Servers").document("Gamecode : \(gamecode)")
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    do {
                        try db.collection("\(gamecode) : Players").document(player.name).setData(from: player)
                        print("Player sucessfully saved")
                    } catch let error {
                        print("Error writing to Firestore: \(error)")
                    }
                } else {
                    print("Gamecode does not exist")
                }
            }
        }
        
        static func removePlayer(_ gamecode: String, _ player: Player){
            db.collection("\(gamecode) : Players").document(player.name).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Player Document successfully removed!")
                }
            }
        }
        

        
}
