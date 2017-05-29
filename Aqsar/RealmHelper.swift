//
//  RealmHelper.swift
//  Aqsar
//
//  Created by moayad on 9/23/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import Foundation
import RealmSwift


class RealmHelper {
    //MARK:- Loggedin User
    class func getLoggedinUser() -> LoggedInUserData? {
        let realm = try! Realm()
        let loggedInUserDataResults = realm.objects(LoggedInUserData)
        
        return loggedInUserDataResults.first
    }
    
    class func resetLoggedinUser() {
        let realm = try! Realm()
        try! realm.write {
            getLoggedinUser()?.booksUnread.removeAll()
            getLoggedinUser()?.booksCount = 0
            getLoggedinUser()?.booksInProgress.removeAll()
            getLoggedinUser()?.booksFinished.removeAll()
            getLoggedinUser()?.booksFavorites.removeAll()
            
            getLoggedinUser()?.quotes.removeAll()
            getLoggedinUser()?.categories.removeAll()
            
            realm.delete(getLoggedinUser()!)
            
            // bddi a5lo9 mn garafak ya zalameh
            realm.deleteAll()
            
            //realm.add(RealmHelper.getLoggedinUser()!, update: true)
            
            print(getLoggedinUser())
        }
    }
}