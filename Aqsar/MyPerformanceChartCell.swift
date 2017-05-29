//
//  MyPerformanceChartCell.swift
//  Aqsar
//
//  Created by moayad on 11/12/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit

class MyPerformanceChartCell: UITableViewCell {
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var lblPercentage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        progressView.transform = CGAffineTransform(scaleX: 1.0, y: 8.0)
        //progressView.setProgress(0.5, animated: true)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
