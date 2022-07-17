//
//  IconCollectionViewCell.swift
//  Game_Walker
//
//  Created by Noah Kim on 6/17/22.
//

import UIKit

class IconCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    
    static let identifier = "IconCollectionViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func configure(with image: UIImage) {
        imageView.image = image
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "IconCollectionViewCell", bundle: nil)
    }

}
