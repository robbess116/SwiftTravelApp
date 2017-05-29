//
//  UIViewController+Decorator.swift
//  Aqsar
//
//  Created by moayad on 8/24/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import Foundation

import Foundation
import UIKit

extension UIViewController {
    //MARK:- AlertControllers
    //MARK: IVars
    fileprivate var loadingAlertController: UIAlertController {
        let alertController = UIAlertController(title: "يرجى الانتظار\n\n\n", message: nil, preferredStyle: .alert)
        
        let indicator = UIActivityIndicatorView(frame: alertController.view.bounds)
        indicator.center = CGPoint(x: alertController.view.frame.size.width / 2, y: alertController.view.frame.size.height / 1.9
        )
        indicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        indicator.activityIndicatorViewStyle = .whiteLarge
        indicator.tintColor = UIColor.black
        indicator.color = darkGreen
        indicator.startAnimating()
        
        alertController.view.addSubview(indicator)
        
        return alertController
    }
    
    //MARK:- Network
    func showNetowrkNoConnectivityAlertController() {
        let alertController = UIAlertController(title: "خطأ بالاتصال", message: "الرجاء التأكد من الاتصال بالشبكة", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "موافق", style: .default) { (action) in
            
        }
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true) {
            // ...
        }
    }
    
    //MARK:- Validation
    func showValidationFillAllRequiredFieldsAlertController() {
        let alertController = UIAlertController(title: "", message: "Please insert all the required fields", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
        }
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true) {
            // ...
        }
    }
    
    func showValidationFillValidEmailAlertController() {
        let alertController = UIAlertController(title: "", message: "الرجاء ادخال ايميل صحيح", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "موافق", style: .default) { (action) in
            
        }
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true) {
            // ...
        }
    }
    
    func showValidationPasswordsNoMatchAlertController() {
        let alertController = UIAlertController(title: "", message: "Password and Confirm Password are not matched, Please try again", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
        }
        alertController.addAction(OKAction)
        
        self.present(alertController, animated: true) {
            // ...
        }
    }
    
    //MARK:- UI
    func showLoadingIndicator() {
        self.present(loadingAlertController, animated: true) { }
    }
    
    func hideLoadingIndicator(_ completion: (()->Void)? = nil) {
        dismiss(animated: true, completion: {
            if let unwrappedCompletion = completion {
                unwrappedCompletion()
            }
        })
    }
    
    //MARK:- User
    func showLogoutConfirmationAlertController(_ yesAction: (()->Void)?) {
        let alertController = UIAlertController(title: "", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            if let unwrappedYesAction = yesAction {
                unwrappedYesAction()
            }
        }
        alertController.addAction(yesAction)
        
        let noAction = UIAlertAction(title: "No", style: .cancel) { (action) in
            
        }
        alertController.addAction(noAction)
        
        self.present(alertController, animated: true) {
            // ...
        }
    }
    
    func showGuestUserAlertController() {
        let alertController = UIAlertController(title: "Dear Guest User", message: "Welcome to our application. In order to access this feature, you need to login first, would you like to login right now?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            // go to login
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window!.rootViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        }
        alertController.addAction(yesAction)
        
        let noAction = UIAlertAction(title: "No, later", style: .cancel) { (action) in
            
        }
        alertController.addAction(noAction)
        
        self.present(alertController, animated: true) {
            // ...
        }
        
    }
    
    //MARK:- URLs Generators
    func getFullURLImage(_ imageID: String) -> String {
        return "http://www.aqssar.com/images/getbyID?ID=\(imageID)"
    }
    
    func getFullURLAudio(_ paperID: String) -> String {
        return "http://www.aqssar.com/Home/download?PaperId=\(paperID)"
    }
}
