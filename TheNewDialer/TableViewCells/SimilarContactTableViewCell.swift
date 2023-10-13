//
//  SimilarContactTableViewCell.swift
//  TheNewDialer
//
//  Created by Chaoqun Ding on 2019-10-25.
//  Copyright © 2019 Chaoqun Ding. All rights reserved.
//

import UIKit

class SimilarContactTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var greenCallIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
