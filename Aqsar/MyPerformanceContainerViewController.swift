//
//  MyPerformanceContainerViewController.swift
//  Aqsar
//
//  Created by moayad on 11/12/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit

class MyPerformanceContainerViewController: BaseViewController {
    @IBOutlet weak var conHeight: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        self.navigationItem.setLeftBarButton(nil, animated: true)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MyPerformanceContainerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if indexPath.row == 0 {
            let myPerf01 = storyboard.instantiateViewController(withIdentifier: "MyPerformanceViewController") as! MyPerformanceViewController
            
            addChildViewController(myPerf01)

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyPerformanceContainerViewControllerCell", for: indexPath)
            
            myPerf01.view.frame = cell.contentView.frame
            
            cell.contentView.addSubview(myPerf01.view)
            
            myPerf01.didMove(toParentViewController: self)

            return cell
        }
        
        let myPerf02 = storyboard.instantiateViewController(withIdentifier: "MyPerformanceChartViewController") as! MyPerformanceChartViewController
        
        addChildViewController(myPerf02)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyPerformanceContainerViewControllerCell", for: indexPath)
        
        myPerf02.view.frame = cell.contentView.frame
        
        cell.contentView.addSubview(myPerf02.view)
        
        myPerf02.didMove(toParentViewController: self)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return UIScreen.main.bounds.size
        //return collectionView.frame.size
    }
}
