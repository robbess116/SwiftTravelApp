//
//  MyPerformanceViewController.swift
//  Aqsar
//
//  Created by moayad on 8/1/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit

class MyPerformanceViewController: BaseViewController {
    //MARK:- IBOutlets
    @IBOutlet weak var imgAvatarMain: UIImageView!
    
    @IBOutlet weak var lblStatusMain: UILabel!
    
    @IBOutlet weak var imgCircle01: UIImageView!
    @IBOutlet weak var imgCircle02: UIImageView!
    @IBOutlet weak var imgCirlce03: UIImageView!
    @IBOutlet weak var imgCircle04: UIImageView!
    @IBOutlet weak var imgCircle05: UIImageView!
    
    @IBOutlet weak var conTopSpacingLabel01: NSLayoutConstraint!
    @IBOutlet weak var conTopSpacingLabel02: NSLayoutConstraint!
    @IBOutlet weak var conTopSpacingLabel03: NSLayoutConstraint!
    @IBOutlet weak var conTopSpacingLabel04: NSLayoutConstraint!
    @IBOutlet weak var conTopSpacingLabel05: NSLayoutConstraint!
    
    @IBOutlet weak var lblCounter01: UILabel!
    @IBOutlet weak var lblCounter02: UILabel!
    @IBOutlet weak var lblCounter03: UILabel!
    @IBOutlet weak var lblCounter04: UILabel!
    @IBOutlet weak var lblCounter05: UILabel!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    //MARK:- IVars
    var circles:[UIImageView] = []
    var labelSpaces:[NSLayoutConstraint] = []
    var counterLabels:[UILabel] = []
    
    var chartContrainer = UIView()
    
    fileprivate let disabledCircleColor = UIColor(red: 55.0/255.0, green: 55.0/255.0, blue: 55.0/255.0, alpha: 1.0)
    fileprivate var noReads = 0
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        circles = [imgCircle01, imgCircle02, imgCirlce03, imgCircle04, imgCircle05]
        labelSpaces = [conTopSpacingLabel01, conTopSpacingLabel02, conTopSpacingLabel03, conTopSpacingLabel04, conTopSpacingLabel05]
        counterLabels = [lblCounter01, lblCounter02, lblCounter03, lblCounter04, lblCounter05]
        
        circleAllImageCircles()
        
//        self.navigationItem.rightBarButtonItem = nil
//        self.navigationItem.leftBarButtonItem = nil
        
//        imgAvatarMain.image = imgAvatarMain.image!.imageWithRenderingMode(.AlwaysTemplate)
//        imgAvatarMain.tintColor = UIColor(red: 177.0/255.0, green: 177.0/255.0, blue: 177.0/255.0, alpha: 1.0)
        
        let parameters = ["UserID": RealmHelper.getLoggedinUser()!.userID]
        
        ApiManager.sharedInstance.getMyAccountCounts(parameters as [String : AnyObject]?, onSuccess: { (array) in
            if let unwrappedMyAccountData = array {
                let obj = unwrappedMyAccountData.table!.first
                self.noReads = obj!.finishedCount
                self.animateUserInfo()
                self.setUpStatusLine()
            }
            }, onFailure: { (error) in
                print(error.description)
            }, loadingViewController: nil)
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        
//        circleAllImageCircles()
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = false
        self.navigationItem.setLeftBarButton(nil, animated: true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        circleAllImageCircles()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // reset the whole shit...
        for constraint in labelSpaces {
            constraint.constant = 8.0
        }
        
        for circle in circles {
            circle.layer.cornerRadius = 0.0
            circle.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            circle.backgroundColor = disabledCircleColor
        }
        
        for lbl in counterLabels {
            lbl.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
    }
    
    //MARK:- UI
    fileprivate func setUpStatusLine() {
        circleAllImageCircles()
        
        if noReads < 49 {
            lblStatusMain.text = "مبتدئ"
            imgAvatarMain.image = UIImage(named: "Shape_120")
            highlightCircle(imgCircle01)
            increaseSpacing(conTopSpacingLabel01)
            highlightCounterLabel(lblCounter01)
        } else if noReads >= 50 && noReads < 80 {
            lblStatusMain.text = "محترف"
            imgAvatarMain.image = UIImage(named: "Shape_122_copy_8")
            highlightCircle(imgCircle02)
            increaseSpacing(conTopSpacingLabel02)
            highlightCounterLabel(lblCounter02)
        } else if noReads >= 80 && noReads < 200 {
            lblStatusMain.text = "مثقف"
            imgAvatarMain.image = UIImage(named: "Shape_123_copy_8")
            highlightCircle(imgCirlce03)
            increaseSpacing(conTopSpacingLabel03)
            highlightCounterLabel(lblCounter03)
        } else if noReads >= 200 && noReads < 250 {
            lblStatusMain.text = "متخصص"
            imgAvatarMain.image = UIImage(named: "Shape_124_copy_2")
            highlightCircle(imgCircle04)
            increaseSpacing(conTopSpacingLabel04)
            highlightCounterLabel(lblCounter04)
        } else if noReads >= 250 {
            lblStatusMain.text = "عالم"
            imgAvatarMain.image = UIImage(named: "Shape_122_copy_2")
            highlightCircle(imgCircle05)
            increaseSpacing(conTopSpacingLabel05)
            highlightCounterLabel(lblCounter04)
        }
    }
    
    fileprivate func circleAllImageCircles() {
        for circle in circles {
            circle.makeMeCircular()
        }
    }
    
    //MARK:- Animation
    fileprivate func animateUserInfo() {
        imgAvatarMain.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        lblStatusMain.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        lblStatusMain.isHidden = true
        
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 3.0, options: .curveEaseIn, animations: {
            self.imgAvatarMain.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }) { _ in
                self.lblStatusMain.isHidden = false
                UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 3.0, options: .curveEaseIn, animations: {
                    self.lblStatusMain.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    }, completion: nil)
        }
    }
    
    fileprivate func highlightCircle(_ imgCircle: UIImageView) {
        for circle in circles {
            if circle === imgCircle {
                UIView.animate(withDuration: 0.5, animations: {
                    circle.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                    circle.backgroundColor = darkGreen
                })
            } else {
                circle.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                circle.backgroundColor = disabledCircleColor
            }
        }
    }
    
    fileprivate func increaseSpacing(_ con: NSLayoutConstraint) {
        for constraint in labelSpaces {
            if constraint === con {
                constraint.constant += 10.0
                UIView.animate(withDuration: 0.5, animations: {
                    self.view.layoutIfNeeded()
                }) 
            } else {
                constraint.constant = 8.0
            }
        }
    }
    
    fileprivate func highlightCounterLabel(_ label: UILabel) {
        for lbl in counterLabels {
            if lbl === label {
                UIView.animate(withDuration: 0.5, animations: {
                    lbl.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
                }) 
            } else {
                lbl.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }
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
