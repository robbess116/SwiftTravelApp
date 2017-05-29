//
//  LoginTableViewController.swift
//  Aqsar
//
//  Created by moayad on 7/25/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit
import RealmSwift

class LoginTableViewController: BaseTableViewController {
    //MARK:- IBOutlets
    @IBOutlet weak fileprivate var viewAlert: UIView!
    @IBOutlet weak fileprivate var lblAlertMessage: UILabel!
    @IBOutlet weak fileprivate var tfEmail: UITextField!
    @IBOutlet weak fileprivate var tfPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnForgotDevice: UIButton!
    @IBOutlet weak var btnForgotPassword: UIButton!
    
    //MARK:- Props
    var isForgotDevice = false
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tableView.backgroundView = UIImageView(image: UIImage(named: "Group_1-1"))
        
        viewAlert.layer.cornerRadius = 2.0
        viewAlert.alpha = 0.0
        
        if isForgotDevice == true {
            btnLogin.setTitle("ارسال", for: UIControlState())
            btnForgotDevice.isHidden = true
        }
        
        title = "تسجيل الدخول"
        let attributes = [NSFontAttributeName: UIFont(name: "DroidArabicKufi", size: 17)!, NSForegroundColorAttributeName: darkGreen]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        self.navigationController?.navigationBar.isHidden = false

        navigateToUserScene()
    }
    
    fileprivate func navigateToUserScene() {
        // if the user data exist, then he is a loggedin user
        print(RealmHelper.getLoggedinUser())
        
        if let userData = RealmHelper.getLoggedinUser() {
            if userData.booksUnread.count > 0 || userData.booksCount > 0 || userData.booksInProgress.count > 0 || userData.booksFinished.count > 0 || userData.booksFavorites.count > 0 {
                
                // user has picked categories and books
                // navigate to the app
                let appDel = UIApplication.shared.delegate as! AppDelegate
                if let window = appDel.window {
                    let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RAMAnimatedTabBarController")
                    window.rootViewController = controller
                }
                
            } else {
                // navigate to choose categories scene
                print(RealmHelper.getLoggedinUser())
                self.performSegue(withIdentifier: "toCategories", sender: self)
            }

        } else {
        }
    }
    
    //MARK:- Animation
    fileprivate func showAlertView(_ message: String) {
        lblAlertMessage.text = message
        UIView.animate(withDuration: 0.25, animations: {
            self.viewAlert.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.25, delay: 3.0, options: .curveEaseOut, animations: {
                self.viewAlert.alpha = 0.0
                }, completion: nil)
        }) 
    }
    
    //MARK:- IBActions
    @IBAction fileprivate func loginTapped(_ sender: AnyObject) {
        view.endEditing(true)

        if Reachability.isConnectedToNetwork() == false {
            showAlertView("الرجاء التأكد من الاتصال بالشبكة")
            //showNetowrkNoConnectivityAlertController()
            return
        }
        
        if ValidationHelper.isTextFieldEmpty(textField: tfEmail) {
            showAlertView("الرجاء تعبئة جميع الحقول")
            return
        }
        
        if ValidationHelper.isTextFieldEmpty(textField: tfPassword) {
            showAlertView("الرجاء تعبئة جميع الحقول")
            return
        }
        
        if !ValidationHelper.isTextFieldEmail(textField: tfEmail) {
            showAlertView("الرجاء ادخال بريد الكتروني صحيح")
            return
        }
        
        if isForgotDevice == true {
            let parameters = ["UserName": tfEmail.text!, "Password": tfPassword.text!]
            
            ApiManager.sharedInstance.forgotDevice(parameters as [String : AnyObject]?, onSuccess: { (array) in
                self.showAlertView("سيتم مراجعة طلبك")
                }, onFailure: { (error) in
                    print(error.description)
                }, loadingViewController: self)
            
            return
        }
        
        ApiManager.sharedInstance.loginGET(tfEmail.text!, password: tfPassword.text!, onSuccess: { (array) in
            if let unwrappedArray = array, unwrappedArray.table != nil {
                // for login API, if "table" array is empty, then "invalid username or password"
                if unwrappedArray.table!.count == 0 {
                    self.showAlertView("خطأ في اسم المستخدم او كلمة المرور")
                    return
                }
                
                // in login API case, we only need the first object
                let userData = unwrappedArray.table![0]
                
                if userData.erorr != "" {
                    self.showAlertView(userData.erorr)
                    return
                }
                
                self.navigateToUserScene()
            } else {
                self.showAlertView(generalErrorMessage)
            }
            }, onFailure: { (error) in
                self.hideLoadingIndicator({
//                    if let err = error as? URLError, err == .connectionDown {
//                        self.showAlertView(checkNetworkMessage)
//                    } else {
                        self.showAlertView(error.description)
//                    }
                })
            }, loadingViewController: self)
    }
    
    @IBAction fileprivate func lostDeviceTapped(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginTableViewController
        loginVC.isForgotDevice = true
        navigationController?.pushViewController(loginVC, animated: true)
        
    }
    
    @IBAction fileprivate func forgotPasswordTapped(_ sender: AnyObject) {
        let altMessage = UIAlertController(title: "نسيت رمز المرور", message: "الرجاء ادخال بريدك الالكتروني", preferredStyle: UIAlertControllerStyle.alert)
        
        altMessage.addAction(UIAlertAction(title: "الغاء", style: UIAlertActionStyle.default, handler:{ (UIAlertAction) in
        }))
        
        func configurationTextField(_ textField: UITextField!) {
            if let emailTextField = textField {
                //emailTextField = UITextField(frame: CGRectMake(0, 0, 120, 40))
                emailTextField.placeholder = "البريد الالكتروني"
                emailTextField.textAlignment = .right
                emailTextField.keyboardType = .emailAddress
            }
        }
        
        altMessage.addTextField(configurationHandler: configurationTextField)
        
        altMessage.addAction(UIAlertAction(title: "موافق", style: UIAlertActionStyle.default, handler:{ (UIAlertAction) in
            let emailTextField = altMessage.textFields![0]
            if let _ = emailTextField.text {
                if ValidationHelper.isTextFieldEmail(textField: emailTextField) {
                    // send the request
                    _ = ["Email": emailTextField.text]
                    
                } else {
                    altMessage.message = "الرجاء ادخال بريد الكتروني صحيح"
                    self.present(altMessage, animated: true, completion: nil)
                }
            }
            
            }))
        
        self.present(altMessage, animated: true, completion: nil)
    }
    
    
    //MARK:- UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 2 {
            textField.resignFirstResponder()
        } else {
            let nextTF = view.viewWithTag(textField.tag + 1) as! UITextField
            nextTF.becomeFirstResponder()
        }
        
        return true
    }
}
