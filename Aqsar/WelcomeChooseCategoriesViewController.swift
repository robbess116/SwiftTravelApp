//
//  WelcomeChooseCategories.swift
//  Aqsar
//
//  Created by moayad on 7/25/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit
import BRYXBanner
import RealmSwift

class WelcomeChooseCategoriesViewController: BaseViewController {
    //MARK:- IBOutlets
    @IBOutlet weak fileprivate var collectionViewCategories: UICollectionView!
    
    //MARK:- IVars
    fileprivate var categories = [Categories]()
    fileprivate var selectedCategoryIDs:[Int] = []
    fileprivate var selectedCategoryIDsString:[String] = []
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK:- Life Cycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        getAndDisplayCategories()
//    }
    
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
    
            getAndDisplayCategories()
        }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        self.navigationController?.navigationBar.isHidden = true
        
    }
    
    //MARK:- API
    fileprivate func getAndDisplayCategories() {
        if Reachability.isConnectedToNetwork() == false {
            showNetowrkNoConnectivityAlertController()
            return
        }
        
        ApiManager.sharedInstance.getCategories(nil, onSuccess: { (array) in
            self.categories = (array?.table)!
            self.collectionViewCategories.reloadData()
            }, onFailure: { (error) in
                print(error.description)
            }, loadingViewController: self)
    }
    
    //MARK:- IBActions
    @IBAction fileprivate func continueTapped(_ sender: AnyObject) {
        if Reachability.isConnectedToNetwork() == false {
            showNetowrkNoConnectivityAlertController()
            return
        }
        
        if selectedCategoryIDs.count == 0 {
            let alertController = UIAlertController(title: nil, message: "الرجاء اختيار قسم واحد على الاقل للمتابعة", preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "موافق", style: .default) { (action) in
                
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true) {
                // ...
            }
            
            return
        }
        
        let paramaters = ["UserID": RealmHelper.getLoggedinUser()!.userID, "Categories": getDollarSignSeperatedString(selectedCategoryIDsString)]
        
        print(getDollarSignSeperatedString(selectedCategoryIDsString))
        
        ApiManager.sharedInstance.setUserCategories(paramaters as [String : AnyObject]?, onSuccess: { (array) in
            self.performSegue(withIdentifier: "toBooks", sender: self)
            let realm = try! Realm()
            try! realm.write {
                realm.delete((RealmHelper.getLoggedinUser()?.categories)!)
                
                for index in self.selectedCategoryIDs {
                    RealmHelper.getLoggedinUser()!.categories.append(self.categories[index])
                }
            }
            }, onFailure: { (error) in
                print(error.description)
            }, loadingViewController: self)
    }
}

//MARK:- Collection View DataSource & Delegate
extension WelcomeChooseCategoriesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.layer.borderWidth = 1
        cell.layer.borderColor = darkGreen.cgColor
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WelcomeCategoriesCell", for: indexPath) as! WelcomeCategoriesCell
        
        let currentCategory = categories[indexPath.row]
        
        cell.lblTitle.text = currentCategory.title
        
        if selectedCategoryIDs.contains(indexPath.row) {
            cell.backgroundColor = darkGreen
            cell.imgIcon.image = UIImage(named: "Check_Icon_New")
            cell.lblTitle.textColor = UIColor.white
        } else {
            cell.lblTitle.textColor = darkGreen
            cell.backgroundColor = UIColor.clear
            cell.imgIcon.image = UIImage(named: "Icon_-_+_copy")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth / 3 - 16, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentCategory = categories[indexPath.row]
        
        
        if selectedCategoryIDs.contains(indexPath.row) {
            let indexToDelete = selectedCategoryIDs.index(of: indexPath.row)!
            print(indexToDelete)
            selectedCategoryIDs.remove(at: indexToDelete)
            selectedCategoryIDsString.remove(at: indexToDelete)
            
        } else {
            selectedCategoryIDs.append(indexPath.row)
            selectedCategoryIDsString.append(currentCategory.categoryID)
        }
        
        
        collectionView.reloadData()
    }
}
