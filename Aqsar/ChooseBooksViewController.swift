//
//  ChooseBooksViewController.swift
//  Aqsar
//
//  Created by moayad on 7/27/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit
import RealmSwift
import Kingfisher

class ChooseBooksViewController: BaseViewController {
    //MARK:- IBOutlets
    @IBOutlet weak fileprivate var tableView: UITableView!
    
    //MARK:- IVars
    fileprivate var booksToChoose = [Book]()
    
    fileprivate var selectedBooksIDs:[Int] = []
    
    // api
    fileprivate var pageNumber = 1
    fileprivate var nextWave = 0
    
    fileprivate var selectedBookIDsString:[String] = []
    
    // api
    var catsIDsParam = [String]()
    
    //MARK:- Life Cycle
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBar()
        
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getAndDisplayBooks()
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
        
        UIApplication.shared.statusBarStyle = .lightContent
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        
    }
    //MARK:- Navigation
    fileprivate func setUpNavigationBar() {
        title = "اختيار الكتب"
        let attributes = [NSFontAttributeName: UIFont(name: "DroidArabicKufi", size: 17)!, NSForegroundColorAttributeName: darkGreen]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
        navigationController?.navigationBar.tintColor = darkGreen
        self.navigationItem.leftBarButtonItem?.tintColor = darkGreen
        
        self.navigationItem.rightBarButtonItem =
            UIBarButtonItem(image:UIImage(named: "check"), style:.plain, target:self, action:#selector(doneTapped))
        self.navigationController?.navigationBar.isHidden = false

    }
    
    //MARK:- API
    fileprivate func getAndDisplayBooks() {
        if Reachability.isConnectedToNetwork() == false {
            showNetowrkNoConnectivityAlertController()
            return
        }
        
        print((RealmHelper.getLoggedinUser()?.categories)!)
        
        
        for categoryID in (RealmHelper.getLoggedinUser()?.categories)! {
            catsIDsParam.append(categoryID.categoryID)
        }

        let parameters = ["Categories": getDollarSignSeperatedString(catsIDsParam), "PageNo": "\(pageNumber)", "PageSize": "10"]
        
        ApiManager.sharedInstance.getBooksToChoose(parameters as [String : AnyObject]?, onSuccess: { (array) in
            self.booksToChoose = (array?.table)!
            //self.booksTotalCountsFromServer = (array?.table?.first?.totalCount)!
            self.nextWave = (array?.table?.count)!
            self.tableView.reloadData()
            }, onFailure: { (error) in
                print(error.description)
            }, loadingViewController: nil)
    }
    
    //MARK:- Targets
    @objc fileprivate func poped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func doneTapped() {
        if Reachability.isConnectedToNetwork() == false {
            showNetowrkNoConnectivityAlertController()
            return
        }
        
        if selectedBooksIDs.count == 0 {
            let alertController = UIAlertController(title: nil, message: "الرجاء اختيار كتاب واحد على الاقل للمتابعة", preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "موافق", style: .default) { (action) in
                
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true) {
                // ...
            }
            
            return
        }
        
        
        let parameters = ["UserID": RealmHelper.getLoggedinUser()!.userID, "BooksIds": getDollarSignSeperatedString(selectedBookIDsString)]
        
        ApiManager.sharedInstance.setUserBooks(parameters as [String : AnyObject]?, onSuccess: { (array) in
            

            let realm = try! Realm()
            try! realm.write {
                //realm.delete((RealmHelper.getLoggedinUser()?.booksUnread)!)
                for index in self.selectedBooksIDs {
                    if realm.object(ofType: Book.self, forPrimaryKey: self.booksToChoose[index].bookID) != nil {
                        
                        continue
                    }else{
                        
                        RealmHelper.getLoggedinUser()!.booksUnread.append(self.booksToChoose[index])
                    }

                    
                }
                realm.add(RealmHelper.getLoggedinUser()!, update: true)
                
                self.getAndDisplayPapers()
            }
            
            self.performSegue(withIdentifier: "toTabBar", sender: self)
            }, onFailure: { (error) in
                print(error.description)
                self.performSegue(withIdentifier: "toTabBar", sender: self)
            }, loadingViewController: nil)
    }
    
    
    fileprivate func getAndDisplayPapers() {
        if !Reachability.isConnectedToNetwork() {
            
            return
        }
        for index in self.selectedBooksIDs{
            
            let parameters = ["BookID": "\(self.booksToChoose[index].bookID)"]
            
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
                    
                    
                    
                    if let bookUnread = RealmHelper.getLoggedinUser()?.booksUnread.filter("bookID == \"\(self.booksToChoose[index].bookID)\"").first {
                        cachPapers(bookUnread)
                    } else if let bookInProgress = RealmHelper.getLoggedinUser()?.booksInProgress.filter("bookID == \"\(self.booksToChoose[index].bookID)\"").first {
                        cachPapers(bookInProgress)
                    } else if let bookFinished = RealmHelper.getLoggedinUser()?.booksFinished.filter("bookID == \"\(self.booksToChoose[index].bookID)\"").first {
                        cachPapers(bookFinished)
                    } else if let bookFavorite = RealmHelper.getLoggedinUser()?.booksFavorites.filter("bookID == \"\(self.booksToChoose[index].bookID)\"").first {
                        cachPapers(bookFavorite)
                    }
                                        
                }
            }, onFailure: { (error) in
                print(error.description)
            }, loadingViewController: nil)
            
        }

        
    }

}


extension ChooseBooksViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return booksToChoose.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if booksToChoose.count - 1 == indexPath.row && nextWave >= 10 {
             pageNumber = pageNumber + 1
            
            let parameters = ["Categories": getDollarSignSeperatedString(catsIDsParam), "PageNo": "\(pageNumber)", "PageSize": "10"]
            
            ApiManager.sharedInstance.getBooksToChoose(parameters as [String : AnyObject]?, onSuccess: { (array) in
                for book in (array?.table)! {
                    self.booksToChoose.append(book)
                }
                
                self.nextWave = (array?.table?.count)!
                print(self.nextWave)
                
                //self.booksTotalCountsFromServer = self.booksTotalCountsFromServer - 10
                self.tableView.reloadData()
                }, onFailure: { (error) in
                    print(error.description)
                }, loadingViewController: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BooksToChooseCell") as! BooksToChooseCell
        
        let currentBookToChoose = booksToChoose[indexPath.row]
        
        cell.lblName.text = currentBookToChoose.title
        cell.lblBrief.text = currentBookToChoose.summary
        cell.lblAuthor.text = currentBookToChoose.author
        cell.lblNoViews.text = "deprecated"
        
        print(currentBookToChoose.hasAudio)
        
//        cell.rate = currentBookToChoose.rate
        cell.imgSound.isHidden = currentBookToChoose.hasAudio.lowercased().trimmingCharacters(in: CharacterSet.whitespaces) == "true" ? false : true
        
        cell.btnAdd.tag = indexPath.row
        cell.btnAdd.addTarget(self, action: #selector(addTapped(_:)), for: .touchUpInside)
        
        if selectedBooksIDs.contains(indexPath.row) {
            cell.btnAdd.setBackgroundImage(UIImage(named: "Shape_154-1"), for: UIControlState())
        } else {
            cell.btnAdd.setBackgroundImage(UIImage(named: "Shape_151_copy"), for: UIControlState())
        }
        
        cell.imgIcon.kf.setImage(with: URL(string: getFullURLImage(currentBookToChoose.imageID)))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let currentBook = booksToChoose[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let summaryVC = storyboard.instantiateViewController(withIdentifier: "SummaryViewController") as! SummaryViewController
        summaryVC.currentBook = currentBook
        present(summaryVC, animated: true, completion: nil)
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerCell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell")
//        
//        return headerCell
//    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 70
//    }
    
    func addTapped(_ button: UIButton) {
        let currentBook = booksToChoose[button.tag]
        
//        if selectedBooksIDs.contains(button.tag) {
//            selectedBooksIDs.removeAtIndex(selectedBooksIDs.indexOf(button.tag)!)
//            selectedBookIDsString.removeAtIndex(button.tag)
//            
//        } else {
//            selectedBooksIDs.append(button.tag)
//            selectedBookIDsString.append(currentBook.bookID)
//        }
        
        
        if selectedBooksIDs.contains(button.tag) {
            let indexToDelete = selectedBooksIDs.index(of: button.tag)!
            print(indexToDelete)
            selectedBooksIDs.remove(at: indexToDelete)
            selectedBookIDsString.remove(at: indexToDelete)
            
        } else {
            selectedBooksIDs.append(button.tag)
            selectedBookIDsString.append(currentBook.bookID)
        }
        tableView.reloadData()
    }
}
