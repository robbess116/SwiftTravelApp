//
//  SummaryViewController.swift
//  Aqsar
//
//  Created by moayad on 11/20/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit
import BRYXBanner

class SummaryViewController: UIViewController {
    //MARK:- IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    
    var currentBook: Book?
    var flagBtnAdd: Bool? = true
    var bookDetailsVC: BookDetailsViewController!
    var playerVC: PlayerViewController!
    var papers = [Paper]()
    fileprivate var shouldDisplayAudios = false
    fileprivate var currentPaperIndex = 0
    fileprivate var formattedPapersString = ""
    static var summaryDetailsFlag:Bool = false

    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        
        tableView.estimatedRowHeight = 83
        tableView.rowHeight = UITableViewAutomaticDimension
        
        print(currentBook?.descriptionText ?? "")
        lblTitle.text = currentBook?.title
        //flagBtnAdd = true;
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        bookDetailsVC = storyboard.instantiateViewController(withIdentifier: "BookDetailsViewController") as! BookDetailsViewController
        
        playerVC = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController

        
        //getBookpapers()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getBookpapers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.isNavigationBarHidden = false
        SummaryViewController.summaryDetailsFlag = false
    }
    
    //MARK:- IBActions
    @IBAction fileprivate func popTapped(_ sender: AnyObject) {
        //navigationController?.popViewControllerAnimated(true)
        dismiss(animated: true, completion: nil)
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
            banner.show(duration: 2.0)
            
            self.tableView.reloadData()
            
            
        }, onFailure: { (error) in
            print(error.description)
            
            let banner = Banner(title: nil, subtitle: "خطأ في العملية. يرجى المحاولة مرة اخرى", image: nil, backgroundColor: lightShinyGreenColor, didTapBlock: nil)
            banner.dismissesOnTap = true
            banner.show(duration: 2.0)
        }, loadingViewController: nil)
    }
    

    //MARK:- APIs
    func getBookpapers() {
        let parameters = ["BookID": "\(currentBook!.bookID)"]
        
        ApiManager.sharedInstance.getPapers(parameters as [String : AnyObject]?, onSuccess: { (array) in
            self.papers.removeAll()
            self.formattedPapersString = ""
            if let papers = array {
                for paper in papers.table! {
                    self.formattedPapersString = self.formattedPapersString + "● \(paper.title)\n"
                }
                self.papers = papers.table!
                self.tableView.reloadData()
            }
            }, onFailure: { (error) in
                print(error.description)
            }, loadingViewController: self)
    }
    
    //MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! BookDetailsViewController
        destination.currentBook = currentBook
        
        if segue.identifier == "toBookDetailsRead" {
            destination.shouldNavigateToPapers = true
        } else if segue.identifier == "toBookDetailsListen" {
            destination.shouldNavigateToAudios = true
        }
    }
}

extension SummaryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 400
        }
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "SummaryHeaderCell") as! SummaryHeaderCell
            headerCell.imgBookCover.kf.setImage(with:URL(string: getFullURLImage(currentBook!.imageID)))
            
            let lblAdd = headerCell.contentView.viewWithTag(10)
            let imgAdd = headerCell.contentView.viewWithTag(11)
            
            if currentBook?.status == -1 ||  currentBook?.status == 0 {
                lblAdd?.isHidden = false
                imgAdd?.isHidden = false
                headerCell.btnAdd.isHidden = false

            if flagBtnAdd!{
                headerCell.imgViewAdd.image = UIImage(named: "Shape_151_copy")
            }else{
                headerCell.imgViewAdd.image = UIImage(named: "Shape_154")
            }
            
                headerCell.btnAdd.addTarget(self, action: #selector(addTapped), for: .touchUpInside)

                
            } else {
                if SummaryViewController.summaryDetailsFlag {
                    lblAdd?.isHidden = true
                    imgAdd?.isHidden = true
                    headerCell.btnAdd.isHidden = true
                }else {
                    headerCell.imgViewAdd.image = UIImage(named: "Shape_154")
                }
                
                
            }
            headerCell.btnRead.addTarget(self, action: #selector(readTapped), for: .touchUpInside)
            headerCell.btnListen.addTarget(self, action: #selector(listenTapped), for: .touchUpInside)
            let gesture = UITapGestureRecognizer(target: self, action: #selector(imageTap(tapgesture:)))
            headerCell.imgBookCover.isUserInteractionEnabled = true
            headerCell.imgBookCover.addGestureRecognizer(gesture)
            return headerCell
        }
        
        let dynamicCell = tableView.dequeueReusableCell(withIdentifier: "SummaryDynamicCell") as! SummaryDynamicCell
        
        if indexPath.row == 1 {
            dynamicCell.lblTitle.text = currentBook?.title
            dynamicCell.lblDescription.text = currentBook?.summary
        }
        
        if indexPath.row == 2 {
            dynamicCell.lblTitle.text = currentBook?.title
            dynamicCell.lblTitle.isHidden = true
            dynamicCell.lblDescription.text = formattedPapersString
        }
        
        return dynamicCell
    }
    
    //MARK:- Header Targets
    func addTapped(_ button: UIButton) {
        if flagBtnAdd! {
            
            let parameters = ["UserID": RealmHelper.getLoggedinUser()!.userID, "BooksIds": currentBook!.bookID]
            //let image = button.currentImage
            //        if (image?.isEqual(UIImage(named: "Shape_154")))!{
            //            self.removeFromLibraries(bookID: currentBook!.bookID)
            //            self.flagBtnAdd = true
            //        }else{
            ApiManager.sharedInstance.setUserBooks(parameters as [String : AnyObject]?, onSuccess: { (array) in
                let banner = Banner(title: nil, subtitle: "تم اضافة الكتاب الى المكتبة", image: nil, backgroundColor: lightShinyGreenColor, didTapBlock: nil)
                banner.dismissesOnTap = true
                banner.show(duration: 3.0)
                self.currentBook!.status = 0
                self.flagBtnAdd = false
                self.tableView.reloadData()
            }, onFailure: { (error) in
                print(error.description)
            }, loadingViewController: nil)
            

        }else{
            
            let parameters = ["UserID":RealmHelper.getLoggedinUser()!.userID, "BookID": currentBook!.bookID, "Status": "-1"]
            
            ApiManager.sharedInstance.setBookStatus(parameters as [String : AnyObject]?, onSuccess: { (array) in
                
                let banner = Banner(title: nil, subtitle: "تم حذف الكتاب من قائمة المكتبة", image: nil, backgroundColor: lightShinyGreenColor, didTapBlock: nil)
                banner.dismissesOnTap = true
                banner.show(duration: 3.0)
                self.currentBook!.status = -1
                self.flagBtnAdd = true
                self.tableView.reloadData()
                
                print("success")
            }, onFailure: { (error) in
                print(error.description)
                
                let banner = Banner(title: nil, subtitle: "خطأ في العملية. يرجى المحاولة مرة اخرى", image: nil, backgroundColor: lightShinyGreenColor, didTapBlock: nil)
                banner.dismissesOnTap = true
                banner.show(duration: 3.0)
            }, loadingViewController: nil)
        }
        
        

    }
   
    func readTapped() {
        
        let parameters = ["UserID": RealmHelper.getLoggedinUser()!.userID, "BooksIds": currentBook!.bookID]
                ApiManager.sharedInstance.setUserBooks(parameters as [String : AnyObject]?, onSuccess: { (array) in
            let banner = Banner(title: nil, subtitle: "تم اضافة الكتاب الى المكتبة", image: nil, backgroundColor: lightShinyGreenColor, didTapBlock: nil)
            banner.dismissesOnTap = true
            banner.show(duration: 2.0)
            self.currentBook!.status = 1
            self.flagBtnAdd = false
            SummaryViewController.summaryDetailsFlag = true
            self.presentBookDetails()
            
        }, onFailure: { (error) in
            print(error.description)
        }, loadingViewController: nil)
        
        

    }
    
    func presentBookDetails(){
        self.bookDetailsVC.currentBook = self.currentBook
        present(self.bookDetailsVC, animated: true, completion: nil)
    }
    
    
    func listenTapped() {
        let parameters = ["UserID":RealmHelper.getLoggedinUser()!.userID, "BookID": currentBook!.bookID, "Status": "1"]
        
        print(currentBook!.bookID)
        
        ApiManager.sharedInstance.setBookStatus(parameters as [String : AnyObject]?, onSuccess: { (array) in
            let banner = Banner(title: nil, subtitle: "تم اضافة الكتاب الى المكتبة", image: nil, backgroundColor: lightShinyGreenColor, didTapBlock: nil)
            banner.dismissesOnTap = true
            banner.show(duration: 2.0)
            NewAudioManager.sharedInstance.currentBook = self.currentBook!
            NewAudioManager.sharedInstance.currentPapers = self.papers
            NewAudioManager.sharedInstance.rowToSelectAudioFile = self.currentPaperIndex
            self.shouldDisplayAudios = true
            self.playerVC.bookObject = self.currentBook!
            self.playerVC.papersArray = self.papers
            self.playerVC.currentPaperIndex = self.currentBook?.userCurrentPage
            self.playerVC.segueIndex = 1
            self.currentBook?.status = 1
            self.flagBtnAdd = false
            SummaryViewController.summaryDetailsFlag = true
            
            self.present(self.playerVC, animated: true, completion: nil)

        }, onFailure: { (error) in
            print(error.description)
        }, loadingViewController: nil)

       
                
    }
    
    func imageTap(tapgesture: UITapGestureRecognizer) {
        print(tapgesture.numberOfTapsRequired)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let summaryDetailVC = storyboard.instantiateViewController(withIdentifier: "SummaryDetailViewController") as! SummaryDetailViewController
        summaryDetailVC.currentBook = currentBook
        present(summaryDetailVC, animated: true, completion: nil)
    }
}
