//
//  MyPerformancePageController.swift
//  Aqsar
//
//  Created by moayad on 10/31/16.
//  Copyright © 2016 Ahmad. All rights reserved.
//

import UIKit

class MyPerformancePageController: UIPageViewController {
    //MARK:- IVars
    //weak var tutorialDelegate: TutorialPageViewControllerDelegate?
    
//    private(set) lazy var orderedViewControllers: [UIViewController] = {
//        // The view controllers will be shown in this order
//        return [self.newColoredViewController("myPerVC01"),
//                self.newColoredViewController("myPerVC02")]
//    }()
    
    var orderedViewControllers = [UIViewController]()
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        orderedViewControllers.append(newColoredViewController("myPerVC01"))
        orderedViewControllers.append(newColoredViewController("myPerVC02"))
        
        print(orderedViewControllers)
        
        dataSource = self
        //delegate = self
    }
    
    //MARK:- Main
    fileprivate func newColoredViewController(_ storyboardID: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: storyboardID)
    }
}

extension MyPerformancePageController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
}
