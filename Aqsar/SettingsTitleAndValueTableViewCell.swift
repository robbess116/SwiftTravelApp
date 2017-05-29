//
//  SettingsTitleAndValueTableViewCell.swift
//  Aqsar
//
//  Created by moayad on 8/10/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit

class SettingsTitleAndValueTableViewCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblValue: UILabel!
    @IBOutlet weak var imgViewArrow: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
