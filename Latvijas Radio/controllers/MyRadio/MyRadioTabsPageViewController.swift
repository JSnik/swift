//
//  MyRadioTabsPageViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

protocol MyRadioTabsPageDelegate: AnyObject {
    func onDidSwitchToPage(_ position: Int)
}

class MyRadioTabsPageViewController: UIPageViewController {
    
    static var TAG = String(describing: MyRadioTabsPageViewController.classForCoder())
    
    static let PAGE_INDEX_NEW_EPISODES_FROM_SUBSCRIBED_BROADCASTS = 0
    static let PAGE_INDEX_SUBSCRIBED_EPISODES = 1
    static let PAGE_INDEX_DOWNLOADS = 2

    lazy var orderedViewControllers: [UIViewController] = {
        return [
            (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_NEW_EPISODES_FROM_SUBSCRIBED_BROADCASTS, bundle: nil)
                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_NEW_EPISODES_FROM_SUBSCRIBED_BROADCASTS) as! NewEpisodesFromSubscribedBroadcastsViewController),
            (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_SUBSCRIBED_EPISODES, bundle: nil)
                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_SUBSCRIBED_EPISODES) as! SubscribedEpisodesViewController),
            (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_DOWNLOADS, bundle: nil)
                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_DOWNLOADS) as! DownloadsViewController)
        ]
    }()
    
    weak var myRadioTabsPageDelegate: MyRadioTabsPageDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(MyRadioTabsPageViewController.TAG, "viewDidLoad")
        
        // listeners
        delegate = self

        // this enables swiping on page itself
        //dataSource = self
    }

    deinit {
        GeneralUtils.log(MyRadioTabsPageViewController.TAG, "deinit")
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

extension MyRadioTabsPageViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let index = getCurrentPageIndex()
        
        myRadioTabsPageDelegate?.onDidSwitchToPage(index)
    }
}

// MARK: UIPageViewControllerDataSource

extension MyRadioTabsPageViewController: UIPageViewControllerDataSource {
 
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
