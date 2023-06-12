//
//  AlgorithmCustomFlowLayout.swift
//  Game_Walker
//
//  Created by Jin Kim on 4/2/23.
//

import UIKit

class AlgorithmCustomFlowLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()

        guard let collectionView = collectionView else { return }
        
        let cellSize = CGSize(width: collectionView.bounds.width / 8, height: collectionView.bounds.width / 8)
        itemSize = cellSize
        
        let spacing = (collectionView.bounds.width - (cellSize.width * 8)) / 7
        minimumInteritemSpacing = spacing
        minimumLineSpacing = spacing
        
        sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        var offset = proposedContentOffset
        offset.x = round(offset.x / itemSize.width) * itemSize.width
        offset.y = round(offset.y / itemSize.height) * itemSize.height
        return offset
    }
}
