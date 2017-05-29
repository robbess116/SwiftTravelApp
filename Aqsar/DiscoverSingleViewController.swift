//
//  DiscoverSingleViewController.swift
//  Aqsar
//
//  Created by moayad on 7/31/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit
import RealmSwift
import BRYXBanner

class DiscoverSingleViewController: BaseViewController {
    //MARK:- IBOutlets
   
    @IBOutlet weak fileprivate var lblCustomTitle: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    //IVars
    fileprivate var selectedBooksIDs:[Int] = []
    fileprivate var selectedBookIDsString:[String] = []
    
    //MARK:- Properties
    var isLatest: Bool?
    var books = [Book]()
    var currentBook: Book?
    var papers = [Paper]()
    
    fileprivate var selectedType: LibrarySelectionType = .unread
    fileprivate var unReadBooks = [Book]()
    var currentCategoryID = "00000000-0000-0000-0000-000000000000"
    
    
    // api
    fileprivate var pageNumber = 2
    fileprivate var nextWave = 0
    
    // filter
    fileprivate var filterViewSingle:LibraryFilterView?
    fileprivate var selectedFilterRow = 0
    
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        lblCustomTitle.text = isLatest == true ? "الاحدث" : "الاكثر قراءة"
        
        //self.tabBarController?.tabBar.layer.zPosition = -1
        collectionView.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        nextWave =  books.count >= 10 ? 10 : 0
               
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       UIApplication.shared.isStatusBarHidden = false
            
              UIApplication.shared.statusBarStyle = .default
        
        setUpNavigationBar()
        //nextWave = 0
        let parameters = ["PageNo": "1", "PageSize": "10", "Categories": currentCategoryID, "UserID": RealmHelper.getLoggedinUser()!.userID]
        if isLatest == true {
            ApiManager.sharedInstance.getDiscoverLatestBooks(parameters as [String : AnyObject]?, onSuccess: { (array) in
                if let books = array {
                    self.books.removeAll()
                    self.books = books.table!
                    self.nextWave =  self.books.count >= 10 ? 10 : 0
                    self.pageNumber = 2
                    self.collectionView.reloadData()
                    
                    
                }
                
            }, onFailure: { (error) in
                print(error.description)
            }, loadingViewController: nil)
        } else {
            ApiManager.sharedInstance.getDiscoverMostRedBooks(parameters as [String : AnyObject]?, onSuccess: { (array) in
                if let books = array {
                    self.books.removeAll()
                    self.books = books.table!
                    self.nextWave =  self.books.count >= 10 ? 10 : 0
                    self.pageNumber = 2
                    self.collectionView.reloadData()
                    
                    
                }
            }, onFailure: { (error) in
                print(error.description)
            }, loadingViewController: nil)
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        getAndDisplayUserBooks(0, pageNumber: 1)
        
    }
    
    //MARK:- Navigation
    fileprivate func setUpNavigationBar() {
        
//        if isLatest! {
//            title = "الجديد"
//        }else{
//            title = "الأكثر قراءة"
//        }
        let attributes = [NSFontAttributeName: UIFont(name: "DroidArabicKufi", size: 17)!, NSForegroundColorAttributeName: darkGreen]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
        navigationController?.navigationBar.tintColor = darkGreen
        self.navigationItem.leftBarButtonItem?.tintColor = darkGreen
        
        self.navigationItem.rightBarButtonItem =
            UIBarButtonItem(image:UIImage(named: "276._Filter"), style:.plain, target:self, action:#selector(filterTapped))
    }
    
    override func pop() {
        super.pop()
        
        print(getDollarSignSeperatedString(selectedBookIDsString))
        
        let parameters = ["UserID": RealmHelper.getLoggedinUser()!.userID, "BooksIds": getDollarSignSeperatedString(selectedBookIDsString)]
        
        ApiManager.sharedInstance.setUserBooks(parameters as [String : AnyObject]?, onSuccess: { (array) in
            print("Success")
        }, onFailure: { (error) in
                print(error.description)
            }, loadingViewController: nil)

    }
    
    //MARK:- Targets
    @objc fileprivate func filterTapped() {
        if Reachability.isConnectedToNetwork() == false {
            showNetowrkNoConnectivityAlertController()
            return
        }
        
        func addAndAnimateMenu() {
            //UIApplication.sharedApplication().keyWindow?.addSubview(filterView!)
            view.addSubview(filterViewSingle!)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.filterViewSingle?.frame.origin.y = screenHeight - 165 - 49
            }) 
        }
        
        if let _ = filterViewSingle {
            addAndAnimateMenu()
            if let filterMenu = filterViewSingle {
                filterMenu.selectedRow = selectedFilterRow
                filterMenu.tableView.isScrollEnabled = false
                filterMenu.tableView.reloadData()
            }
            
        } else {
            filterViewSingle = LibraryFilterView.instanceFromNib()
            
            filterViewSingle?.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: 165)
            filterViewSingle?.tableView.isScrollEnabled = false
            if let menu = filterViewSingle {
                menu.delegate = self
                menu.selectedRow = selectedFilterRow
            }
            
            addAndAnimateMenu()
        }
    }
    
    fileprivate func getAndDisplayUserBooks(_ status: Int, pageNumber: Int) {

        //CheckSub
        if checkSubscriptionAvailability() == false {
                    return
                }
        
        if Reachability.isConnectedToNetwork() == false {
            self.unReadBooks.removeAll()
            
            for book in (RealmHelper.getLoggedinUser()?.booksUnread)! {
                unReadBooks.append(book)
            }
            
            
            return
        }
        
        print(RealmHelper.getLoggedinUser()!.userID)
        let parameters = ["UserID": RealmHelper.getLoggedinUser()!.userID, "PageNo": "\(pageNumber)", "PageSize": "10", "Status": "\(status)","filterBy":"\(self.selectedFilterRow)"]
        
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
            self.collectionView.reloadData()
            
            
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
    


}

extension DiscoverSingleViewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView{
        //1
        switch kind {
        //2
        case UICollectionElementKindSectionHeader:
            //3
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: "DiscoverFooterCollectionReusableView",
                                                                             for: indexPath) as! DiscoverFooterCollectionReusableView
            
            return headerView
        default:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: "DiscoverFooterCollectionReusableView",
                                                                             for: indexPath) as! DiscoverFooterCollectionReusableView
            
            //headerView.isHidden = true
            
            return headerView

           
        }
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        if books.count%2 == 0 {
            return books.count/2
        }else {
            return books.count/2+1
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width/2 - 15, height: 360)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        
        //return books.count
        //let indexCurrentBook =  indexPath.section * 2 + indexPath.row

        if books.count%2 == 0 {
            return 2
        }else {
            if section == books.count/2 {
                return 1
            } else {
                return 2
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath){
        
        if books.count - 1 == (indexPath.section * 2 + indexPath.row) && nextWave >= 10 {
            if Reachability.isConnectedToNetwork() == false {
                showNetowrkNoConnectivityAlertController()
                return
            }
            
            print(currentCategoryID)
            
            let parameters = ["PageNo": "\(pageNumber)", "PageSize": "10", "Categories": currentCategoryID, "UserID": RealmHelper.getLoggedinUser()!.userID]
            if isLatest == true {
                ApiManager.sharedInstance.getDiscoverLatestBooks(parameters as [String : AnyObject]?, onSuccess: { (array) in
                    if let books = array {
                        for book in books.table! {
                            self.books.append(book)
                        }
                        
                        self.nextWave = books.table!.count
                        self.pageNumber = self.pageNumber + 1
                        self.collectionView.reloadData()
                    }
                    
                }, onFailure: { (error) in
                    print(error.description)
                }, loadingViewController: nil)
            } else {
                ApiManager.sharedInstance.getDiscoverMostRedBooks(parameters as [String : AnyObject]?, onSuccess: { (array) in
                    if let books = array {
                        for book in books.table! {
                            self.books.append(book)
                        }
                        
                        self.nextWave = books.table!.count
                        self.pageNumber = self.pageNumber + 1
                        self.collectionView.reloadData()
                    }
                }, onFailure: { (error) in
                    print(error.description)
                }, loadingViewController: nil)
            }
        }
    }


    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let indexCurrentBook =  indexPath.section * 2 + indexPath.row
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverMainCollectionViewCell",
                                                      for: indexPath) as! DiscoverMainCollectionViewCell

//        if indexCurrentBook > (books.count-1){
//            cell.isHidden = true
//            return cell
//        }else{
                        //cell.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            
            let currentBookToChoose = books[indexCurrentBook]
            
            if isLatest! {
                cell.lblTitle.text = currentBookToChoose.title
                cell.lblAuthor.text = currentBookToChoose.author
                
//                cell.imgSound.isHidden = currentBookToChoose.hasAudio.lowercased().trimmingCharacters(in: CharacterSet.whitespaces) == "true" ? false : true
                
                cell.rate = 4
                
                cell.imgIcon.kf.setImage(with:URL(string: getFullURLImage(currentBookToChoose.imageID)))
                
                
                if currentBookToChoose.status == 0 || currentBookToChoose.status == -1{
                    cell.lblTotalPagesCount.isHidden = true
                    cell.lblProgressPagesCount.isHidden = true
                    cell.btnAdd.isHidden = false
                    
                    var isExist = false
                    
                    for book in unReadBooks {
                        
                        
                        if book.bookID == currentBookToChoose.bookID {
                            isExist = true
                        }
                    }
                    
                    if isExist {
                        cell.btnAdd.setImage(UIImage(named: "Shape_154"), for: .normal)
                        //                    cell.btnAdd.isEnabled = false
                    } else {
                        cell.btnAdd.setImage(UIImage(named: "Shape_151_copy"), for: .normal)
                    }
                    
                    cell.btnAdd.tag = indexCurrentBook
                    //                cell.btnAdd.tag = 1000 +  indexPath.row
                    
                    cell.btnAdd.addTarget(self, action: #selector(addLatestTapped), for: .touchUpInside)
                    
                } else {
                    cell.lblTotalPagesCount.isHidden = false
                    cell.lblProgressPagesCount.isHidden = false
                    //Change progress 0 to 1
                    //                if currentBookToChoose.progress == 1 {
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
                    
                    
                    //                if currentBookToChoose.totalPages > 10 && currentBookToChoose.progress < 11 {
                    //                    if cell.lblProgressPagesCount.frame.origin.y > 185 {
                    //                        cell.lblProgressPagesCount.frame.origin.y = cell.lblProgressPagesCount.frame.origin.y - 5
                    //                    }
                    //                } else {
                    //                    cell.lblProgressPagesCount.frame.origin.y = 190
                    //                }
                    
                    cell.addTotalPapersCount(currentBookToChoose.totalPages)
                    cell.addProgressPapersCount(currentBookToChoose.progress)
                }
                
            }else{
                cell.lblTitle.text = currentBookToChoose.title
                cell.lblAuthor.text = currentBookToChoose.author
                cell.rate = 4
                
//                cell.imgSound.isHidden = currentBookToChoose.hasAudio.lowercased().trimmingCharacters(in: CharacterSet.whitespaces) == "true" ? false : true
                cell.imgIcon.kf.setImage(with:URL(string: getFullURLImage(currentBookToChoose.imageID)))
                
                if currentBookToChoose.status == 0 || currentBookToChoose.status == -1{
                    cell.lblTotalPagesCount.isHidden = true
                    cell.lblProgressPagesCount.isHidden = true
                    cell.btnAdd.isHidden = false
                    var isExist = false
                    
                    for book in unReadBooks {
                        
                        if book.bookID == currentBookToChoose.bookID {
                            isExist = true
                        }
                    }
                    
                    if isExist {
                        cell.btnAdd.setImage(UIImage(named: "Shape_154"), for: .normal)
                        
                    } else {
                        cell.btnAdd.setImage(UIImage(named: "Shape_151_copy"), for: .normal)
                    }
                    
                    cell.btnAdd.tag = indexCurrentBook
                    //            cell.btnAdd.tag = 1000 +  indexPath.row
                    
                    cell.btnAdd.addTarget(self, action: #selector(addMostReadTapped), for: .touchUpInside)
                    
                } else {
                    cell.lblTotalPagesCount.isHidden = false
                    cell.lblProgressPagesCount.isHidden = false
                    //                if currentBookToChoose.progress == 1 {
                    //                    cell.btnAdd.setImage(UIImage(named: "Shape_154"), for: .normal)
                    //                    cell.btnAdd.isHidden = false
                    //                    cell.lblTotalPagesCount.isHidden = true
                    //                    cell.lblProgressPagesCount.isHidden = true
                    //                }else{
                    cell.btnAdd.isHidden = true
                    cell.btnAdd.setImage(UIImage(named: "Shape_151_copy"), for: .normal)
                    cell.lblTotalPagesCount.isHidden = false
                    cell.lblProgressPagesCount.isHidden = false
                    //                }
                    
                    //               if currentBookToChoose.totalPages > 10 && currentBookToChoose.progress < 11 {
                    //                   if cell.lblProgressPagesCount.frame.origin.y > 185 {
                    //                       cell.lblProgressPagesCount.frame.origin.y = cell.lblProgressPagesCount.frame.origin.y - 5
                    //                   }
                    //               } else {
                    //                   cell.lblProgressPagesCount.frame.origin.y = 190
                    //               }
                    
                    cell.addTotalPapersCount(currentBookToChoose.totalPages)
                    cell.addProgressPapersCount(currentBookToChoose.progress)
                }
                
                
                
            }
            
            return cell
 
//        }

        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentBookToChoose = books[indexPath.section * 2 + indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
               if currentBookToChoose.status == -1 || currentBookToChoose.status == 0 {
            let summaryVC = storyboard.instantiateViewController(withIdentifier: "SummaryViewController") as! SummaryViewController
            summaryVC.currentBook = currentBookToChoose
                var isExist =  true
                for book in unReadBooks {
                                        
                    if book.bookID == currentBookToChoose.bookID {
                        isExist = false
                    }
                }
                summaryVC.flagBtnAdd = isExist

            present(summaryVC, animated: true, completion: nil)
        }else {
            let bookDetailsVC = storyboard.instantiateViewController(withIdentifier: "BookDetailsViewController") as! BookDetailsViewController
            
            bookDetailsVC.currentBook = currentBookToChoose
            present(bookDetailsVC, animated: true, completion: nil)
            
        }

    }


    func addLatestTapped(_ button: UIButton) {
        print(button.tag)
        let currentBook = books[button.tag]
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
        
        let currentBook = books[button.tag]
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

extension DiscoverSingleViewController:LibraryFilterViewDelegate {
    func libraryFilterCloseDidTap() {
        UIView.animate(withDuration: 0.25, animations: {
            self.filterViewSingle?.frame.origin.y = screenHeight
        }, completion: { _ in
            self.filterViewSingle?.removeFromSuperview()
            self.view.isUserInteractionEnabled = true
        }) 
        
    }
    
    func libraryFilterRowDidSelected(_ row: Int) {
        UIView.animate(withDuration: 0.25, animations: {
            self.filterViewSingle?.frame.origin.y = screenHeight
        }, completion: { _ in
            self.filterViewSingle?.removeFromSuperview()
            self.view.isUserInteractionEnabled = true
            
            self.setTabBarDisabled(false)
            
            self.selectedFilterRow = row
            
            
                        
        })
    }
}
