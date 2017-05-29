//
//  BaseViewController.swift
//  Aqsar
//
//  Created by moayad on 7/25/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit
import AVFoundation

class BaseViewController: UIViewController, AudioPlayerDelegate {
//    override func preferredStatusBarStyle() -> UIStatusBarStyle {
//        return .LightContent
//    }
    
    // audio
    var localProgressView: UIProgressView?
    
    var AudioPlayerYMargin = screenHeight - 60 - 49
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        self.navigationController?.navigationBar.isTranslucent = true
        
        //self.navigationController?.navigationBar.barStyle = .Black
        
        navigationController?.navigationBar.tintColor = darkGreen
        self.navigationController?.navigationBar.shadowImage = UIImage(named: "")
        self.navigationItem.leftBarButtonItem =
            UIBarButtonItem(image:#imageLiteral(resourceName: "arrow_green"), style:.plain, target:self, action:#selector(pop))
        
//        if let _ = self.tabBarController {
//            self.tabBarController?.delegate = self
//        }
//        
        NotificationCenter.default.addObserver(self, selector: #selector(shit), name: NSNotification.Name(rawValue: "AudioDidFinish"), object: nil)

    }
    
    func shit() {
        if let viewController = self.navigationController?.viewControllers.last {
            if !viewController.isKind(of: BookDetailsViewController.self) {
                self.addAudioPlayerNib()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let viewController = self.navigationController?.viewControllers.last {
            if !viewController.isKind(of: BookDetailsViewController.self) {
                self.addAudioPlayerNib()
            }
        }
        
        NewAudioManager.sharedInstance.jukebox.delegate = self

        checkSubscriptionAvailability()
        //checkSubscriptionAvailability()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    //MARK:- Tabbar
    func setTabBarDisabled(_ disabled: Bool) {
        var tabBarItemONE: UITabBarItem = UITabBarItem()
        var tabBarItemTWO: UITabBarItem = UITabBarItem()
        var tabBarItemTHREE: UITabBarItem = UITabBarItem()
        var tabBarItemFOUR: UITabBarItem = UITabBarItem()
//        var tabBarItemFIVE: UITabBarItem = UITabBarItem()
        
        let tabBarControllerItems = self.tabBarController?.tabBar.items
        
        if let arrayOfTabBarItems = tabBarControllerItems as AnyObject as? NSArray{
            
            tabBarItemONE = arrayOfTabBarItems[0] as! UITabBarItem
            tabBarItemONE.isEnabled = !disabled
            
            
            tabBarItemTWO = arrayOfTabBarItems[1] as! UITabBarItem
            tabBarItemTWO.isEnabled = !disabled
            
            tabBarItemTHREE = arrayOfTabBarItems[2] as! UITabBarItem
            tabBarItemTHREE.isEnabled = !disabled
            
            tabBarItemFOUR = arrayOfTabBarItems[3] as! UITabBarItem
            tabBarItemFOUR.isEnabled = !disabled
            
//            tabBarItemFIVE = arrayOfTabBarItems[4] as! UITabBarItem
//            tabBarItemFIVE.isEnabled = !disabled

        }
    }
    
    //MARK:- Targets
    func pop() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK:- IAPs
    func checkSubscriptionAvailability() -> Bool {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let subscriptionVC = storyboard.instantiateViewControllerWithIdentifier("SubscriptionViewController") as! SubscriptionViewController
//        presentViewController(subscriptionVC, animated: true, completion: nil)
//        
//        return false
        
        // get user end subscription date as NSDate
        guard let _ = RealmHelper.getLoggedinUser() else {
            return false
        }
        
        print(RealmHelper.getLoggedinUser()!.subscriptionEndDate)
        
        let str = RealmHelper.getLoggedinUser()!.subscriptionEndDate
        let readableDate = str[str.characters.index(str.startIndex, offsetBy: 0)...str.characters.index(str.startIndex, offsetBy: 9)]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        //dateFormatter.timeZone = NSTimeZone(name: "UTC")
        let userSubscriptionDate = dateFormatter.date(from: readableDate)
        
        let userSubscriptionDatePlusOneDay = (Calendar.current as NSCalendar)
            .date(
                byAdding: .day,
                value: 1,
                to: userSubscriptionDate!,
                options: []
        )
        
        // by default userSubscriptionDate is minus 1 day, that's why im adding another one...
        if userSubscriptionDate! == Date() {
            
        }
        
        print(userSubscriptionDatePlusOneDay)
        
        if Date().isGreaterThanDate(userSubscriptionDatePlusOneDay!) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let subscriptionVC = storyboard.instantiateViewController(withIdentifier: "SubscriptionViewController") as! SubscriptionViewController
            //present(subscriptionVC, animated: true, completion: nil)
            
            //return false
        }
        
        return true
    }
    
    //MARK:- Audio Player
    func addAudioPlayerNib() {
        if let partName = NewAudioManager.sharedInstance.partName {
            let apv = view.viewWithTag(399)
            apv?.removeFromSuperview()
            
            let audioPlayerArray = Bundle.main.loadNibNamed("AudioPlayerCell", owner: self, options: nil)
            let audioPlayerView = audioPlayerArray?[0] as! AudioPlayerCell
            audioPlayerView.delegate = self
            audioPlayerView.tag = 399
            audioPlayerView.frame = CGRect(x: 0, y: AudioPlayerYMargin, width: screenWidth, height: 60)
            
            localProgressView = audioPlayerView.progressView
            
            audioPlayerView.lblPartName.text = partName
            audioPlayerView.lblAuthorAndName.text = NewAudioManager.sharedInstance.titleAndAuthor
            
            view.addSubview(audioPlayerView)
        } else {
            let audioPlayerView = view.viewWithTag(399)
            audioPlayerView?.removeFromSuperview()
        }
    }
    
    @objc fileprivate func updateTimingViews() {
        //lblTrackCountdown.text = audioPlayer?.getCurrentTimeAsString()
        
        if let localProgressViewExists = localProgressView {
            localProgressViewExists.progress = AudioPlayer.sharedInstance.getProgress()
        }
    }
    
    func playPauseTapped(_ button: UIButton) {
        
        switch  NewAudioManager.sharedInstance.jukebox.state {
        case .ready :
            NewAudioManager.sharedInstance.jukebox.play(atIndex: 0)
        case .playing :
            NewAudioManager.sharedInstance.jukebox.pause()
            button.setImage(UIImage(named: "cross"), for: UIControlState())

        case .paused :
            NewAudioManager.sharedInstance.jukebox.play()
            button.setImage(UIImage(named: "open"), for: UIControlState())

        default:
            NewAudioManager.sharedInstance.jukebox.stop()
        }
        
        //AudioPlayer.sharedInstance.player?.delegate
        NewAudioManager.sharedInstance.jukebox.delegate = self

    }
    
    func closeAudioTapped() {
        
        
        
        NewAudioManager.sharedInstance.partName = nil
        if NewAudioManager.sharedInstance.jukebox.queuedItems.count != 0 {
            for item in NewAudioManager.sharedInstance.jukebox.queuedItems {
                NewAudioManager.sharedInstance.jukebox.remove(item: item)
            }
            NewAudioManager.sharedInstance.jukebox.stop()
        }
        
        
        for subview in self.view.subviews {
            if subview.tag == 399 {
                closeDidTap()
            }
        }
    }
    
    func presentAudiosListTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let audioListVC = storyboard.instantiateViewController(withIdentifier: "BookPapersListViewController") as! BookPapersListViewController
        audioListVC.papers = NewAudioManager.sharedInstance.currentPapers
        audioListVC.book = NewAudioManager.sharedInstance.currentBook
        audioListVC.shouldDisplayAudios = true
        audioListVC.shouldHidePapers = true
        present(audioListVC, animated: true, completion: nil)
    }
    
    func presentPaperTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let paperVC = storyboard.instantiateViewController(withIdentifier: "BookDetailsViewController") as! BookDetailsViewController
        paperVC.currentBook = NewAudioManager.sharedInstance.currentBook
        
        
        present(paperVC, animated: true, completion: nil)
    }
    
    //MARK:- Audio Player Delegate
    func audioPlayerDidPlayNextTrack() {
        print("Hello")
    }
}

extension BaseViewController: AudioPlayerCellDelegate {
    func playPauseDidTap(_ button: UIButton) {
        
        switch  NewAudioManager.sharedInstance.jukebox.state {
        case .ready :
            NewAudioManager.sharedInstance.jukebox.play(atIndex: 0)
        case .playing :
            NewAudioManager.sharedInstance.jukebox.pause()
            button.setImage(UIImage(named: "Group_14"), for: UIControlState())
            
        case .paused :
            NewAudioManager.sharedInstance.jukebox.play()
            button.setImage(UIImage(named: "Groupuu"), for: UIControlState())
            
        default:
            NewAudioManager.sharedInstance.jukebox.stop()
        }
        
    }
    
    
    func listDidTap() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let audioListVC = storyboard.instantiateViewController(withIdentifier: "AudioListViewController") as! AudioListViewController
        audioListVC.papersArray = NewAudioManager.sharedInstance.currentPapers
        audioListVC.currentBook = NewAudioManager.sharedInstance.currentBook
        audioListVC.arrayOfAudio = NewAudioManager.sharedInstance.jukebox.queuedItems
        audioListVC.currentPaperIndex = NewAudioManager.sharedInstance.jukebox.playIndex
        present(audioListVC, animated: true, completion: nil)
    }
    
    func currentPageDidTap() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let paperVC = storyboard.instantiateViewController(withIdentifier: "BookDetailsViewController") as! BookDetailsViewController
//        NewAudioManager.sharedInstance.currentBook.userCurrentPage = NewAudioManager.sharedInstance.jukebox.playIndex+1
        paperVC.currentBook = NewAudioManager.sharedInstance.currentBook
        paperVC.papers = NewAudioManager.sharedInstance.currentPapers
        paperVC.cameFromAudioPlayer = true
        
        present(paperVC, animated: true, completion: nil)
    }
    
    func closeDidTap() {
        let audioPlayerView = view.viewWithTag(399)

        audioPlayerView?.removeFromSuperview()
       
        NewAudioManager.sharedInstance.partName = nil
        if NewAudioManager.sharedInstance.jukebox.queuedItems.count != 0 {
            for item in NewAudioManager.sharedInstance.jukebox.queuedItems {
                NewAudioManager.sharedInstance.jukebox.remove(item: item)
            }
            NewAudioManager.sharedInstance.jukebox.stop()
        }
    
        
        for subview in self.view.subviews {
            if subview.tag == 399 {
                closeDidTap()
            }
        }
        
        
    }
}



//MARK:- NSDate Extenstion
extension Date {
    func isGreaterThanDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    func isLessThanDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func equalToDate(_ dateToCompare: Date) -> Bool {
        //Declare Variables
        var isEqualTo = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedSame {
            isEqualTo = true
        }
        
        //Return Result
        return isEqualTo
    }
    
    func addDays(_ daysToAdd: Int) -> Date {
        let secondsInDays: TimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded: Date = self.addingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    func addHours(_ hoursToAdd: Int) -> Date {
        let secondsInHours: TimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded: Date = self.addingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
}


extension BaseViewController :  JukeboxDelegate {
    
    func jukeboxDidLoadItem(_ jukebox: Jukebox, item: JukeboxItem) {
        print("Jukebox did load: \(item.URL.lastPathComponent)")
         NewAudioManager.sharedInstance.partName = "المقطع \(NewAudioManager.sharedInstance.jukebox.playIndex + 1)"
         self.addAudioPlayerNib()
        let parameters = ["UserId": RealmHelper.getLoggedinUser()!.userID, "BookID": NewAudioManager.sharedInstance.currentBook.bookID, "PageNumber": "\(NewAudioManager.sharedInstance.jukebox.playIndex + 1)"]
        
        ApiManager.sharedInstance.setBookCuurrentPage(parameters as [String : AnyObject]?, onSuccess: { (array) in
            print("setBookCuurrentPage successed")
        }, onFailure: { (error) in
            print(error.description)
        }, loadingViewController: nil)

    }
    
    func jukeboxPlaybackProgressDidChange(_ jukebox: Jukebox) {
        
        if let currentTime = jukebox.currentItem?.currentTime, let duration = jukebox.currentItem?.meta.duration {
            let value = Float(currentTime / duration)
            self.localProgressView?.progress = value
        } else {
            //resetUI()
        }
    }
    
    func jukeboxStateDidChange(_ jukebox: Jukebox) {
    
        print("Jukebox state changed to \(jukebox.state)")
    }
    
    func jukeboxFinished() {
        print("baseViewController finished...")
        let parameters = ["UserId": RealmHelper.getLoggedinUser()!.userID, "BookID": NewAudioManager.sharedInstance.currentBook.bookID, "PageNumber": "\(NewAudioManager.sharedInstance.jukebox.playIndex + 1)"]
        
        ApiManager.sharedInstance.setBookCuurrentPage(parameters as [String : AnyObject]?, onSuccess: { (array) in
            print("setBookCuurrentPage successed")
        }, onFailure: { (error) in
            print(error.description)
        }, loadingViewController: nil)

       
    }
    func jukeboxDidUpdateMetadata(_ jukebox: Jukebox, forItem: JukeboxItem) {
        print("Item updated:\n\(forItem)")
    }
}

//extension BaseViewController: UITabBarControllerDelegate {
//    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//         
//        return true
//    }
//    
//}
