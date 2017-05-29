//
//  SummaryDetailViewController.swift
//  Aqsar
//
//  Created by RichMan on 4/9/17.
//  Copyright © 2017 Ahmad. All rights reserved.
//

import UIKit
import BRYXBanner
import RealmSwift
import AVFoundation

class SummaryDetailViewController: UIViewController {

    @IBOutlet var imgViewBookCover: UIImageView!
    @IBOutlet var btnRead: UIButton!
    @IBOutlet var btnListen: UIButton!
    @IBOutlet var lbTitle: UILabel!
    var btnListenFlag: Bool!
    var btnReadFlag: Bool!
    var currentBook: Book?
    var papers = [Paper]()
    fileprivate var shouldDisplayAudios = false
    fileprivate var currentPaperIndex = 0
    var bookDetailsVC: BookDetailsViewController!
    var playerVC: PlayerViewController!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        
        lbTitle.text = (currentBook?.title)! + "/" + (currentBook?.author)!
        imgViewBookCover.kf.setImage(with:URL(string: getFullURLImage(currentBook!.imageID)))
       
        btnReadFlag = false
        btnListenFlag = false
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(imageTap(tapgesture:)))
        imgViewBookCover.isUserInteractionEnabled = true
        imgViewBookCover.addGestureRecognizer(gesture)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        bookDetailsVC = storyboard.instantiateViewController(withIdentifier: "BookDetailsViewController") as! BookDetailsViewController
        
       playerVC = storyboard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController

        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.isStatusBarHidden = false
            
        getBookpapers()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        let parameters = ["UserId": RealmHelper.getLoggedinUser()!.userID, "BookID": self.currentBook!.bookID, "PageNumber": "\(self.currentPaperIndex + 1)"]
       
        ApiManager.sharedInstance.setBookCuurrentPage(parameters as [String : AnyObject]?, onSuccess: { (array) in
            print("setBookCuurrentPage successed")
        }, onFailure: { (error) in
            print(error.description)
        }, loadingViewController: nil)

    }

    func getBookpapers() {
        let parameters = ["BookID": "\(currentBook!.bookID)"]
        print(parameters)
        ApiManager.sharedInstance.getPapers(parameters as [String : AnyObject]?, onSuccess: { (array) in
            if let papers = array {
                for paper in papers.table! {
                        print(paper)
                }
                self.papers = papers.table!
               
            }
            
        }, onFailure: { (error) in
            print(error.description)
        }, loadingViewController: self)
    }
    

    //MARK:- IBActions
    @IBAction fileprivate func popTapped(_ sender: AnyObject) {
        //navigationController?.popViewControllerAnimated(true)
        dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
  
        if segue.identifier == "toAudioPlayer" {
            let destination = segue.destination as! PlayerViewController
            destination.currentPaperIndex = 0
            destination.papersArray = papers
            //destination.delegate = self
            destination.bookObject = currentBook!
        }
    }
    

    @IBAction func tappedBtnListen(_ sender: UIButton) {
        
        if !self.btnListenFlag {
            self.btnListen.setImage(UIImage(named: "headphones"), for:.normal)
            self.btnRead.setImage(UIImage(named: "Shape_7"), for: .normal)
            self.btnListenFlag = true
            self.btnReadFlag = false
        }
        
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
            SummaryViewController.summaryDetailsFlag = true

            self.present(self.playerVC, animated: true, completion: nil)
            
        }, onFailure: { (error) in
            print(error.description)
        }, loadingViewController: nil)
        
        
    }
    
    @IBAction func tappedBtnRead(_ sender: UIButton) {
        let parameters = ["UserID": RealmHelper.getLoggedinUser()!.userID, "BooksIds": currentBook!.bookID]
        ApiManager.sharedInstance.setUserBooks(parameters as [String : AnyObject]?, onSuccess: { (array) in
            let banner = Banner(title: nil, subtitle: "تم اضافة الكتاب الى المكتبة", image: nil, backgroundColor: lightShinyGreenColor, didTapBlock: nil)
            banner.dismissesOnTap = true
            banner.show(duration: 2.0)
            self.currentBook!.status = 1
            SummaryViewController.summaryDetailsFlag = true

            self.presentBookDetails()
            
        }, onFailure: { (error) in
            print(error.description)
        }, loadingViewController: nil)

        
        if !btnReadFlag {
            btnListen.setImage(UIImage(named: "headphones-1"), for:.normal)
            btnRead.setImage(UIImage(named: "Shape_7-1"), for: .normal)
            btnReadFlag = true
             btnListenFlag = false
        }
        
        


    }
    func presentBookDetails(){
        bookDetailsVC.currentBook = currentBook
        present(bookDetailsVC, animated: true, completion: nil)

    }
    
    func imageTap(tapgesture: UITapGestureRecognizer) {
        print(tapgesture.numberOfTapsRequired)
        
    }

    @IBAction func btnShareTapped(_ sender: Any) {
        
    }
}

