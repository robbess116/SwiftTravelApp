//
//  MyAccountDoneReadingCell.swift
//  Aqsar
//
//  Created by moayad on 7/30/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit
import RealmSwift
import MBCircularProgressBar

class MyAccountDoneReadingCell: LLSwipeCell {
    //MARK:- IBOutlets
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblBrief: UILabel!
    @IBOutlet weak var lblAuthor: UILabel!
    @IBOutlet weak var lblNOViews: UILabel!
    @IBOutlet weak var lblNOComments: UILabel!
    @IBOutlet weak var imgSound: UIImageView!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnIcon: UIButton!
    //    @IBOutlet weak var pageControlTotalCount: UIPageControl!
    //    @IBOutlet weak var pageControlUserCount: UIPageControl!
    @IBOutlet weak fileprivate var imgStar01: UIImageView!
    @IBOutlet weak fileprivate var imgStar02: UIImageView!
    @IBOutlet weak fileprivate var imgStar03: UIImageView!
    @IBOutlet weak fileprivate var imgStar04: UIImageView!
    @IBOutlet weak fileprivate var imgStar05: UIImageView!
    @IBOutlet weak var lblTotalPagesCount: UILabel!
    @IBOutlet weak var lblProgressPagesCount: UILabel!
    @IBOutlet  var progressView: MBCircularProgressBarView!
    var totalPapersCount = 0
    
    @IBOutlet weak fileprivate var btnDownload: UIButton!
    var bookObj : Book!
    //MARK:- Properties
    var rate:Int?
    var hasSound:Bool?
    
    var forLibrary = false
    
    var removeFavoriteButton: UIButton?
    
    //MARK:- Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //pageControlUserCount.hidden = true
        //pageControlTotalCount.hidden = true
        
        imgIcon.layer.cornerRadius = 2.0
        
        if forLibrary {
            
        } else {
            removeFavoriteButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
            removeFavoriteButton!.backgroundColor = darkGreen
            leftButtons = [removeFavoriteButton!]
            removeFavoriteButton!.setImage(UIImage(named: "favorite_cross"), for: UIControlState())
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //drawTotalPapersCount(totalPapersCount)
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
    
    func drawTotalPapersCount(_ numberOfPapers: Int) {
        for imageView in contentView.subviews {
            if imageView is UIImageView && imageView.tag > 399 {
                imageView.removeFromSuperview()
            }
        }
        
        var currentX = lblAuthor.frame.origin.x + lblAuthor.frame.size.width
        var currentTag = 400
        for _ in 0..<numberOfPapers {
            let rectFrame = CGRect(x: currentX, y: lblAuthor.frame.origin.y + lblAuthor.frame.size.height + 8, width: 20, height: 20)
            let dotImage = UIImageView(frame: rectFrame)
            dotImage.tag = currentTag
            dotImage.backgroundColor = UIColor.lightGray
            slideContentView.addSubview(dotImage)
            
            currentX = currentX - 28
            currentTag = currentTag + 1
        }
    }
    
    
    
    //MARK:- IBActions
    @IBAction func moreTapped(_ sender: AnyObject) {
        expandLeftButtons()
    }
    
    @IBAction func downloadTapped(_ sender: AnyObject) {
        let realm = try! Realm()
        let inProgress = realm.objects(Book.self).filter("thereIsLoad == \(true)")
        
        if inProgress.count == 0 {
            /*
             //Must change status thereIsLoad when start any downloading audio
             try! realm.write {
             bookObj.thereIsLoad = true
             realm.add(bookObj, update: true)
             }
             */
            
            let parameters = ["BookID": "\(bookObj!.bookID)"]
            self.progressView.isHidden = false
            ApiManager.sharedInstance.getPapers(parameters as [String : AnyObject]?, onSuccess: { (array) in
                                if let papers = array {
                    for paper in papers.table! {
                        
                        if paper.audioURL == "" {
                            
                        }else {
                            
                            ApiManager.sharedInstance.downloadAudio(paper.audioID, progressHandler: { (progress) in
                                //print(progress.description)
                                print(progress)
                                 self.progressView.value = CGFloat( progress.completedUnitCount)
                                
                                
                            }, completion: { (isSuccess) in
                                if isSuccess {
                                    UserDefaultsManager.sharedInstance.setValueByUserDefaults(self.bookObj.bookID,value: true)
                                    DispatchQueue.main.async {
                                        
                                        UIView.animate(withDuration: 1.0, animations: {
                                            self.progressView.value = self.progressView.maxValue
                                        })
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                                            self.progressView.isHidden = true
                                            self.btnDownload.isHidden = false
                                            self.btnDownload.isEnabled = false
                                            self.btnDownload.setImage(UIImage(named: "Shape_136_copy_12-1"), for: UIControlState())

                                        })

                                        
                                    }
                                    
                                }else{
                                    self.btnDownload.isHidden = false
                                    self.progressView.isHidden = true
                                }
                            })
                        }

                    }
                        
                        
                }
            }, onFailure: { (error) in
                print(error.description)
            }, loadingViewController: nil)
            
        }else{
            //Sorry we can't download other audio now because there is some audio try to download
        }
    }
    
    
    func updateView(book : Book) {
        if !Reachability.isConnectedToNetwork() {
            btnDownload.isHidden = true
            return
        }
        bookObj = book
        let hasAudio = bookObj.hasAudio.lowercased().trimmingCharacters(in: CharacterSet.whitespaces)
        let isDownloaed = UserDefaultsManager.sharedInstance.checkIfValueExistsInUserDefaults(self.bookObj.bookID)
        if hasAudio == "true" && !isDownloaed {
            btnDownload.isHidden = false
            btnDownload.isEnabled = true

        }else if isDownloaed {
            btnDownload.isHidden = false
            btnDownload.isEnabled = false
            btnDownload.setImage(UIImage(named: "Shape_136_copy_12-1"), for: UIControlState())
        }else{
            btnDownload.isHidden = true
        }
        //btnDownload.isHidden = bookObj.hasAudio.lowercased().trimmingCharacters(in: CharacterSet.whitespaces) == "true" ? false : true
    }
    
}
