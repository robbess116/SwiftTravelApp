//
//  LibraryFilterView.swift
//  Aqsar
//
//  Created by moayad on 8/1/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit

protocol LibraryFilterViewDelegate {
    func libraryFilterCloseDidTap()
    func libraryFilterRowDidSelected(_ row: Int)
}

class LibraryFilterView: UIView {
    //MARK:- IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnCancel: UIButton!
    var items:Array<String> = []
    
    //MARK:- Properties
    var delegate: LibraryFilterViewDelegate?
    var selectedRow = 0
    
    class func instanceFromNib() -> LibraryFilterView {
        return UINib(nibName: "LibraryFilterView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! LibraryFilterView
    }

    //MARK:- Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "LibraryFilterCell", bundle: nil), forCellReuseIdentifier: "LibraryFilterCell")
        
        items = ["الأحدث","ترتيب أبجدي","عدد الصفحات"]
        
    }
    
    //MARK:- IBActions
    @IBAction fileprivate func closeTapped(_ sender: AnyObject) {
        delegate?.libraryFilterCloseDidTap()
    }
}

extension LibraryFilterView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LibraryFilterCell") as! LibraryFilterCell
        
        cell.lblTitle.text = items[indexPath.row]
        
        if indexPath.row == selectedRow {
            cell.lblTitle.textColor = UIColor.white
            cell.backgroundColor = UIColor(red: 75.0/255.0, green: 160.0/255.0, blue: 151.0/255.0, alpha: 1.0)
        } else {
            cell.lblTitle.textColor = UIColor(red: 104.0/255.0, green: 104.0/255.0, blue: 104.0/255.0, alpha: 1.0)
            cell.backgroundColor = UIColor.white
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedRow = indexPath.row
        delegate?.libraryFilterRowDidSelected(indexPath.row)
        
    }
}
