//
//  AllBroadcastsViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class AllBroadcastsViewController: UIViewController, TabsNavigationDelegate, AllBroadcastsPageDelegate {
    
    static var TAG = String(describing: AllBroadcastsViewController.classForCoder())

    @IBOutlet weak var containerNotification: UIView!
    @IBOutlet weak var buttonBack: UIButtonQuinary!
    @IBOutlet weak var containerTabsNavigation: UIView!
    @IBOutlet weak var containerTabsContent: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var textTitle: UILabelH3!
    
    weak var notificationViewController: NotificationViewController!
    weak var tabsNavigationViewController: TabsNavigationViewController!
    weak var allBroadcastsPageViewController: AllBroadcastsPageViewController!
    
    var initialTabIndex: Int?
    var broadcastsLatin: [BroadcastModel]!
    var broadcastsCyrillic: [BroadcastModel]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(AllBroadcastsViewController.TAG, "viewDidLoad")
        
        // listeners
        buttonBack.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        
        tabsNavigationViewController.delegate = self
        
        allBroadcastsPageViewController.allBroadcastsPageDelegate = self

        // UI
        setViewStateNormal()

        performRequestBroadcast()
        let customFont1 = UIFont(name: "FuturaPT-Bold", size: 18.0)
        textTitle.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont1 ?? UIFont.systemFont(ofSize: 18.0))
        textTitle.adjustsFontForContentSizeCategory = true
    }
    
    deinit {
        GeneralUtils.log(AllBroadcastsViewController.TAG, "deinit")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch(segue.identifier ?? "") {
        case StoryboardsHelper.SEGUE_EMBED_NOTIFICATION:
            self.notificationViewController = (segue.destination as! NotificationViewController)
            self.notificationViewController.setContainerView(containerNotification)
            
            break
        case StoryboardsHelper.SEGUE_EMBED_TABS_NAVIGATION:
            self.tabsNavigationViewController = (segue.destination as! TabsNavigationViewController)

            break
        case StoryboardsHelper.SEGUE_EMBED_ALL_BROADCASTS_PAGE:
            self.allBroadcastsPageViewController = (segue.destination as! AllBroadcastsPageViewController)

            break
        default:
            break
        }
    }
    
    // MARK: NavigationDelegate
    
    func onNavigationItemClicked(_ position: Int) {
        navigateToPage(position)
    }
    
    // MARK: AllBroadcastsPageDelegate
    
    func onDidSwitchToPage(_ position: Int) {
        tabsNavigationViewController.setActiveNavigationIndex(position)
    }
    
    // MARK: Custom
    
    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonBack) {
            navigationController?.popViewController(animated: true)
        }
    }
    
    func navigateToPage(_ position: Int) {
        var direction: UIPageViewController.NavigationDirection = .forward

        let currentPageIndex = allBroadcastsPageViewController.getCurrentPageIndex()

        if (position < currentPageIndex) {
            direction = .reverse
        }

        allBroadcastsPageViewController.setViewControllers([allBroadcastsPageViewController.orderedViewControllers[position]], direction: direction, animated: true, completion: nil)

        // update navigation button visuals
        tabsNavigationViewController.setActiveNavigationIndex(position)
    }
    
    func setViewStateNormal() {
        containerTabsNavigation.isHidden = false
        containerTabsContent.isHidden = false
        activityIndicator.setVisibility(UIView.VISIBILITY_GONE)
    }

    func setViewStateLoading() {
        containerTabsNavigation.isHidden = true
        containerTabsContent.isHidden = true
        activityIndicator.setVisibility(UIView.VISIBILITY_VISIBLE)
    }
    
    func performRequestBroadcast() {
        setViewStateLoading()

        let broadcastRequest = BroadcastRequest(notificationViewController)

        broadcastRequest.successCallback = { [weak self] (data) -> Void in
            self?.handleBroadcastResponse(data)
        }

        broadcastRequest.execute()
    }

    func handleBroadcastResponse(_ data: [String: Any]) {
        let broadcasts = data[BroadcastRequest.RESPONSE_PARAM_BROADCASTS] as! [String: Any]
        let broadcastsLatinJsonArray = broadcasts[BroadcastRequest.RESPONSE_PARAM_LATIN] as! [[String: Any]]
        let broadcastsCyrillicJsonArray = broadcasts[BroadcastRequest.RESPONSE_PARAM_CYRILLIC] as! [[String: Any]]

        broadcastsLatin = BroadcastsHelper.getBroadcastsListFromJsonArray(broadcastsLatinJsonArray)
        broadcastsCyrillic = BroadcastsHelper.getBroadcastsListFromJsonArray(broadcastsCyrillicJsonArray)

        let viewControllerLatin = allBroadcastsPageViewController.orderedViewControllers[0] as! BroadcastsByAlphabetCollectionViewController
        let viewControllerCyrillic = allBroadcastsPageViewController.orderedViewControllers[1] as! BroadcastsByAlphabetCollectionViewController

        viewControllerLatin.broadcasts = broadcastsLatin
        viewControllerCyrillic.broadcasts = broadcastsCyrillic

        if (initialTabIndex != nil) {
            navigateToPage(initialTabIndex!)
        } else {
            navigateToPage(AllBroadcastsPageViewController.PAGE_INDEX_LATIN)
        }
        
        setViewStateNormal()
    }
}

