//
//  SettingsCounterTableViewCell.swift
//  Aqsar
//
//  Created by moayad on 8/10/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit

class SettingsCounterTableViewCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var btnMinus: UIButton!
    @IBOutlet weak var lblOutput: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        lblOutput.layer.borderWidth = 1.0
        lblOutput.layer.borderColor = UIColor(red: 236.0/255.0, green: 236.0/255.0, blue: 236.0/255.0, alpha: 1.0).cgColor
    }
    
    @IBAction fileprivate func plusTapped(_ sender: AnyObject) {
        if let outputInt = Int(lblOutput.text!) {
            lblOutput.text = "\(outputInt + 1)"
        }
    }
    
    @IBAction fileprivate func minusTapped(_ sender: AnyObject) {
        if let outputInt = Int(lblOutput.text!) {
            lblOutput.text = "\(outputInt - 1)"
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
