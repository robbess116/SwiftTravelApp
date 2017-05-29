//
//  WelcomeViewController.swift
//  Aqsar
//
//  Created by moayad on 7/25/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit
import AVFoundation

class WelcomeViewController: BaseViewController {
    //MARK:- IBoutlets
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet var secondView: UIView!
    @IBOutlet var thirdView: UIView!
    @IBOutlet var forthView: UIView!
    var player1: AVPlayer!
    var player2: AVPlayer!
    var player3: AVPlayer!
    
    var playerLayer: AVPlayerLayer!
    var playerLayer2: AVPlayerLayer!
    var playerLayer3: AVPlayerLayer!
    
    static var backFlag: Bool! = false
    var currentIndex: Int! = 0

    
    //MARK:- Life Cycle
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        //super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        let url1 = Bundle.main.url(forResource: "2", withExtension: "mp4")!
        let url2 = Bundle.main.url(forResource: "3", withExtension: "mp4")!
        let url3 = Bundle.main.url(forResource: "4", withExtension: "mp4")!
        
        let playerItem:AVPlayerItem = AVPlayerItem(url: url1)
        player1 = AVPlayer(playerItem: playerItem)
        playerLayer=AVPlayerLayer(player: player1!)
        
        self.secondView.layer.addSublayer(playerLayer)
        
        let playerItem2:AVPlayerItem = AVPlayerItem(url: url2)
        player2 = AVPlayer(playerItem: playerItem2)
        playerLayer2=AVPlayerLayer(player: player2!)
        
        self.thirdView.layer.addSublayer(playerLayer2)
        
        
        let playerItem3:AVPlayerItem = AVPlayerItem(url: url3)
        player3 = AVPlayer(playerItem: playerItem3)
        playerLayer3=AVPlayerLayer(player: player3!)
        
        self.forthView.layer.addSublayer(playerLayer3)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd1),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: self.player1.currentItem)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd2),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: self.player2.currentItem)

        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd3),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: self.player3.currentItem)


        
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        self.navigationController?.navigationBar.isHidden = true
        setNeedsStatusBarAppearanceUpdate()
        if WelcomeViewController.backFlag ==  true{
            switch currentIndex {
            case 1:
                player1.play()
                player2.pause()
                player3.pause()
                break
            case 2:
                player1.pause()
                player2.play()
                player3.pause()
                break
            case 3:
                player1.pause()
                player2.pause()
                player3.play()
                break
            default:
                player1.pause()
                player2.pause()
                player3.pause()
                break
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        playerLayer.frame=self.secondView.bounds
        playerLayer3.frame=self.forthView.bounds
        playerLayer2.frame=self.thirdView.bounds
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player1.pause()
        player2.pause()
        player3.pause()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentIndex: Int = Int(scrollView.contentOffset.x) / Int(scrollView.frame.size.width)
        
        pageControl.currentPage = currentIndex
        self.currentIndex = currentIndex
        switch currentIndex {
        case 1:
//            let url = Bundle.main.url(forResource: "2", withExtension: "mp4")!
//            let playerItem:AVPlayerItem = AVPlayerItem(url: url)
//            player = AVPlayer(playerItem: playerItem)
//            let playerLayer=AVPlayerLayer(player: player!)
//            playerLayer.frame=self.secondView.bounds
//            self.secondView.layer.addSublayer(playerLayer)
//            player.play()
            player1.play()
            player2.pause()
            player3.pause()
            
            break
        case 2:
//            let url = Bundle.main.url(forResource: "3", withExtension: "mp4")!
//            let playerItem:AVPlayerItem = AVPlayerItem(url: url)
//            player = AVPlayer(playerItem: playerItem)
//            let playerLayer=AVPlayerLayer(player: player!)
//            playerLayer.frame=self.thirdView.bounds
//            self.thirdView.layer.addSublayer(playerLayer)
//            player.play()
            //            NotificationCenter.default.removeObserver(self)
            //            NotificationCenter.default.addObserver(self,
            //                                                   selector: #selector(playerItemDidReachEnd),
            //                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            //                                                   object: self.player.currentItem)
            
            player1.pause()
            player2.play()
            player3.pause()
            break
            
        case 3:
//            let url = Bundle.main.url(forResource: "4", withExtension: "mp4")!
//            let playerItem:AVPlayerItem = AVPlayerItem(url: url)
//            player = AVPlayer(playerItem: playerItem)
//            let playerLayer=AVPlayerLayer(player: player!)
//            playerLayer.frame=self.forthView.bounds
//            self.forthView.layer.addSublayer(playerLayer)
//            player.play()
            //            NotificationCenter.default.removeObserver(self)
            //            NotificationCenter.default.addObserver(self,
            //                                                   selector: #selector(playerItemDidReachEnd),
            //                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            //                                                  object: self.player.currentItem)
            player1.pause()
            player2.pause()
            player3.play()
            break
            
        default:
            player1.pause()
            player2.pause()
            player3.pause()
            break
        }
        
    }
    
    func playerItemDidReachEnd1(notification: NSNotification) {
        self.player1.seek(to: kCMTimeZero)
        self.player1.play()
    }
    
    func playerItemDidReachEnd2(notification: NSNotification) {
        self.player2.seek(to: kCMTimeZero)
        self.player2.play()
    }
    
    func playerItemDidReachEnd3(notification: NSNotification) {
        self.player3.seek(to: kCMTimeZero)
        self.player3.play()
    }

}

//extension WelcomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 1
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "welcomeBG", for: indexPath)
//        
//        if let imageBG = collectionView.viewWithTag(20) as? UIImageView {
//            if indexPath.row == 0 {
//                imageBG.image = UIImage(named: "open")
//            } else if indexPath.row == 1 {
//                imageBG.image = UIImage(named: "open")
//            } else if indexPath.row == 2 {
//                imageBG.image = UIImage(named: "open")
//            }
//        }
//        
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        //return CGSize(width: 300, height: 300)
//        return UIScreen.main.bounds.size
//    }
//    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let currentIndex: Int = Int(scrollView.contentOffset.x) / Int(scrollView.frame.size.width)
//        
//        pageControl.currentPage = currentIndex
//        switch currentIndex {
//        case 1:
//            let url = Bundle.main.url(forResource: "2", withExtension: "mp4")! 
//            let playerItem:AVPlayerItem = AVPlayerItem(url: url)
//            player = AVPlayer(playerItem: playerItem)
//            let playerLayer=AVPlayerLayer(player: player!)
//            playerLayer.frame=self.secondView.bounds
//            self.secondView.layer.addSublayer(playerLayer)
//            player.play()
////            NotificationCenter.default.addObserver(self,
////                                                   selector: #selector(playerItemDidReachEnd),
////                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
////                                                   object: self.player.currentItem)
//            break
//        case 2:
//            let url = Bundle.main.url(forResource: "3", withExtension: "mp4")!
//            let playerItem:AVPlayerItem = AVPlayerItem(url: url)
//            player = AVPlayer(playerItem: playerItem)
//            let playerLayer=AVPlayerLayer(player: player!)
//            playerLayer.frame=self.thirdView.bounds
//            self.thirdView.layer.addSublayer(playerLayer)
//            player.play()
////            NotificationCenter.default.removeObserver(self)
////            NotificationCenter.default.addObserver(self,
////                                                   selector: #selector(playerItemDidReachEnd),
////                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
////                                                   object: self.player.currentItem)
//             break
//
//        case 3:
//            let url = Bundle.main.url(forResource: "4", withExtension: "mp4")!
//            let playerItem:AVPlayerItem = AVPlayerItem(url: url)
//            player = AVPlayer(playerItem: playerItem)
//            let playerLayer=AVPlayerLayer(player: player!)
//            playerLayer.frame=self.forthView.bounds
//            self.forthView.layer.addSublayer(playerLayer)
//            player.play()
////            NotificationCenter.default.removeObserver(self)
////            NotificationCenter.default.addObserver(self,
////                                                   selector: #selector(playerItemDidReachEnd),
////                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
////                                                  object: self.player.currentItem)
//            break
//            
//        default:
//            break
//        }
//        
//    }
//    
//    func playerItemDidReachEnd(notification: NSNotification) {
//        self.player.seek(to: kCMTimeZero)
//        self.player.play()
//    }
////    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
////        if scrollView === collectionView {
////            if let indexPath = collectionView.indexPathForCell(collectionView.visibleCells()[0]) {
////                pageControl.currentPage = indexPath.row
////            }
////        }
////    }
//}
