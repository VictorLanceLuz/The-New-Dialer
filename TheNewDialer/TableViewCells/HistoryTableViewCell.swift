//
//  HistoryTableViewCell.swift
//  TheNewDialer
//
//  Created by Chaoqun Ding on 2019-10-25.
//  Copyright © 2019 Chaoqun Ding. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "ContactCell"
    
    @IBOutlet var contactLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
