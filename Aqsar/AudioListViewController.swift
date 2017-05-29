//
//  AudioListViewController.swift
//  Aqsar
//
//  Created by RichMan on 4/11/17.
//  Copyright © 2017 Ahmad. All rights reserved.
//

import UIKit
import RealmSwift
import AVFoundation
import BRYXBanner

class AudioListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,JukeboxDelegate{
    
    var papersArray = [Paper]()
    var currentBook = Book()
    var arrayOfAudio = [JukeboxItem]()
    var currentPaperIndex : Int!
    var tableRowIndex : Int!
    
    @IBOutlet var lbBookName: UILabel!
    @IBOutlet var tableView: UITableView!

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
       UIApplication.shared.isStatusBarHidden = false
            
      
        lbBookName.text = currentBook.title
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
//        if the same book or not,where if not the same must delete all items and insert new item.else skip this check.
        if NewAudioManager.sharedInstance.currentBook.bookID != currentBook.bookID {
            if NewAudioManager.sharedInstance.jukebox.queuedItems.count != 0 {
                for item in NewAudioManager.sharedInstance.jukebox.queuedItems {
                    NewAudioManager.sharedInstance.jukebox.remove(item: item)
                }
                NewAudioManager.sharedInstance.jukebox.stop()
            }
        }
        
        
        if arrayOfAudio.count == 0 {
            
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
            //NewAudioManager.sharedInstance.jukebox.play(atIndex: currentPaperIndex)
        }else{
            NewAudioManager.sharedInstance.jukebox.delegate = self
            //jukeboxPlaybackProgressDidChange(NewAudioManager.sharedInstance.jukebox)
        }
        
        tableView.reloadData()


    }
    
    @objc fileprivate func addTappedFromFavorites(_ button: UIButton) {
        print("tag to add: \(button.tag)")
        
        let audioID = papersArray[button.tag - 100000].audioID
        
        print(audioID)
        
        let parameters = ["UserId": RealmHelper.getLoggedinUser()!.userID, "BookID": currentBook.bookID, "Audio": audioID]
        
        ApiManager.sharedInstance.AddAudioQuoteToFavorites(parameters as [String : AnyObject]?, onSuccess: { (array) in
            for cell in self.tableView.visibleCells {
                let llSwipeCell = cell as! LLSwipeCell
                llSwipeCell.hideSwipeOptions()
            }
        }, onFailure: { (error) in
            print(error.description)
            
            let banner = Banner(title: nil, subtitle: "خطأ في العملية. يرجى المحاولة مرة اخرى", image: nil, backgroundColor: lightShinyGreenColor, didTapBlock: nil)
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
        }, loadingViewController: self)
    }

    
    
    
    // tablbeViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return papersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioListTableViewCell") as! AudioListTableViewCell
        cell.lbPageName.text = papersArray[indexPath.row].title
        cell.lbAuthorName.text = papersArray[indexPath.row].audioID
        
//        cell.lbLoading.isHidden = true
//        cell.viewLoading.isHidden = true
        
        let imageName: String
        if NewAudioManager.sharedInstance.jukebox.currentItem == arrayOfAudio[indexPath.row] {
            
            tableRowIndex    =  indexPath.row
            
            switch NewAudioManager.sharedInstance.jukebox.state {
                
            case .playing:
                imageName = "ic_audio_play"
                cell.btnPlay.alpha = 1
                cell.btnPlay.isEnabled = true
            case .paused:
                imageName = "ic_audio_pause"
                cell.btnPlay.alpha = 1
                cell.btnPlay.isEnabled = true
            default:
                imageName = "ic_audio_play-1"
            }
        }else{
            imageName = "ic_audio_play-1"
            //cell.btnPlay.alpha = 0.3
            cell.btnPlay.isEnabled = true
        }

        cell.btnPlay.tag = indexPath.row
        cell.btnPlay.setImage(UIImage(named: imageName), for: UIControlState())
        cell.btnPlay.addTarget(self, action: #selector(btnPlayTapped), for: .touchUpInside)

        cell.progressView.tag = 1000 + indexPath.row
        cell.lbTime.tag = 10000 + indexPath.row
        if let currentTime = arrayOfAudio[indexPath.row].currentTime, let duration = arrayOfAudio[indexPath.row].meta.duration {
            let value = Float(currentTime / duration)
            cell.progressView.progress = value
            populateLabelWithTime(cell.lbTime, time: duration-currentTime)
            //populateLabelWithTime(timeLabel, time: duration)
        }

//        let addToFavorites = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
//        addToFavorites.tag = indexPath.row + 100000
//        addToFavorites.setImage(UIImage(named: "favorite_plus"), for: UIControlState())
//        addToFavorites.backgroundColor = darkGreen
//
//        addToFavorites.addTarget(self, action: #selector(addTappedFromFavorites), for: .touchUpInside)
//
//        cell.rightButtons = [addToFavorites]



        return cell
       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

    
    // MARK:- Helpers -
    
    func btnPlayTapped(_ button: UIButton) {
        tableRowIndex = button.tag
        if NewAudioManager.sharedInstance.jukebox.currentItem == arrayOfAudio[tableRowIndex] {
            switch  NewAudioManager.sharedInstance.jukebox.state {
            case .ready :
                NewAudioManager.sharedInstance.jukebox.play(atIndex: tableRowIndex)
            case .playing :
                NewAudioManager.sharedInstance.jukebox.pause()
            case .paused :
                NewAudioManager.sharedInstance.jukebox.play()
            default:
                NewAudioManager.sharedInstance.jukebox.stop()
            }

        }else{
//            if NewAudioManager.sharedInstance.partName != nil {
//                NewAudioManager.sharedInstance.partName = "المقطع \(NewAudioManager.sharedInstance.rowToSelectAudioFile + 1)"
//                //self.isFromFinishedAudio = false
//                NewAudioManager.sharedInstance.jukebox.play(atIndex: NewAudioManager.sharedInstance.rowToSelectAudioFile)
//            }
//            
//            // call api to set current paper...
//            let parameters = ["UserId": RealmHelper.getLoggedinUser()!.userID, "BookID": self.currentBook.bookID, "PageNumber": "\(self.currentPaperIndex + 1)"]
//            ApiManager.sharedInstance.setBookCuurrentPage(parameters as [String : AnyObject]?, onSuccess: { (array) in
//                print("setBookCuurrentPage successed")
//            }, onFailure: { (error) in
//                print(error.description)
//            }, loadingViewController: nil)
            //          
            do {
            let realm = try Realm()
            try! realm.write {
                NewAudioManager.sharedInstance.currentBook.userCurrentPage = tableRowIndex + 1
                NewAudioManager.sharedInstance.rowToSelectAudioFile = tableRowIndex
                
            }
        } catch {
            
        }
            NewAudioManager.sharedInstance.jukebox.play(atIndex: tableRowIndex)
            tableView.reloadData()
        }
        
    }
    
    func populateLabelWithTime(_ label : UILabel, time: Double) {
        let minutes = Int(time / 60)
        let seconds = Int(time) - minutes * 60
        
        label.text = "-" + String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
    }
    
    
    //Mark: Jukebox Delegate
    func jukeboxStateDidChange(_ jukebox : Jukebox){
        
        tableView.reloadData()
        print("Jukebox state changed to \(jukebox.state)")
        
        
    }
    
    func jukeboxPlaybackProgressDidChange(_ jukebox : Jukebox){
        let progressView = self.view.viewWithTag(1000+self.tableRowIndex) as! UIProgressView
        let lbTime = self.view.viewWithTag(10000+self.tableRowIndex) as! UILabel
        if let currentTime = NewAudioManager.sharedInstance.jukebox.currentItem?.currentTime, let duration = NewAudioManager.sharedInstance.jukebox.currentItem?.meta.duration {
            let value = Float(currentTime / duration)
            progressView.progress = value
            populateLabelWithTime(lbTime, time: duration-currentTime)
            //populateLabelWithTime(timeLabel, time: duration)
        } else {
            //resetUI()
        }
        
        //tableView.reloadData()
    }
    
    
    func jukeboxDidLoadItem(_ jukebox : Jukebox, item : JukeboxItem){
        
    }
    
   
    
    func jukeboxDidUpdateMetadata(_ jukebox : Jukebox, forItem: JukeboxItem){
        print("Item updated:\n\(forItem)")
    }
    
    func jukeboxFinished(){
        print("PlayerViewController finished...")
         tableView.reloadData()
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


   
    @IBAction func btnCloseTapped(_ sender: Any) {
        //NewAudioManager.sharedInstance.jukebox.stop()
        NewAudioManager.sharedInstance.partName = "المقطع \(NewAudioManager.sharedInstance.jukebox.playIndex + 1)"
        
        dismiss(animated: false, completion: nil)
    }
}
