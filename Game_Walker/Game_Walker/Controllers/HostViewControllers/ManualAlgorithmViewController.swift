//
//  ManualAlgorithmViewController.swift
//  Game_Walker
//
//  Created by Jin Kim on 4/2/23.
//

import UIKit

class ManualAlgorithmViewController: BaseViewController {
    
    private var gamecode = UserData.readGamecode("gamecode")!

    
    var collectionView: UICollectionView!
    
    let layout = UICollectionViewFlowLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.layout)
        collectionView.dragInteractionEnabled = true
        collectionView.backgroundColor = UIColor.gray
        collectionView.register(UINib(nibName: "AlgorithmCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AlgorithmCollectionViewCell")

        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.collectionView.translatesAutoresizingMaskIntoConstraints = false
            self.collectionView.delegate = self
            self.collectionView.dataSource = self

            // Set constraints for the collection view to fill the view
            NSLayoutConstraint.activate([
                self.collectionView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5),
                self.collectionView.heightAnchor.constraint(equalTo: self.collectionView.widthAnchor),
                self.collectionView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                self.collectionView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
            ])
        }

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Set the content size of the scroll view to be larger than the frame size of the collection view
        let contentSize = CGSize(width: collectionView.frame.width * 1.5, height: collectionView.frame.height * 1.5)
        let scrollView = UIScrollView(frame: .zero)
        scrollView.contentSize = contentSize
        scrollView.addSubview(collectionView)
        view.addSubview(scrollView)
        
        // Set constraints for the scroll view to fill the view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
            scrollView.heightAnchor.constraint(equalTo: scrollView.widthAnchor),
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor)

        ])
    }
    
       
}
    extension ManualAlgorithmViewController: UICollectionViewDelegate, UICollectionViewDataSource {
        
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 8
        }
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return 8
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlgorithmCollectionViewCell.identifier, for: indexPath) as? AlgorithmCollectionViewCell else {
                return UICollectionViewCell()
            }

            let teamnumberlabel = 1
            
            print(teamnumberlabel)


            cell.configureAlgorithmSpecialCell2(cellteamnum: teamnumberlabel)
            return cell
        }
    }
        
        
    
    extension ManualAlgorithmViewController: UICollectionViewDelegateFlowLayout {
        func cellSize() -> CGFloat {
            return 10
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: cellSize(), height: cellSize())
        }
    }
    

    


