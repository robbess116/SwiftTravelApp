//
//  Array+Extension.swift
//  Aqsar
//
//  Created by moayad on 9/5/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import Foundation

func getDollarSignSeperatedString(_ array: [String]) -> String {
    if array.count == 0 {
        return ""
    }
    
    var returnedString = ""
    for string in array {
        if string != array.last {
            returnedString += string + "$"
        } else {
            returnedString += string
        }
    }
    
    return returnedString
}
