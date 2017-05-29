//
//  SubscriptionViewController.swift
//  Aqsar
//
//  Created by moayad on 11/19/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit
import RealmSwift

enum SubscriptionType: Int {
    case free = 0, golden, forLife
}

class SubscriptionViewController: UIViewController {

    
    @IBOutlet var imgViewTop: UIImageView!
    @IBOutlet var btnYearMembership: UIButton!
    @IBOutlet var btnGoldMembership: UIButton!
    @IBOutlet var btnFree: UIButton!
    
    @IBOutlet var viewFree: UIView!
    @IBOutlet var viewYear: UIView!
    @IBOutlet var viewGold: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        
    }
    func initView() {
        
        btnGoldMembership.backgroundColor = UIColor.white
        btnFree.backgroundColor = darkGreen
        btnYearMembership.backgroundColor = darkGreen

        self.viewGold.isHidden = false
        self.viewFree.isHidden = true
        self.viewYear.isHidden = true
    }
    
    @IBAction func btnGoldMembershipTapped(_ sender: Any) {
        
        btnGoldMembership.backgroundColor = UIColor.white
        btnFree.backgroundColor = darkGreen
        btnYearMembership.backgroundColor = darkGreen
        
        
        self.viewGold.isHidden = false
        self.viewFree.isHidden = true
        self.viewYear.isHidden = true
    }
    
    @IBAction func btnFreeTapped(_ sender: Any) {
        
        btnGoldMembership.backgroundColor = darkGreen
        btnFree.backgroundColor = UIColor.white
        btnYearMembership.backgroundColor = darkGreen
        
        
        self.viewGold.isHidden = true
        self.viewFree.isHidden = false
        self.viewYear.isHidden = true

    }
    
    
    @IBAction func btnYearMembershipTapped(_ sender: Any) {
        
        btnGoldMembership.backgroundColor = darkGreen
        btnFree.backgroundColor = darkGreen
        btnYearMembership.backgroundColor = UIColor.white
        
        
        self.viewGold.isHidden = true
        self.viewFree.isHidden = true
        self.viewYear.isHidden = false
    }
    
    @IBAction func btnSubscriptionTapped(_ sender: Any) {
        
        if self.viewFree.isHidden == false {
            let parameters = ["UserID": RealmHelper.getLoggedinUser()!.userID, "LibraryID": "0"]
            
            ApiManager.sharedInstance.purchase(parameters as [String : AnyObject]?, onSuccess: { table in
                if let unwrappedTable = table {
                    let responsedDate = unwrappedTable.table!.first!.endSubscriptionDate
                    
                    let realm = try! Realm()
                    try! realm.write {
                        RealmHelper.getLoggedinUser()?.subscriptionEndDate = responsedDate
                        
                        realm.add(RealmHelper.getLoggedinUser()!, update: true)
                    }
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }, onFailure: { (error) in
                print(error.description)
            }, loadingViewController: self)
            
        } else if self.viewGold.isHidden == false {
            SwiftyStoreKit.purchaseProduct("com.aqsar.Aqsar.Golden") { result in
                switch result {
                case .success(let productId):
                    print("Purchase Success: \(productId)")
                    let parameters = ["UserID": RealmHelper.getLoggedinUser()!.userID, "LibraryID": "1"]
                    
                    ApiManager.sharedInstance.purchase(parameters as [String : AnyObject]?, onSuccess: { table in
                        if let unwrappedTable = table {
                            let responsedDate = unwrappedTable.table!.first!.endSubscriptionDate
                            
                            let realm = try! Realm()
                            try! realm.write {
                                RealmHelper.getLoggedinUser()?.subscriptionEndDate = responsedDate
                                
                                realm.add(RealmHelper.getLoggedinUser()!, update: true)
                            }
                            
                            self.dismiss(animated: true, completion: nil)
                        }
                    }, onFailure: { (error) in
                        print(error.description)
                    }, loadingViewController: self)
                case .error(let error):
                    print("Purchase Failed: \(error)")
                }
            }
        } else if self.viewYear.isHidden == false {
            SwiftyStoreKit.purchaseProduct("com.aqsar.Aqsar.ForLife") { result in
                switch result {
                case .success(let productId):
                    print("Purchase Success: \(productId)")
                    let parameters = ["UserID": RealmHelper.getLoggedinUser()!.userID, "LibraryID": "2"]
                    
                    ApiManager.sharedInstance.purchase(parameters as [String : AnyObject]?, onSuccess: { table in
                        if let unwrappedTable = table {
                            let responsedDate = unwrappedTable.table!.first!.endSubscriptionDate
                            
                            let realm = try! Realm()
                            try! realm.write {
                                RealmHelper.getLoggedinUser()?.subscriptionEndDate = responsedDate
                                
                                realm.add(RealmHelper.getLoggedinUser()!, update: true)
                            }
                            
                            self.dismiss(animated: true, completion: nil)
                        }
                    }, onFailure: { (error) in
                        print(error.description)
                    }, loadingViewController: self)
                case .error(let error):
                    print("Purchase Failed: \(error)")
                }
            }
        }

        
    }
    
    @IBAction func dismissedTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
}



extension SubscriptionViewController: UITableViewDataSource, UITableViewDelegate {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 3
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section == 0 {
//            let headerCell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell")
//            return headerCell
//        }
//        
//        return nil
//    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.layer.cornerRadius = 5.0
//        cell.layer.borderColor = darkGreen.cgColor
//        cell.layer.borderWidth = 1.0
//    }
//    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 40
//    }
//    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 40))
//        view.backgroundColor = UIColor.clear
//        return view
//    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if section == 0 {
//            return 110.0
//        }
//        return 0
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionTableViewCell") as! SubscriptionTableViewCell
        
//        let lblTitle = cell!.viewWithTag(1) as! UILabel
//        let lblDescription = cell!.viewWithTag(2) as! UILabel
        
//        if indexPath.section == SubscriptionType.free.rawValue {
//            lblTitle.text = "أقصر المجانية"
//            lblDescription.text = "• كتاب واحد نصي اسبوعياً\n• تصفح عبر صفحة اكتشف ما هوا جديد في اقصر"
//        } else if indexPath.section == SubscriptionType.golden.rawValue {
//            lblTitle.text = "أقصر الذهبيه ٤٤٥ ريال بعد الخصم ٢٩٩"
//            lblDescription.text = "• تصفح اكثر من ٢٠٠+ كتاب في اقصر\n•كل شهر هناك اكثر من ٢٠+ كتاب جديد\n• سمعي ونصي\n• اقرأ واسمع جميع الكتب في مكتبتك من غير اتصال\n• احصل على إحصائيات عن أدائك ومستوى تقدمك"
//        } else if indexPath.section == SubscriptionType.forLife.rawValue {
//            lblTitle.text = "أقصر الحياة ١٤٦٠ريال"
//            lblDescription.text = "• تمتع بجميع مميزات الباقة الذهبية\n• حرية استخدام اقصر مدى الحياة"
//        }
        if indexPath.row == 0 || indexPath.row == 3 {
            cell.lbTitle.text = "قصر المجانية"
        }else {
            cell.lbTitle.text = "أقصر الحياة ١٤٦٠ريال"

        }
        
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == 1 {
//            return 250
//        }
//        
//        return 171
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
            }
}
