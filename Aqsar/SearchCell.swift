//
//  SearchCell.swift
//  Aqsar
//
//  Created by moayad on 11/2/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {
    //MARK:- IBOutlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSummary: UILabel!
    @IBOutlet weak var lblAuthor: UILabel!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var imgAudio: UIImageView!
    @IBOutlet weak var btnAdd: UIButton!
    
    //MARK:- Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}