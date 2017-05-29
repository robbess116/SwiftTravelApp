//
//  ValidationHelper.swift
//  Aqsar
//
//  Created by moayad on 7/25/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import Foundation
import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


struct ValidationHelper {
    static func isTextFieldEmpty(textField:UITextField) -> Bool {
        return textField.text!.isEmpty
    }
    
    static func isTextFieldEmail(textField:UITextField) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: textField.text!)
    }
    
    static func isTextFieldsTextEquals(textField textField1:UITextField, textField2:UITextField) -> Bool {
        return textField1.text! == textField2.text!
    }
    
    static func isTextFieldslessThan6Chars(textField:UITextField) -> Bool {
        return textField.text?.characters.count < 6
    }
}
