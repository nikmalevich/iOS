//
//  ReportTableViewCell.swift
//  JogTracker
//
//  Created by Admin on 04/06/2020.
//  Copyright © 2020 nikmal. All rights reserved.
//

import UIKit

class ReportTableViewCell: UITableViewCell {
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
