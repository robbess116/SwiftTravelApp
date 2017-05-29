//
//  AudioPlayerCell.swift
//  Aqsar
//
//  Created by moayad on 11/5/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit

protocol AudioPlayerCellDelegate {
    func playPauseDidTap(_ button: UIButton)
    func listDidTap()
    func currentPageDidTap()
    func closeDidTap()
}

class AudioPlayerCell: UITableViewCell {
    //MARK:- IBOutlets
    @IBOutlet weak var btnPlayPause: UIButton!
    @IBOutlet weak var lblPartName: UILabel!
    @IBOutlet weak var lblAuthorAndName: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var btnAudiosList: UIButton!
    @IBOutlet weak var btnCurrentPage: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    
    var delegate: AudioPlayerCellDelegate?
    
    //MARK:- IBActions
    @IBAction fileprivate func playPauseTapped(_ sender: AnyObject) {
        delegate?.playPauseDidTap(sender as! UIButton)
    }
    
    @IBAction fileprivate func audioListTapped(_ sender: AnyObject) {
        delegate?.listDidTap()
    }
    
    @IBAction fileprivate func currentPageTapped(_ sender: AnyObject) {
        delegate?.currentPageDidTap()
    }
    
    @IBAction func closeTapped(_ sender: AnyObject) {
        delegate?.closeDidTap()
    }
    
    
}
