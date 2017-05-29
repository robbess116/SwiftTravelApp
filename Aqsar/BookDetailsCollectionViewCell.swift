//
//  BookDetailsCollectionViewCell.swift
//  Aqsar
//
//  Created by moayad on 8/4/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit

class BookDetailsCollectionViewCell: UICollectionViewCell {
    //MARK:- IBOutlets
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        for subView in subviews {
            subView.mirrorMe()
        }
    }
    
    //MARK:- Properties
    var textViewOffset: CGFloat {
        get {
            return textView.contentOffset.y
        }
        
        set {
            textView.contentOffset.y = newValue
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        textView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    func addCustomMenu() {
        let printToConsole = UIMenuItem(title: "Print To Console", action: #selector(BookDetailsCollectionViewCell.printToConsole))
        UIMenuController.shared.menuItems = [printToConsole]
    }
    
    func printToConsole() {
        if let textRange = textView.selectedTextRange {
            let selectedText = textView.text(in: textRange)
            
            print(selectedText)
        }
    }
}
