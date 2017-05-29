//
//  BookPaperListAudioCell.swift
//  Aqsar
//
//  Created by moayad on 11/4/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit

class BookPaperListAudioCell: LLSwipeCell {
    //MARK:- IBOutlets
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblPart: UILabel!
    @IBOutlet weak var lblName: UILabel!
    //@IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var viewDisabling: UIView!
    @IBOutlet weak var lblLoading: UILabel!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var btnRightButtons: UIButton!
    
    var addFavoriteButton: UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //indicator.startAnimating()
        
        addFavoriteButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
        addFavoriteButton!.backgroundColor = darkGreen
        rightButtons = [addFavoriteButton!]
        addFavoriteButton!.setImage(UIImage(named: "favorite_plus"), for: UIControlState())
    }
    
    //MARK:- IBActions
    @IBAction func moreTapped(_ sender: AnyObject) {
        expandRightButtons()
    }
}
