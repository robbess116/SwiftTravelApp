//
//  BaseTableViewController.swift
//  Aqsar
//
//  Created by moayad on 7/25/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.tintColor = darkGreen
        self.navigationController?.navigationBar.shadowImage = UIImage(named: "")
        
        self.navigationItem.leftBarButtonItem =
            UIBarButtonItem(image:UIImage(named: "arrow_green"), style:.plain, target:self, action:#selector(pop))
        
//        if let _ = self.tabBarController {
//            self.tabBarController?.delegate = self
//        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        view.addGestureRecognizer(tapGesture)
    }
    
    //MARK:- Targets
    @objc fileprivate func pop() {
        navigationController?.popViewController(animated: true)
        WelcomeViewController.backFlag = true
        
    }
    
    @objc fileprivate func endEditing() {
        view.endEditing(true)
    }
}


//extension BaseTableViewController: UITabBarControllerDelegate {
//    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        let index = tabBarController.viewControllers?.index(of: viewController)
//        if index == 2 {
//            return false
//        }
//        
//        return true
//    }
//}
