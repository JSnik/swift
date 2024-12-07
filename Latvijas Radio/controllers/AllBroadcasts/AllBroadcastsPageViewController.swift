//
//  AllBroadcastsPageViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

protocol AllBroadcastsPageDelegate: AnyObject {
    func onDidSwitchToPage(_ position: Int)
}

class AllBroadcastsPageViewController: UIPageViewController {
    
    static var TAG = String(describing: AllBroadcastsPageViewController.classForCoder())

    static let PAGE_INDEX_LATIN = 0
    static let PAGE_INDEX_CYRILLIC = 1
    
    lazy var orderedViewControllers: [UIViewController] = {
        return [
            (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_BROADCASTS_BY_ALPHABET_COLLECTION, bundle: nil)
                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_BROADCASTS_BY_ALPHABET_COLLECTION) as! BroadcastsByAlphabetCollectionViewController),
            (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_BROADCASTS_BY_ALPHABET_COLLECTION, bundle: nil)
                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_BROADCASTS_BY_ALPHABET_COLLECTION) as! BroadcastsByAlphabetCollectionViewController)
        ]
    }()
    
    weak var allBroadcastsPageDelegate: AllBroadcastsPageDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(AllBroadcastsPageViewController.TAG, "viewDidLoad")
        
        // listeners
        delegate = self
        
        // this enables swiping on page itself
        dataSource = self
    }

    deinit {
        GeneralUtils.log(AllBroadcastsPageViewController.TAG, "deinit")
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

extension AllBroadcastsPageViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let index = getCurrentPageIndex()
        
        allBroadcastsPageDelegate?.onDidSwitchToPage(index)
    }
}

// MARK: UIPageViewControllerDataSource

extension AllBroadcastsPageViewController: UIPageViewControllerDataSource {
 
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
