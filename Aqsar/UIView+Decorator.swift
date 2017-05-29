//
//  UIView+Decorator.swift
//  Aqsar
//
//  Created by moayad on 7/28/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func makeMeCircular() {
        layer.cornerRadius = frame.height / 2
    }
    
    func mirrorMe() {
        transform = CGAffineTransform(scaleX: -1, y: 1)
    }
}
