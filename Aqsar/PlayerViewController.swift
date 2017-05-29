//
//  PlayerViewController.swift
//  Aqsar
//
//  Created by MacBook Pro on 3/18/17.
//  Copyright © 2017 Ahmad. All rights reserved.
//

import UIKit
import RealmSwift
import AVFoundation

class PlayerViewController: UIViewController,AVAudioPlayerDelegate,JukeboxDelegate{
    
    var currentPaperIndex : Int!
    var papersArray = [Paper]()
    var bookObject = Book()
    var delegate: BookPapersListViewControllerDelegate?
    var bookDetailsVC: BookDetailsViewController!
    var audioListVC: AudioListViewController!
    var segueIndex = 0
    
    @IBOutlet var btnBackJump: UIButton!
    @IBOutlet var btnJump: UIButton!
    @IBOutlet var playButton          : UIButton!
    @IBOutlet var pauseButton         : UIButton!
    @IBOutlet var nextButton          : UIButton!
    @IBOutlet var prevButton          : UIButton!
    
    @IBOutlet var imgViewBook: UIImageView!
    @IBOutlet var bookNameLabel       : UILabel!
    @IBOutlet var writerLabel         : UILabel!
    @IBOutlet var numberOfPaperLabel  : UILabel!
    @IBOutlet var timeLabel  : UILabel!
    @IBOutlet var progressView  : UIProgressView!
    
    @IBOutlet var btnPaper: UIButton!
    @IBOutlet var btnAudioList: UIButton!
    @IBOutlet var slider: UISlider!
    @IBOutlet var btnSpeed: UIButton!
    
    @IBOutlet var btnClose: UIButton!
    @IBOutlet var topNavView: UIView!
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet var btnPrevious: UIButton!
    @IBOutlet var btnNext: UIButton!
    
    var backgroundMode = 2
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        bookDetailsVC = storyboard.instantiateViewController(withIdentifier: "BookDetailsViewController") as! BookDetailsViewController
        audioListVC = storyboard.instantiateViewController(withIdentifier: "AudioListViewController") as! AudioListViewController
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        
        if backgroundMode == 2{
            
            topNavView.backgroundColor = navColor
            btnClose.tintColor = darkGreen
            toolbar.backgroundColor = navColor
            toolbar.barTintColor = navColor
            toolbar.tintColor = navColor
            self.view.backgroundColor = navColor
            slider.thumbTintColor = darkGreen
            nextButton.tintColor = darkGreen
            prevButton.tintColor = darkGreen
            pauseButton.tintColor = darkGreen
            btnJump.tintColor = darkGreen
            btnBackJump.tintColor = darkGreen
            btnSpeed.setTitleColor(UIColor.black, for: UIControlState())
            btnPaper.tintColor = darkGreen
            btnAudioList.tintColor = darkGreen
            
            
            
            
        }else {
            topNavView.backgroundColor = UIColor.black
            btnClose.tintColor = UIColor.white
            toolbar.backgroundColor = UIColor.black
            toolbar.barTintColor = UIColor.black
            toolbar.tintColor = UIColor.black
            self.view.backgroundColor = UIColor.black
            slider.thumbTintColor = UIColor.white
            nextButton.tintColor = UIColor.white
            prevButton.tintColor = UIColor.white
            pauseButton.tintColor = UIColor.white
            btnJump.tintColor = UIColor.white
            btnBackJump.tintColor = UIColor.white
            btnSpeed.setTitleColor(UIColor.white, for: UIControlState())
            btnPaper.tintColor = UIColor.white
            btnAudioList.tintColor = UIColor.white

            
        }

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        // begin receiving remote events
        UIApplication.shared.beginReceivingRemoteControlEvents()

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
            print("papersArray====>\n", papersArray)
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
                    audioUrl = item.audioURL.trimmingCharacters(in: .whitespaces) as String
                    if !audioUrl.isEmpty{
                        
                         arrayOfAudio.append(JukeboxItem(URL: URL(string: audioUrl)!))
                    }else {
                        let url = Bundle.main.url(forResource: "01 1", withExtension: "mp3")!
                        arrayOfAudio.append(JukeboxItem(URL: url))
                        print("URL=>", url)
                    }
                    print("audioURL", audioUrl)
                   
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
             btnSpeed.setTitle("1x", for: .normal)

        default:
             NewAudioManager.sharedInstance.jukebox.stop()
        }
        
        
    }
    @IBAction func nextTapped(_ sender: AnyObject) {
        
        NewAudioManager.sharedInstance.jukebox.playNext()
        playCurrentPaperIndex(true)
        btnSpeed.setTitle("1x", for: .normal)

        updateUI()
    }
    
    @IBAction func prevTapped(_ sender: AnyObject) {
        
        if let time = NewAudioManager.sharedInstance.jukebox.currentItem?.currentTime, time > 5.0 || NewAudioManager.sharedInstance.jukebox.playIndex == 0 {
            NewAudioManager.sharedInstance.jukebox.replayCurrentItem()
        } else {
            NewAudioManager.sharedInstance.jukebox.playPrevious()
        }
        
        playCurrentPaperIndex(true)
        btnSpeed.setTitle("1x", for: .normal)

        updateUI()
    }
    
    private func updateUI() {
        bookNameLabel.text = bookObject.title + "/" + bookObject.author
        //writerLabel.text = bookObject.author
        imgViewBook.kf.setImage(with:URL(string: getFullURLImage(bookObject.imageID)))
        let currentIndex = NewAudioManager.sharedInstance.jukebox.playIndex + 1
        numberOfPaperLabel.text = "(\(currentIndex)/\(papersArray.count))"
        //slider.setThumbImage(UIImage(named: "thumb"), for: .normal)
        
        if NewAudioManager.sharedInstance.jukebox.state == .ready {
            pauseButton.setImage(UIImage(named: "Group_14"), for: UIControlState())
        } else if NewAudioManager.sharedInstance.jukebox.state == .loading  {
            pauseButton.setImage(UIImage(named: "Groupuu"), for: UIControlState())
        } else {
            let imageName: String
            switch NewAudioManager.sharedInstance.jukebox.state  {
            case .playing, .loading:
                imageName = "Groupuu"
            case .paused, .failed, .ready:
                imageName = "Group_14"
            }
            pauseButton.setImage(UIImage(named: imageName), for: UIControlState())
        }
        

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
            bookObject.userCurrentPage = NewAudioManager.sharedInstance.jukebox.playIndex + 1
        }
        
        NewAudioManager.sharedInstance.rowToSelectAudioFile = NewAudioManager.sharedInstance.jukebox.playIndex
        NewAudioManager.sharedInstance.currentBook = bookObject
        NewAudioManager.sharedInstance.currentPapers = papersArray
        
    }
    //MARK:- Actions
    @IBAction func minimizeTapped(_ sender: AnyObject){
        
        
        playCurrentPaperIndex(false)
        
        let currentIndex = NewAudioManager.sharedInstance.jukebox.playIndex
        SummaryViewController.summaryDetailsFlag = true
        delegate?.BookPapersListViewControllerTableViewDidSelect(currentIndex, isPaper: false)
        dismiss(animated: false, completion: nil)
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
    
    
    @IBAction func btnBackJumpTapped(_ sender: Any) {
        let value = (NewAudioManager.sharedInstance.jukebox.currentItem?.currentTime)! - 15
        NewAudioManager.sharedInstance.jukebox.seek(toSecond: Int(value))
        
    }
    @IBAction func btnSpeedTapped(_ sender: UIButton) {
        //let value = (NewAudioManager.sharedInstance.jukebox.currentItem?.forwa)! - 15
        let strSpeed = btnSpeed.titleLabel?.text
        if strSpeed == "1x" {
            NewAudioManager.sharedInstance.jukebox.rate(1.25)
            btnSpeed.setTitle("1.25x", for: .normal)
        }else if strSpeed == "1.25x" {
            NewAudioManager.sharedInstance.jukebox.rate(1.5)
            btnSpeed.setTitle("1.5x", for: .normal)

        }else if strSpeed == "1.5x" {
            NewAudioManager.sharedInstance.jukebox.rate(2.0)
            btnSpeed.setTitle("2x", for: .normal)

        }else if strSpeed == "2x" {
            NewAudioManager.sharedInstance.jukebox.rate(1.0)
            btnSpeed.setTitle("1x", for: .normal)

        }
        
    }
    @IBAction func btnForwardJumpTapped(_ sender: Any) {
        let value = (NewAudioManager.sharedInstance.jukebox.currentItem?.currentTime)! + 15
        NewAudioManager.sharedInstance.jukebox.seek(toSecond: Int(value))
    }
    
    @IBAction func btnTextTapped(_ sender: Any) {
        if self.segueIndex == 1 {
            bookObject.userCurrentPage = NewAudioManager.sharedInstance.jukebox.playIndex + 1
            bookDetailsVC.currentBook = bookObject
            bookDetailsVC.segueIndex = 1
            present(bookDetailsVC, animated: true, completion: nil)
        }else{
            playCurrentPaperIndex(false)
            
            let currentIndex = NewAudioManager.sharedInstance.jukebox.playIndex
            delegate?.BookPapersListViewControllerTableViewDidSelect(currentIndex, isPaper: false)
            dismiss(animated: false, completion: nil)
        }
        
    }

    @IBAction func btnListTapped(_ sender: Any) {
        audioListVC.papersArray = papersArray
        audioListVC.currentBook = bookObject
        audioListVC.currentPaperIndex = currentPaperIndex
        audioListVC.arrayOfAudio = NewAudioManager.sharedInstance.jukebox.queuedItems
        //NewAudioManager.sharedInstance.jukebox.stop()
        present(audioListVC, animated: true, completion: nil)
        
    }
    func jukeboxDidLoadItem(_ jukebox: Jukebox, item: JukeboxItem) {
        print("Jukebox did load: \(item.URL.lastPathComponent)")
    }
    
    func jukeboxPlaybackProgressDidChange(_ jukebox: Jukebox) {
        
        if let currentTime = jukebox.currentItem?.currentTime, let duration = jukebox.currentItem?.meta.duration {
            let value = Float(currentTime / duration)
            //progressView.progress = value
            slider.value = value
            populateLabelWithTime(timeLabel, time: duration-currentTime)
            //populateLabelWithTime(timeLabel, time: duration)
        } else {
            //resetUI()
        }
    }
    
    @IBAction func sliderDidChanged(_ sender: Any) {
        let value = Double(slider.value)  * (NewAudioManager.sharedInstance.jukebox.currentItem?.meta.duration)!
        NewAudioManager.sharedInstance.jukebox.seek(toSecond: Int(value))
        
    }
    func jukeboxStateDidChange(_ jukebox: Jukebox) {
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.pauseButton.alpha = jukebox.state == .loading ? 0.5 : 1
            self.pauseButton.isEnabled = jukebox.state == .loading ? false : true
            self.btnSpeed.alpha = jukebox.state == .loading ? 0.5 : 1
            self.btnSpeed.isEnabled = jukebox.state == .loading ? false : true
            self.btnJump.alpha = jukebox.state == .loading ? 0.5 : 1
            self.btnJump.isEnabled = jukebox.state == .loading ? false : true
            self.btnBackJump.alpha = jukebox.state == .loading ? 0.5 : 1
            self.btnBackJump.isEnabled = jukebox.state == .loading ? false : true
            self.slider.alpha = jukebox.state == .loading ? 0.5 : 1
            self.slider.isEnabled = jukebox.state == .loading ? false : true
            self.btnAudioList.alpha = jukebox.state == .loading ? 0.5 : 1
            self.btnAudioList.isEnabled = jukebox.state == .loading ? false : true
            self.btnPaper.alpha = jukebox.state == .loading ? 0.5 : 1
            self.btnPaper.isEnabled = jukebox.state == .loading ? false : true
            self.nextButton.alpha = jukebox.state == .loading ? 0.5 : 1
            self.nextButton.isEnabled = jukebox.state == .loading ? false : true
            self.prevButton.alpha = jukebox.state == .loading ? 0.5 : 1
            self.prevButton.isEnabled = jukebox.state == .loading ? false : true


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
        let parameters = ["UserId": RealmHelper.getLoggedinUser()!.userID, "BookID": NewAudioManager.sharedInstance.currentBook.bookID, "PageNumber": "\(NewAudioManager.sharedInstance.jukebox.playIndex + 1)"]
        
        ApiManager.sharedInstance.setBookCuurrentPage(parameters as [String : AnyObject]?, onSuccess: { (array) in
            print("setBookCuurrentPage successed")
        }, onFailure: { (error) in
            print(error.description)
        }, loadingViewController: nil)

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
        
        label.text = "-" + String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
    }
    
    
        
}
