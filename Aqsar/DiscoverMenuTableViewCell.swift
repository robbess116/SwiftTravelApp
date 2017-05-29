//
//  DiscoverMenuTableViewCell.swift
//  Aqsar
//
//  Created by moayad on 7/30/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit

class DiscoverMenuTableViewCell: UITableViewCell {
    //MARK:- IBOutlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgIcon: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
