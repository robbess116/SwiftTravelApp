//
//  RenewalSubscriptionViewController.swift
//  Aqsar
//
//  Created by RichMan on 4/17/17.
//  Copyright © 2017 Ahmad. All rights reserved.
//

import UIKit

class RenewalSubscriptionViewController: BaseViewController {

    @IBOutlet var lbSubscriptionEndDate: UILabel!
    
    @IBOutlet var switchAutomatic: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        super.viewDidLoad()
        
        setUpNavigationBar()
        
        let defaults = UserDefaults.standard
        if let automaticSettingFlag = defaults.string(forKey: "automaticRenewalFlag"){
            
            print(automaticSettingFlag) // Some String Value
            
            if automaticSettingFlag == "YES" {
                switchAutomatic.setOn(true, animated: true)
                
                            }else{
                switchAutomatic.setOn(false, animated: true)
            }
        }
        
        if switchAutomatic.isOn {
            
            let str = (RealmHelper.getLoggedinUser()?.subscriptionEndDate)! as String
            let index = str.index(str.startIndex, offsetBy: 10)
            
            lbSubscriptionEndDate.text = str.substring(to: index)
            

        }else{
            if let automaticSettingFlag = defaults.string(forKey: "subscriptionEndDate"){
                
                print(automaticSettingFlag) // Some String Value
                lbSubscriptionEndDate.text = defaults.string(forKey: "subscriptionEndDate")
                
            }else{
                let str = (RealmHelper.getLoggedinUser()?.subscriptionEndDate)! as String
                let index = str.index(str.startIndex, offsetBy: 10)
                
                lbSubscriptionEndDate.text = str.substring(to: index)

            }

        }

        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        
    }
    //MARK:- Navigation
    fileprivate func setUpNavigationBar() {
        
        navigationController?.navigationBar.tintColor = darkGreen
        self.navigationItem.leftBarButtonItem?.tintColor = darkGreen
    }
    
    
    
    @IBAction func automaticRenewalSwitchTapped(_ sender: Any) {
   
        let defaults = UserDefaults.standard
        if switchAutomatic.isOn {
            
            defaults.set("YES", forKey: "automaticRenewalFlag")
        }else{
            defaults.set("NO", forKey: "automaticRenewalFlag")
            let str = (RealmHelper.getLoggedinUser()?.subscriptionEndDate)! as String
            let index = str.index(str.startIndex, offsetBy: 10)
            
            defaults.set(str.substring(to: index), forKey: "subscriptionEndDate")
        }
    }
    
}
