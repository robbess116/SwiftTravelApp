//
//  SettingsViewController.swift
//  Aqsar
//
//  Created by moayad on 8/10/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit
import RealmSwift

class SettingsViewController: BaseViewController {
    //MARK:- IBOutlets
    @IBOutlet weak fileprivate var lblCustomTitle: UILabel!
    @IBOutlet weak fileprivate var tableView: UITableView!
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        lblCustomTitle.text = "الاعدادات"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .default
        UIApplication.shared.isStatusBarHidden = false
        
       setUpNavigationBar()
        
        tableView.reloadData()
    }
    
    //MARK:- Navigation
    fileprivate func setUpNavigationBar() {
    
//        title = "ضبط"
//        let attributes = [NSFontAttributeName: UIFont(name: "DroidArabicKufi", size: 17)!, NSForegroundColorAttributeName: darkGreen]
//    self.navigationController?.navigationBar.titleTextAttributes = attributes

        navigationController?.navigationBar.tintColor = darkGreen
        self.navigationItem.leftBarButtonItem?.tintColor = darkGreen
    }
    
    //MARK:- Selectors
    func notificationsSwitchChanged(_ switcher: UISwitch) {
        print(switcher.tag)
        
        if switcher.isOn {
            print("enable push notifications")
            UIApplication.shared.registerForRemoteNotifications()
        } else {
            UIApplication.shared.unregisterForRemoteNotifications()
            print("disable push notifications")
        }
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
//        return 3
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // account settings
        if section == 0 {
            return 3
        }
        
        // support and help
        if section == 1 {
            return 3
        }
        
        // play settings
        if section == 2 {
            //return 2
            return 1
        }
        
        // copy code
        if section == 3 {
            //return 2
            return 1
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // account settings section
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let accountSettingsCell = tableView.dequeueReusableCell(withIdentifier: "SettingsBoldTitleTableViewCell") as! SettingsBoldTitleTableViewCell
                accountSettingsCell.lblTitle.text = "اعدادات الحساب"
                
                return accountSettingsCell
            }
            
            if indexPath.row == 1 {
                let emailCell = tableView.dequeueReusableCell(withIdentifier: "SettingsTitleAndValueTableViewCell") as! SettingsTitleAndValueTableViewCell
                
                emailCell.lblTitle.text = "الايميل"
                emailCell.lblValue.text = RealmHelper.getLoggedinUser()?.email
                emailCell.imgViewArrow.isHidden = true
                
                return emailCell
            }
            
            if indexPath.row == 2 {
                let emailCell = tableView.dequeueReusableCell(withIdentifier: "SettingsTitleAndValueTableViewCell") as! SettingsTitleAndValueTableViewCell
                
                emailCell.lblTitle.text = "ادارة الاشتراك"
                
                
                let defaults = UserDefaults.standard
                if let automaticSettingFlag = defaults.string(forKey: "automaticRenewalFlag"){
                    
                    print(automaticSettingFlag) // Some String Value
                    
                    if automaticSettingFlag == "YES" {
                        
                        let str = (RealmHelper.getLoggedinUser()?.subscriptionEndDate)! as String
                        let index = str.index(str.startIndex, offsetBy: 10)
                        
                        emailCell.lblValue.text = str.substring(to: index)
                        
                    }else{
                        
                        if let strSubscriptionEndDate = defaults.string(forKey: "subscriptionEndDate") {
                            emailCell.lblValue.text = strSubscriptionEndDate

                        }else{
                            let str = (RealmHelper.getLoggedinUser()?.subscriptionEndDate)! as String
                            let index = str.index(str.startIndex, offsetBy: 10)
                            
                            emailCell.lblValue.text = str.substring(to: index)
                        }
                        
                    }
                }

                

                
                return emailCell
            }
        }
        
        // support and help section
        if indexPath.section == 1 {
            let titleCell = tableView.dequeueReusableCell(withIdentifier: "SettingsTitleTableViewCell") as! SettingsTitleTableViewCell
            
            if indexPath.row == 0 {
                titleCell.lblTitle.text = "المساعدة والدعم"
            } else if indexPath.row == 1 {
                titleCell.lblTitle.text = "ادارة الخصوصية"
            } else if indexPath.row == 2 {
                titleCell.lblTitle.text = "الاسئلة الاكثر شيوعا"
            }
            
            return titleCell
        }
        
        // play settings
        if indexPath.section == 2 {
            if indexPath.row == 0 {
                let switchCell = tableView.dequeueReusableCell(withIdentifier: "SettingsSwitchTableViewCell") as! SettingsSwitchTableViewCell
                
                switchCell.lblTitle.text = "التنبيهات"
                switchCell.switcher.tag = 101
                switchCell.switcher.addTarget(self, action: #selector(notificationsSwitchChanged(_:)), for: .valueChanged)
                
                if UIApplication.shared.isRegisteredForRemoteNotifications {
                    switchCell.switcher.setOn(true, animated: false)
                } else {
                    switchCell.switcher.setOn(false, animated: false)
                }
                
                return switchCell
            }
            
            if indexPath.row == 1 {
                let counterCell = tableView.dequeueReusableCell(withIdentifier: "SettingsCounterTableViewCell") as! SettingsCounterTableViewCell
                
                //counterCell.lblTitle.text = "القفز الى الامام والخلف"
                counterCell.lblTitle.text = "اتصل بنا"
                counterCell.btnMinus.isHidden = true
                counterCell.btnPlus.isHidden = true
                counterCell.lblOutput.isHidden = true
                
                return counterCell
            }
        }
        
        // copy code
        if indexPath.section == 3 {
            if indexPath.row == 1 {
                let copyCodeCell = tableView.dequeueReusableCell(withIdentifier: "SettingsTitleTableViewCell") as! SettingsTitleTableViewCell
                
                copyCodeCell.lblTitle.text = "123-345-567"
                
                return copyCodeCell
            }
            
            if indexPath.row == 0 {
                let logoutCell = tableView.dequeueReusableCell(withIdentifier: "SettingsLogoutTableViewCell") as! SettingsLogoutTableViewCell
                
                logoutCell.lblTitle.text = "تسجيل الخروج"
                
                return logoutCell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0  || section == 3 {
            return nil
        }
        
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "SettingsBoldTitleTableViewCell") as! SettingsBoldTitleTableViewCell
        headerCell.backgroundColor = UIColor(red: 244.0/255.0, green: 244.0/255.0, blue: 244.0/255.0, alpha: 1.0)
        
        if section == 1 {
            headerCell.lblTitle.text = "المساعدة والدعم"
        } else if section == 2 {
            headerCell.lblTitle.text = "اعدادات التشغيل"
        }
//        else if section == 3 {
//            headerCell.lblTitle.text = "كود النسخة"
//        }
        
//        if section == 1 {
//            headerCell.lblTitle.text = "اعدادات التشغيل"
//        } else if section == 2 {
//            headerCell.lblTitle.text = "كود النسخة"
//        }
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 3 {
            return 0
        }
        
        return 44
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 && indexPath.row == 0 {
            return false
        }
        
        if indexPath.section == 1 && indexPath.row == 0 {
            return false
        }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 && indexPath.row == 1 {
            performSegue(withIdentifier: "toChangeEmail", sender: self)
            return
        }
        
        if indexPath.section == 0 && indexPath.row == 2 {
            performSegue(withIdentifier: "toRenewalSubscription", sender: self)
            return
        }
        
        if indexPath.section == 1 && indexPath.row == 1 {
            print("contact us")
            performSegue(withIdentifier: "toContactUs", sender: self)
        }
        
        
        
        if indexPath.section == 3 && indexPath.row == 0 {
            let alertController = UIAlertController(title: "", message: "هل تريد تسجيل الخروج؟", preferredStyle: .alert)
            
            let yesAction = UIAlertAction(title: "نعم", style: .default) { (action) in
                let parameters = ["UserID": RealmHelper.getLoggedinUser()!.userID]
                
                ApiManager.sharedInstance.logout(parameters as [String : AnyObject]?, onSuccess: { (array) in
                    RealmHelper.resetLoggedinUser()
                    super.closeDidTap()
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let loginView = storyboard.instantiateViewController(withIdentifier: "defaultAppLaunchNav")
                    UIApplication.shared.keyWindow?.rootViewController = loginView
                    }, onFailure: { (error) in
                        print(error.description)
                    }, loadingViewController: self)
            }
            alertController.addAction(yesAction)
            
            let noAction = UIAlertAction(title: "لا", style: .cancel) { (action) in
                
            }
            alertController.addAction(noAction)
            
            self.present(alertController, animated: true) {
                // ...
            }
        }
    }
}
