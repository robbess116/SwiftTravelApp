//
//  LibraryViewController.swift
//  Aqsar
//
//  Created by moayad on 7/31/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit
import BRYXBanner
import RealmSwift

enum LibrarySelectionType: Int {
    case unread = 0, inProgress, finished
}

class LibraryViewController: BaseViewController {
    //MARK:- IBOutlets
    @IBOutlet weak fileprivate var btnDidRead: UIButton!
    @IBOutlet weak fileprivate var btnToRead: UIButton!
    @IBOutlet weak fileprivate var viewSeperator: UIView!
    @IBOutlet weak fileprivate var tableView: UITableView!
    
    @IBOutlet weak var viewOneDay: UIView!
    @IBOutlet weak var viewBackground: UIView!
    
    @IBOutlet weak var conHeight: NSLayoutConstraint!
    fileprivate var refreshControl: UIRefreshControl!
    
    //MARK:- IVars
    fileprivate let animatableButtonsView = UIView()
    fileprivate let defaultButtonsColor = UIColor(red: 105.0/255.0, green: 105.0/255.0, blue: 105.0/255.0, alpha: 1.0)
    fileprivate let selectedButtonsColor = UIColor(red: 248/255.0, green: 248/255.0, blue: 248/255.0, alpha: 1.0)

    
    fileprivate var checkingPaymentBeforeOneDay = Timer()
    
    // filter
    fileprivate var selectedType: LibrarySelectionType = .unread
    fileprivate var filterView:LibraryFilterView?
    fileprivate var selectedFilterRow = 0
    
    fileprivate var unReadBooks = [Book]()
    fileprivate var inProgressBooks = [Book]()
    
    fileprivate var isViewDidAppear = false
    
    fileprivate var selectedRow = 0
    
    fileprivate var isDidReadTapped = false
    
    // api
    fileprivate var pageNumberForUnread = 1
    fileprivate var pageNumberForInProgress = 1
    //private var booksTotalCountsFromServer = 0
    fileprivate var nextWaveForUnread = 0
    fileprivate var nextWaveForInProgress = 0
    
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "AudioPlayerCell", bundle: nil), forCellReuseIdentifier: "AudioPlayerCell")
        
        setUpAnimatableButtonsView()
        
        tableView.register(UINib(nibName: "MyAccountDoneReadingCell", bundle: nil), forCellReuseIdentifier: "MyAccountDoneReadingCell")
        
//        getAndDisplayUserBooks(0, pageNumber: pageNumberForUnread)
        
        // pull to refresh setup
        refreshControl = UIRefreshControl()
        //refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        refreshControl.tintColor = darkGreen
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        
        // checking payment before one day
        checkingPaymentBeforeOneDay = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(checkSubscriptiobAvalabilityBeforeOneDay), userInfo: nil, repeats: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        UIApplication.shared.isStatusBarHidden = false
            
        setUpNavigationBar()
        
        addAudioPlayerNib()
        if let _ = AudioPlayer.sharedInstance.partName {
            conHeight.constant = 60
        } else {
            conHeight.constant = 0
        }
        
        // imlemented in the base viewcontroller
        //CheckSub
        checkSubscriptionAvailability()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.statusBarStyle = .default
        getAndDisplayUserBooks(selectedType.rawValue, pageNumber: pageNumberForUnread)
        tableView.reloadData()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem =
            UIBarButtonItem(image:UIImage(named: "483._Back"), style:.plain, target:self, action:#selector(poped))
        
        //UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
    
    //MARK:- Navigation
    fileprivate func setUpNavigationBar() {
        
        //title = "اكتشف"
        let attributes = [NSFontAttributeName: UIFont(name: "DroidArabicKufi", size: 17)!, NSForegroundColorAttributeName: darkGreen]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
        navigationController?.navigationBar.tintColor = darkGreen
        self.navigationItem.leftBarButtonItem?.tintColor = darkGreen
        
        self.navigationItem.leftBarButtonItem =
            UIBarButtonItem(image:UIImage(named: "276._Filter"), style:.plain, target:self, action:#selector(filterTapped))
        
//        self.navigationItem.rightBarButtonItem =
//            UIBarButtonItem(image:UIImage(named: "magnifier"), style:.Plain, target:self, action:#selector(searchTapped))
    }
    
    //MARK:- APIs
    fileprivate func getAndDisplayUserBooks(_ status: Int, pageNumber: Int) {

        //CheckSub
        if checkSubscriptionAvailability() == false {
            return
        }
        
        if Reachability.isConnectedToNetwork() == false {
            //showNetowrkNoConnectivityAlertController()
            self.unReadBooks.removeAll()
            self.inProgressBooks.removeAll()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                for book in (RealmHelper.getLoggedinUser()?.booksInProgress)! {
                    self.inProgressBooks.append(book)
                    
                }
                
                for book in (RealmHelper.getLoggedinUser()?.booksUnread)! {
                    
                    self.unReadBooks.append(book)
                    
                }
                
                self.tableView.reloadData()
                
 
//            }
            return
            
        }
        
        print(RealmHelper.getLoggedinUser()!.userID)
        let parameters = ["UserID": RealmHelper.getLoggedinUser()!.userID, "PageNo": "\(pageNumber)", "PageSize": "10", "Status": "\(status)","filterBy":"\(self.selectedFilterRow)"]
        
        ApiManager.sharedInstance.getUserLibrary(parameters as [String : AnyObject]?, onSuccess: { userBooks in
            if let unwrappedUserBooks = userBooks {
                self.unReadBooks.removeAll()
                self.inProgressBooks.removeAll()
                
                if self.selectedType == .unread {
                    //self.nextWaveForUnread = (unwrappedUserBooks.table?.count)!
                    print(self.nextWaveForUnread)
                    for book in unwrappedUserBooks.table! {
                        self.unReadBooks.append(book)
                    }
                    self.nextWaveForUnread = self.unReadBooks.count
                    let realm = try! Realm()
                    try! realm.write {
                       for book in unwrappedUserBooks.table! {
                            if realm.object(ofType: Book.self, forPrimaryKey: book.bookID) != nil {
                                
                                continue
                            }else{
                                
                                RealmHelper.getLoggedinUser()!.booksUnread.append(book)
                            }
                            
                        }
                        
                        realm.add(RealmHelper.getLoggedinUser()!, update: true)
                    }
                } else if self.selectedType == .inProgress {
                    //self.nextWaveForInProgress = (unwrappedUserBooks.table?.count)!
                    print(self.nextWaveForInProgress)
                    for book in unwrappedUserBooks.table! {
                        self.inProgressBooks.append(book)
                    }
                    self.nextWaveForInProgress = self.inProgressBooks.count
                    
                    let realm = try! Realm()
                    try! realm.write {
                        for book in self.inProgressBooks {
                            if realm.object(ofType: Book.self, forPrimaryKey: book.bookID) != nil{
                                continue
                            }else{
                                RealmHelper.getLoggedinUser()!.booksInProgress.append(book)
                                self.getAndDisplayPapers(bookId: book.bookID)

                            }

                        }
                        
                        realm.add(RealmHelper.getLoggedinUser()!, update: true)
                        
                    }
                }
            }
            
            self.tableView.reloadData()

            }, onFailure: { (error) in
                print(error.description)
            }, loadingViewController: self)
    }
    
    fileprivate func getAndDisplayPapers(bookId: String) {
        if !Reachability.isConnectedToNetwork() {
            
            return
        }
       
            
        let parameters = ["BookID": "\(bookId)"]
        
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
                    
                    
                }
                
                
                
                if let bookUnread = RealmHelper.getLoggedinUser()?.booksUnread.filter("bookID == \"\(bookId)\"").first {
                    cachPapers(bookUnread)
                } else if let bookInProgress = RealmHelper.getLoggedinUser()?.booksInProgress.filter("bookID == \"\(bookId)\"").first {
                    cachPapers(bookInProgress)
                } else if let bookFinished = RealmHelper.getLoggedinUser()?.booksFinished.filter("bookID == \"\(bookId)\"").first {
                    cachPapers(bookFinished)
                } else if let bookFavorite = RealmHelper.getLoggedinUser()?.booksFavorites.filter("bookID == \"\(bookId)\"").first {
                    cachPapers(bookFavorite)
                }
                
            }
        }, onFailure: { (error) in
            print(error.description)
        }, loadingViewController: nil)
        
      
        
        
    }

    func refresh() {
        if Reachability.isConnectedToNetwork() == false {
            showNetowrkNoConnectivityAlertController()
            self.refreshControl.endRefreshing()
            return
        }
        
        let tempStatus = selectedType == .unread ? 0 : 1
        
        print(RealmHelper.getLoggedinUser()!.userID)
        let parameters = ["UserID": RealmHelper.getLoggedinUser()!.userID, "PageNo": "1", "PageSize": "10", "Status": "\(tempStatus)","filterBy":"\(self.selectedFilterRow)"]
        
        ApiManager.sharedInstance.getUserLibrary(parameters as [String : AnyObject]?, onSuccess: { userBooks in
            if let unwrappedUserBooks = userBooks {
                if self.selectedType == .unread {
                    self.nextWaveForUnread = (unwrappedUserBooks.table?.count)!
                    print(self.nextWaveForUnread)
                    self.unReadBooks = unwrappedUserBooks.table!
                    self.pageNumberForUnread = 1
                } else if self.selectedType == .inProgress {
                    self.nextWaveForInProgress = (unwrappedUserBooks.table?.count)!
                    self.inProgressBooks = unwrappedUserBooks.table!
                    self.pageNumberForInProgress = 1
                }
            }
            
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            
            }, onFailure: { (error) in
                print(error.description)
            }, loadingViewController: nil)
    }
    
    func getBooksByFilter(_ status: Int, pageNumber: Int) {
        if Reachability.isConnectedToNetwork() == false {
            showNetowrkNoConnectivityAlertController()
            self.refreshControl.endRefreshing()
            return
        }
        
        print(RealmHelper.getLoggedinUser()!.userID)
        let parameters = ["UserID": RealmHelper.getLoggedinUser()!.userID, "PageNo": "\(pageNumber)", "PageSize": "10", "Status": "\(status)","filterBy":"\(self.selectedFilterRow)"]
        
        ApiManager.sharedInstance.getBooksByFilter(parameters as [String : AnyObject]?, onSuccess: { userBooks in
            if let unwrappedUserBooks = userBooks {
                self.unReadBooks.removeAll()
                self.inProgressBooks.removeAll()
                
                if self.selectedType == .unread {
                    //self.nextWaveForUnread = (unwrappedUserBooks.table?.count)!
                    
                    for book in unwrappedUserBooks.table! {
                        self.unReadBooks.append(book)
                    }
                    self.nextWaveForUnread = self.unReadBooks.count
                    
                    let realm = try! Realm()
                    try! realm.write {

                        for book in unwrappedUserBooks.table! {
                            if realm.object(ofType: Book.self, forPrimaryKey: book.bookID) != nil {
                                
                                continue
                            }else{
                                
                                RealmHelper.getLoggedinUser()!.booksUnread.append(book)
                            }
                        }
                        
                        realm.add(RealmHelper.getLoggedinUser()!, update: true)
                    }
                } else if self.selectedType == .inProgress {
                    //self.nextWaveForInProgress = (unwrappedUserBooks.table?.count)!
                    
                    for book in unwrappedUserBooks.table! {
                        self.inProgressBooks.append(book)
                    }
                    self.nextWaveForInProgress = self.inProgressBooks.count
                    
                    let realm = try! Realm()
                    try! realm.write {
                        
                        for book in self.inProgressBooks {
                            if realm.object(ofType: Book.self, forPrimaryKey: book.bookID) != nil {
                                
                                continue
                            }else{
                                
                                RealmHelper.getLoggedinUser()!.booksInProgress.append(book)
                            }
                           
                        }
                        
                        realm.add(RealmHelper.getLoggedinUser()!, update: true)
                        
                    }
                }
            }
            
            
            self.tableView.reloadData()
            
        }, onFailure: { (error) in
            print(error.description)
        }, loadingViewController: self)
    }
    
    //MARK:- Audio Player
    override func closeDidTap() {
        super.closeDidTap()
        conHeight.constant = 0
    }
    
    //MARK:- Targets
    @objc fileprivate func filterTapped() {
        func addAndAnimateMenu() {
            //UIApplication.sharedApplication().keyWindow?.addSubview(filterView!)
            view.addSubview(filterView!)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.filterView?.frame.origin.y = screenHeight - 210 - 49
            }) 
            
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let subscriptionVC = storyboard.instantiateViewController(withIdentifier: "SubscriptionViewController") as! SubscriptionViewController
//            present(subscriptionVC, animated: true, completion: nil)
        }
        
        if let _ = filterView {
            addAndAnimateMenu()
            if let filterMenu = filterView {
                filterMenu.selectedRow = selectedFilterRow
                filterMenu.tableView.reloadData()
            }
            
        } else {
            filterView = LibraryFilterView.instanceFromNib()
            
            filterView?.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: 210)
            
            if let menu = filterView {
                menu.delegate = self
                menu.selectedRow = selectedFilterRow
            }
            
            addAndAnimateMenu()
        }
    }
    
    @objc fileprivate func searchTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let searchVC = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        
        present(searchVC, animated: true, completion: nil)
    }
    
    @objc fileprivate func poped() {
        navigationController?.popViewController(animated: true)
    }
    
    func checkSubscriptiobAvalabilityBeforeOneDay() {
        print(RealmHelper.getLoggedinUser()!.subscriptionEndDate)
        
        let str = RealmHelper.getLoggedinUser()!.subscriptionEndDate
        let readableDate = str[str.characters.index(str.startIndex, offsetBy: 0)...str.characters.index(str.startIndex, offsetBy: 9)]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        //dateFormatter.timeZone = NSTimeZone(name: "UTC")
        let userSubscriptionDate = dateFormatter.date(from: readableDate)
        
        // by default userSubscriptionDate is minus 1 day, that's why im adding another one...
        if userSubscriptionDate! == Date() {
            let ad = UIApplication.shared.delegate as! AppDelegate
            
            viewBackground.frame = UIScreen.main.bounds
            viewBackground.alpha = 0.0
            //view.addSubview(viewBackground)
            ad.window?.addSubview(viewBackground)
            
            viewOneDay.frame = CGRect(x: 0, y: 0, width: 300, height: 257)
            viewOneDay.center = view.center
            //viewOneDay.alpha = 0.0
            viewOneDay.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            //view.addSubview(viewOneDay)
            ad.window?.addSubview(viewOneDay)
            
            
            
            UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 3.0, options: .curveEaseIn, animations: {
                self.viewBackground.alpha = 0.8
                self.viewOneDay.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }, completion: nil)
            
            checkingPaymentBeforeOneDay.invalidate()
        }
    }
    
    //MARK:- IBActions
    @IBAction func toReadTapped(_ sender: AnyObject) {
        btnToRead.setTitleColor(darkGreen, for: UIControlState())
        btnDidRead.setTitleColor(defaultButtonsColor, for: UIControlState())
        
        btnDidRead.backgroundColor = selectedButtonsColor
        btnToRead.backgroundColor = UIColor.white

        //animateButtonsView(toX: screenWidth / 2)
        
        selectedType = .inProgress
        tableView.reloadData()
        
        if isDidReadTapped == false {
            isDidReadTapped = true
            getAndDisplayUserBooks(1, pageNumber: pageNumberForInProgress)
            //getAndDisplayUserBooks(0, pageNumber: pageNumberForUnread)
        } else {
            tableView.reloadData()
        }
    }
    
    @IBAction func didReadTapped(_ sender: AnyObject) {
        btnToRead.setTitleColor(defaultButtonsColor, for: UIControlState())
        btnDidRead.setTitleColor(darkGreen, for: UIControlState())
        btnToRead.backgroundColor = selectedButtonsColor
        btnDidRead.backgroundColor = UIColor.white
        //animateButtonsView(toX: 0)
        
        selectedType = .unread
        tableView.reloadData()
        if isDidReadTapped == true {
            isDidReadTapped = false
            getAndDisplayUserBooks(0, pageNumber: pageNumberForUnread)
        } else {
            tableView.reloadData()
        }
        
    }
    
    
    @IBAction fileprivate func oneDayDialogTapped(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.25, animations: {
            self.viewOneDay.alpha = 0.0
            self.viewBackground.alpha = 0.0
            }, completion: { _ in
                self.viewOneDay.removeFromSuperview()
                self.viewBackground.removeFromSuperview()
        }) 
    }
    
    //MARK:- UI
    fileprivate func setUpAnimatableButtonsView() {
        //animatableButtonsView.frame = CGRect(x: screenWidth / 2, y: viewSeperator.frame.origin.y - 2, width: screenWidth / 2, height: 2)
        animatableButtonsView.frame = CGRect(x: 0, y: viewSeperator.frame.origin.y - 2, width: screenWidth / 2, height: 2)
        
        animatableButtonsView.backgroundColor = darkGreen
//        view.addSubview(animatableButtonsView)
        
        //btnDidRead.setTitleColor(defaultButtonsColor, forState: .Normal)
        btnToRead.setTitleColor(defaultButtonsColor, for: UIControlState())
    }
    
    //MARK:- Animation
    fileprivate func animateButtonsView(toX: CGFloat) {
        UIView.animate(withDuration: 0.25, animations: {
            self.animatableButtonsView.frame.origin.x = toX
        }) 
    }

}


extension LibraryViewController:UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        func showNoBooksLabel(_ selectedType: LibrarySelectionType) {
            removeNoBooksLabel()
            
            let label = UILabel(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: screenWidth, height: 50)))
            label.center = centerOfScreen
            label.tag = 120
            label.textColor = darkGreen
            label.textAlignment = .center
            label.font = UIFont(name: "DroidArabicKufi", size: 14)!
            
            if selectedType == .inProgress {
                label.text = "لا يوجد كتب جاري قرائتها حاليا"
            } else if selectedType == .unread {
                label.text = "لا يوجد كتب سيتم قرائتها حاليا"
            }
            
            view.addSubview(label)
        }
        
        func removeNoBooksLabel() {
            if let labelIfExist = view.viewWithTag(120) {
                labelIfExist.removeFromSuperview()
            }
        }
        
        switch selectedType {
        case .unread:
            if unReadBooks.count == 0 {
                showNoBooksLabel(.unread)
            } else {
                removeNoBooksLabel()
            }
            
            return unReadBooks.count
            
        case .inProgress:
            if inProgressBooks.count == 0 {
                showNoBooksLabel(.inProgress)
            } else {
                removeNoBooksLabel()
            }
            
            return inProgressBooks.count
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if selectedType == .unread {
            print(nextWaveForUnread)
            if unReadBooks.count - 1 == indexPath.row && nextWaveForUnread >= 10 {
                pageNumberForUnread = pageNumberForUnread + 1
                
                 getAndDisplayUserBooks(0, pageNumber: pageNumberForUnread)
                
                
                
            }
        } else if selectedType == .inProgress {
            print(pageNumberForInProgress)
            if inProgressBooks.count - 1 == indexPath.row && nextWaveForInProgress >= 10 {
                pageNumberForInProgress = pageNumberForInProgress + 1
                getAndDisplayUserBooks(1, pageNumber: pageNumberForInProgress)
                
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch selectedType {
        case .unread:

            let cell = tableView.dequeueReusableCell(withIdentifier: "MyAccountDoneReadingCell") as! MyAccountDoneReadingCell
            cell.forLibrary = true
            
            cell.hideSwipeOptions()
            
            let remove = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
            remove.tag = indexPath.row
            remove.setImage(UIImage(named: "cross-1"), for: UIControlState())
            remove.backgroundColor = UIColor(red: 239.0/255.0, green: 239.0/255.0, blue: 239.0/255.0, alpha: 1.0)
            remove.addTarget(self, action: #selector(removeTappedFromFavorites), for: .touchUpInside)
            
            let addToFavorites = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
            addToFavorites.tag = indexPath.row
            addToFavorites.setImage(UIImage(named: "favorite_plus"), for: UIControlState())
            addToFavorites.backgroundColor = darkGreen
            
            addToFavorites.addTarget(self, action: #selector(addTappedFromFavorites), for: .touchUpInside)
            
            cell.leftButtons = [remove, addToFavorites]
            
//            cell.removeFavoriteButton?.tag = indexPath.row
//            cell.removeFavoriteButton!.addTarget(self, action: #selector(removeTappedFromFavorites(_:)), forControlEvents: .TouchUpInside)
            
            
            let currentBook = unReadBooks[indexPath.row]
            
            print("Has Audio .... \(currentBook.hasAudio)")
            cell.updateView(book: currentBook)
            cell.lblName.text = currentBook.title
            cell.lblDate.text = "2/12/2015"
            cell.lblAuthor.text = currentBook.author
            cell.lblBrief.text = currentBook.summary
            cell.lblNOViews.text = "12"
            cell.lblNOComments.text = "43"
            
            cell.lblTotalPagesCount.isHidden = true
            cell.lblProgressPagesCount.isHidden = true
            
//            cell.pageControlTotalCount.numberOfPages = currentBook.totalPages
//            cell.pageControlUserCount.numberOfPages = currentBook.userCurrentPage
            cell.imgIcon.kf.setImage(with: URL(string: getFullURLImage(currentBook.imageID)))
            
            
            cell.imgSound.isHidden = currentBook.hasAudio.lowercased().trimmingCharacters(in: CharacterSet.whitespaces) == "true" ? false : true
            cell.rate = 4
            cell.progressView.isHidden =  true
            cell.btnDone.tag = indexPath.row
            cell.btnIcon.addTarget(self, action: #selector(iconTapped), for: .touchUpInside)
            
            return cell
        case .inProgress:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyAccountDoneReadingCell") as! MyAccountDoneReadingCell
            
            cell.hideSwipeOptions()      
            
            cell.forLibrary = true
            
            cell.removeFavoriteButton?.tag = indexPath.row
            
            let currentBook = inProgressBooks[indexPath.row]
            
            print(currentBook.totalPages)
            
            print("Has Audio .... \(currentBook.hasAudio)")
            cell.updateView(book: currentBook)

            cell.lblName.text = currentBook.title
            cell.lblDate.text = "2/12/2015"
            cell.lblAuthor.text = currentBook.author
            cell.lblBrief.text = currentBook.summary
            cell.lblNOViews.text = "12"
            cell.lblNOComments.text = "43"
            cell.progressView.isHidden =  true
            cell.lblTotalPagesCount.isHidden = false
            cell.lblProgressPagesCount.isHidden = false
            
            cell.addTotalPapersCount(currentBook.totalPages)
            cell.addProgressPapersCount(currentBook.progress)
            
//            cell.pageControlTotalCount.numberOfPages = currentBook.totalPages
//            cell.pageControlUserCount.numberOfPages = currentBook.progress
            
            //cell.drawTotalPapersCount(currentBook.totalPages)
            cell.totalPapersCount = currentBook.totalPages
            
            cell.imgSound.isHidden = currentBook.hasAudio.lowercased().trimmingCharacters(in: CharacterSet.whitespaces) == "true" ? false : true
            
            cell.imgIcon.kf.setImage(with:URL(string: getFullURLImage(currentBook.imageID)))
            
            print(currentBook.bookID)
            //cell.rate = 4
            
            
            let remove = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
            remove.tag = indexPath.row
            remove.setImage(UIImage(named: "cross-1"), for: UIControlState())
            remove.backgroundColor = UIColor(red: 239.0/255.0, green: 239.0/255.0, blue: 239.0/255.0, alpha: 1.0)
            remove.addTarget(self, action: #selector(removeTappedFromFavorites), for: .touchUpInside)
            
            let addToFavorites = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
            addToFavorites.tag = indexPath.row
            addToFavorites.setImage(UIImage(named: "favorite_plus"), for: UIControlState())
            addToFavorites.backgroundColor = darkGreen
            
            addToFavorites.addTarget(self, action: #selector(addTappedFromFavorites), for: .touchUpInside)
            
            cell.leftButtons = [remove, addToFavorites]
            
            cell.btnDone.tag = indexPath.row
            cell.btnIcon.addTarget(self, action: #selector(iconTapped), for: .touchUpInside)
            
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedRow = indexPath.row
        
        performSegue(withIdentifier: "todetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSummary" {
            let destination = segue.destination as! SummaryViewController
            destination.currentBook = selectedType == .unread ? unReadBooks[selectedRow] : inProgressBooks[selectedRow]
            
            return
        }
        
        let destination = segue.destination as! BookDetailsViewController
        
        destination.currentBook = selectedType == .unread ? unReadBooks[selectedRow] : inProgressBooks[selectedRow]
    }
    
    
    override func closeAudioTapped() {
        super.closeAudioTapped()
        
        tableView.reloadData()
    }
    
    @objc fileprivate func removeTappedFromFavorites(_ button: UIButton) {
        print("tag to remove: \(button.tag)")
        
        let bookID = selectedType == .unread ? unReadBooks[button.tag].bookID : inProgressBooks[button.tag].bookID
        _ = selectedType == .unread ? unReadBooks[button.tag] : inProgressBooks[button.tag]
        print(bookID)
        if !Reachability.isConnectedToNetwork() {
       
//            let realm = try! Realm()
//            try! realm.write {
//                let bookObj = realm.object(ofType: Book.self, forPrimaryKey: bookID)
//                bookObj?.status = -1
//                realm.add(bookObj!, update: true)
//                if self.selectedType == .unread {
//                    let index = RealmHelper.getLoggedinUser()?.booksUnread.index(of: bookObj!)
//                    RealmHelper.getLoggedinUser()?.booksUnread.remove(objectAtIndex: index!)
//                }else{
//                    let index = RealmHelper.getLoggedinUser()?.booksInProgress.index(of: bookObj!)
//                    RealmHelper.getLoggedinUser()?.booksInProgress.remove(objectAtIndex: index!)
//                    
//                }
//                
//                realm.add(RealmHelper.getLoggedinUser()!, update: true)
//            }
//            
//            self.tableView.beginUpdates()
//            
//            if self.selectedType == .unread {
//                self.unReadBooks.remove(at: button.tag)
//            } else {
//                self.inProgressBooks.remove(at: button.tag)
//            }
//            
//            CATransaction.begin()
//            
//            CATransaction.setCompletionBlock {
//                self.tableView.reloadData()
//            }
//            
//            self.tableView.deleteRows(at: NSArray(object: IndexPath(row: button.tag, section: 0)) as! [IndexPath], with: .left)
//            self.tableView.endUpdates()
//            
//            CATransaction.commit()
//
            return
        }
        

        //let parameters = ["UserId": RealmHelper.getLoggedinUser()!.userID, "BookID": bookID]
        
        let parameters = ["UserID":RealmHelper.getLoggedinUser()!.userID, "BookID": bookID, "Status": "-1"]
        
        ApiManager.sharedInstance.setBookStatus(parameters as [String : AnyObject]?, onSuccess: { (array) in
        //ApiManager.sharedInstance.removeBookFromFavorites(parameters, onSuccess: { (array) in
            let banner = Banner(title: nil, subtitle: "تم حذف الكتاب من قائمة المكتبة", image: nil, backgroundColor: lightShinyGreenColor, didTapBlock: nil)
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
            
            self.tableView.beginUpdates()
            
            if self.selectedType == .unread {
                self.unReadBooks.remove(at: button.tag)
            } else {
                self.inProgressBooks.remove(at: button.tag)
            }
            
            CATransaction.begin()
            
            CATransaction.setCompletionBlock {
                self.tableView.reloadData()
            }
            
            self.tableView.deleteRows(at: NSArray(object: IndexPath(row: button.tag, section: 0)) as! [IndexPath], with: .left)
            self.tableView.endUpdates()
            
            CATransaction.commit()
//            let realm = try! Realm()
//            try! realm.write {
//                let bookObj = realm.object(ofType: Book.self, forPrimaryKey: bookID)
//
//                if self.selectedType == .unread {
//                    let index = RealmHelper.getLoggedinUser()?.booksUnread.index(of: bookObj!)
//                    RealmHelper.getLoggedinUser()?.booksUnread.remove(objectAtIndex: index!)
//                }else{
//                    let index = RealmHelper.getLoggedinUser()?.booksInProgress.index(of: bookObj!)
//                    RealmHelper.getLoggedinUser()?.booksInProgress.remove(objectAtIndex: index!)
//                    
//                }
//                                bookObj?.status = -1
//                realm.add(bookObj!, update: true)
//                realm.add(RealmHelper.getLoggedinUser()!, update: true)
//            }

            
            
            print("success")
            }, onFailure: { (error) in
                print(error.description)
                
                let banner = Banner(title: nil, subtitle: "خطأ في العملية. يرجى المحاولة مرة اخرى", image: nil, backgroundColor: lightShinyGreenColor, didTapBlock: nil)
                banner.dismissesOnTap = true
                banner.show(duration: 3.0)
            }, loadingViewController: nil)
    }
    
    @objc fileprivate func addTappedFromFavorites(_ button: UIButton) {
        print("tag to add: \(button.tag)")
        
        let bookID = selectedType == .unread ? unReadBooks[button.tag].bookID : inProgressBooks[button.tag].bookID
        _ = selectedType == .unread ? unReadBooks[button.tag] : inProgressBooks[button.tag]
        let parameters = ["UserId": RealmHelper.getLoggedinUser()!.userID, "BookID": bookID]
        if !Reachability.isConnectedToNetwork() {
//            let realm = try! Realm()
//            try! realm.write {
//                if RealmHelper.getLoggedinUser()?.booksFavorites.filter("bookID == \"\(bookID)\"").first != nil{
//                    
//                }else{
//                    let realmBook = realm.object(ofType: Book.self, forPrimaryKey: bookID)
//                    RealmHelper.getLoggedinUser()!.booksFavorites.append(realmBook!)
//                }
//                
//                realm.add(RealmHelper.getLoggedinUser()!, update: true)
//            }
            for cell in self.tableView.visibleCells {
                let llSwipeCell = cell as! LLSwipeCell
                llSwipeCell.hideSwipeOptions()
            }


            return
        }
                ApiManager.sharedInstance.addBookToFavorites(parameters as [String : AnyObject]?, onSuccess: { (array) in
//            let banner = Banner(title: nil, subtitle: "تم اضافة الكتاب الى قائمة المفضلة", image: nil, backgroundColor: lightShinyGreenColor, didTapBlock: nil)
//            banner.dismissesOnTap = true
//            banner.show(duration: 3.0)
            
            
//            let realm = try! Realm()
//            try! realm.write {
//                if RealmHelper.getLoggedinUser()?.booksFavorites.filter("bookID == \"\(bookID)\"").first != nil{
//                    
//                }else{
//                    let realmBook = realm.object(ofType: Book.self, forPrimaryKey: bookID)
//                    RealmHelper.getLoggedinUser()!.booksFavorites.append(realmBook!)
//                }
//                
//                realm.add(RealmHelper.getLoggedinUser()!, update: true)
//            }
//                    
//
            
            for cell in self.tableView.visibleCells {
                let llSwipeCell = cell as! LLSwipeCell
                llSwipeCell.hideSwipeOptions()
            }
            
            print("success")
            }, onFailure: { (error) in
                print(error.description)
                
                let banner = Banner(title: nil, subtitle: "خطأ في العملية. يرجى المحاولة مرة اخرى", image: nil, backgroundColor: lightShinyGreenColor, didTapBlock: nil)
                banner.dismissesOnTap = true
                banner.show(duration: 3.0)
            }, loadingViewController: self)
    }
}

extension LibraryViewController:LibraryFilterViewDelegate {
    func libraryFilterCloseDidTap() {
        UIView.animate(withDuration: 0.25, animations: {
            self.filterView?.frame.origin.y = screenHeight
        }, completion: { _ in
            self.filterView?.removeFromSuperview()
            self.view.isUserInteractionEnabled = true
        }) 

    }
    
    func libraryFilterRowDidSelected(_ row: Int) {
        UIView.animate(withDuration: 0.25, animations: {
            self.filterView?.frame.origin.y = screenHeight
        }, completion: { _ in
            self.filterView?.removeFromSuperview()
            self.view.isUserInteractionEnabled = true
            
            self.setTabBarDisabled(false)
            
            self.selectedFilterRow = row
            
            self.pageNumberForUnread = 1
            self.pageNumberForInProgress = 1
            //private var booksTotalCountsFromServer = 0
            self.nextWaveForUnread = 0
            self.nextWaveForInProgress = 0
            
            if self.selectedType == .unread {
                self.getAndDisplayUserBooks(0, pageNumber: self.pageNumberForUnread)
                
            } else if self.selectedType == .inProgress {
                self.getAndDisplayUserBooks(1, pageNumber: self.pageNumberForInProgress)
                
            }
        })
    }
    
    func iconTapped(_ button: UIButton) {
//        print(button.tag)
//        selectedRow = button.tag
//        
//        performSegueWithIdentifier("toSummary", sender: self)
    }
}
