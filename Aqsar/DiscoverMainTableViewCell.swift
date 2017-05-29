//
//  DiscoverMainCell.swift
//  Aqsar
//
//  Created by moayad on 7/30/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit

class DiscoverMainTableViewCell: UITableViewCell{
    //MARK:- IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnWatchAll: UIButton!
    
    @IBOutlet var lblAlertNoBook: UILabel!
    @IBOutlet weak fileprivate var lblTotalPagesCount: UILabel!
    @IBOutlet weak fileprivate var lblProgressPagesCount: UILabel!
    
    //MARK:- Properties
    var collectionViewOffset: CGFloat {
        get {
            return collectionView.contentOffset.x
        }
        
        set {
            collectionView.contentOffset.x = newValue
        }
    }
    
    //MARK:- Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.mirrorMe()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
    
    //MARK:- CollectionView
    func setCollectionViewDataSourceDelegate(dataSourceDelegate: BaseViewController, forRow row: Int){
//        collectionView.delegate = dataSourceDelegate
//        collectionView.dataSource = dataSourceDelegate
//        collectionView.tag = row
//        collectionView.reloadData()
    }
    
//    func setCollectionViewDataSourceDelegate
//        <(UICollectionViewDataSource & UICollectionViewDelegate)>
//        (_ dataSourceDelegate: D, forRow row: Int) {
//        
//        collectionView.delegate = dataSourceDelegate
//        collectionView.dataSource = dataSourceDelegate
//        collectionView.tag = row
//        collectionView.reloadData()
//    }

}
