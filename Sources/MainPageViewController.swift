//
//  MainPageViewController.swift
//  GeoConfess
//
//  Created by Матвей Кравцов on 01.03.16.
//  Copyright © 2016 Andrei Costache. All rights reserved.
//

import UIKit

class MainPageViewController: UIPageViewController  {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clearColor()
        
        dataSource = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                direction: .Forward,
                animated: true,
                completion: nil)
        }
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newVC("firstView"),
            self.newVC("secondView"),]
    }()
    
    private func newVC(name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewControllerWithIdentifier(name)
    }
    
}

extension MainPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
                return nil
            }
            
            let previousIndex = viewControllerIndex - 1
            
            guard previousIndex >= 0 else {
                return nil
            }
            
            guard orderedViewControllers.count > previousIndex else {
                return nil
            }
            
            return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
            guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
                return nil
            }
        
            let nextIndex = viewControllerIndex + 1
            let orderedViewControllersCount = orderedViewControllers.count
            
            guard orderedViewControllersCount != nextIndex else {
                return nil
            }
            
            guard orderedViewControllersCount > nextIndex else {
                return nil
            }
            
            return orderedViewControllers[nextIndex]
    }
    
}
