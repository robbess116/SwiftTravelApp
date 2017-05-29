//
//  RegisterTableViewController.swift
//  Aqsar
//
//  Created by moayad on 7/27/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit
import MRCountryPicker

class RegisterTableViewController: BaseTableViewController ,MRCountryPickerDelegate, UITextFieldDelegate{
    //MARK:- IBOutlets
    @IBOutlet weak fileprivate var viewAlert: UIView!
    @IBOutlet weak fileprivate var lblAlertMessage: UILabel!
        @IBOutlet weak fileprivate var tfName: UITextField!
    @IBOutlet weak fileprivate var tfEmail: UITextField!
    @IBOutlet weak fileprivate var tfPassword: UITextField!
    @IBOutlet weak fileprivate var tfPhoneNumber: UITextField!

    @IBOutlet var countryPciker: MRCountryPicker!
    @IBOutlet weak fileprivate var tfConfirmPassword: UITextField!
    @IBOutlet var phoneCodeView: UIView!
    @IBOutlet var tfphoneCode: UITextField!
        @IBOutlet var flagImgView: UIImageView!
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tableView.backgroundView = UIImageView(image: UIImage(named: "Group_1-1"))
        
        countryPciker.countryPickerDelegate = self
        countryPciker.showPhoneNumbers = true
        countryPciker.setCountry("US")
        //self.tfphoneCode.text =
        countryPciker.isHidden = true
        countryPciker.frame.origin.x = screenWidth - 110
        countryPciker.frame.origin.y = 280
        
        self.tableView.addSubview(countryPciker)
        
        viewAlert.layer.cornerRadius = 2.0
        viewAlert.alpha = 0.0
        self.countryPciker.alpha = 0.0
        
        title = "انشاء حساب"
        let attributes = [NSFontAttributeName: UIFont(name: "DroidArabicKufi", size: 17)!, NSForegroundColorAttributeName: darkGreen]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
        
        phoneCodeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
        self.tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickerViewTapped)))


    }
    
    
    @objc fileprivate func viewTapped() {
        view.removeGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
        
        UIView.animate(withDuration: 0.8, animations: {
            self.countryPciker.isHidden = false
            self.countryPciker.alpha = 1.0
            //self.btnFont.setImage(UIImage(named: "ic_aa"), for: .normal)
            
        })
    }
    @objc fileprivate func pickerViewTapped() {
        view.removeGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickerViewTapped)))
        tfPhoneNumber.resignFirstResponder()
        UIView.animate(withDuration: 0.8, animations: {
            self.countryPciker.isHidden = true
            self.countryPciker.alpha = 0.0
            //self.btnFont.setImage(UIImage(named: "ic_aa"), for: .normal)
            
        })
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        self.navigationController?.navigationBar.isHidden = false
        
        
    }
    //MARK:- Animation
    fileprivate func showAlertView(_ message: String) {
//        lblAlertMessage.text = message
//        UIView.animateWithDuration(0.25, animations: {
//            self.viewAlert.alpha = 1.0
//        }) { _ in
//            UIView.animateWithDuration(0.25, delay: 3.0, options: .CurveEaseOut, animations: {
//                self.viewAlert.alpha = 0.0
//                }, completion: nil)
//        }
        
        lblAlertMessage.text = message
        UIView.animate(withDuration: 0.25, animations: {
            self.viewAlert.alpha = 1.0
        }, completion: { _ in
            
        }) 
    }
    
    //MARK:- IBActions
    @IBAction fileprivate func registerTapped(_ sender: AnyObject) {
        view.endEditing(true)
        
        if Reachability.isConnectedToNetwork() == false {
            showAlertView("الرجاء التأكد من الاتصال بالشبكة")
            //showNetowrkNoConnectivityAlertController()
            return
        }
        
//        if ValidationHelper.isTextFieldEmpty(textField: tfPassword) || ValidationHelper.isTextFieldEmpty(textField: tfName) || ValidationHelper.isTextFieldEmpty(textField: tfEmail) || ValidationHelper.isTextFieldEmpty(textField: tfPhoneNumber) || ValidationHelper.isTextFieldEmpty(textField: tfConfirmPassword) {
        if ValidationHelper.isTextFieldEmpty(textField: tfPassword) || ValidationHelper.isTextFieldEmpty(textField: tfName) || ValidationHelper.isTextFieldEmpty(textField: tfEmail) || ValidationHelper.isTextFieldEmpty(textField: tfPhoneNumber) {
            showAlertView("الرجاء تعبئة جميع الحقول")
            return
        }
        
//        if !ValidationHelper.isTextFieldsTextEquals(textField: tfPassword, textField2: tfConfirmPassword) {
//            showAlertView("لا يوجد تطابق بين الرقم السري وتاكيد الرقم السري")
//            return
//        }
        
        if !ValidationHelper.isTextFieldEmail(textField: tfEmail) {
            showAlertView("الرجاء ادخال بريد الكتروني صحيح")
            return
        }
        
        if ValidationHelper.isTextFieldslessThan6Chars(textField: tfPassword) {
            showAlertView("يجب ان يحتوي رمز المرور على ٦ رموز على الاقل")
            return
        }
        
        //valid input...
        let phoneNumber = tfphoneCode.text! + tfPhoneNumber.text!
        let phoneNumberCode = phoneNumber.replacingOccurrences(of: "+", with: "")
        let parameters = ["UserName": tfName.text!.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines),
        "Password": tfPassword.text!,
        "PhoneNumber":phoneNumberCode,
        "Email": tfEmail.text!.trimmingCharacters(
            in: CharacterSet.whitespacesAndNewlines)]
        
        print(parameters)
        
        ApiManager.sharedInstance.registerGET(parameters as [String : AnyObject]?, onSuccess: { (array) in
            if array == nil {
                self.showAlertView("هناك خطأ ما!")
                return
            }
            if let response = array {
                let firstResponse = response.table?.first
                
                // failure
                if firstResponse?.column1 == "00000000-0000-0000-0000-000000000000" {
                    self.showAlertView("يوجد تكرار في البيانات المدخلة")
                    return
                }
                
                // automatic login
                ApiManager.sharedInstance.loginGET(self.tfEmail.text!, password: self.tfPassword.text!, onSuccess: { (array) in
                        self.performSegue(withIdentifier: "toCategories", sender: self)
                    }, onFailure: { (error) in
                    print(error.description)
                    }, loadingViewController: self)
            }else{
                print("timeout")
            }
            }, onFailure: { (error) in
                print(error.description)
                self.showAlertView("وقت الطلب خارج!")
            }, loadingViewController: self)
    }
    
    //MARK:- UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 3 || textField.tag == 4{
            textField.resignFirstResponder()
        } else {
            if textField.tag == 2{
                textField.resignFirstResponder()
            }else{
                let nextTF = view.viewWithTag(textField.tag + 1) as! UITextField
                nextTF.becomeFirstResponder()
 
            }
            
        }
        
        return true
    }
    
//    func textFieldDidBeginEditing(_ textField: UITextField) {    //delegate method
//        if textField.tag == 4 {
//            var phoneCode = textField.text!
//            let index = phoneCode.index(phoneCode.startIndex, offsetBy: 1)
//            if phoneCode.substring(to: index) == "+"{
//                
//            }else{
//                phoneCode = "+" + phoneCode
//            }
//            countryPciker.setCountryByPhoneCode(phoneCode)
//        }
//    }
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
//        if textField.tag == 4 {
//            var phoneCode = textField.text!
//            let index = phoneCode.index(phoneCode.startIndex, offsetBy: 1)
//            if phoneCode.substring(to: index) == "+"{
//                
//            }else{
//                phoneCode = "+" + phoneCode
//            }
//            countryPciker.setCountryByPhoneCode(phoneCode)
//
//        }
//
//        return true
//    }
//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {  //delegate method
//        if textField.tag == 4 {
//            var phoneCode = textField.text!
//            let index = phoneCode.index(phoneCode.startIndex, offsetBy: 1)
//            if phoneCode.substring(to: index) == "+"{
//                
//            }else{
//                phoneCode = "+" + phoneCode
//            }
//            countryPciker.setCountryByPhoneCode(phoneCode)
//
//        }
//        return true
//    }
    
        func countryPhoneCodePicker(_ picker: MRCountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
//        self.countryName.text = name
//        self.countryCode.text = countryCode
        self.tfphoneCode.text = phoneCode
        self.flagImgView.image = flag
        
//        UIView.animate(withDuration: 2, animations: {
//            self.countryPciker.isHidden = true
//            //self.btnFont.setImage(UIImage(named: "ic_aa"), for: .normal)
//            self.countryPciker.alpha = 0.0
//            
//        })
    }
    

}
