//
//  AppController.swift
//  Aqsar
//
//  Created by RichMan on 5/16/17.
//  Copyright © 2017 Ahmad. All rights reserved.
//

import UIKit

class AppController: NSObject {
    
    static let sharedInstance = AppController()
    var currentBook = Book()
    var backFlag = false
    var commentFlag = false
        //MARK:- Inits
    override init(){
                
        super.init()
        
    }
    
}
