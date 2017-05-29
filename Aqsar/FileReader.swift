//
//  FileReader.swift
//  Aqsar
//
//  Created by moayad on 8/15/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import Foundation
import UIKit

class FileReader: NSObject {
    class func readFiles() -> [String] {
        return  Bundle.main.paths(forResourcesOfType: "mp3", inDirectory: nil) 
    }
}
