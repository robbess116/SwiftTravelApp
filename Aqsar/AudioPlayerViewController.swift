//
//  AudioPlayerViewController.swift
//  Aqsar
//
//  Created by moayad on 8/15/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit
import RealmSwift
import AVFoundation

class AudioPlayerViewController: UIViewController,AVAudioPlayerDelegate,JukeboxDelegate {
    var currentPaperIndex : Int!
    var papersArray = [Paper]()
    var bookObject = Book()
    var delegate: BookPapersListViewControllerDelegate?
    
    @IBOutlet var pauseButton         : UIButton!
    @IBOutlet var nextButton          : UIButton!
    @IBOutlet var prevButton          : UIButton!
    
    @IBOutlet var imgViewBook: UIImageView!
    @IBOutlet var bookNameLabel       : UILabel!
    @IBOutlet var numberOfPaperLabel  : UILabel!
    @IBOutlet var timeLabel  : UILabel!
    @IBOutlet var progressView  : UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // begin receiving remote events
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        //to check if the same book or not,where if not the same must delete all items and insert new item.else skip this check.
        if NewAudioManager.sharedInstance.currentBook.bookID != bookObject.bookID {
            if NewAudioManager.sharedInstance.jukebox.queuedItems.count != 0 {
                for item in NewAudioManager.sharedInstance.jukebox.queuedItems {
                    NewAudioManager.sharedInstance.jukebox.remove(item: item)
                }
                NewAudioManager.sharedInstance.jukebox.stop()
            }
        }
        
        //
        if NewAudioManager.sharedInstance.jukebox.queuedItems.count == 0 {
            var arrayOfAudio = [JukeboxItem]()
            for item in papersArray {
                let audioId = item.audioID
                let currentFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                
                var audioUrl = ""
                if FileManager.default.fileExists(atPath: currentFilePath.appendingPathComponent("\(audioId).mp3").path) {
                    //it's exist ...
                    audioUrl = "\(NSHomeDirectory())/Documents/\(audioId).mp3"
                    arrayOfAudio.append(JukeboxItem(URL: URL(fileURLWithPath: audioUrl, isDirectory: true)))
                    //NewAudioManager.sharedInstance.jukebox.append(item: JukeboxItem(URL: URL(fileURLWithPath: audioUrl, isDirectory: true)), loadingAssets: true)
                }else{
                    //it's not exsit ...
                    audioUrl = item.audioURL.trimmingCharacters(in: .whitespaces)
                    arrayOfAudio.append(JukeboxItem(URL: URL(string: audioUrl)!))
                    //NewAudioManager.sharedInstance.jukebox.append(item:JukeboxItem(URL: URL(string: audioUrl)!), loadingAssets: true)
                    
                }
                
            }
            NewAudioManager.sharedInstance.jukebox = Jukebox(delegate: self, items: arrayOfAudio)
            NewAudioManager.sharedInstance.jukebox.play(atIndex: currentPaperIndex)
            
        }else{
            NewAudioManager.sharedInstance.jukebox.delegate = self
            jukeboxPlaybackProgressDidChange(NewAudioManager.sharedInstance.jukebox)
        }
        
        updateUI()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeTapped(_ sender: AnyObject) {
        
    }
    
    @IBAction func playAndPauseTapped(_ sender: AnyObject) {
        
        switch  NewAudioManager.sharedInstance.jukebox.state {
        case .ready :
            NewAudioManager.sharedInstance.jukebox.play(atIndex: 0)
        case .playing :
            NewAudioManager.sharedInstance.jukebox.pause()
        case .paused :
            NewAudioManager.sharedInstance.jukebox.play()
        default:
            NewAudioManager.sharedInstance.jukebox.stop()
        }
        
        
    }
    @IBAction func nextTapped(_ sender: AnyObject) {
        
        NewAudioManager.sharedInstance.jukebox.playNext()
        playCurrentPaperIndex(true)
        updateUI()
    }
    
    @IBAction func prevTapped(_ sender: AnyObject) {
        
        if let time = NewAudioManager.sharedInstance.jukebox.currentItem?.currentTime, time > 5.0 || NewAudioManager.sharedInstance.jukebox.playIndex == 0 {
            NewAudioManager.sharedInstance.jukebox.replayCurrentItem()
        } else {
            NewAudioManager.sharedInstance.jukebox.playPrevious()
        }
        
        playCurrentPaperIndex(true)
        updateUI()
    }
    
    private func updateUI() {
        bookNameLabel.text = bookObject.title
        //writerLabel.text = bookObject.author
        imgViewBook.kf.setImage(with:URL(string: getFullURLImage(bookObject.imageID)))
        
        let currentIndex = NewAudioManager.sharedInstance.jukebox.playIndex + 1
        numberOfPaperLabel.text = "(\(currentIndex)/\(papersArray.count))"
    }
    private func playCurrentPaperIndex(_ withPlay: Bool) {
        
        let currentIndex = NewAudioManager.sharedInstance.jukebox.playIndex + 1
        NewAudioManager.sharedInstance.partName = "المقطع \(currentIndex)"
        NewAudioManager.sharedInstance.titleAndAuthor = "\(bookObject.title) / \(bookObject.author)"
        
        NewAudioManager.sharedInstance.rowToSelectAudioFile = currentPaperIndex
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let bookDetails = sb.instantiateViewController(withIdentifier: "BookDetailsViewController") as! BookDetailsViewController
        //AudioPlayer.sharedInstance.player?.delegate = self
        
        let realm = try! Realm()
        try! realm.write {
            bookObject.userCurrentPage = NewAudioManager.sharedInstance.jukebox.playIndex
        }
        
        NewAudioManager.sharedInstance.rowToSelectAudioFile = NewAudioManager.sharedInstance.jukebox.playIndex
        NewAudioManager.sharedInstance.currentBook = bookObject
        NewAudioManager.sharedInstance.currentPapers = papersArray
        
    }
    //MARK:- Actions
    @IBAction func minimizeTapped(_ sender: AnyObject){
        
        
        playCurrentPaperIndex(false)
        
        let currentIndex = NewAudioManager.sharedInstance.jukebox.playIndex
        delegate?.BookPapersListViewControllerTableViewDidSelect(currentIndex, isPaper: false)
        dismiss(animated: false, completion: nil)
    }
    
    
    @IBAction func btnTextTapped(_ sender: Any) {
    }
    
    
    @IBAction func btnListTapped(_ sender: Any) {
    }
    /*
     func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
     
     if NewAudioManager.sharedInstance.rowToSelectAudioFile < papersArray.count - 1 {
     NewAudioManager.sharedInstance.rowToSelectAudioFile = NewAudioManager.sharedInstance.rowToSelectAudioFile + 1
     let currentPaper = papersArray[AudioPlayer.sharedInstance.rowToSelectAudioFile]
     let audioUrlString = "\(NSHomeDirectory())/Documents/\(currentPaper.audioID)"
     
     NewAudioManager.sharedInstance.partName = "المقطع \(AudioPlayer.sharedInstance.rowToSelectAudioFile + 1)"
     
     
     
     NotificationCenter.default.post(name: Notification.Name(rawValue: "AudioDidFinish"), object: self)
     } else {
     AudioPlayer.sharedInstance.rowToSelectAudioFile = -1
     //isAudioPlaying = false
     }
     }
     */
    
    
    
    func jukeboxDidLoadItem(_ jukebox: Jukebox, item: JukeboxItem) {
        print("Jukebox did load: \(item.URL.lastPathComponent)")
    }
    
    func jukeboxPlaybackProgressDidChange(_ jukebox: Jukebox) {
        
        if let currentTime = jukebox.currentItem?.currentTime, let duration = jukebox.currentItem?.meta.duration {
            let value = Float(currentTime / duration)
            progressView.progress = value
            populateLabelWithTime(timeLabel, time: currentTime)
            //populateLabelWithTime(timeLabel, time: duration)
        } else {
            //resetUI()
        }
    }
    
    func jukeboxStateDidChange(_ jukebox: Jukebox) {
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.pauseButton.alpha = jukebox.state == .loading ? 0 : 1
            self.pauseButton.isEnabled = jukebox.state == .loading ? false : true
        })
        
        if jukebox.state == .ready {
            pauseButton.setImage(UIImage(named: "Group_14"), for: UIControlState())
        } else if jukebox.state == .loading  {
            pauseButton.setImage(UIImage(named: "Groupuu"), for: UIControlState())
        } else {
            let imageName: String
            switch jukebox.state {
            case .playing, .loading:
                imageName = "Groupuu"
            case .paused, .failed, .ready:
                imageName = "Group_14"
            }
            pauseButton.setImage(UIImage(named: imageName), for: UIControlState())
        }
        
        print("Jukebox state changed to \(jukebox.state)")
    }
    
    func jukeboxFinished() {
        print("PlayerViewController finished...")
        self.updateUI()
        
    }
    func jukeboxDidUpdateMetadata(_ jukebox: Jukebox, forItem: JukeboxItem) {
        print("Item updated:\n\(forItem)")
    }
    
    
    override func remoteControlReceived(with event: UIEvent?) {
        if event?.type == .remoteControl {
            switch event!.subtype {
            case .remoteControlPlay :
                NewAudioManager.sharedInstance.jukebox.play()
            case .remoteControlPause :
                NewAudioManager.sharedInstance.jukebox.pause()
            case .remoteControlNextTrack :
                NewAudioManager.sharedInstance.jukebox.playNext()
            case .remoteControlPreviousTrack:
                NewAudioManager.sharedInstance.jukebox.playPrevious()
            case .remoteControlTogglePlayPause:
                if NewAudioManager.sharedInstance.jukebox.state == .playing {
                    NewAudioManager.sharedInstance.jukebox.pause()
                } else {
                    NewAudioManager.sharedInstance.jukebox.play()
                }
            default:
                break
            }
        }
    }
    
    // MARK:- Helpers -
    
    func populateLabelWithTime(_ label : UILabel, time: Double) {
        let minutes = Int(time / 60)
        let seconds = Int(time) - minutes * 60
        
        label.text = String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
    }
    
    
    
}
