//
//  ContactUsViewController.swift
//  Aqsar
//
//  Created by moayad on 1/18/17.
//  Copyright © 2017 Ahmad. All rights reserved.
//

import UIKit

class ContactUsViewController: UIViewController {
    @IBOutlet weak var tvContactUs: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tvContactUs.becomeFirstResponder()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func sendTapped(_ sender: AnyObject) {
        if tvContactUs.text!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {
            let alertController = UIAlertController(title: "خطأ بالاتصال", message: "الرجاء تعبئة حقل الرسالة", preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "موافق", style: .default) { (action) in
                
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true) {
                // ...
            }
            
            return
        }
        
        //request
        let parameters = ["UserId": RealmHelper.getLoggedinUser()!.userID, "Message": tvContactUs.text!]
        
        ApiManager.sharedInstance.contactUs(parameters as [String : AnyObject]?, onSuccess: { (array) in
            self.dismiss(animated: true, completion: nil)
            self.tvContactUs.resignFirstResponder()
            }, onFailure: { (error) in
                print(error.description)
            }, loadingViewController: nil)
    }
    
    @IBAction func dismissTapped(_ sender: AnyObject) {
        if tvContactUs.text!.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty == false {
            let alertController = UIAlertController(title: nil, message: "هل انت متأكد من انك تريدالخروج؟", preferredStyle: .alert)
            
            let noAction = UIAlertAction(title: "لا", style: .default) { (action) in
                
            }
            alertController.addAction(noAction)
            
            let OKAction = UIAlertAction(title: "نعم", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
                self.tvContactUs.resignFirstResponder()
            }
            alertController.addAction(OKAction)
            
            self.present(alertController, animated: true) {
                // ...
            }
        } else {
            dismiss(animated: true, completion: nil)
            tvContactUs.resignFirstResponder()
        }
    }
}
