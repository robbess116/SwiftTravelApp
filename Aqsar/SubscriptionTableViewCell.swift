//
//  SubscriptionTableViewCell.swift
//  Aqsar
//
//  Created by RichMan on 4/18/17.
//  Copyright © 2017 Ahmad. All rights reserved.
//

import UIKit

class SubscriptionTableViewCell: UITableViewCell {

    @IBOutlet var lbTitle: UILabel!
    @IBOutlet var imgViewCheck: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
