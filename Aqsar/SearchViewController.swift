//
//  SearchViewController.swift
//  Aqsar
//
//  Created by moayad on 11/2/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    //MARK:- IBOutlets
    
    @IBOutlet weak fileprivate var tfSearch: UITextField!
    @IBOutlet weak fileprivate var tableView: UITableView!
    
    //MARK:- IVars
    fileprivate var books = [Book]()
    fileprivate var selectedBooksIDs:[Int] = []
    fileprivate var selectedBookIDsString:[String] = []
    
    fileprivate var pageNumber = 1
    fileprivate var nextWave = 0
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfSearch.becomeFirstResponder()
        tfSearch.addTarget(self, action: #selector(search), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        
    }
    //MARK:- Targets
    func search() {
        print(tfSearch.text!)
        
        let parameters = ["BookTitle": tfSearch.text!, "PageNo": "\(pageNumber)", "PageSize": "10", "UserID": RealmHelper.getLoggedinUser()!.userID]
        
        ApiManager.sharedInstance.getSearchBooks(parameters as [String : AnyObject]?, onSuccess: { (array) in
            if let searchBooks = array, searchBooks.table != nil  {
                self.books = searchBooks.table!
                self.nextWave = (array?.table?.count)!
                
                self.tableView.reloadData()
            }
            }, onFailure: { error in
                print(error.description)
            }, loadingViewController: nil)
    }
    
    //MARK:- IBActions
    @IBAction fileprivate func dismissTapped(_ sender: AnyObject) {
        tfSearch.resignFirstResponder()
        
        let parameters = ["UserID": RealmHelper.getLoggedinUser()!.userID, "BooksIds": getDollarSignSeperatedString(selectedBookIDsString)]
        
        ApiManager.sharedInstance.setUserBooks(parameters as [String : AnyObject]?, onSuccess: { (array) in
//            print(RealmHelper.getLoggedinUser())
//            
//            let realm = try! Realm()
//            try! realm.write {
//                realm.delete((RealmHelper.getLoggedinUser()?.booksUnread)!)
//                for index in self.selectedBooksIDs {
//                    RealmHelper.getLoggedinUser()!.booksUnread.append(self.booksToChoose[index])
//                }
//                realm.add(RealmHelper.getLoggedinUser()!, update: true)
//                
//                print(RealmHelper.getLoggedinUser())
//            }
            
            self.dismiss(animated: true, completion: nil)
            }, onFailure: { (error) in
                print(error.description)
                self.dismiss(animated: true, completion: nil)
            }, loadingViewController: nil)
    }
    
    @IBAction fileprivate func cancelTapped(_ sender: AnyObject) {
        tfSearch.resignFirstResponder()
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
//        let parameters = ["BookTitle": tfSearch.text!, "PageNo": "\(pageNumber)", "PageSize": "10", "UserID": RealmHelper.getLoggedinUser()!.userID]
//        
//        ApiManager.sharedInstance.getSearchBooks(parameters, onSuccess: { (array) in
//            if let searchBooks = array where searchBooks.table != nil  {
//                self.books = searchBooks.table!
//                self.nextWave = (array?.table?.count)!
//                
//                self.tableView.reloadData()
//            }
//            }, onFailure: { error in
//                print(error.description)
//            }, loadingViewController: self)
        
        return true
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as! SearchCell
        
        let currentBook = books[indexPath.row]
        
        cell.lblTitle.text = currentBook.title
        cell.lblSummary.text = currentBook.summary
        cell.lblAuthor.text = currentBook.author
        
        cell.imgAudio.isHidden = currentBook.hasAudio.lowercased().trimmingCharacters(in: CharacterSet.whitespaces) == "true" ? false : true
        
        cell.btnAdd.tag = indexPath.row
        cell.btnAdd.addTarget(self, action: #selector(addTapped(_:)), for: .touchUpInside)
        
        if selectedBooksIDs.contains(indexPath.row) {
            cell.btnAdd.setBackgroundImage(UIImage(named: "Shape_154"), for: UIControlState())
        } else {
            cell.btnAdd.setBackgroundImage(UIImage(named: "Shape_151_copy"), for: UIControlState())
        }
        
       cell.imgIcon.kf.setImage(with:URL(string: getFullURLImage(currentBook.imageID)))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if books.count - 1 == indexPath.row && nextWave >= 10 {
            pageNumber = pageNumber + 1
            
            let parameters = ["BookTitle": tfSearch.text!, "PageNo": "\(pageNumber)", "PageSize": "10", "UserID": RealmHelper.getLoggedinUser()!.userID]
            
            ApiManager.sharedInstance.getSearchBooks(parameters as [String : AnyObject]?, onSuccess: { (array) in
                for book in (array?.table)! {
                    self.books.append(book)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let currentBook = books[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let summaryVC = storyboard.instantiateViewController(withIdentifier: "SummaryViewController") as! SummaryViewController
        summaryVC.currentBook = currentBook
        present(summaryVC, animated: true, completion: nil)
    }
    
    func addTapped(_ button: UIButton) {
        let currentBook = books[button.tag]
        
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
