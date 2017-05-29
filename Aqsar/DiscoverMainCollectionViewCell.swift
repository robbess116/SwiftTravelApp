//
//  DiscoverMainCollectionViewCell.swift
//  Aqsar
//
//  Created by moayad on 7/30/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit

class DiscoverMainCollectionViewCell: UICollectionViewCell {
    //MARK:- IBOutlets
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var imgSound: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblAuthor: UILabel!
    
    @IBOutlet weak fileprivate var imgStar01: UIImageView!
    @IBOutlet weak fileprivate var imgStar02: UIImageView!
    @IBOutlet weak fileprivate var imgStar03: UIImageView!
    @IBOutlet weak fileprivate var imgStar04: UIImageView!
    @IBOutlet weak fileprivate var imgStar05: UIImageView!
    
    @IBOutlet weak var lblTotalPagesCount: UILabel!
    @IBOutlet weak var lblProgressPagesCount: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    
    //MARK:- Properties
    var rate:Int?
    var hasSound:Bool?
    
    //MARK:- Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        for subView in subviews {
            subView.mirrorMe()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        lblTotalPagesCount.sizeToFit()
//        lblProgressPagesCount.numberOfLines = 2
//        lblProgressPagesCount.textAlignment = .Right
//        lblProgressPagesCount.sizeToFit()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if let unwrappedRate = rate {
            setRate(unwrappedRate)
        } else {
            setRate(0)
        }
        
        if let unwrappedHasSound = hasSound, unwrappedHasSound == true {
            imgSound.isHidden = false
        } else {
            imgSound.isHidden = true
        }
    }
    
    func addTotalPapersCount(_ numberOfPapers: Int) {
        lblTotalPagesCount.text = ""
        if numberOfPapers < 1 {
            return
        }
        
        for _ in 1...numberOfPapers {
            lblTotalPagesCount.text! = "\(lblTotalPagesCount.text!)● "
        }
    }
    
    func addProgressPapersCount(_ numberOfPapers: Int) {
        lblProgressPagesCount.text = ""
        if numberOfPapers < 1 {
            return
        }
        
        for _ in 1...numberOfPapers {
            lblProgressPagesCount.text! = "\(lblProgressPagesCount.text!)● "
        }
    }

    
    //MARK:- UI
    fileprivate func setRate(_ rate: Int) {
        let stars = [imgStar01, imgStar02, imgStar03, imgStar04, imgStar05]
        
        for i in 0..<rate {
            let currentStar = stars[i]
            currentStar?.image = UIImage(named: "Star_copie_3_copy_6")
            
            if i > 4 {
                break
            }
        }
    }
}
