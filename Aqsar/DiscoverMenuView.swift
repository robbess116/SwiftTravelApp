//
//  DiscoverMenuView.swift
//  Aqsar
//
//  Created by moayad on 7/30/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit
import Kingfisher

protocol DiscoverMenuViewDelegate {
    func DiscoverMenuCloseDidTap()
    func DiscoverMenuRowDidSelected(_ row: Int, categoryID: String)
}

class DiscoverMenuView: UIView {
    //MARK:- IBOutlets
    @IBOutlet weak fileprivate var btnClose: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var categories = [Categories]()
    
    //MARK:- Properties
    var delegate: DiscoverMenuViewDelegate?
    var selectedRow = 0
    
    class func instanceFromNib() -> DiscoverMenuView {
        return UINib(nibName: "DiscoverMenuView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! DiscoverMenuView
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.register(UINib(nibName: "DiscoverMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "DiscoverMenuTableViewCell")
        
        getAndDisplayCategories()
    }
    
    @IBAction fileprivate func closeTapped(_ sender: AnyObject) {
        delegate?.DiscoverMenuCloseDidTap()
    }
    
    fileprivate func getAndDisplayCategories() {
        if Reachability.isConnectedToNetwork() == false {
            return
        }
        
        ApiManager.sharedInstance.getCategories(nil, onSuccess: { (array) in
            self.categories = (array?.table)!
            
            // adding addtional options: all, newest all, most read all
            let allCat = Categories()
            allCat.categoryID = "00000000-0000-0000-0000-000000000000"
            allCat.title = "الكل"
            self.categories.insert(allCat, at: 0)
            
            let newestAllCat = Categories()
            newestAllCat.categoryID = "00000000-0000-0000-0000-000000000000"
            newestAllCat.title = "الاحدث"
            self.categories.insert(newestAllCat, at: 1)
            
            let newestMostRead = Categories()
            newestMostRead.categoryID = "00000000-0000-0000-0000-000000000000"
            newestMostRead.title = "الاكثر قراءة"
            self.categories.insert(newestMostRead, at: 2)

            
            self.tableView.reloadData()
            }, onFailure: { (error) in
                print(error.description)
            }, loadingViewController: nil)
    }
    
    fileprivate func getFullURLImage(_ imageID: String) -> String {
        return "http://www.aqssar.com/images/getbyID?ID=\(imageID)"
    }
    
}

extension DiscoverMenuView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if categories.count != 0 {
            return categories.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverMenuTableViewCell") as! DiscoverMenuTableViewCell
        
        if categories.count != 0 {
            let currentCat = categories[indexPath.row]
            
            cell.lblTitle.text = currentCat.title
            
            if selectedRow == indexPath.row {
                cell.lblTitle.textColor = UIColor(red: 86.0/255.0, green: 196.0/255.0, blue: 182.0/255.0, alpha: 1.0)
                cell.imgIcon.image = cell.imgIcon.image?.withRenderingMode(.alwaysTemplate)
                cell.imgIcon.tintColor = UIColor(red: 86.0/255.0, green: 196.0/255.0, blue: 182.0/255.0, alpha: 1.0)
            } else {
                cell.lblTitle.textColor = UIColor(red: 177.0/255.0, green: 177.0/255.0, blue: 177.0/255.0, alpha: 1.0)
                cell.imgIcon.image = cell.imgIcon.image?.withRenderingMode(.alwaysTemplate)
                cell.imgIcon.tintColor = UIColor(red: 177.0/255.0, green: 177.0/255.0, blue: 177.0/255.0, alpha: 1.0)
                
                print(getFullURLImage(currentCat.imageID))
                
                cell.imgIcon.kf.setImage(with:URL(string: getFullURLImage(currentCat.imageID)))
            }
            
            return cell
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedRow = indexPath.row
        var catID = ""
        
        if categories.count != 0 {
            catID = categories[indexPath.row].categoryID
        }
        
        delegate?.DiscoverMenuRowDidSelected(indexPath.row, categoryID: catID)
        
    }
}
