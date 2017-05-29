//
//  DiscoverMainViewController.swift
//  Aqsar
//
//  Created by moayad on 7/30/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit
import BRYXBanner
import RealmSwift

class DiscoverMainViewController: BaseViewController {
    //MARK:- IBOutlets
    @IBOutlet weak fileprivate var tableView: UITableView!
    @IBOutlet weak fileprivate var imgHeader: UIImageView!
    @IBOutlet weak fileprivate var lblHeaderTitle: UILabel!
    @IBOutlet weak var lblHeaderAuthor: UILabel!
    
    @IBOutlet weak var conHeight: NSLayoutConstraint!
    
    @IBOutlet weak var headerPageControl: UIPageControl!
    @IBOutlet weak var headerCollectionView: UICollectionView!
    
   
    //MARK:- IVars
    fileprivate var storedOffsets = [Int: CGFloat]()
    fileprivate var menuView:UIView?
    fileprivate var selectedMenuRow = 0
    fileprivate var selectedType: LibrarySelectionType = .unread
    
    fileprivate var booksLatest = [Book]()
    fileprivate var booksMostRedundent = [Book]()
    fileprivate var headerBooks = [Book]()
    fileprivate var unReadBooks = [Book]()
    
    //apis
    fileprivate var currentCategoryID = "00000000-0000-0000-0000-000000000000"
    fileprivate var isLatestWatchAll = false
    fileprivate var refreshControl: UIRefreshControl!
    
    //MARK:- IVars
    var currentBook: Book?
    var papers = [Paper]()
    var discoverSingleVC:DiscoverSingleViewController!
    
    // header collection view
    let headercollectionViewTag = 201

    //MARK:- Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.setStatusBarHidden(false, with: .none)
        
        setUpNavigationBar()
        
        tableView.reloadData()
        
        if let _ = AudioPlayer.sharedInstance.partName {
            conHeight.constant = 60
        } else {
            conHeight.constant = 0
        }
       
        UIApplication.shared.isStatusBarHidden = false
            
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.statusBarStyle = .default
        getAndDisplayLatestBooks()
        //getAndDisplayMostRedBooks()
        getAndDisplayUserBooks(0, pageNumber: 1)
        getHeaderBooks()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
              
        headerPageControl.numberOfPages = 0
        
        tableView.register(UINib(nibName: "AudioPlayerCell", bundle: nil), forCellReuseIdentifier: "AudioPlayerCell")
        
        
        

        
        // pull to refresh setup
        refreshControl = UIRefreshControl()
        //refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        refreshControl.tintColor = darkGreen
        tableView.addSubview(refreshControl)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        discoverSingleVC = storyboard.instantiateViewController(withIdentifier: "DiscoverSingleViewController") as? DiscoverSingleViewController
        
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
    
    fileprivate func setupImgHeader() {
        imgHeader.isUserInteractionEnabled = true
        let imgTapGesture = UITapGestureRecognizer(target: self, action: #selector(imgHeaderTapped))
        
        imgHeader.addGestureRecognizer(imgTapGesture)
    }
    
    //MARK:- API
    fileprivate func getAndDisplayLatestBooks() {
        if Reachability.isConnectedToNetwork() == false {
            showNetowrkNoConnectivityAlertController()
            return
        }
        
        let parameters = ["PageNo": "1", "PageSize": "10", "Categories": currentCategoryID, "UserID": RealmHelper.getLoggedinUser()!.userID]
        ApiManager.sharedInstance.getDiscoverLatestBooks(parameters as [String : AnyObject]?, onSuccess: { (array) in
            if let books = array {
                self.booksLatest.removeAll()
                self.booksLatest = books.table!
                self.tableView.reloadData()
                
                self.getAndDisplayMostRedBooks()
            }
            }, onFailure: { (error) in
                print(error.description)
            }, loadingViewController: self)
    }
    
    fileprivate func getAndDisplayMostRedBooks() {
        if Reachability.isConnectedToNetwork() == false {
            showNetowrkNoConnectivityAlertController()
            return
        }
        
        let parameters = ["PageNo": "1", "PageSize": "10", "Categories": currentCategoryID, "UserID": RealmHelper.getLoggedinUser()!.userID]
        ApiManager.sharedInstance.getDiscoverMostRedBooks(parameters as [String : AnyObject]?, onSuccess: { (array) in
            if let books = array {
                self.booksMostRedundent.removeAll()
                self.booksMostRedundent = books.table!
                print(self.booksMostRedundent)
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
            }, onFailure: { (error) in
                print(error.description)
            }, loadingViewController: nil)
    }
    
    fileprivate func getHeaderBooks() {
        let parameters = ["PageNo": "1", "PageSize": "10", "Categories": currentCategoryID]
        
        ApiManager.sharedInstance.getDiscoverHeaderBook(parameters as [String : AnyObject]?, onSuccess: { array in
            if let books = array {
                self.headerBooks = books.table!
                self.headerPageControl.numberOfPages = self.headerBooks.count
                self.headerCollectionView.reloadData()
                
//                self.imgHeader.kf_setImageWithURL(NSURL(string: self.getFullURLImage((headerBook?.imageID)!)))
//                self.lblHeaderTitle.text = headerBook?.title
//                self.lblHeaderAuthor.text = headerBook?.author
            }
            }, onFailure: { (error) in
                print(error.description)
            }, loadingViewController: nil)
    }
    
    
    fileprivate func getAndDisplayUserBooks(_ status: Int, pageNumber: Int) {
        //CheckSub
                if checkSubscriptionAvailability() == false {
                    return
                }
        
        if Reachability.isConnectedToNetwork() == false {
            
            
            for book in (RealmHelper.getLoggedinUser()?.booksUnread)! {
                unReadBooks.append(book)
            }
            
            
            return
        }
        
        print(RealmHelper.getLoggedinUser()!.userID)
        let parameters = ["UserID": RealmHelper.getLoggedinUser()!.userID, "PageNo": "\(pageNumber)", "PageSize": "10", "Status": "\(status)","filterBy":"0"]
        
        ApiManager.sharedInstance.getUserLibrary(parameters as [String : AnyObject]?, onSuccess: { userBooks in
            if let unwrappedUserBooks = userBooks {
                self.unReadBooks.removeAll()
                if self.selectedType == .unread {
//                    self.nextWaveForUnread = (unwrappedUserBooks.table?.count)!
//                    print(self.nextWaveForUnread)
                    for book in unwrappedUserBooks.table! {
                        self.unReadBooks.append(book)
                    }
                    
                    let realm = try! Realm()
                    try! realm.write {
                        //RealmHelper.getLoggedinUser()?.booksUnread.removeAll()
                        for book in unwrappedUserBooks.table! {
                            if realm.object(ofType: Book.self, forPrimaryKey: book.bookID) != nil{
                                continue
                            }else{
                                RealmHelper.getLoggedinUser()!.booksUnread.append(book)
                            }
                            
                        }
                        
                        realm.add(RealmHelper.getLoggedinUser()!, update: true)
                    }
                }
            }
            print(self.unReadBooks);
            self.tableView.reloadData()
           
            
        }, onFailure: { (error) in
            print(error.description)
        }, loadingViewController: nil)
    }
    
    
    fileprivate func getAndDisplayPapers() {
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

    fileprivate func removeFromLibraries(bookID: String) {
        
//        let bookID = selectedType == .unread ? unReadBooks[button.tag].bookID : inProgressBooks[button.tag].bookID
        
        print(bookID)
        
        //let parameters = ["UserId": RealmHelper.getLoggedinUser()!.userID, "BookID": bookID]
        
        let parameters = ["UserID":RealmHelper.getLoggedinUser()!.userID, "BookID": bookID, "Status": "-1"]
        
        ApiManager.sharedInstance.setBookStatus(parameters as [String : AnyObject]?, onSuccess: { (array) in
            //ApiManager.sharedInstance.removeBookFromFavorites(parameters, onSuccess: { (array) in
            let banner = Banner(title: nil, subtitle: "تم حذف الكتاب من قائمة المكتبة", image: nil, backgroundColor: lightShinyGreenColor, didTapBlock: nil)
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
            
            self.getAndDisplayUserBooks(0, pageNumber: 1)
            
            
        }, onFailure: { (error) in
            print(error.description)
            
            let banner = Banner(title: nil, subtitle: "خطأ في العملية. يرجى المحاولة مرة اخرى", image: nil, backgroundColor: lightShinyGreenColor, didTapBlock: nil)
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
        }, loadingViewController: nil)
    }

    
    //MARK:- Navigation
    fileprivate func setUpNavigationBar() {
        //title = "اكتشف"
        let attributes = [NSFontAttributeName: UIFont(name: "DroidArabicKufi", size: 17)!, NSForegroundColorAttributeName: darkGreen]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
        navigationController?.navigationBar.tintColor = darkGreen
        self.navigationItem.leftBarButtonItem?.tintColor = darkGreen
        
        self.navigationItem.leftBarButtonItem =
            UIBarButtonItem(image:UIImage(named: "magnifier"), style:.plain, target:self, action:#selector(searchTapped))
        
        self.navigationItem.rightBarButtonItem =
            UIBarButtonItem(image:UIImage(named: "290._Stack"), style:.plain, target:self, action:#selector(stackTapped))
    }
    
    //MARK:- Audio Player
    override func closeDidTap() {
        super.closeDidTap()
        conHeight.constant = 0
    }
    
    //MARK:- Targets
    @objc fileprivate func poped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func stackTapped() {
        func addAndAnimateMenu() {
            UIApplication.shared.keyWindow?.addSubview(menuView!)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.menuView?.frame.origin.x = 0
            }) 
        }
        
        if let _ = menuView {
            addAndAnimateMenu()
            if let menu = menuView as? DiscoverMenuView {
                menu.selectedRow = selectedMenuRow
                menu.tableView.reloadData()
            }

        } else {
            menuView = DiscoverMenuView.instanceFromNib()
            
            menuView?.frame = CGRect(x: screenWidth, y: 0, width: screenWidth, height: screenHeight)
            
            if let menu = menuView as? DiscoverMenuView {
                menu.delegate = self
                menu.selectedRow = selectedMenuRow
            }
            
            addAndAnimateMenu()
        }
        
        view.isUserInteractionEnabled = false
        setTabBarDisabled(true)
    }
    
    @objc fileprivate func searchTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let searchVC = storyboard.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        
        present(searchVC, animated: true, completion: nil)
    }
    
    func imgHeaderTapped() {
        
    }
    
    func refresh() {
        if Reachability.isConnectedToNetwork() == false {
            showNetowrkNoConnectivityAlertController()
            self.refreshControl.endRefreshing()
            return
        }
        
        let parameters = ["PageNo": "1", "PageSize": "10", "Categories": currentCategoryID, "UserID": RealmHelper.getLoggedinUser()!.userID]
        ApiManager.sharedInstance.getDiscoverLatestBooks(parameters as [String : AnyObject]?, onSuccess: { (array) in
            if let books = array {
                self.booksLatest.removeAll()
                self.booksLatest = books.table!
                //self.refreshControl.endRefreshing()
                self.tableView.reloadData()
                
                self.getAndDisplayMostRedBooks()
            }
            }, onFailure: { (error) in
                print(error.description)
            }, loadingViewController: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDiscoverSingle" {
            let destinationVC = segue.destination as! DiscoverSingleViewController
            
            destinationVC.isLatest = isLatestWatchAll
            destinationVC.books = isLatestWatchAll == true ? booksLatest : booksMostRedundent
            destinationVC.currentCategoryID = currentCategoryID
            
            //destinationVC.hidesBottomBarWhenPushed = true
        }
    }
    
    

}

extension DiscoverMainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                                   forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? DiscoverMainTableViewCell else { return }
        
       // tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        tableViewCell.collectionView.delegate = self
        tableViewCell.collectionView.dataSource = self
        tableViewCell.collectionView.tag = indexPath.row
        tableViewCell.collectionView.reloadData()
        tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    
    func tableView(_ tableView: UITableView,
                   didEndDisplaying cell: UITableViewCell,
                                        forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? DiscoverMainTableViewCell else { return }
        
        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverMainTableViewCell",
                                                               for: indexPath) as! DiscoverMainTableViewCell
        
        cell.btnWatchAll.tag = indexPath.row
        cell.lblTitle.text = indexPath.row == 0 ? "الاحدث" : "الاكثر قراءة"
        cell.btnWatchAll.addTarget(self, action: #selector(watchAllTapped(_:)), for: .touchUpInside)
        if indexPath.row == 0 && booksLatest.count == 0{
            cell.lblTitle.isHidden = false
            cell.btnWatchAll.isHidden = false
        }
        
        if indexPath.row == 1 && booksMostRedundent.count == 0{
            cell.lblTitle.isHidden = false
            cell.btnWatchAll.isHidden = false

        }
        return cell
    }
    
    @objc fileprivate func watchAllTapped(_ button: UIButton) {
        isLatestWatchAll = button.tag == 0 ? true : false
        performSegue(withIdentifier: "toDiscoverSingle", sender: self)
    }
}

extension DiscoverMainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == headercollectionViewTag {
            return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
        }
        
        return CGSize(width: 110.0, height: 268.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView.tag == headercollectionViewTag {
            return 0
        }
        return 11
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = self.headerCollectionView.frame.size.width
        headerPageControl.currentPage = Int(self.headerCollectionView.contentOffset.x / pageWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        if collectionView.tag == headercollectionViewTag {
            return headerBooks.count
        }
        
        if collectionView.tag == 0 {
            return booksLatest.count
        }
        
        return booksMostRedundent.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == headercollectionViewTag {
            let headerCell = collectionView.dequeueReusableCell(withReuseIdentifier: "headerCell", for: indexPath)
            
            let lblTitle = headerCell.viewWithTag(100) as! UILabel
            let lblAuthor = headerCell.viewWithTag(101) as! UILabel
            let imageView = headerCell.viewWithTag(102) as! UIImageView
            
            let currentHeaderBook = headerBooks[indexPath.row]
            
            lblTitle.text = currentHeaderBook.title
            lblAuthor.text = currentHeaderBook.author
            imageView.kf.setImage(with: URL(string: getFullURLImage(currentHeaderBook.imageID)))
            
            return headerCell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverMainCollectionViewCell",
                                                                         for: indexPath) as! DiscoverMainCollectionViewCell
        if collectionView.tag == 0 && booksLatest.count != 0 {
            let currentBook = collectionView.tag == 0 ? booksLatest[indexPath.row] : booksLatest[indexPath.row]
            
            cell.lblTitle.text = currentBook.title
            cell.lblAuthor.text = currentBook.author
            print(currentBook.hasAudio.lowercased())
            
//            cell.imgSound.isHidden = currentBook.hasAudio.lowercased().trimmingCharacters(in: CharacterSet.whitespaces) == "true" ? false : true

            cell.rate = 4
            
            cell.imgIcon.kf.setImage(with:URL(string: getFullURLImage(currentBook.imageID)))
            //            currentBook.totalPages = 20
//            currentBook.progress = 9
            
            print("statuse: \(currentBook.status)")
            //Change Status Value:-1 to 0
            if currentBook.status == 0 || currentBook.status == -1{
                cell.lblTotalPagesCount.isHidden = true
                cell.lblProgressPagesCount.isHidden = true
                cell.btnAdd.isHidden = false
                
                var isExist = false
                
                for book in unReadBooks {
                    print(book.bookID)
                    print(currentBook.bookID)
                    
                    if book.bookID == currentBook.bookID {
                        isExist = true
                    }
                }
                
                if isExist {
                    cell.btnAdd.setImage(UIImage(named: "Shape_154"), for: .normal)
//                    cell.btnAdd.isEnabled = false
                } else {
                    cell.btnAdd.setImage(UIImage(named: "Shape_151_copy"), for: .normal)
                }
                
                cell.btnAdd.tag = indexPath.row
//                cell.btnAdd.tag = 1000 +  indexPath.row

                cell.btnAdd.addTarget(self, action: #selector(addLatestTapped), for: .touchUpInside)
                
            } else {
                cell.lblTotalPagesCount.isHidden = false
                cell.lblProgressPagesCount.isHidden = false
                //Change progress 0 to 1
//                if currentBook.progress == 0 {
//                    cell.btnAdd.setImage(UIImage(named: "Shape_154"), for: .normal)
//                    cell.btnAdd.isHidden = false
//                    //BtnAdd no enable
//                    cell.btnAdd.isEnabled = false
//                    cell.lblTotalPagesCount.isHidden = true
//                    cell.lblProgressPagesCount.isHidden = true
//                }else{
                    cell.btnAdd.isHidden = true
                    cell.btnAdd.setImage(UIImage(named: "Shape_151_copy"), for: .normal)
                    cell.lblTotalPagesCount.isHidden = false
                    cell.lblProgressPagesCount.isHidden = false
//                }
                
                print(currentBook.title)
                if currentBook.totalPages > 10 && currentBook.progress < 11 {
                    if cell.lblProgressPagesCount.frame.origin.y > 185 {
//                        cell.lblProgressPagesCount.frame.origin.y = cell.lblProgressPagesCount.frame.origin.y - 5
                    }
                } else {
//                    cell.lblProgressPagesCount.frame.origin.y = 190
                }
                
                cell.addTotalPapersCount(currentBook.totalPages)
                cell.addProgressPapersCount(currentBook.progress)
            }
            
            return cell
        }
        
        let currentBook = booksMostRedundent[indexPath.row]
        
        cell.lblTitle.text = currentBook.title
        cell.lblAuthor.text = currentBook.author
        print(currentBook.hasAudio.lowercased())
        //cell.hasSound = currentBook.hasAudio.lowercaseString == "true" ? true : false
        cell.rate = 4
        
//        cell.imgSound.isHidden = currentBook.hasAudio.lowercased().trimmingCharacters(in: CharacterSet.whitespaces) == "true" ? false : true
        cell.imgIcon.kf.setImage(with:URL(string: getFullURLImage(currentBook.imageID)))
        
        if currentBook.status == 0 || currentBook.status == -1{
            cell.lblTotalPagesCount.isHidden = true
            cell.lblProgressPagesCount.isHidden = true
            cell.btnAdd.isHidden = false
            var isExist = false
            
            for book in unReadBooks {
                print(book.bookID)
                print(currentBook.bookID)
                
                if book.bookID == currentBook.bookID {
                    isExist = true
                }
            }
            
            if isExist {
                cell.btnAdd.setImage(UIImage(named: "Shape_154"), for: .normal)
                
            } else {
                cell.btnAdd.setImage(UIImage(named: "Shape_151_copy"), for: .normal)
            }
           
            cell.btnAdd.tag = indexPath.row
//            cell.btnAdd.tag = 1000 +  indexPath.row

            cell.btnAdd.addTarget(self, action: #selector(addMostReadTapped), for: .touchUpInside)
            
        } else {
            cell.lblTotalPagesCount.isHidden = false
            cell.lblProgressPagesCount.isHidden = false
//            if currentBook.progress == 0 {
//                cell.btnAdd.setImage(UIImage(named: "Shape_154"), for: .normal)
//                cell.btnAdd.isHidden = false
//                cell.lblTotalPagesCount.isHidden = true
//                cell.lblProgressPagesCount.isHidden = true
//            }else{
                cell.btnAdd.isHidden = true
                cell.btnAdd.setImage(UIImage(named: "Shape_151_copy"), for: .normal)
                cell.lblTotalPagesCount.isHidden = false
                cell.lblProgressPagesCount.isHidden = false
//            }
            
            print(currentBook.title)
            if currentBook.totalPages > 10 && currentBook.progress < 11 {
                if cell.lblProgressPagesCount.frame.origin.y > 185 {
//                    cell.lblProgressPagesCount.frame.origin.y = cell.lblProgressPagesCount.frame.origin.y - 5
                }
            } else {
//                cell.lblProgressPagesCount.frame.origin.y = 190
            }
            
            cell.addTotalPapersCount(currentBook.totalPages)
            cell.addProgressPapersCount(currentBook.progress)
        }
        
//        cell.imgSound.isHidden = currentBook.hasAudio.lowercased().trimmingCharacters(in: CharacterSet.whitespaces) == "true" ? false : true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentBook = collectionView.tag == 0 ? booksLatest[indexPath.row] : booksMostRedundent[indexPath.row]
//        let button =  self.view.viewWithTag(indexPath.row) as! UIButton
        
        if currentBook.status == -1 || currentBook.status == 0 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let summaryVC = storyboard.instantiateViewController(withIdentifier: "SummaryViewController") as! SummaryViewController
            summaryVC.currentBook = currentBook
            var isExist =  true
            for book in unReadBooks {
                               
                if book.bookID == currentBook.bookID {
                    isExist = false
                }
            }
            summaryVC.flagBtnAdd = isExist
            
            present(summaryVC, animated: true, completion: nil)
            
        }else {
           
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let bookDetailsVC = storyboard.instantiateViewController(withIdentifier: "BookDetailsViewController") as! BookDetailsViewController
            bookDetailsVC.currentBook = currentBook
            present(bookDetailsVC, animated: true, completion: nil)

        }
        
    }
    
    override func closeAudioTapped() {
        super.closeAudioTapped()
        
        tableView.reloadData()
    }
    
    func addLatestTapped(_ button: UIButton) {
        print(button.tag)
        let currentBook = booksLatest[button.tag]
        self.currentBook = currentBook
        
//        let btn = self.view.viewWithTag(button.tag) as! UIButton
        
        let parameters = ["UserID": RealmHelper.getLoggedinUser()!.userID, "BooksIds": currentBook.bookID]
        let image = button.currentImage
        if (image?.isEqual(UIImage(named: "Shape_154")))!{
            self.removeFromLibraries(bookID: currentBook.bookID)
        }else{
        ApiManager.sharedInstance.setUserBooks(parameters as [String : AnyObject]?, onSuccess: { (array) in
            let banner = Banner(title: nil, subtitle: "تم اضافة الكتاب الى المكتبة", image: nil, backgroundColor: lightShinyGreenColor, didTapBlock: nil)
//            btn.setImage(UIImage(named: "icon_circle_minus"), for: .normal)
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
            self.getAndDisplayUserBooks(0, pageNumber: 1)
            self.getAndDisplayPapers()

            }, onFailure: { (error) in
                print(error.description)
                let banner = Banner(title: nil, subtitle: "خطأ في العملية. يرجى المحاولة مرة اخرى", image: nil, backgroundColor: lightShinyGreenColor, didTapBlock: nil)
                banner.dismissesOnTap = true
                banner.show(duration: 3.0)
            }, loadingViewController: nil)
        }
        
    }
    
    func addMostReadTapped(_ button: UIButton) {
        print(button.tag)
        
        let currentBook = booksMostRedundent[button.tag]
        self.currentBook = currentBook
//        let btn = self.view.viewWithTag(button.tag) as! UIButton
        let parameters = ["UserID": RealmHelper.getLoggedinUser()!.userID, "BooksIds": currentBook.bookID]
        let image = button.currentImage
        if (image?.isEqual(UIImage(named: "Shape_154")))!{
            self.removeFromLibraries(bookID: currentBook.bookID)
        }else{
            ApiManager.sharedInstance.setUserBooks(parameters as [String : AnyObject]?, onSuccess: { (array) in
                let banner = Banner(title: nil, subtitle: "تم اضافة الكتاب الى المكتبة", image: nil, backgroundColor: lightShinyGreenColor, didTapBlock: nil)
                //            btn.setImage(UIImage(named: "icon_circle_minus"), for: .normal)
                
                banner.dismissesOnTap = true
                banner.show(duration: 3.0)
                self.getAndDisplayUserBooks(0, pageNumber: 1)
                self.getAndDisplayPapers()
            }, onFailure: { (error) in
                print(error.description)
                let banner = Banner(title: nil, subtitle: "خطأ في العملية. يرجى المحاولة مرة اخرى", image: nil, backgroundColor: lightShinyGreenColor, didTapBlock: nil)
                banner.dismissesOnTap = true
                
                banner.show(duration: 3.0)
            }, loadingViewController: nil)
 
        }
        
    }
}

extension DiscoverMainViewController: DiscoverMenuViewDelegate {
    func DiscoverMenuCloseDidTap() {
        UIView.animate(withDuration: 0.25, animations: {
            self.menuView?.frame.origin.x = screenWidth
            }, completion: { _ in
                self.menuView?.removeFromSuperview()
                self.view.isUserInteractionEnabled = true
                
                self.setTabBarDisabled(false)
        }) 
    }
    
    func DiscoverMenuRowDidSelected(_ row: Int, categoryID: String) {
        UIView.animate(withDuration: 0.25, animations: {
            self.menuView?.frame.origin.x = screenWidth
        }, completion: { _ in
            self.menuView?.removeFromSuperview()
            self.view.isUserInteractionEnabled = true
            
            self.setTabBarDisabled(false)
            
            if row == 1 { // newest
                self.isLatestWatchAll = true
                self.performSegue(withIdentifier: "toDiscoverSingle", sender: self)
                return
            }
            
            if row == 2 { // most read
                self.isLatestWatchAll = false
                self.performSegue(withIdentifier: "toDiscoverSingle", sender: self)
                return
            }
            
            if row == 0 {
                self.selectedMenuRow = row
                
                self.currentCategoryID = categoryID
                self.getAndDisplayLatestBooks()
                return
            }
            
            if row > 2 {
                self.discoverSingleVC.isLatest = true
                self.discoverSingleVC.currentCategoryID = categoryID
                self.navigationController?.pushViewController(self.discoverSingleVC, animated: true)
                return

            }
            
        })
    }
}
