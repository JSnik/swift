//
//  MainPageViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

protocol MainPageDelegate: AnyObject {
    func onDidSwitchToPage(_ position: Int)
}

// https://spin.atomicobject.com/2015/12/23/swift-uipageviewcontroller-tutorial/

class MainPageViewController: UIPageViewController {
    
    static var TAG = String(describing: MainPageViewController.classForCoder())

    lazy var orderedViewControllers: [UIViewController] = {
        return [
            (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_DASHBOARD, bundle: nil)
                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_DASHBOARD) as! DashboardViewController),
            (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_LIVESTREAMS, bundle: nil)
                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_LIVESTREAMS) as! LivestreamsViewController),
            (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_BROADCASTS, bundle: nil)
                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_BROADCASTS) as! BroadcastsViewController),
            (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_SEARCH, bundle: nil)
                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_SEARCH) as! SearchViewController),
            (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_MY_RADIO, bundle: nil)
                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_MY_RADIO) as! MyRadioViewController)
        ]
    }()
    
    weak var mainPageDelegate: MainPageDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(MainPageViewController.TAG, "viewDidLoad")
        
        // listeners
        delegate = self
        
        // this enables swiping on page itself
        //dataSource = self
    }

    deinit {
        GeneralUtils.log(MainPageViewController.TAG, "deinit")
    }
    
    // MARK: Custom
    
    func getCurrentPageIndex() -> Int {
        var result = -1

        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.firstIndex(of: firstViewController) {
            result = index
        }
        
        return result
    }
}

// MARK: UIPageViewControllerDelegate

extension MainPageViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let index = getCurrentPageIndex()
        
        mainPageDelegate?.onDidSwitchToPage(index)
    }
}

// MARK: UIPageViewControllerDataSource

extension MainPageViewController: UIPageViewControllerDataSource {
 
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
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
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
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
