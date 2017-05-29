//
//  MyAccountQuotationsCell.swift
//  Aqsar
//
//  Created by moayad on 7/28/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit

class MyAccountQuotationsCell: LLSwipeCell {
    //MARK:- IBOutlets
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAuthor: UILabel!
    @IBOutlet weak var lblPages: UILabel!
    @IBOutlet weak var lblListens: UILabel!
    
    //MARK:- Porperties
    let removeButton = UIButton()
    
    //MARK:- Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgIcon.layer.cornerRadius = 3.0
        
        removeButton.setImage(UIImage(named: "cross"), for: UIControlState())
        removeButton.frame = CGRect(x: 0, y: 0, width: 75, height: 10)
        removeButton.backgroundColor = darkGreen
        leftButtons = [removeButton]
        
        canOpenLeftButtons = true
    }
    
    //MARK:- IBActions
    @IBAction fileprivate func moreTapped(_ sender: AnyObject) {
        expandLeftButtons()
    }
}
