//
//  ChangeEmailViewController.swift
//  Aqsar
//
//  Created by moayad on 10/30/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit
import RealmSwift

class ChangeEmailViewController: BaseViewController {
    //MARK:- IBOutlets
    @IBOutlet weak fileprivate var lblCurrentEmail: UILabel!
    @IBOutlet weak fileprivate var tfNewEmail: UITextField!
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavigationBar()
        
        lblCurrentEmail.text = RealmHelper.getLoggedinUser()?.email
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        
    }
    //MARK:- Navigation
    fileprivate func setUpNavigationBar() {
        self.navigationItem.rightBarButtonItem =
            UIBarButtonItem(image:UIImage(named: "check"), style:.plain, target:self, action:#selector(doneTapped))
        
        navigationController?.navigationBar.tintColor = darkGreen
        self.navigationItem.leftBarButtonItem?.tintColor = darkGreen
    }
    
    //MARK:- Targets
    @objc fileprivate func doneTapped() {
        if !ValidationHelper.isTextFieldEmail(textField: tfNewEmail) {
            showValidationFillValidEmailAlertController()
            return
        }
        
        // call api
        let parameters = ["UserID": RealmHelper.getLoggedinUser()!.userID, "Email": tfNewEmail.text!]
        
        ApiManager.sharedInstance.changeUserEmail(parameters as [String : AnyObject]?, onSuccess: { (array) in
            let alertController = UIAlertController(title: "", message: "تم تغيير الايميل بنجاح", preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "موافق", style: .default) { (action) in
                let realm = try! Realm()
                try! realm.write {
                    RealmHelper.getLoggedinUser()?.email = self.tfNewEmail.text!
                    
                    realm.add(RealmHelper.getLoggedinUser()!, update: true)
                }
                
                
                self.pop()
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true) {
                // ...
            }
            }, onFailure: { (error) in
                print(error.description)
            }, loadingViewController: self)
    }
}

extension ChangeEmailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
