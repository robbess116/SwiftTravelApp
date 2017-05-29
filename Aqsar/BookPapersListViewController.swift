	//
//  BookPapersListViewController.swift
//  Aqsar
//
//  Created by moayad on 10/25/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit
import RealmSwift
import BRYXBanner
import AVFoundation

protocol BookPapersListViewControllerDelegate {
    func BookPapersListViewControllerTableViewDidSelect(_ row: Int, isPaper: Bool)
}

    
enum SelectedType: Int {
    
    case paper = 0, audio
}

class BookPapersListViewController: BaseViewController, AVAudioPlayerDelegate {
    //MARK:- IBOutlets
    @IBOutlet weak fileprivate var btnDismiss: UIButton!
    @IBOutlet weak fileprivate var lblTitle: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tabbar: UITabBar!
    var currentHighlightedIndex = 0
    var papers = [Paper]()
    var book = Book()
    
    var shouldDisplayAudios = false
    var shouldHidePapers = false
    
    // my account
    var isCameFormMyAccount = false
    fileprivate var pageNumberForTextQuotes = 1
    fileprivate var pageNumberForAudioQuotes = 1
    fileprivate var textQuotes = [Quote]()
    fileprivate var audioQuotes = [Quote]()
    
    fileprivate var isAudioQuotesRequested = false
    
    @IBOutlet var viewQuoteBG: UIView!
    @IBOutlet var viewQuote: UIView!
    @IBOutlet weak var lblQuote: UILabel!
    
    
    var delegate: BookPapersListViewControllerDelegate?
    
    fileprivate var selectedType: SelectedType = .paper
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.setStatusBarHidden(true, with: .none)
        setupTitleLabel()
        
        ApiManager.sharedInstance.delegate = self
        
        tabbar.backgroundColor = darkGreen
        tabbar.barTintColor = UIColor(red: 243.0/255.0, green: 243.0/255.0, blue: 243.0/255.0, alpha: 1.0)
        tabbar.delegate = self
        
        if shouldDisplayAudios == true { selectedType = .audio }
        
        if shouldHidePapers == true {
            tabbar.isHidden = true
            tableViewHeight.constant = 0
            AudioPlayerYMargin = screenHeight - 60
        } else {
            tabbar.isHidden = false
            tableViewHeight.constant = 49
        }
        tabbar.isHidden = true
        if isCameFormMyAccount {
            selectedType = .paper
            
            let parameters = ["UserId": RealmHelper.getLoggedinUser()!.userID, "PageNumber": "\(pageNumberForTextQuotes)", "PageSize": "20", "BookID": book.bookID]
            
            ApiManager.sharedInstance.getTextQuotes(parameters as [String : AnyObject]?, onSuccess: { array in
                self.textQuotes = array!.table!
                self.tableView.reloadData()
                
                }, onFailure: { (error) in
                    print(error.description)
                }, loadingViewController: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //UIApplication.shared.setStatusBarHidden(false, with: .none)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        tabbar.selectedItem = shouldDisplayAudios == true ? tabbar.items![1] :  tabbar.items![0]
    }
    
    //MARK:- Setup
   
    
    fileprivate func setupTitleLabel() {
        let bookName = book.title
        let authorName  = book.author
        
        let attrs = [NSFontAttributeName : UIFont(name: "DroidArabicKufi-Bold", size: 14)!]
        let boldString = NSMutableAttributedString(string:authorName, attributes:attrs)
        
        let attributedString = NSMutableAttributedString()
        attributedString.append(boldString)
        attributedString.append(NSAttributedString(string: "/"))
        attributedString.append(NSAttributedString(string: bookName))
        
        lblTitle.attributedText = attributedString
    }
    
    //MARK:- IBActions
    @IBAction fileprivate func dismissTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction fileprivate func paperTapped(_ sender: AnyObject) {
        selectedType = .paper
        tableView.reloadData()
    }
    
    @IBAction fileprivate func audioTapped(_ sender: AnyObject) {
        selectedType = .audio
        
        if isCameFormMyAccount {
            let parameters = ["UserId": RealmHelper.getLoggedinUser()!.userID, "PageNumber": "\(pageNumberForAudioQuotes)", "PageSize": "20", "BookID": book.bookID]
            
            ApiManager.sharedInstance.getAudioQuotes(parameters as [String : AnyObject]?, onSuccess: { (array) in
                self.audioQuotes = array!.table!
                self.tableView.reloadData()

                }, onFailure: { (error) in
                    print(error.description)
                }, loadingViewController: self)
        } else {
            tableView.reloadData()
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
    
}

extension BookPapersListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isCameFormMyAccount {
            if selectedType == .paper {
                return textQuotes.count
            }
            
            return audioQuotes.count
        }
        
        return papers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedType == .paper {
            return 110
        }
        
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isCameFormMyAccount {
            switch selectedType {
                case .paper:
                let cell = tableView.dequeueReusableCell(withIdentifier: "BookPaperListCell") as! BookPaperListCell
                
                let currentQuote = textQuotes[indexPath.row]
                cell.lblNoPaper.text = "\(indexPath.row + 1)"
                cell.lblSummary.text = currentQuote.quote
                
                return cell
                
                case .audio:
                let cell = tableView.dequeueReusableCell(withIdentifier: "BookPaperListAudioCell") as! BookPaperListAudioCell
                
                let currentQuote = audioQuotes[indexPath.row]
                cell.lblPart.isHidden = true
                cell.lblName.text = currentQuote.title
                cell.rightButtons = []
                cell.btnRightButtons.isHidden = true
                
                return cell
            }
        }
        
        switch selectedType {
        case .paper:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookPaperListCell") as! BookPaperListCell
            
            let currentPaper = papers[indexPath.row]
            
            cell.lblNoPaper.text = "\(indexPath.row + 1)"
            cell.lblSummary.text = currentPaper.title
            
            if indexPath.row == currentHighlightedIndex {
                cell.lblSummary.textColor = UIColor(red: 35.0/255.0, green: 76.0/255.0, blue: 80.0/255.0, alpha: 1.0)
                cell.contentView.backgroundColor = UIColor(red: 245.0/255.0, green: 243.0/255.0, blue: 247.0/255.0, alpha: 1.0)
            } else {
                cell.lblSummary.textColor = UIColor.gray
                cell.contentView.backgroundColor = UIColor.white
            }
            
            return cell

        case .audio:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BookPaperListAudioCell") as! BookPaperListAudioCell
            
            let currentPaper = papers[indexPath.row]
            
            cell.lblPart.text = "المقطع \(indexPath.row + 1)"
            cell.lblName.text = "\(book.title) / \(book.author)"
            
            let currentFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            if !FileManager.default.fileExists(atPath: currentFilePath.appendingPathComponent(currentPaper.audioID).path) {
                //cell.indicator.hidden = false
                cell.viewDisabling.isHidden = false
                cell.lblLoading.isHidden = false
            } else {
                //cell.indicator.hidden = true
                cell.viewDisabling.isHidden = true
                cell.lblLoading.isHidden = true
            }
            
            let addToFavorites = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
            addToFavorites.tag = indexPath.row
            addToFavorites.setImage(UIImage(named: "favorite_plus"), for: UIControlState())
            addToFavorites.backgroundColor = darkGreen
            
            addToFavorites.addTarget(self, action: #selector(addTappedFromFavorites), for: .touchUpInside)
            
            cell.rightButtons = [addToFavorites]
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if isCameFormMyAccount {
            return true
        }
        
        let currentPaper = papers[indexPath.row]
        
        let currentFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
//        if !FileManager.default.fileExists(atPath: currentFilePath.appendingPathComponent(currentPaper.audioID).path) {
//            return false
//        }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if isCameFormMyAccount {
            if selectedType == .paper {
                func viewQuoteDialog() {
                    let quote = textQuotes[indexPath.row]
                    
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
                
                viewQuoteDialog()
            } else {
                
            }
            
            return
        }
        
        if selectedType == .paper {
            if NewAudioManager.sharedInstance.jukebox.state == .playing || NewAudioManager.sharedInstance.jukebox.state == .paused {
                NewAudioManager.sharedInstance.partName = "المقطع \(indexPath.row + 1)"
                NewAudioManager.sharedInstance.currentBook.userCurrentPage = indexPath.row + 1
                NewAudioManager.sharedInstance.rowToSelectAudioFile = indexPath.row

            }
            
            delegate?.BookPapersListViewControllerTableViewDidSelect(indexPath.row, isPaper: true)
        } else {
            
            let currentPaper = papers[indexPath.row]
            let audioUrl = "\(NSHomeDirectory())/Documents/\(currentPaper.audioID)"
            
            AudioPlayer.sharedInstance.play(URL(string: audioUrl)!)
            AudioPlayer.sharedInstance.partName = "المقطع \(indexPath.row + 1)"
            AudioPlayer.sharedInstance.titleAndAuthor = "\(book.title) / \(book.author)"
            
            AudioPlayer.sharedInstance.rowToSelectAudioFile = indexPath.row
            
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let bookDetails = sb.instantiateViewController(withIdentifier: "BookDetailsViewController") as! BookDetailsViewController
            AudioPlayer.sharedInstance.player?.delegate = self
            
            let realm = try! Realm()
            try! realm.write {
                book.userCurrentPage = indexPath.row + 1
            }
            
            AudioPlayer.sharedInstance.currentBook = book
            AudioPlayer.sharedInstance.currentPapers = papers
            
            delegate?.BookPapersListViewControllerTableViewDidSelect(indexPath.row, isPaper: false)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
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
            
            addAudioPlayerNib()
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "AudioDidFinish"), object: self)
        } else {
            AudioPlayer.sharedInstance.rowToSelectAudioFile = -1
            //isAudioPlaying = false
        }
    }

    override func closeAudioTapped() {
        super.closeAudioTapped()
        
        tableView.reloadData()
    }
    
    @objc fileprivate func addTappedFromFavorites(_ button: UIButton) {
        print("tag to add: \(button.tag)")
        
        let audioID = papers[button.tag].audioID
        
        print(audioID)
        
        let parameters = ["UserId": RealmHelper.getLoggedinUser()!.userID, "BookID": book.bookID, "Audio": audioID]
        
        ApiManager.sharedInstance.AddAudioQuoteToFavorites(parameters as [String : AnyObject]?, onSuccess: { (array) in
            for cell in self.tableView.visibleCells {
                let llSwipeCell = cell as! LLSwipeCell
                llSwipeCell.hideSwipeOptions()
            }
            }, onFailure: { (error) in
                print(error.description)
                
                let banner = Banner(title: nil, subtitle: "خطأ في العملية. يرجى المحاولة مرة اخرى", image: nil, backgroundColor: lightShinyGreenColor, didTapBlock: nil)
                banner.dismissesOnTap = true
                banner.show(duration: 3.0)
            }, loadingViewController: self)
    }
}
    
    extension BookPapersListViewController: APIManagerDelegate {
        func APIManagerDelegateDidDownload() {
            tableView.reloadData()
        }
    }
    
    extension BookPapersListViewController: UITabBarDelegate {
        func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
            if item.tag == 1 {
                selectedType = .paper
            } else if item.tag == 2 {
                selectedType = .audio
                
                if isCameFormMyAccount {
                    if !isAudioQuotesRequested {
                        isAudioQuotesRequested = true
                        
                        let parameters = ["UserId": RealmHelper.getLoggedinUser()!.userID, "PageNumber": "\(pageNumberForAudioQuotes)", "PageSize": "20", "BookID": book.bookID]
                        
                        ApiManager.sharedInstance.getAudioQuotes(parameters as [String : AnyObject]?, onSuccess: { (array) in
                            self.audioQuotes = array!.table!
                            self.tableView.reloadData()
                            
                            }, onFailure: { (error) in
                                print(error.description)
                            }, loadingViewController: self)
                    }
                }
            }
            
            tableView.reloadData()
        }
    }
