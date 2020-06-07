//
//  ImageCollectionViewCell.swift
//  Notes
//
//  Created by ios_school on 2/20/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
    }

}
