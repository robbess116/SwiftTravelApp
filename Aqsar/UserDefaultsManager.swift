//
//  UserDefaultsManager.swift
//  Aqsar
//
//  Created by MacBook Pro on 3/13/17.
//  Copyright © 2017 Ahmad. All rights reserved.
//

import UIKit

final class UserDefaultsManager {
    
    // MARK: - Shared Instance
    static let sharedInstance = UserDefaultsManager()

    func checkIfValueExistsInUserDefaults(_ key: String) -> Bool {
        guard UserDefaults.standard.value(forKey: key) != nil else {
         return false
        }
       return  true
    }
    
    func getValueByUserDefaults(_ key: String) -> String {
       return UserDefaults.standard.value(forKey: key) as! String
    }
    
    func setValueByUserDefaults(_ key: String,value: Bool) {
        UserDefaults.standard.setValue(value, forKey: key)
    }
    
}
