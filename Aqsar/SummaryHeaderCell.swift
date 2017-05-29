//
//  SummaryHeaderCell.swift
//  Aqsar
//
//  Created by moayad on 11/20/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit

class SummaryHeaderCell: UITableViewCell {
    //MARK:- IBOutlets
    @IBOutlet weak var imgBookCover: UIImageView!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnRead: UIButton!
    @IBOutlet weak var btnListen: UIButton!
    @IBOutlet var imgViewAdd: UIImageView!
    
    //MARK:- Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
