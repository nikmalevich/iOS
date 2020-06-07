//
//  NoteTableViewCell.swift
//  Notes
//
//  Created by ios_school on 2/16/20.
//  Copyright © 2020 ios_school. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        colorView.layer.borderWidth = 1
        colorView.layer.borderColor = UIColor.black.cgColor
    }
    
}
