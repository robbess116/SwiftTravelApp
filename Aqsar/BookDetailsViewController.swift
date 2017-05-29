//
//  BookDetailsViewController.swift
//  Aqsar
//
//  Created by moayad on 8/4/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit
import BRYXBanner
import RealmSwift
import AVFoundation

class BookDetailsViewController: BaseViewController {
    //MARK:- IBOutlets
    @IBOutlet weak fileprivate var btnClose: UIButton!
    @IBOutlet weak fileprivate var btnListen: UIButton!
    @IBOutlet weak fileprivate var btnBrightness: UIButton!
    @IBOutlet weak fileprivate var btnFont: UIButton!
    @IBOutlet weak fileprivate var btnList: UIButton!
    
    @IBOutlet weak fileprivate var collectionView: UICollectionView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblAuthor: UILabel!
    
    @IBOutlet weak fileprivate var viewPageNumber: UIView!
    @IBOutlet weak fileprivate var viewDone: UIView!
    
    @IBOutlet weak fileprivate var viewPageTip: UIView!
    @IBOutlet weak fileprivate var lblCurrentPage: UILabel!
    @IBOutlet weak fileprivate var lblNOPages: UILabel!
    
    @IBOutlet weak fileprivate var viewBrightness: UIView!
    @IBOutlet weak fileprivate var sliderBrightness: UISlider!
    
    @IBOutlet weak fileprivate var viewFont: UIView!
    @IBOutlet weak fileprivate var sliderFont: UISlider!
    @IBOutlet weak fileprivate var btnFontNightMode: UIButton!
    @IBOutlet weak fileprivate var btnFontDefaultMode: UIButton!
    
    
    // comment view
    @IBOutlet weak fileprivate var viewComment: UIView!
    @IBOutlet weak var tvComment: UITextView!
    @IBOutlet weak var btnCommentS1: UIButton!
    @IBOutlet weak var btnCommentS2: UIButton!
    @IBOutlet weak var btnCommentS3: UIButton!
    @IBOutlet weak var btnCommentS4: UIButton!
    @IBOutlet weak var btnCommentS5: UIButton!
    @IBOutlet weak var btnCommentDone: UIButton!
    
    @IBOutlet var topNavView: UIView!
    @IBOutlet var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet var bottomBarHeightConstrant: NSLayoutConstraint!
    @IBOutlet var toolbar: UIToolbar!
    @IBOutlet var imgViewBrightBig: UIImageView!
    @IBOutlet var imgViewBrightSmall: UIImageView!
    @IBOutlet var imgViewFontBig: UIImageView!
    @IBOutlet var imgViewFontSmall: UIImageView!
    
    var segueIndex = 0
    
    fileprivate var bookRate = 0
    
    // Audio
    var cameFromAudioPlayer = false
    
    //MARK:- IVars
    var currentBook: Book?
    static var finalBook: Book!
    
    var pageNumberToScroll = 1
    
    fileprivate var pageNumberView = UIView()
    fileprivate var shouldDisplayAudios = false
    fileprivate var commentFlag = false
    
    var papers = [Paper]()
    fileprivate var currentPaperIndex = 0
    
    fileprivate var currentFontSize:CGFloat = 15.0 {
        willSet {
            print("currentFontSize var is about to be \(newValue)")
        }
        
        didSet {
            collectionView.reloadData()
        }
    }
    
    fileprivate var isFontNightMode = 2 {
        didSet {
            if isFontNightMode == 2{
                
                topNavView.backgroundColor = navColor
                btnClose.tintColor = darkGreen
                toolbar.backgroundColor = navColor
                toolbar.barTintColor = navColor
                toolbar.tintColor = navColor
                btnFont.tintColor = darkGreen
                btnListen.tintColor = darkGreen
                btnList.tintColor =  darkGreen
                viewFont.backgroundColor = UIColor.white
                imgViewBrightBig.image = UIImage(named: "less_bright")
                imgViewBrightSmall.image = UIImage(named: "less_bright")
                imgViewFontBig.image = UIImage(named: "font")
                imgViewFontSmall.image = UIImage(named: "font")
                
                
            }else {
                topNavView.backgroundColor = UIColor.black
                btnClose.tintColor = UIColor.white
                toolbar.backgroundColor = UIColor.black
                toolbar.barTintColor = UIColor.black
                toolbar.tintColor = UIColor.black
                btnFont.tintColor = UIColor.white
                btnListen.tintColor = UIColor.white
                btnList.tintColor =  UIColor.white
                viewFont.backgroundColor = UIColor.black
                
                imgViewBrightBig.image = UIImage(named: "less_bright_white")
                imgViewBrightSmall.image = UIImage(named: "less_bright_white")
                imgViewFontBig.image = UIImage(named: "font_white")
                imgViewFontSmall.image = UIImage(named: "font_white")
                
            }
            collectionView.reloadData()
        }
    }
    
    // download
    var currentPaperIndexToDownload = 0
    
    var textView: UITextView = UITextView()
    
    fileprivate var currentTextViewOffset: CGFloat = 0
    
    // audio tracking
    fileprivate var rangeToHighlight = NSRange()
    fileprivate var audioTrackingCurrentSecond = 0
    
    var paragraghs = [String]()
    var timers = [String]()
    var currentTimerTracker = 0
    var rangesToHighlight = [NSRange]()
    var rangesTracker = 0
    
    var isTrimmingDone = false
    var textToView = ""
    
    // came from summary
    var shouldNavigateToPapers = false
    var shouldNavigateToAudios = false
    
    var textViewTappedFlag = true
    
    //New From Azar
    var audioArray : [String]?
    var currentPageSelected = 0
    var isFromFinishedAudio = true
    
    var tapTerm:UITapGestureRecognizer = UITapGestureRecognizer()
    
    var playerVC: PlayerViewController!
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setBookStatus(1)
        
        if currentBook?.bookID != NewAudioManager.sharedInstance.currentBook.bookID {
            super.closeAudioTapped()
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        
        playerVC = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        
        viewDone.alpha = 0.0
        viewComment.alpha = 0.0
        
        pageNumberView.frame = CGRect(x: screenWidth, y: 0, width: 0, height: viewPageNumber.frame.size.height)
        
        collectionView.mirrorMe()
        
        
        tapTerm = UITapGestureRecognizer(target: self, action: #selector(textViewTapped))
        
        tapTerm.numberOfTapsRequired = 1
        
        collectionView.addGestureRecognizer(tapTerm)
        
       
        btnFontNightMode.layer.borderWidth = 1
        btnFontNightMode.layer.borderColor = UIColor(red: 13.0/255.0, green: 83.0/255.0, blue: 78.0/255.0, alpha: 1.0).cgColor
        
        
    }
    
   
    
    func textViewTapped(recognizer: UITapGestureRecognizer) {
        
        self.viewFont.alpha = 0.0
        
        if textViewTappedFlag {
            
            navBarHeightConstraint.constant = 0
            bottomBarHeightConstrant.constant = 0
           
            
            textViewTappedFlag = false
            
            UIView.animateKeyframes(withDuration: 0.4, delay: 0, options: .allowUserInteraction, animations: {
                 self.toolbar.alpha = 0.0
                self.viewDone.frame = CGRect(x: 0, y: self.viewPageNumber.frame.origin.y, width: screenWidth, height: 49)
                self.viewPageTip.frame = CGRect(x: self.viewPageTip.frame.origin.x, y: screenHeight - 58, width: 74, height: 50)
                
                self.view.layoutIfNeeded()
            }, completion: { (isFinish) in
                self.collectionView.reloadData()
            })

        }else {
            
            navBarHeightConstraint.constant = 64.0
            bottomBarHeightConstrant.constant = 44.0
             toolbar.alpha = 1.0
            textViewTappedFlag = true
            
            UIView.animateKeyframes(withDuration: 0.4, delay: 0, options: .allowUserInteraction, animations: {
                self.viewDone.frame = CGRect(x: 0, y: self.viewPageNumber.frame.origin.y - 91, width: screenWidth, height: 49)
                self.viewPageTip.frame = CGRect(x: self.viewPageTip.frame.origin.x, y: screenHeight - 58 - 44, width: 74, height: 50)
                
                self.view.layoutIfNeeded()
            }, completion: { (isFinish) in
                self.collectionView.reloadData()
            })
        }
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
        UIApplication.shared.isStatusBarHidden = true
        setupTitleLabel()
        NewAudioManager.sharedInstance.jukebox.delegate = self
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewDone.frame = CGRect(x: 0, y: viewPageNumber.frame.origin.y - 49, width: screenWidth, height: 49)
        view.addSubview(viewDone)
        
        viewComment.frame = CGRect(x:0, y: 0, width: 240, height: 280)
        viewComment.center = centerOfScreen
        viewComment.frame.origin.y -= 100
        
        view.addSubview(viewComment)
        
        pageNumberView.backgroundColor = darkGreen
        viewPageNumber.addSubview(pageNumberView)
        
        viewPageTip.frame = CGRect(x: 0, y: screenHeight - 58 - 44, width: 74, height: 50)
        viewPageTip.alpha = 0.0
        //lblNOPages.text = "0"
        view.addSubview(viewPageTip)
        
        // brightness
        sliderBrightness.value = Float(UIScreen.main.brightness)
        viewFont.frame = CGRect(x: 0, y: screenHeight-50-self.viewFont.frame.size.height, width: screenWidth, height: viewFont.frame.size.height)
        viewFont.alpha = 0.0
        view.addSubview(viewFont)
        
        let printToConsole = UIMenuItem(title: "اقتباس", action: #selector(BookDetailsCollectionViewCell.printToConsole))
        UIMenuController.shared.menuItems = [printToConsole]
        
        //self.collectionView.reloadData()
        self.getAndDisplayPapers()

    }
    
    func addFinishBook(){
        
        let realm = try! Realm()
        
        try! realm.write {
            
            let bookID =  (self.currentBook?.bookID)! as String
            if (RealmHelper.getLoggedinUser()?.booksUnread.filter("bookID == \"\(bookID)\"").first) != nil {
                let index = RealmHelper.getLoggedinUser()?.booksUnread.index(of: (RealmHelper.getLoggedinUser()?.booksUnread.filter("bookID == \"\(bookID)\"").first)!)
                RealmHelper.getLoggedinUser()?.booksUnread.remove(objectAtIndex: index!)
                var realmbook = realm.object(ofType: Book.self, forPrimaryKey: bookID)
                realmbook =  self.currentBook
                realm.add(realmbook!, update: true)
                RealmHelper.getLoggedinUser()?.booksFinished.append(realmbook!)
            }else if (RealmHelper.getLoggedinUser()?.booksInProgress.filter("bookID == \"\(bookID)\"").first) != nil{
                let index = RealmHelper.getLoggedinUser()?.booksInProgress.index(of: (RealmHelper.getLoggedinUser()?.booksInProgress.filter("bookID == \"\(bookID)\"").first)!)
                RealmHelper.getLoggedinUser()?.booksInProgress.remove(objectAtIndex: index!)
                var realmbook = realm.object(ofType: Book.self, forPrimaryKey: bookID)
                realmbook =  self.currentBook
                realm.add(realmbook!, update: true)
                RealmHelper.getLoggedinUser()?.booksFinished.append(realmbook!)

            } else {
                var book = RealmHelper.getLoggedinUser()?.booksInProgress.filter("bookID == \"\(bookID)\"").first
                book = self.currentBook
                realm.add(book!, update: true)
            }
            
            realm.add(RealmHelper.getLoggedinUser()!, update: true)
        }

    }
    
    func removeBookFromUnreadBooks(){
        
        let realm = try! Realm()
        
        try! realm.write {
           
            let bookID =  (self.currentBook?.bookID)! as String
            if (RealmHelper.getLoggedinUser()?.booksUnread.filter("bookID == \"\(bookID)\"").first) != nil {
                let index = RealmHelper.getLoggedinUser()?.booksUnread.index(of: (RealmHelper.getLoggedinUser()?.booksUnread.filter("bookID == \"\(bookID)\"").first)!)
                RealmHelper.getLoggedinUser()?.booksUnread.remove(objectAtIndex: index!)

                var realmbook = realm.object(ofType: Book.self, forPrimaryKey: bookID)
                realmbook =  self.currentBook
                realm.add(realmbook!, update: true)
                RealmHelper.getLoggedinUser()?.booksInProgress.append(realmbook!)
            }else {
                var book = RealmHelper.getLoggedinUser()?.booksInProgress.filter("bookID == \"\(bookID)\"").first
                book = self.currentBook
                realm.add(book!, update: true)
            }
                        
            
            realm.add(RealmHelper.getLoggedinUser()!, update: true)
        }

        
    }
    func printToConsole() {
        if let textRange = textView.selectedTextRange {
            if let selectedText = textView.text(in: textRange) {
                print(selectedText)
                
                if selectedText.characters.count > 200 {
                    let banner = Banner(title: nil, subtitle: "يجب ان لا يحتوي الاقتباس اكثر من ٢٠٠ رمز", image: nil, backgroundColor: lightShinyGreenColor, didTapBlock: nil)
                    banner.dismissesOnTap = true
                    banner.show(duration: 3.0)
                    
                    return
                }
                
                print(selectedText.characters.count)
                
                let parameters = ["UserId": RealmHelper.getLoggedinUser()!.userID, "BookID": currentBook!.bookID, "Quote":selectedText]
                
                ApiManager.sharedInstance.AddQuoteToFavorites(parameters as [String : AnyObject]?, onSuccess: { (array) in
                    print("success")
                    
                    let banner = Banner(title: nil, subtitle: "تم اضافة الكتاب الى قائمة المفضلة", image: nil, backgroundColor: lightShinyGreenColor, didTapBlock: nil)
                    banner.dismissesOnTap = true
                    banner.show(duration: 3.0)
                    }, onFailure: { (error) in
                        print(error.description)
                        
                        let banner = Banner(title: nil, subtitle: "خطأ في العملية. يرجى المحاولة مرة اخرى", image: nil, backgroundColor: lightShinyGreenColor, didTapBlock: nil)
                        banner.dismissesOnTap = true
                        banner.show(duration: 3.0)
                    }, loadingViewController: nil)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
        AppController.sharedInstance.currentBook = self.currentBook!
        if commentFlag == false{
            //remove book from Realm Unreadbooks
            self.removeBookFromUnreadBooks()
            
        }else {
            self.addFinishBook()
        }

        
        
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.getPapers()
        
    }
    //MARK:- Override
    override func currentPageDidTap() {
        print("nothing to do here!")
    }
    
    
    func getPapers() {
        if !Reachability.isConnectedToNetwork() {
            //if currentBook?.papersList.count > 0 {
            if let bookUnread = RealmHelper.getLoggedinUser()?.booksUnread.filter("bookID == \"\(self.currentBook!.bookID)\"").first {
                for paper in bookUnread.papersList {
                    papers.append(paper)
                }
            } else if let bookInProgress = RealmHelper.getLoggedinUser()?.booksInProgress.filter("bookID == \"\(self.currentBook!.bookID)\"").first {
                for paper in bookInProgress.papersList {
                    papers.append(paper)
                }
            } else if let bookFinished = RealmHelper.getLoggedinUser()?.booksFinished.filter("bookID == \"\(self.currentBook!.bookID)\"").first {
                for paper in bookFinished.papersList {
                    papers.append(paper)
                }
            } else if let bookFavorite = RealmHelper.getLoggedinUser()?.booksFavorites.filter("bookID == \"\(self.currentBook!.bookID)\"").first {
                for paper in bookFavorite.papersList {
                    papers.append(paper)
                }
            }
            
            
            return
        }
        
        let parameters = ["BookID": "\(currentBook!.bookID)"]
        
        ApiManager.sharedInstance.getPapers(parameters as [String : AnyObject]?, onSuccess: { (array) in
            if let papers = array {
                print(papers)
                
                func cachPapers(_ book: Book) {
                    let realm = try! Realm()
                    
                    try! realm.write {
                        book.papersList.removeAll()
                        for paper in papers.table! {
                            book.papersList.append(paper)
                        }
                    
                        //''Book' does not have a primary key and can not be updated'
                        realm.add(book, update: true)
                    }
                    
                    
                    print(book.papersList)
                }
                
                
                
                if let bookUnread = RealmHelper.getLoggedinUser()?.booksUnread.filter("bookID == \"\(self.currentBook!.bookID)\"").first {
                    cachPapers(bookUnread)
                } else if let bookInProgress = RealmHelper.getLoggedinUser()?.booksInProgress.filter("bookID == \"\(self.currentBook!.bookID)\"").first {
                    cachPapers(bookInProgress)
                } else if let bookFinished = RealmHelper.getLoggedinUser()?.booksFinished.filter("bookID == \"\(self.currentBook!.bookID)\"").first {
                    cachPapers(bookFinished)
                } else if let bookFavorite = RealmHelper.getLoggedinUser()?.booksFavorites.filter("bookID == \"\(self.currentBook!.bookID)\"").first {
                    cachPapers(bookFavorite)
                }
                
                self.papers = papers.table!
                
            }
        }, onFailure: { (error) in
            print(error.description)
        }, loadingViewController: nil)
    }

    
    //MARK:- APIs
    fileprivate func getAndDisplayPapers() {
        if !Reachability.isConnectedToNetwork() {
            
            if let bookUnread = RealmHelper.getLoggedinUser()?.booksUnread.filter("bookID == \"\(self.currentBook!.bookID)\"").first {
                for paper in bookUnread.papersList {
                    papers.append(paper)
                }
            } else if let bookInProgress = RealmHelper.getLoggedinUser()?.booksInProgress.filter("bookID == \"\(self.currentBook!.bookID)\"").first {
                for paper in bookInProgress.papersList {
                    papers.append(paper)
                }
            } else if let bookFinished = RealmHelper.getLoggedinUser()?.booksFinished.filter("bookID == \"\(self.currentBook!.bookID)\"").first {
                for paper in bookFinished.papersList {
                    papers.append(paper)
                }
            } else if let bookFavorite = RealmHelper.getLoggedinUser()?.booksFavorites.filter("bookID == \"\(self.currentBook!.bookID)\"").first {
                for paper in bookFavorite.papersList {
                    papers.append(paper)
                }
            }
            
            //self.papers = papers.table!
            
            self.lblNOPages.text = "\(self.papers.count)"
            
            self.collectionView.reloadData()
            
            self.rangeToHighlight.location = 0
            
            print(self.currentBook!.userCurrentPage - 1)
            
            if self.cameFromAudioPlayer {
                let indexPath = IndexPath(item: NewAudioManager.sharedInstance.rowToSelectAudioFile, section: 0)
                self.collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: false)
                if NewAudioManager.sharedInstance.rowToSelectAudioFile == self.papers.count - 1 {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.viewDone.alpha = 1.0
                        
                    })
                }else {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.viewDone.alpha = 0.0
                        
                    })
                    
                }
                
                let parameters = ["UserId": RealmHelper.getLoggedinUser()!.userID, "BookID": self.currentBook!.bookID, "PageNumber": "\(NewAudioManager.sharedInstance.rowToSelectAudioFile + 1)"]
                ApiManager.sharedInstance.setBookCuurrentPage(parameters as [String : AnyObject]?, onSuccess: { (array) in
                    print("setBookCuurrentPage successed")
                }, onFailure: { (error) in
                    print(error.description)
                }, loadingViewController: nil)
            } else {
                var userCurrent = self.currentBook!.userCurrentPage - 1
                if userCurrent < 0 {
                    userCurrent = 0
                }
                let indexPath = IndexPath(item: userCurrent, section: 0)
                self.collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: false)
            }
            
            if self.shouldNavigateToPapers {
                self.performSegue(withIdentifier: "toPapersList", sender: self)
            }
            
            if self.shouldNavigateToAudios {
                self.shouldDisplayAudios = true
                self.performSegue(withIdentifier: "toPapersList", sender: self)
            }
            
            let triggerTime = (Int64(NSEC_PER_MSEC) * 500)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                if self.papers.count > 0 {
                    let firstPageCell = self.collectionView.visibleCells[0] as! BookDetailsCollectionViewCell
                    firstPageCell.textView.setContentOffset(CGPoint.zero, animated: false)
                    
                    if self.currentBook!.userCurrentPage - 1 == self.papers.count - 1 {
                        UIView.animate(withDuration: 0.25, animations: {
                            self.viewDone.alpha = 1.0
                            
                        })
                    }
                }
                
            })

            return
        }
        
        let parameters = ["BookID": "\(currentBook!.bookID)"]
        
        ApiManager.sharedInstance.getPapers(parameters as [String : AnyObject]?, onSuccess: { (array) in
            if let papers = array {
                print(papers)
                
                func cachPapers(_ book: Book) {
                    let realm = try! Realm()
                    
                    try! realm.write {
                        book.papersList.removeAll()
                        for paper in papers.table! {
                            book.papersList.append(paper)
                        }
                    
                        //''Book' does not have a primary key and can not be updated'
                        realm.add(book, update: true)                    }
                    
                    
                }
                
              
                if let bookUnread = RealmHelper.getLoggedinUser()?.booksUnread.filter("bookID == \"\(self.currentBook!.bookID)\"").first {
                    cachPapers(bookUnread)
                } else if let bookInProgress = RealmHelper.getLoggedinUser()?.booksInProgress.filter("bookID == \"\(self.currentBook!.bookID)\"").first {
                    cachPapers(bookInProgress)
                } else if let bookFinished = RealmHelper.getLoggedinUser()?.booksFinished.filter("bookID == \"\(self.currentBook!.bookID)\"").first {
                    cachPapers(bookFinished)
                } else if let bookFavorite = RealmHelper.getLoggedinUser()?.booksFavorites.filter("bookID == \"\(self.currentBook!.bookID)\"").first {
                    cachPapers(bookFavorite)
                }
                
                self.papers = papers.table!
                
                self.lblNOPages.text = "\(self.papers.count)"
                
                self.collectionView.reloadData()
                
                self.rangeToHighlight.location = 0
                
                print(self.currentBook!.userCurrentPage - 1)
                
                if self.cameFromAudioPlayer {
                    let indexPath = IndexPath(item: NewAudioManager.sharedInstance.rowToSelectAudioFile, section: 0)
                    self.collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: false)
                    if NewAudioManager.sharedInstance.rowToSelectAudioFile == self.papers.count - 1 {
                        UIView.animate(withDuration: 0.25, animations: {
                            self.viewDone.alpha = 1.0
                            
                        })
                    }else {
                        UIView.animate(withDuration: 0.25, animations: {
                            self.viewDone.alpha = 0.0
                            
                        })

                    }
                    
                    let parameters = ["UserId": RealmHelper.getLoggedinUser()!.userID, "BookID": self.currentBook!.bookID, "PageNumber": "\(NewAudioManager.sharedInstance.rowToSelectAudioFile + 1)"]
                    ApiManager.sharedInstance.setBookCuurrentPage(parameters as [String : AnyObject]?, onSuccess: { (array) in
                        print("setBookCuurrentPage successed")
                        }, onFailure: { (error) in
                            print(error.description)
                        }, loadingViewController: nil)
                } else {
                    var userCurrent = self.currentBook!.userCurrentPage - 1
                    if userCurrent < 0 {
                        userCurrent = 0
                    }
                    let indexPath = IndexPath(item: userCurrent, section: 0)
                    self.collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: false)
                }
                
                if self.shouldNavigateToPapers {
                    self.performSegue(withIdentifier: "toPapersList", sender: self)
                }
                
                if self.shouldNavigateToAudios {
                    self.shouldDisplayAudios = true
                    self.performSegue(withIdentifier: "toPapersList", sender: self)
                }
                
                let triggerTime = (Int64(NSEC_PER_MSEC) * 500)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                    if self.papers.count > 0 {
                        let firstPageCell = self.collectionView.visibleCells[0] as! BookDetailsCollectionViewCell
                        firstPageCell.textView.setContentOffset(CGPoint.zero, animated: false)
                        
                        if self.currentBook!.userCurrentPage - 1 == self.papers.count - 1 {
                            UIView.animate(withDuration: 0.25, animations: {
                                self.viewDone.alpha = 1.0

                            })
                        }
                    }
                    
                })
            }
            }, onFailure: { (error) in
                print(error.description)
            }, loadingViewController: nil)
    }
    
    fileprivate func setBookStatus(_ status: Int) {
        let parameters = ["UserID":RealmHelper.getLoggedinUser()!.userID, "BookID": currentBook!.bookID, "Status": "\(status)"]
        
        print(currentBook!.bookID)
        let realm = try! Realm()
        
        try! realm.write {
            let book = realm.object(ofType: Book.self, forPrimaryKey: self.currentBook?.bookID)
            book?.status = status
            realm.add(book!, update: true)
            
        }
        

        ApiManager.sharedInstance.setBookStatus(parameters as [String : AnyObject]?, onSuccess: { (array) in
            print("success")
            
        }, onFailure: { (error) in
                print(error.description)
            }, loadingViewController: nil)
    }
    
    fileprivate func startDwonloadAudios() {
        for paper in papers {
            ApiManager.sharedInstance.downloadAudio(paper.audioID, progressHandler: { (progress) in
                
            }, completion: { (isSuccess) in
                print("paper \(paper.audioID) has been downoaded")
            })
        }
    }
    
    //MARK:- UI
    fileprivate func setupTitleLabel() {
        let bookName = currentBook!.title
        let authorName  = currentBook!.author
        //let title = authorName + "/" + bookName
        lblTitle.text = authorName
        lblAuthor.text = bookName
        
//        let attrs = [NSFontAttributeName : UIFont(name: "DroidArabicKufi-Bold", size: 14)!]
//        let boldString = NSMutableAttributedString(string:authorName, attributes:attrs)
//        
//        let attributedString = NSMutableAttributedString()
//        attributedString.appendAttributedString(boldString)
//        attributedString.appendAttributedString(NSAttributedString(string: "/"))
//        attributedString.appendAttributedString(NSAttributedString(string: bookName))
//        
//        lblTitle.attributedText = attributedString
    }
    
    
    //MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPapersList" {
            let destination = segue.destination as! BookPapersListViewController
            
            destination.papers = papers
            destination.currentHighlightedIndex = currentPaperIndex
            destination.book = currentBook!
            destination.delegate = self
            destination.shouldDisplayAudios = shouldDisplayAudios
        }else if segue.identifier == "toAudioPlayer" {
            let destination = segue.destination as! PlayerViewController
            destination.currentPaperIndex = currentPaperIndex
            destination.papersArray = papers
            destination.backgroundMode = isFontNightMode
            destination.delegate = self
            destination.bookObject = currentBook!
        }
    }
    
    //MARK:- IBActions
    @IBAction fileprivate func closeTapped(_ sender: AnyObject) {
        SummaryViewController.summaryDetailsFlag = true

        dismiss(animated: true, completion: nil)
    }
    
    @IBAction fileprivate func listenTapped(_ sender: AnyObject) {
        
        if self.segueIndex == 1 {
            dismiss(animated: true, completion: nil)
        }else {
            NewAudioManager.sharedInstance.currentBook = currentBook!
            NewAudioManager.sharedInstance.currentPapers = papers
            NewAudioManager.sharedInstance.rowToSelectAudioFile = currentPaperIndex
            shouldDisplayAudios = true
            
            performSegue(withIdentifier: "toAudioPlayer", sender: self)

        }
        
    }
    
    @IBAction fileprivate func brightnessTapped(_ sender: AnyObject) {
    }
    
    @IBAction fileprivate func fontTapped(_ sender: AnyObject) {
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
        UIView.animate(withDuration: 0.25, animations: {
            if self.viewFont.alpha == 0.0 {
                
                //self.btnFont.setImage(UIImage(named: "ic_aa-1"), for: .normal)
                self.viewFont.alpha = 1.0
                
                
            }else{
                self.viewFont.alpha = 0.0
                //self.btnFont.setImage(UIImage(named: "ic_aa"), for: .normal)
            }
            
        })
    }
    
    @IBAction fileprivate func listTapped(_ sender: AnyObject) {
        //btnFont.setImage(UIImage(named: "ic_aa"), for: .normal)
        shouldDisplayAudios = false
        UIView.animate(withDuration: 0.25, animations: {
            self.viewFont.alpha = 0.0
            //self.viewBrightness.alpha = 0.0
        }) 
    }
    
    @IBAction fileprivate func doneReadingTapped(_ sender: AnyObject) {
        if Reachability.isConnectedToNetwork() == false {
            showNetowrkNoConnectivityAlertController()
            return
        }
        
        //collectionView.setContentOffset(CGPointZero, animated: true)
        
        //setBookStatus(2)
        
        UIView.animate(withDuration: 0.25, animations: {
            //self.viewDone.alpha = 0.0
            self.viewComment.alpha = 1.0
        })
    }
    
    @IBAction fileprivate func sliderBrightnessChanged(_ sender: AnyObject) {
        let slider = sender as! UISlider
        
        UIScreen.main.brightness = CGFloat(slider.value)
    }
    
    @IBAction fileprivate func sliderFontChanged(_ sender: AnyObject) {
        let slider = sender as! UISlider
        
        currentFontSize = CGFloat(slider.value) * 10 + 10
    }
    
    @IBAction fileprivate func fontNightModeTapped(_ sender: AnyObject) {
        isFontNightMode = 2 //true
        //btnFontNightMode.setImage(UIImage(named: "ic_paper1-1"), for: .normal)
        //btnFontDefaultMode.setImage(UIImage(named: "ic_paper3"), for: .normal)
        //btnFontMiddleMode.setImage(UIImage(named: "ic_paper2"), for: .normal)
        btnFontNightMode.layer.borderWidth = 1
        btnFontDefaultMode.layer.borderWidth = 0
        btnFontNightMode.layer.borderColor = UIColor(red: 13.0/255.0, green: 83.0/255.0, blue: 78.0/255.0, alpha: 1.0).cgColor
    }
    
    @IBAction fileprivate func fontDefaultModeTapped(_ sender: AnyObject) {
        isFontNightMode = 1 //false
        btnFontDefaultMode.layer.borderWidth = 1
        btnFontNightMode.layer.borderWidth = 0
        btnFontDefaultMode.layer.borderColor = UIColor(red: 13.0/255.0, green: 83.0/255.0, blue: 78.0/255.0, alpha: 1.0).cgColor
        
        //btnFontNightMode.setImage(UIImage(named: "ic_paper1"), for: .normal)
        //btnFontDefaultMode.setImage(UIImage(named: "ic_paper3-1"), for: .normal)
        //btnFontMiddleMode.setImage(UIImage(named: "ic_paper2"), for: .normal)
    }
    
    @IBAction func fontMiddleModeTapped(_ sender: Any) {
        isFontNightMode = 3
        //btnFontNightMode.setImage(UIImage(named: "ic_paper1"), for: .normal)
        //btnFontDefaultMode.setImage(UIImage(named: "ic_paper3"), for: .normal)
        //btnFontMiddleMode.setImage(UIImage(named: "ic_paper2-1"), for: .normal)
    }
    //MARK:- Comment View Actions
    @IBAction func commentDoneTapped(_ sender: AnyObject) {
        view.endEditing(true)
        
        collectionView.setContentOffset(CGPoint.zero, animated: true)
        
        UIView.animate(withDuration: 0.25, animations: { 
            self.viewComment.alpha = 0.0
            self.viewDone.alpha = 0.0
        }) 
        if tvComment.text == "" {
            tvComment.text = "."
        }
        let parameters = ["UserId": RealmHelper.getLoggedinUser()!.userID, "BookID": self.currentBook!.bookID, "Comment": tvComment.text!, "Rate": "\(bookRate)"]
        
        ApiManager.sharedInstance.finishBook(parameters as [String : AnyObject]?, onSuccess: { (array) in
            self.commentFlag = true
            print("finish a book success")
            self.dismiss(animated: true, completion: nil)
            }, onFailure: { (error) in
                print(error.description)
            }, loadingViewController: nil)
    }
    
    @IBAction func starTapped(_ sender: AnyObject) {
        btnCommentS1.setBackgroundImage(UIImage(named: "Star_copie_3_copy_6"), for: UIControlState())
        btnCommentS2.setBackgroundImage(UIImage(named: "Star_copie_3_copy"), for: UIControlState())
        btnCommentS3.setBackgroundImage(UIImage(named: "Star_copie_3_copy"), for: UIControlState())
        btnCommentS4.setBackgroundImage(UIImage(named: "Star_copie_3_copy"), for: UIControlState())
        btnCommentS5.setBackgroundImage(UIImage(named: "Star_copie_3_copy"), for: UIControlState())
        
        bookRate = 1
    }
    
    @IBAction func starTowTapped(_ sender: AnyObject) {
        btnCommentS1.setBackgroundImage(UIImage(named: "Star_copie_3_copy_6"), for: UIControlState())
        btnCommentS2.setBackgroundImage(UIImage(named: "Star_copie_3_copy_6"), for: UIControlState())
        btnCommentS3.setBackgroundImage(UIImage(named: "Star_copie_3_copy"), for: UIControlState())
        btnCommentS4.setBackgroundImage(UIImage(named: "Star_copie_3_copy"), for: UIControlState())
        btnCommentS5.setBackgroundImage(UIImage(named: "Star_copie_3_copy"), for: UIControlState())
        
        bookRate = 2
    }
    
    @IBAction func starThreeTapped(_ sender: AnyObject) {
        btnCommentS1.setBackgroundImage(UIImage(named: "Star_copie_3_copy_6"), for: UIControlState())
        btnCommentS2.setBackgroundImage(UIImage(named: "Star_copie_3_copy_6"), for: UIControlState())
        btnCommentS3.setBackgroundImage(UIImage(named: "Star_copie_3_copy_6"), for: UIControlState())
        btnCommentS4.setBackgroundImage(UIImage(named: "Star_copie_3_copy"), for: UIControlState())
        btnCommentS5.setBackgroundImage(UIImage(named: "Star_copie_3_copy"), for: UIControlState())
        
        bookRate = 3
    }
    
    @IBAction func starFourTapped(_ sender: AnyObject) {
        btnCommentS1.setBackgroundImage(UIImage(named: "Star_copie_3_copy_6"), for: UIControlState())
        btnCommentS2.setBackgroundImage(UIImage(named: "Star_copie_3_copy_6"), for: UIControlState())
        btnCommentS3.setBackgroundImage(UIImage(named: "Star_copie_3_copy_6"), for: UIControlState())
        btnCommentS4.setBackgroundImage(UIImage(named: "Star_copie_3_copy_6"), for: UIControlState())
        btnCommentS5.setBackgroundImage(UIImage(named: "Star_copie_3_copy"), for: UIControlState())
        
        bookRate = 4
    }
    
    @IBAction func starFiveTapped(_ sender: AnyObject) {
        btnCommentS1.setBackgroundImage(UIImage(named: "Star_copie_3_copy_6"), for: UIControlState())
        btnCommentS2.setBackgroundImage(UIImage(named: "Star_copie_3_copy_6"), for: UIControlState())
        btnCommentS3.setBackgroundImage(UIImage(named: "Star_copie_3_copy_6"), for: UIControlState())
        btnCommentS4.setBackgroundImage(UIImage(named: "Star_copie_3_copy_6"), for: UIControlState())
        btnCommentS5.setBackgroundImage(UIImage(named: "Star_copie_3_copy_6"), for: UIControlState())
        
        bookRate = 5
    }
    
    //MARK:- Targets
    @objc fileprivate func viewTapped() {
        view.removeGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
        
        UIView.animate(withDuration: 0.25, animations: {
            self.viewFont.alpha = 0.0
            //self.btnFont.setImage(UIImage(named: "ic_aa"), for: .normal)
            
           })
    }
    
}

extension BookDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        layout : UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return papers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let myCell = cell as? BookDetailsCollectionViewCell else { return }
        
        myCell.textViewOffset = currentTextViewOffset
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let myCell = cell as? BookDetailsCollectionViewCell else { return }
        
        currentTextViewOffset = myCell.textViewOffset
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookDetailsCollectionViewCell", for: indexPath) as! BookDetailsCollectionViewCell
        
        let currentPaper = papers[indexPath.row]
        
        print(currentBook!.hasAudio)
                
//        let strTitle = NSMutableAttributedString(string: currentPaper.title,
//                                                   attributes: [ NSFontAttributeName: UIFont.boldSystemFont(ofSize: 20) ])
//        
//        strTitle.append(NSMutableAttributedString(string: currentPaper.body,
//                                                                      attributes: [ NSFontAttributeName: UIFont.systemFontSize]))
//        //let textToDisplay = currentPaper.title + "\n\n" + currentPaper.body
        let bodyString =  currentPaper.body as NSString
        let newBodyString = bodyString.replacingOccurrences(of: ".", with: ".\n\n")
        let newBodyString1 =  newBodyString.replacingOccurrences(of: "?", with: "?\n\n")
        let newBodyString2 =  newBodyString1.replacingOccurrences(of: "!", with: "!\n\n")
        let string = ("\n\n"+currentPaper.title + "\n\n" + newBodyString2 + "\n\n") as NSString
        
        let attributedString = NSMutableAttributedString(string: string as String, attributes: [NSFontAttributeName:UIFont(name: "DroidArabicKufi", size: currentFontSize) ?? UIFont.systemFont(ofSize: currentFontSize)])
        
        let boldFontAttribute = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: currentFontSize+5.0)]
        
        // Part of string to be bold
        attributedString.addAttributes(boldFontAttribute, range: string.range(of: currentPaper.title))
        cell.textView.attributedText = attributedString
        cell.textView.textAlignment = .right
        //cell.textView.font = UIFont(name: "DroidArabicKufi", size: currentFontSize)!
        switch isFontNightMode
        {
        case 1:
            cell.contentView.backgroundColor = UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 1.0)
            cell.textView.backgroundColor = UIColor.black
            cell.textView.textColor = UIColor.white
            break
        case 2:
            cell.backgroundColor = UIColor.white
            cell.textView.backgroundColor = UIColor.white
            cell.textView.textColor = UIColor.black
            break
            
        case 3:
            cell.contentView.backgroundColor = UIColor(red: 230.0/255.0, green: 221.0/255.0, blue: 221.0/255.0, alpha: 1.0)
            cell.textView.backgroundColor = UIColor(red: 230.0/255.0, green: 221.0/255.0, blue: 221.0/255.0, alpha: 1.0)
            cell.textView.textColor = UIColor(red: 132.0/255.0, green: 112.0/255.0, blue: 112.0/255.0, alpha: 1.0)

            break
        default:
            break
        }
//        if isFontNightMode == true {
//            
//        } else {
//            cell.backgroundColor = UIColor.white
//            cell.textView.backgroundColor = UIColor.white
//            cell.textView.textColor = UIColor.black
//        }
//        
        //TODO: scrolling pages logic
        textView = cell.textView!
        cell.textView.setContentOffset(CGPoint.zero, animated: false)
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pageNumberView.frame.size.width = scrollView.contentOffset.x  / CGFloat(papers.count - 1)
        self.pageNumberView.frame.origin.x = screenWidth - scrollView.contentOffset.x  / CGFloat(papers.count - 1)
        pageNumberView.mirrorMe()
        
        currentPaperIndex = Int(self.collectionView.contentOffset.x) / Int(self.collectionView.frame.size.width)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let triggerTime = (Int64(NSEC_PER_MSEC) * 250)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
            
            
            
            let rightEdge = scrollView.contentOffset.x + scrollView.frame.size.width
            
            if rightEdge >= scrollView.contentSize.width {
                // we are at the end
                UIView.animate(withDuration: 0.25, animations: {
                    self.viewDone.alpha = 1.0
                   
                })
            } else {
                UIView.animate(withDuration: 0.25, animations: {
                    self.viewDone.alpha = 0.0
                })
            }
//
            // page tip
            let visibleCellIndexPath = self.collectionView.indexPathsForVisibleItems[0]
            
            if visibleCellIndexPath.row == 0 {
                self.viewPageTip.frame.origin.x = screenWidth - self.viewPageTip.frame.width
            } else if visibleCellIndexPath.row == self.papers.count - 1 {
                self.viewPageTip.frame.origin.x = 0
            } else {
                self.viewPageTip.frame.origin.x = screenWidth - self.pageNumberView.frame.size.width - (self.viewPageTip.frame.size.width / 2)
            }
            
            NewAudioManager.sharedInstance.rowToSelectAudioFile = visibleCellIndexPath.row
            
            self.lblCurrentPage.text = "\(visibleCellIndexPath.row + 1)"
            if rightEdge != 0 || rightEdge != scrollView.contentSize.width {
                UIView.animate(withDuration: 0.25, animations: {
                    self.viewPageTip.alpha = 1.0
                    }, completion: { _ in
                        UIView.animate(withDuration: 0.25, delay: 1.0, options: .curveEaseIn, animations: {
                            self.viewPageTip.alpha = 0.0
                            }, completion: nil)
                })
            }
            
            if NewAudioManager.sharedInstance.partName != nil {
                NewAudioManager.sharedInstance.rowToSelectAudioFile = visibleCellIndexPath.row
                let currentPaper = self.papers[NewAudioManager.sharedInstance.rowToSelectAudioFile]
                
                NewAudioManager.sharedInstance.partName = "المقطع \(NewAudioManager.sharedInstance.rowToSelectAudioFile + 1)"
                self.isFromFinishedAudio = false
                NewAudioManager.sharedInstance.jukebox.play(atIndex: NewAudioManager.sharedInstance.rowToSelectAudioFile)
               // NewAudioManager.sharedInstance.jukebox.delegate = self
                
                //self.addAudioPlayerNib()
            }
            
            //        if isAudioPlaying {
            //            let currentPaper = papers[visibleCellIndexPath.row]
            //            let audioUrlString = "\(NSHomeDirectory())/Documents/\(currentPaper.audioID)"
            //
            //            if let audioUrl = NSURL(string: audioUrlString) {
            //                play(audioUrl)
            //            }
            //        }
            
            // call api to set current paper...
            let parameters = ["UserId": RealmHelper.getLoggedinUser()!.userID, "BookID": self.currentBook!.bookID, "PageNumber": "\(self.currentPaperIndex + 1)"]
            
            let realm = try! Realm()
            
            try! realm.write {
                let book = realm.object(ofType: Book.self, forPrimaryKey: self.currentBook?.bookID)
                book?.userCurrentPage = self.currentPaperIndex + 1
                book?.progress = self.currentPaperIndex + 1
                realm.add(book!, update: true)
                
            }
            
//            self.currentBook?.userCurrentPage = self.currentPaperIndex + 1
//            self.currentBook?.progress = self.currentPaperIndex + 1

            ApiManager.sharedInstance.setBookCuurrentPage(parameters as [String : AnyObject]?, onSuccess: { (array) in
                print("setBookCuurrentPage successed")
                
                
            }, onFailure: { (error) in
                    print(error.description)
                }, loadingViewController: nil)
        })
    }
    
    
    
    
    
    
    //MARK:- Delegate New Audio
    override func jukeboxDidLoadItem(_ jukebox: Jukebox, item: JukeboxItem) {
        print("Jukebox did load: \(item.URL.lastPathComponent)")
    }
    
    
    override func jukeboxStateDidChange(_ jukebox: Jukebox) {
        
        print("Jukebox state changed to \(jukebox.state)")
    }
    
    override func jukeboxFinished() {
        print("BookDetailsViewController finished...")
        if isFromFinishedAudio {
            if NewAudioManager.sharedInstance.rowToSelectAudioFile < papers.count - 1 {
                NewAudioManager.sharedInstance.rowToSelectAudioFile = NewAudioManager.sharedInstance.rowToSelectAudioFile + 1
                let currentPaper = papers[NewAudioManager.sharedInstance.rowToSelectAudioFile]
                NewAudioManager.sharedInstance.partName = "المقطع \(NewAudioManager.sharedInstance.rowToSelectAudioFile + 1)"
                
                
                
                let indexPath = IndexPath(item: NewAudioManager.sharedInstance.rowToSelectAudioFile, section: 0)
                self.collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: true)
                
                if NewAudioManager.sharedInstance.rowToSelectAudioFile == papers.count - 1 {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.viewDone.alpha = 1.0
//                        var rect:CGRect = self.textView.frame
//                        rect.origin.y = -self.viewDone.frame.size.height
//                        self.textView.frame = rect
//                        self.textView.setContentOffset(CGPoint(x:0,y:-self.viewDone.frame.size.height), animated: true)

                    })
                }
                
                //addAudioPlayerNib()
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "AudioDidFinish"), object: self)
            } else {
                NewAudioManager.sharedInstance.rowToSelectAudioFile = -1
                //isAudioPlaying = false
            }
        }else{
            isFromFinishedAudio = true
        }
        
    }
    override func jukeboxDidUpdateMetadata(_ jukebox: Jukebox, forItem: JukeboxItem) {
        print("Item updated:\n\(forItem)")
    }
}

extension BookDetailsViewController: BookPapersListViewControllerDelegate {
    func BookPapersListViewControllerTableViewDidSelect(_ row: Int, isPaper: Bool) {
        // call api to set current paper...
        let parameters = ["UserId": RealmHelper.getLoggedinUser()!.userID, "BookID": currentBook!.bookID, "PageNumber": "\(row + 1)"]
        
        
        ApiManager.sharedInstance.setBookCuurrentPage(parameters as [String : AnyObject]?, onSuccess: { (array) in
            print("setBookCuurrentPage successed")
            
            do {
                let realm = try Realm()
                try! realm.write {
                    self.currentBook?.userCurrentPage = row + 1
                }
            } catch {
                
            }
            
                
            }, onFailure: { (error) in
                print(error.description)
            }, loadingViewController: nil)
        
        
        let currentIndex = row
       
        let indexPath = IndexPath(item: currentIndex, section: 0)
        
        
        if NewAudioManager.sharedInstance.jukebox.state == .playing {
            NewAudioManager.sharedInstance.jukebox.play(atIndex: currentIndex)
        }else if NewAudioManager.sharedInstance.jukebox.state == .paused {
            NewAudioManager.sharedInstance.jukebox.play(atIndex: currentIndex)
            NewAudioManager.sharedInstance.jukebox.pause()
        }
        collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: false)
        collectionView.reloadData()
        
        
        
        if row == papers.count - 1 {
            UIView.animate(withDuration: 0.25, animations: {
                self.viewDone.alpha = 1.0
                
            })
        }else{
            UIView.animate(withDuration: 0.25, animations: {
                self.viewDone.alpha = 0.0
                
            })

        }
        
        
    }
}

//MARK:- Audio
extension BookDetailsViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("end")
        
        if AudioPlayer.sharedInstance.rowToSelectAudioFile < papers.count - 1 {
            AudioPlayer.sharedInstance.rowToSelectAudioFile = AudioPlayer.sharedInstance.rowToSelectAudioFile + 1
            let currentPaper = papers[AudioPlayer.sharedInstance.rowToSelectAudioFile]
            let audioUrlString = "\(NSHomeDirectory())/Documents/\(currentPaper.audioID)"
            
            AudioPlayer.sharedInstance.partName = "المقطع \(AudioPlayer.sharedInstance.rowToSelectAudioFile + 1)"
            
            if let audioUrl = URL(string: audioUrlString) {
                AudioPlayer.sharedInstance.play(audioUrl)
            }
            
            AudioPlayer.sharedInstance.player?.delegate = self
            
            let indexPath = IndexPath(item: AudioPlayer.sharedInstance.rowToSelectAudioFile, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: true)
            
            if AudioPlayer.sharedInstance.rowToSelectAudioFile == papers.count - 1 {
                UIView.animate(withDuration: 0.25, animations: {
                    self.viewDone.alpha = 1.0
//                    var rect:CGRect = self.textView.frame
//                    rect.origin.y = -self.viewDone.frame.size.height
//                    self.textView.frame = rect
//                    self.textView.setContentOffset(CGPoint(x:0,y:-self.viewDone.frame.size.height), animated: true)

                })
            }
            
            //addAudioPlayerNib()
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "AudioDidFinish"), object: self)
        } else {
            AudioPlayer.sharedInstance.rowToSelectAudioFile = -1
            //isAudioPlaying = false
        }
    }
}

extension String {
    func heightWithConstrainedWidth(_ width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
}
