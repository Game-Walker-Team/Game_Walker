//
//  PlayerFrame3_1.swift
//  Game_Walker
//
//  Created by Noah Kim on 6/16/22.
//

import Foundation
import UIKit

class PlayerFrame3_1: UIViewController {
    
    @IBOutlet weak var teamNameTextField: UITextField!
    

    @IBOutlet weak var createTeamButton: UIButton!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 60, height: 60)
        collectionView.collectionViewLayout = layout
        
        collectionView.register(IconCollectionViewCell.nib(), forCellWithReuseIdentifier: IconCollectionViewCell.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    @IBAction func createTeamButtonPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "goToTPF4", sender: self)
        
    }
}

extension PlayerFrame3_1: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        print("You tapped me")
    }
}

extension PlayerFrame3_1: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IconCollectionViewCell.identifier , for: indexPath) as! IconCollectionViewCell
        
        cell.configure(with: UIImage(named: "5")!)
        
        return cell
    }
}

extension PlayerFrame3_1: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
    
}
