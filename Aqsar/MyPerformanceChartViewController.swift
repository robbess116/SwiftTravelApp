//
//  MyPerformanceChartViewController.swift
//  Aqsar
//
//  Created by moayad on 11/12/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit

class MyPerformanceChartViewController: UIViewController {
    //MARK:- IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
    fileprivate var chartsInits = [MyPerformanceChartData]()
    fileprivate var totalCount:Int = 0
    //private var booksCounts = [Int]()
    //private var chartMonths = [MyPerformanceChartData]()
    
    fileprivate var isAPILoaded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let localMyPerformanceChartDataObj = MyPerformanceChartData(bookCount: 0, finishedMonth: 0)
        for i in 0...11 {
            chartsInits.append(localMyPerformanceChartDataObj)
        }

        let date = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.day , .month , .year], from: date)
        
        let year =  components.year
//        let month = components.month
//        let day = components.day
        
        let parameters = ["UserId": RealmHelper.getLoggedinUser()!.userID, "Year": "\(year)"]
        
        ApiManager.sharedInstance.getPerformanceChartData(parameters as [String : AnyObject]?, onSuccess: { (array) in
            if let unwrappedChartObjs = array {
                print(unwrappedChartObjs)
                
                //self.chartMonths = unwrappedChartObjs.table!
                
                for chartObj in unwrappedChartObjs.table! {
                    //self.booksCounts.append(chartObj.bookCount)
                    self.chartsInits[chartObj.finishedMonth - 1] = chartObj
                    self.totalCount = self.totalCount + chartObj.bookCount
                }

                self.isAPILoaded = true
                //print(self.chartMonths)
                self.tableView.reloadData()
            }
            }, onFailure: { (error) in
                print(error.description)
            }, loadingViewController: nil)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        self.navigationItem.setLeftBarButton(nil, animated: true)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension MyPerformanceChartViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !isAPILoaded {
            return 0
        }
        
        return chartsInits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyPerformanceChartCell") as! MyPerformanceChartCell
        
        cell.lblMonth.text = months[indexPath.row]
        
        let currentChartData = chartsInits[indexPath.row]
        cell.progressView.setProgress(Float(currentChartData.bookCount) / Float(totalCount), animated: false)
        cell.lblPercentage.text = "\(currentChartData.bookCount)/\(totalCount)"
//        if chartMonths.count > indexPath.row + 1 {
//            let currentMonth = chartMonths[indexPath.row]
//            if currentMonth.finishedMonth == indexPath.row + 1 {
//                cell.progressView.setProgress(Float(currentMonth.bookCount) / Float(totalCount), animated: false)
//            } else {
//                cell.progressView.setProgress(0.0, animated: false)
//            }
//        }
        
        //cell.progressView.setProgress(Float(booksCounts[indexPath.row]/totalCount), animated: false)
        
        return cell
    }
}
