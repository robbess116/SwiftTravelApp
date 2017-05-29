//
//  MyAccountViewController.swift
//  Aqsar
//
//  Created by moayad on 7/27/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit
import RealmSwift
import BRYXBanner
import RAMAnimatedTabBarController

enum MyAccountSelectionType: Int {
    case quotations = 0, favorites, done
}

class MyAccountViewController: BaseViewController {
    //MARK:- IBOutlets
    @IBOutlet weak fileprivate var imgUserIcon: UIImageView!
    @IBOutlet weak fileprivate var viewSeperator: UIView!
    
    @IBOutlet weak fileprivate var btnDone: UIButton!
    @IBOutlet weak fileprivate var btnFavorites: UIButton!
    @IBOutlet weak fileprivate var btnQuotations: UIButton!
    
    @IBOutlet weak fileprivate var tableView: UITableView!
    
    //@IBOutlet private weak var lblEmail: UILabel!
    
    @IBOutlet fileprivate weak var lblNoFinishedBooks: UILabel!
    @IBOutlet fileprivate weak var lblNoFavoriteBooks: UILabel!
    @IBOutlet fileprivate weak var lblNoQuotes: UILabel!
    fileprivate var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var viewQuote: UIView!
    @IBOutlet var viewQuoteBG: UIView!
    @IBOutlet weak var lblQuote: UILabel!
    
    @IBOutlet weak var conHeight: NSLayoutConstraint!
    //MARK:- IVars
    fileprivate let animatableButtonsView = UIView()
    fileprivate let defaultButtonsColor = UIColor(red: 127.0/255.0, green: 127.0/255.0, blue: 127.0/255.0, alpha: 1.0)
    
    //private var noRows = 10
    
    fileprivate var selectedType: MyAccountSelectionType = .done
    
    fileprivate var finishedBooks = [Book]()
    fileprivate var favoriteBooks = [Book]()
    fileprivate var quotes = [Quote]()
    fileprivate var textQuotes = [Quote]()
    
    // apis
    fileprivate var pageNumberForFinished = 1
    fileprivate var nextWaveForFinished = 0
    
    fileprivate var pageNumberForFavorites = 1
    fileprivate var nextWaveForFavorties = 0
    fileprivate var isFavoriteTapped = false
    
    fileprivate var pageNumberForQuotes = 1
    fileprivate var nextWaveForQuotes = 0
    fileprivate var isQuoteTapped = false
    
    fileprivate var selectedRow = 0
    
    //MARK:- Life Cycle
//    override func preferredStatusBarStyle() -> UIStatusBarStyle {
//        return .LightContent
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        //imgUserIcon.makeMeCircular()
        
        setUpAnimatableButtonsView()
        
        //lblEmail.text = RealmHelper.getLoggedinUser()?.email
        
        tableView.register(UINib(nibName: "MyAccountQuotationsCell", bundle: nil), forCellReuseIdentifier: "MyAccountQuotationsCell")
        tableView.register(UINib(nibName: "MyAccountDoneReadingCell", bundle: nil), forCellReuseIdentifier: "MyAccountDoneReadingCell")
        
        
        
//        let tabBarVC = self.tabBarController as? RAMAnimatedTabBarController
//        tabBarVC?.setSelectIndex(from: 0, to: 3)
//        //tabBarVC?.tabBar.tintColor = darkGreen
//        tabBarVC?.changeSelectedColor(darkGreen, iconSelectedColor: darkGreen)
        
        let tabBarVC = self.tabBarController
        tabBarVC?.selectedIndex = 3
        
        
        
        //getAndDisplayUserFinishedBooks()
        
        // pull to refresh setup
        refreshControl = UIRefreshControl()
        //refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        refreshControl.tintColor = darkGreen
        tableView.addSubview(refreshControl) // not required when using UITableViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.isStatusBarHidden = false
            
        
        getAndDisplayUserFinishedBooks()
        
        UIApplication.shared.statusBarStyle = .default
        
        setUpNavigationBar()
        
        if let _ = AudioPlayer.sharedInstance.partName {
            conHeight.constant = 60
        } else {
            conHeight.constant = 0
        }
        
        let parameters = ["UserID": RealmHelper.getLoggedinUser()!.userID]
        
        ApiManager.sharedInstance.getMyAccountCounts(parameters as [String : AnyObject]?, onSuccess: { (array) in
            if let unwrappedMyAccountData = array {
                let obj = unwrappedMyAccountData.table!.first
                
                self.lblNoFinishedBooks.text = "\(obj!.finishedCount)"
                self.lblNoFavoriteBooks.text = "\(obj!.favoriteCount)"
                self.lblNoQuotes.text = "\(obj!.quotesCount)"
            }
            }, onFailure: { (error) in
                print(error.description)
            }, loadingViewController: nil)
    }
    
    //MARK:- UI
    fileprivate func setUpAnimatableButtonsView() {
        animatableButtonsView.frame = CGRect(x: 0, y: viewSeperator.frame.origin.y - 2, width: screenWidth / 3, height: 2)
        animatableButtonsView.backgroundColor = darkGreen
        view.addSubview(animatableButtonsView)
    }
    
    //MARK:- Animation
    fileprivate func animateButtonsView(toX: CGFloat) {
        UIView.animate(withDuration: 0.25, animations: {
            self.animatableButtonsView.frame.origin.x = toX
        }) 
    }
    
    //MARK:- IBActions
    @IBAction fileprivate func doneTapped(_ sender: AnyObject) {
        animateButtonsView(toX: 0)
        btnDone.setTitleColor(darkGreen, for: UIControlState())
        btnFavorites.setTitleColor(defaultButtonsColor, for: UIControlState())
        btnQuotations.setTitleColor(defaultButtonsColor, for: UIControlState())
        
        selectedType = .done
        //noRows = 10
        
        tableView.setContentOffset(CGPoint.zero, animated: false)
        tableView.reloadData()
    }
    
    @IBAction fileprivate func favoritesTapped(_ sender: AnyObject) {
        animateButtonsView(toX: screenWidth * 1/3)
        btnDone.setTitleColor(defaultButtonsColor, for: UIControlState())
        btnFavorites.setTitleColor(darkGreen, for: UIControlState())
        btnQuotations.setTitleColor(defaultButtonsColor, for: UIControlState())
        
        selectedType = .favorites
        tableView.setContentOffset(CGPoint.zero, animated: false)
        tableView.reloadData()
        
        if !isFavoriteTapped {
            isFavoriteTapped = true
            
            if Reachability.isConnectedToNetwork() == false {
                //showNetowrkNoConnectivityAlertController()
                
                for book in (RealmHelper.getLoggedinUser()?.booksFavorites)! {
                    favoriteBooks.append(book)
                }
                
                lblNoFavoriteBooks.text = "\(favoriteBooks.count)"
                
                tableView.reloadData()
                return
            }
            
            
            let parameters = ["UserID": RealmHelper.getLoggedinUser()!.userID, "PageNo": "\(pageNumberForFavorites)", "PageSize": "10"]
            
            ApiManager.sharedInstance.getUserFavoriteBooks(parameters as [String : AnyObject]?, onSuccess: { userFavoriteBooks in
                if let unwrappedUserBooks = userFavoriteBooks {
                    self.nextWaveForFavorties = (unwrappedUserBooks.table?.count)!
                    
                    self.favoriteBooks = unwrappedUserBooks.table!
                    
                    let realm = try! Realm()
                    try! realm.write {
                       
                        for book in unwrappedUserBooks.table! {
                            if realm.object(ofType: Book.self, forPrimaryKey: book.bookID) != nil {
                                
                                continue
                            }else{
                                
                                RealmHelper.getLoggedinUser()!.booksFavorites.append(book)
                            }

                       }
                        
                        realm.add(RealmHelper.getLoggedinUser()!, update: true)
                    }
                    
                    //self.lblNoFavoriteBooks.text = "\(self.favoriteBooks.count)"
//                    if let first = unwrappedUserBooks.table!.first {
//                        self.lblNoFavoriteBooks.text = "\(first.totalCount)"
//                    }
                    
                    //self.lblNoFavoriteBooks.text = "\(unwrappedUserBooks.table?.first?.totalCount)"
                    
                    self.tableView.reloadData()
                }
                
                }, onFailure: { (error) in
                    print(error.description)
                }, loadingViewController: self)
        }
    }
    
    @IBAction fileprivate func quotationTapped(_ sender: AnyObject) {
        animateButtonsView(toX: screenWidth * (2/3))
        btnDone.setTitleColor(defaultButtonsColor, for: UIControlState())
        btnFavorites.setTitleColor(defaultButtonsColor, for: UIControlState())
        btnQuotations.setTitleColor(darkGreen, for: UIControlState())
        
        selectedType = .quotations
        //noRows = 10
        
        tableView.setContentOffset(CGPoint.zero, animated: false)
        tableView.reloadData()
        
        if !isQuoteTapped {
            isQuoteTapped = true
            
            if Reachability.isConnectedToNetwork() == false {
                //showNetowrkNoConnectivityAlertController()
                
                for quote in (RealmHelper.getLoggedinUser()?.quotes)! {
                    quotes.append(quote)
                }
                
                lblNoQuotes.text = "\(quotes.count)"
                tableView.reloadData()
                return
            }
            
            let parameters = ["UserId": RealmHelper.getLoggedinUser()!.userID, "pageNumber": "\(pageNumberForFavorites)", "PageSize": "10"]
            
            ApiManager.sharedInstance.getUserQuotes(parameters as [String : AnyObject]?, onSuccess: { quotes in
                if let unwrappedQuotes = quotes {
                    self.quotes = unwrappedQuotes.table!
                    
//                    let realm = try! Realm()
//                    try! realm.write {
//                        
//                        for quote in unwrappedQuotes.table! {
//                            if realm.object(ofType: Quote.self, forPrimaryKey: quote.quoteID) != nil {
//                                
//                                continue
//                            }else{
//                                
//                                RealmHelper.getLoggedinUser()!.quotes.append(quote)
//                            }
//
//                           
//                        }
//                        
//                        realm.add(RealmHelper.getLoggedinUser()!, update: true)
//                    }
//                    
                    //self.lblNoQuotes.text = "\(self.quotes.count)"
//                    if let first = unwrappedQuotes.table!.first {
//                        self.lblNoQuotes.text = "\(first.totalCount)"
//                    }
                    
                    //self.lblNoQuotes.text = "\(unwrappedQuotes.table!.first?.totalCount)"
                    self.tableView.reloadData()
                    
                }
                }, onFailure: { (error) in
                    print(error.description)
                }, loadingViewController: self)
        }
    }
    
    @IBAction fileprivate func quoteViewTapped(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.25, animations: {
            self.viewQuote.alpha = 0.0
            self.viewQuoteBG.alpha = 0.0
        }, completion: { _ in
            self.viewQuoteBG.removeFromSuperview()
            self.viewQuote.removeFromSuperview()
        }) 
    }
    
    //MARK:- Navigation
    fileprivate func setUpNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.isHidden = false
        
        self.navigationItem.rightBarButtonItem =
            UIBarButtonItem(image:UIImage(named: "gear"), style:.plain, target:self, action:#selector(settingsTapped))
        //self.navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
        self.navigationItem.setLeftBarButton(nil, animated: true)

        navigationController?.navigationBar.tintColor = darkGreen
        //self.navigationItem.leftBarButtonItem?.tintColor = darkGreen
    }
    
    
    @objc fileprivate func settingsTapped() {
        performSegue(withIdentifier: "toSettings", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetails" {
            let destination = segue.destination as! BookDetailsViewController
            
            if selectedType == .done {
                destination.currentBook = finishedBooks[selectedRow]
            } else if selectedType == .favorites {
                destination.currentBook = favoriteBooks[selectedRow]
            }
        }
    }
    
    //MARK:- APIs
    fileprivate func getAndDisplayUserFinishedBooks() {

        //CheckSub
        if checkSubscriptionAvailability() == false {
            return
        }
        
        if Reachability.isConnectedToNetwork() == false {
            //showNetowrkNoConnectivityAlertController()
            finishedBooks.removeAll()
            for book in (RealmHelper.getLoggedinUser()?.booksFinished)! {
                finishedBooks.append(book)
            }
            
            lblNoFinishedBooks.text = "\(finishedBooks.count)"
            tableView.reloadData()
            return
        }
        
        let parameters = ["UserID": RealmHelper.getLoggedinUser()!.userID, "PageNo": "\(pageNumberForFinished)", "PageSize": "10", "Status": "2","filterBy":"0"]
        
        ApiManager.sharedInstance.getUserLibrary(parameters as [String : AnyObject]?, onSuccess: { userFinishedBooks in
            if let unwrappedUserBooks = userFinishedBooks {
                self.nextWaveForFinished = (unwrappedUserBooks.table?.count)!
                
                self.finishedBooks = unwrappedUserBooks.table!
                let realm = try! Realm()
                try! realm.write {
                  
                    for book in unwrappedUserBooks.table! {
                        
                        if realm.object(ofType: Book.self, forPrimaryKey: book.bookID) != nil {
                            
                            continue
                        }else{
                            
                            RealmHelper.getLoggedinUser()!.booksFinished.append(book)
                        }

                    }
                    
                    realm.add(RealmHelper.getLoggedinUser()!, update: true)
                }
                
                //self.lblNoFinishedBooks.text = "\(self.finishedBooks.count)"
                if let first = unwrappedUserBooks.table!.first {
                    self.lblNoFinishedBooks.text = "\(first.totalCount)"
                }
                
                print(self.finishedBooks)
                self.tableView.reloadData()
            }
            }, onFailure: { (error) in
                print(error.description)
            }, loadingViewController: self)
    }
    
    //MARK:- Audio Player
    override func closeDidTap() {
        super.closeDidTap()
        conHeight.constant = 0
    }
}

extension MyAccountViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selectedType {
        case .done:
            return finishedBooks.count
        case .favorites:
            return favoriteBooks.count
        case .quotations:
            return quotes.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if selectedType == .quotations {
//            return 70
//        }
        
        return 150
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch selectedType {
        case .done:
            print(nextWaveForFinished)
            if finishedBooks.count - 1 == indexPath.row && nextWaveForFinished >= 10 {
                pageNumberForFinished = pageNumberForFinished + 1
                
                let parameters = ["UserID": RealmHelper.getLoggedinUser()!.userID, "PageNo": "\(pageNumberForFinished)", "PageSize": "10", "Status": "2"]
                
                ApiManager.sharedInstance.getUserLibrary(parameters as [String : AnyObject]?, onSuccess: { userFinishedBooks in
                    if let unwrappedUserBooks = userFinishedBooks {
                        self.nextWaveForFinished = (unwrappedUserBooks.table?.count)!
                        
                        for book in unwrappedUserBooks.table! {
                            self.finishedBooks.append(book)
                        }
                        let realm = try! Realm()
                        try! realm.write {
                            
                            for book in unwrappedUserBooks.table! {
                                if realm.object(ofType: Book.self, forPrimaryKey: book.bookID) != nil {
                                    
                                    continue
                                }else{
                                    
                                    RealmHelper.getLoggedinUser()!.booksFinished.append(book)
                                }

                            }
                            
                            realm.add(RealmHelper.getLoggedinUser()!, update: true)
                        }
                        
                        self.lblNoFinishedBooks.text = "\(self.finishedBooks.count)"
                        self.tableView.reloadData()
                    }
                    }, onFailure: { (error) in
                        print(error.description)
                    }, loadingViewController: self)
            }
            
        case .favorites:
            print(nextWaveForFavorties)
            if favoriteBooks.count - 1 == indexPath.row && nextWaveForFavorties >= 10 {
                pageNumberForFavorites = pageNumberForFavorites + 1
                
                let parameters = ["UserID": RealmHelper.getLoggedinUser()!.userID, "PageNo": "\(pageNumberForFavorites)", "PageSize": "10"]
                
                ApiManager.sharedInstance.getUserFavoriteBooks(parameters as [String : AnyObject]?, onSuccess: { userFavoriteBooks in
                    if let unwrappedUserBooks = userFavoriteBooks {
                        self.nextWaveForFavorties = (unwrappedUserBooks.table?.count)!
                        
                        for book in unwrappedUserBooks.table! {
                            self.favoriteBooks.append(book)
                        }
                        
                        let realm = try! Realm()
                        try! realm.write {
                            
                            for book in unwrappedUserBooks.table! {
                                if realm.object(ofType: Book.self, forPrimaryKey: book.bookID) != nil {
                                    
                                    continue
                                }else{
                                    
                                    RealmHelper.getLoggedinUser()!.booksFavorites.append(book)
                                }

                               
                            }
                            
                            realm.add(RealmHelper.getLoggedinUser()!, update: true)
                        }
                        
                        self.lblNoFavoriteBooks.text = "\(self.favoriteBooks.count)"
                        print(self.favoriteBooks)
                        self.tableView.reloadData()
                    }
                    
                    }, onFailure: { (error) in
                        print(error.description)
                    }, loadingViewController: self)
            }
            
        case .quotations:
            print(nextWaveForQuotes)
            if quotes.count - 1 == indexPath.row && nextWaveForQuotes >= 10 {
                pageNumberForQuotes = pageNumberForQuotes + 1
                
                let parameters = ["UserId": RealmHelper.getLoggedinUser()!.userID, "pageNumber": "\(pageNumberForQuotes)", "PageSize": "10"]
                
                ApiManager.sharedInstance.getUserQuotes(parameters as [String : AnyObject]?, onSuccess: { quotes in
                    if let unwrappedQuotes = quotes {
                        self.quotes = unwrappedQuotes.table!
                        
//                        let realm = try! Realm()
//                        try! realm.write {
//                            
//                            for quote in unwrappedQuotes.table! {
//                                if realm.object(ofType: Quote.self, forPrimaryKey: quote.quoteID) != nil {
//                                    
//                                    continue
//                                }else{
//                                    
//                                    RealmHelper.getLoggedinUser()!.quotes.append(quote)
//                                }
//
//                                
//                            }
//                            
//                            realm.add(RealmHelper.getLoggedinUser()!, update: true)
//                        }
                        
                        self.lblNoQuotes.text = "\(self.quotes.count)"
                        self.tableView.reloadData()
                        
                    }
                    }, onFailure: { (error) in
                        print(error.description)
                    }, loadingViewController: self)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch selectedType {
            
        case .quotations:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyAccountQuotationsCell") as! MyAccountQuotationsCell
            
            let currentQuote = quotes[indexPath.row]
            
            cell.removeButton.tag = indexPath.row
            cell.removeButton.addTarget(self, action: #selector(removeTappedFromQuotations(_:)), for: .touchUpInside)
            
            cell.lblName.text = currentQuote.title
            cell.lblAuthor.text = currentQuote.authorName
            cell.lblListens.text = "\(currentQuote.audioQuotesCount)"
            cell.lblPages.text = "\(currentQuote.textQuotesCount)"
            //cell.imgIcon.kf.setImage(with:URL(string: getFullURLImage(currentQuote.)))
            return cell
            
        case .favorites:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyAccountDoneReadingCell") as! MyAccountDoneReadingCell
            
            let currentBook = favoriteBooks[indexPath.row]
            cell.updateView(book: currentBook)
            cell.lblName.text = currentBook.title
            cell.lblAuthor.text = currentBook.author
            cell.lblBrief.text = currentBook.summary
            cell.hasSound = currentBook.hasAudio.lowercased().trimmingCharacters(in: CharacterSet.whitespaces) == "true" ? true : false
            cell.rate = 3
            
            cell.imgSound.isHidden = currentBook.hasAudio.lowercased().trimmingCharacters(in: CharacterSet.whitespaces) == "true" ? false : true
            
            cell.addTotalPapersCount(currentBook.totalPages)
            cell.addProgressPapersCount(currentBook.progress)
            
            let removeFromFavorites = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
            removeFromFavorites.tag = indexPath.row
            removeFromFavorites.setImage(UIImage(named: "favorite_cross"), for: UIControlState())
            removeFromFavorites.backgroundColor = darkGreen
            removeFromFavorites.addTarget(self, action: #selector(removeTappedFromFavorites(_:)), for: .touchUpInside)
            
            cell.leftButtons = [removeFromFavorites]
            
            cell.imgIcon.kf.setImage(with:URL(string: getFullURLImage(currentBook.imageID)))
            
            return cell
            
        case .done:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyAccountDoneReadingCell") as! MyAccountDoneReadingCell
            
            cell.removeFavoriteButton?.tag = indexPath.row
            cell.removeFavoriteButton!.addTarget(self, action: #selector(removeTappedFromFavorites(_:)), for: .touchUpInside)
            
            let currentBook = finishedBooks[indexPath.row]
            cell.updateView(book: currentBook)
            cell.lblName.text = currentBook.title
            cell.lblAuthor.text = currentBook.author
            cell.lblBrief.text = currentBook.summary
            cell.hasSound = currentBook.hasAudio.lowercased().trimmingCharacters(in: CharacterSet.whitespaces) == "true" ? true : false
            cell.rate = 3
            
            cell.imgSound.isHidden = currentBook.hasAudio.lowercased().trimmingCharacters(in: CharacterSet.whitespaces) == "true" ? false : true
            
            cell.addTotalPapersCount(currentBook.totalPages)
            cell.addProgressPapersCount(currentBook.progress)
            
            cell.addTotalPapersCount(currentBook.totalPages)
            cell.addProgressPapersCount(currentBook.progress)
            
            let remove = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
            remove.tag = indexPath.row
            remove.setImage(UIImage(named: "cross-1"), for: UIControlState())
            remove.backgroundColor = UIColor(red: 239.0/255.0, green: 239.0/255.0, blue: 239.0/255.0, alpha: 1.0)
            remove.addTarget(self, action: #selector(removeTappedFromFinished), for: .touchUpInside)
            
            let addToFavorites = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
            addToFavorites.tag = indexPath.row
            addToFavorites.setImage(UIImage(named: "favorite_plus"), for: UIControlState())
            addToFavorites.backgroundColor = darkGreen
            addToFavorites.addTarget(self, action: #selector(addTappedFromFinished), for: .touchUpInside)
            
            cell.forLibrary = true
            cell.leftButtons = [remove, addToFavorites]
            
            cell.imgIcon.kf.setImage(with:URL(string: getFullURLImage(currentBook.imageID)))
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if selectedType != .quotations {
            selectedRow = indexPath.row
            performSegue(withIdentifier: "toDetails", sender: self)
        } else {
            func viewQuoteDialog() {
                let quote = quotes[indexPath.row]
                
                let ad = UIApplication.shared.delegate as! AppDelegate
                
                viewQuoteBG.frame = UIScreen.main.bounds
                viewQuoteBG.alpha = 0.0
                //view.addSubview(viewBackground)
                ad.window?.addSubview(viewQuoteBG)
                
                viewQuote.frame = CGRect(x: 0, y: 0, width: 300, height: 128)
                viewQuote.center = view.center
                //viewOneDay.alpha = 0.0
                viewQuote.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                //view.addSubview(viewOneDay)
                ad.window?.addSubview(viewQuote)
                
                lblQuote.text = quote.quote
                
                UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 3.0, options: .curveEaseIn, animations: {
                    self.viewQuoteBG.alpha = 0.8
                    self.viewQuote.alpha = 1.0
                    self.viewQuote.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    }, completion: nil)
            }
            
            //viewQuoteDialog()
            
            let booksPaperVC = storyboard?.instantiateViewController(withIdentifier: "BookPapersListViewController") as! BookPapersListViewController
            booksPaperVC.isCameFormMyAccount = true
            let aBook = Book()
            aBook.title = quotes[indexPath.row].title
            aBook.author = quotes[indexPath.row].authorName
            aBook.bookID = quotes[indexPath.row].bookID
            
            booksPaperVC.book = aBook
            present(booksPaperVC, animated: true, completion: nil)

        }
        
    }
    
    
    //MARK:- Targets
    @objc fileprivate func removeTappedFromQuotations(_ button: UIButton) {
        print(button.tag)
//        let parameters1 = ["UserId": RealmHelper.getLoggedinUser()!.userID, "PageNumber": "1", "PageSize": "20", "BookID": quotes[button.tag].bookID]
//        
//        ApiManager.sharedInstance.getTextQuotes(parameters1 as [String : AnyObject]?, onSuccess: { array in
//            self.textQuotes = array!.table!
//            
            let parameters = ["UserId": RealmHelper.getLoggedinUser()!.userID, "Quote": self.quotes[button.tag].quoteID, "BookID": self.quotes[button.tag].bookID]
            print(parameters)
        
            ApiManager.sharedInstance.removeQuote(parameters as [String : AnyObject]?, onSuccess: { (array) in
                if let _ = array {
                    let banner = Banner(title: nil, subtitle: "تم حذف الاقتباس", image: nil, backgroundColor: lightShinyGreenColor, didTapBlock: nil)
                    banner.dismissesOnTap = true
                    banner.show(duration: 3.0)
                    
                    self.tableView.beginUpdates()
                    
                    self.quotes.remove(at: button.tag)
                    
                    CATransaction.begin()
                    
                    CATransaction.setCompletionBlock {
                        self.refresh()
                        self.lblNoQuotes.text = "\(self.quotes.count)"
                        self.tableView.reloadData()
                    }
                    
                    self.tableView.deleteRows(at: NSArray(object: IndexPath(row: button.tag, section: 0)) as! [IndexPath], with: .left)
                    self.tableView.endUpdates()
                    
                    CATransaction.commit()
                    
                }
            }, onFailure: { (error) in
                print(error.description)
            }, loadingViewController: nil)
            
//        }, onFailure: { (error) in
//            print(error.description)
//        }, loadingViewController: self)
//        
        
    }
    
    @objc fileprivate func removeTappedFromFavorites(_ button: UIButton) {
        let parameters = ["UserId": RealmHelper.getLoggedinUser()!.userID, "BookID": favoriteBooks[button.tag].bookID]
        
        ApiManager.sharedInstance.removeBookFromFavorites(parameters as [String : AnyObject]?, onSuccess: { (array) in
            let banner = Banner(title: nil, subtitle: "تم حذف الكتاب من قائمة المفضلة", image: nil, backgroundColor: lightShinyGreenColor, didTapBlock: nil)
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
            
            self.tableView.beginUpdates()
            
            self.favoriteBooks.remove(at: button.tag)
            
            CATransaction.begin()
            
            CATransaction.setCompletionBlock {
                self.refresh()
                self.lblNoFavoriteBooks.text = "\(self.favoriteBooks.count)"
                self.tableView.reloadData()
            }
            
            self.tableView.deleteRows(at: NSArray(object: IndexPath(row: button.tag, section: 0)) as! [IndexPath], with: .left)
            self.tableView.endUpdates()
            
            CATransaction.commit()
            
            }, onFailure: { (error) in
                print(error)
            }, loadingViewController: nil)
        
        
//        print(button.tag)
//        
//        self.tableView.beginUpdates()
//        //self.arrayData.removeObjectAtIndex(button.tag) // also remove an array object if exists.
//        
//        //noRows -= 1
//        
//        CATransaction.begin()
//        
//        CATransaction.setCompletionBlock {
//            self.tableView.reloadData()
//        }
//        
//        self.tableView.deleteRows(at: NSArray(object: IndexPath(row: button.tag, section: 0)) as! [IndexPath], with: .left)
//        self.tableView.endUpdates()
//        
//        CATransaction.commit()
    }
    
    func removeTappedFromFinished(_ button: UIButton) {
        print("tag to remove: \(button.tag)")
        let bookID = finishedBooks[button.tag].bookID
        print(bookID)
        
        //let parameters = ["UserId": RealmHelper.getLoggedinUser()!.userID, "BookID": bookID]
        
        let parameters = ["UserID":RealmHelper.getLoggedinUser()!.userID, "BookID": bookID, "Status": "-1"]
        
        ApiManager.sharedInstance.setBookStatus(parameters as [String : AnyObject]?, onSuccess: { (array) in
            //ApiManager.sharedInstance.removeBookFromFavorites(parameters, onSuccess: { (array) in
            let banner = Banner(title: nil, subtitle: "تم حذف الكتاب من القائمة", image: nil, backgroundColor: lightShinyGreenColor, didTapBlock: nil)
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
            
            self.tableView.beginUpdates()
            
            self.finishedBooks.remove(at: button.tag)
            
            CATransaction.begin()
            
            CATransaction.setCompletionBlock {
                self.lblNoFinishedBooks.text = "\(self.finishedBooks.count)"
                self.tableView.reloadData()
            }
            
            self.tableView.deleteRows(at: NSArray(object: IndexPath(row: button.tag, section: 0)) as! [IndexPath], with: .left)
            self.tableView.endUpdates()
            
            CATransaction.commit()
            
            print("success")
            }, onFailure: { (error) in
                print(error.description)
                
                let banner = Banner(title: nil, subtitle: "خطأ في العملية. يرجى المحاولة مرة اخرى", image: nil, backgroundColor: lightShinyGreenColor, didTapBlock: nil)
                banner.dismissesOnTap = true
                banner.show(duration: 3.0)
            }, loadingViewController: nil)
    }
    
    func addTappedFromFinished(_ button: UIButton) {
        print("tag to add: \(button.tag)")
        let bookID = finishedBooks[button.tag].bookID
        let parameters = ["UserId": RealmHelper.getLoggedinUser()!.userID, "BookID": bookID]
        
        ApiManager.sharedInstance.addBookToFavorites(parameters as [String : AnyObject]?, onSuccess: { (array) in
            let banner = Banner(title: nil, subtitle: "تم اضافة الكتاب الى قائمة المفضلة", image: nil, backgroundColor: lightShinyGreenColor, didTapBlock: nil)
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
            
            print("success")
            }, onFailure: { (error) in
                print(error.description)
                
                let banner = Banner(title: nil, subtitle: "خطأ في العملية. يرجى المحاولة مرة اخرى", image: nil, backgroundColor: lightShinyGreenColor, didTapBlock: nil)
                banner.dismissesOnTap = true
                banner.show(duration: 3.0)
            }, loadingViewController: nil)
    }
    
    func refresh() {
        if Reachability.isConnectedToNetwork() == false {
            showNetowrkNoConnectivityAlertController()
            self.refreshControl.endRefreshing()
            return
        }
        
        if selectedType == .done {
            let parameters = ["UserID": RealmHelper.getLoggedinUser()!.userID, "PageNo": "1", "PageSize": "10", "Status": "2"]
            
            ApiManager.sharedInstance.getUserLibrary(parameters as [String : AnyObject]?, onSuccess: { (userBooks) in
                if let unwrappedUserBooks = userBooks {
                    self.nextWaveForFinished = (unwrappedUserBooks.table?.count)!
                    self.finishedBooks = unwrappedUserBooks.table!
                    self.pageNumberForFinished = 1
                    
                    self.lblNoFinishedBooks.text = "\(self.finishedBooks.count)"
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
                }, onFailure: { (error) in
                    print(error.description)
                }, loadingViewController: nil)
        } else if selectedType == .favorites {
            let parameters = ["UserID": RealmHelper.getLoggedinUser()!.userID, "PageNo": "1", "PageSize": "10"]
            
            ApiManager.sharedInstance.getUserFavoriteBooks(parameters as [String : AnyObject]?, onSuccess: { userFavoriteBooks in
                if let unwrappedUserBooks = userFavoriteBooks {
                    self.nextWaveForFavorties = (unwrappedUserBooks.table?.count)!
                    
                    self.favoriteBooks = unwrappedUserBooks.table!
                    let realm = try! Realm()
                    try! realm.write {
                        
                        for book in unwrappedUserBooks.table! {
                            if realm.object(ofType: Book.self, forPrimaryKey: book.bookID) != nil {
                                
                                continue
                            }else{
                                
                                RealmHelper.getLoggedinUser()!.booksFavorites.append(book)
                            }

                            
                        }
                        
                        realm.add(RealmHelper.getLoggedinUser()!, update: true)
                    }
                    
                    self.lblNoFavoriteBooks.text = "\(self.favoriteBooks.count)"
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
                
                }, onFailure: { (error) in
                    print(error.description)
                }, loadingViewController: self)
        } else if selectedType == .quotations {
            let parameters = ["UserId": RealmHelper.getLoggedinUser()!.userID, "pageNumber": "1", "PageSize": "10"]
            
            ApiManager.sharedInstance.getUserQuotes(parameters as [String : AnyObject]?, onSuccess: { quotes in
                if let unwrappedQuotes = quotes {
                    self.quotes = unwrappedQuotes.table!
                    
//                    let realm = try! Realm()
//                    try! realm.write {
//                        
//                        for quote in unwrappedQuotes.table! {
//                            if realm.object(ofType: Quote.self, forPrimaryKey: quote.quoteID) != nil {
//                                
//                                continue
//                            }else{
//                                
//                                RealmHelper.getLoggedinUser()!.quotes.append(quote)
//                            }
//
//                            
//                        }
//                        
//                        realm.add(RealmHelper.getLoggedinUser()!, update: true)
//                    }
                    
                    //self.lblNoQuotes.text = "\(self.quotes.count)"
                    
//                    if let first = unwrappedQuotes.table!.first {
//                        self.lblNoQuotes.text = "\(first.totalCount)"
//                    }
                    
                    var totalCount = 0
                    for quote in self.quotes {
//                        totalCount += quote.audioQuotesCount
                        totalCount += quote.textQuotesCount
                    }
                    
                    //self.lblNoQuotes.text = "\(unwrappedQuotes.table!.first?.totalCount)"
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    
                }
                }, onFailure: { (error) in
                    print(error.description)
                }, loadingViewController: self)
        }
    }
}
