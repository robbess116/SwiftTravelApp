//
//  NewAudioManager.swift
//  Aqsar
//
//  Created by MacBook Pro on 3/25/17.
//  Copyright © 2017 Ahmad. All rights reserved.
//

import UIKit

class NewAudioManager: NSObject {

    static let sharedInstance = NewAudioManager()
    var jukebox : Jukebox!

    var partName: String?
    var titleAndAuthor = ""
    var currentBook = Book()
    var currentPapers = [Paper]()
    var rowToSelectAudioFile = -1
    
    //MARK:- Inits
    override init(){
        
        jukebox = Jukebox()
        super.init()
        
    }
    
}
