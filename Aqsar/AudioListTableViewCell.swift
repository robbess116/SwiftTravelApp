//
//  AudioListTableViewCell.swift
//  Aqsar
//
//  Created by RichMan on 4/11/17.
//  Copyright © 2017 Ahmad. All rights reserved.
//

import UIKit

class AudioListTableViewCell: LLSwipeCell {

    @IBOutlet var btnPlay: UIButton!
    @IBOutlet var lbPageName: UILabel!
    @IBOutlet var lbAuthorName: UILabel!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var lbTime: UILabel!
    @IBOutlet var lbLoading: UILabel!
    @IBOutlet var viewLoading: UIView!
    @IBOutlet var btnMore: UIButton!
    
    var addFavoriteButton: UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        addFavoriteButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
//        addFavoriteButton!.backgroundColor = darkGreen
//        rightButtons = [addFavoriteButton!]
//        addFavoriteButton!.setImage(UIImage(named: "favorite_plus"), for: UIControlState())
    }

        
        

    @IBAction func moreTapped(_ sender: Any) {
//        expandRightButtons()
    }
  

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

       
    
    
}
