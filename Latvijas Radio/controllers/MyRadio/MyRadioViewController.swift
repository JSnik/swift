//
//  MyRadioViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class MyRadioViewController: UIViewController, MyRadioTabsNavigationDelegate, MyRadioTabsPageDelegate, UIScrollViewDelegate {
    
    static var TAG = String(describing: MyRadioViewController.classForCoder())

    static var needsScrollReset = false
    static var subscribedBroadcastsListNeedsUpdate = true
    static let EVENT_SCROLL_TO_TOP_MYRADIO = "EVENT_SCROLL_TO_TOP_MYRADIO"

    @IBOutlet weak var containerSubscribedBroadcasts: UIView!
    @IBOutlet var containerSubscribedBroadcastsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var subscribedBroadcastsActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var textTitle: UILabelH1!
    
    @IBOutlet weak var mainScrollView: UIScrollViewCollaborative!
    @IBOutlet weak var buttonSettings: UIButtonGenericWithCustomBackground!
    
    weak var dynamicBlockPresentationType3ViewController: DynamicBlockPresentationType3ViewController!
    weak var myRadioTabsNavigationViewController: MyRadioTabsNavigationViewController!
    weak var myRadioTabsPageViewController: MyRadioTabsPageViewController!

    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(MyRadioViewController.TAG, "viewDidLoad")
        
        // listeners
        buttonSettings.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        
        // delegates
        mainScrollView.delegate = self
        myRadioTabsNavigationViewController.delegate = self

        // UI
        navigateToPage(MyRadioTabsPageViewController.PAGE_INDEX_NEW_EPISODES_FROM_SUBSCRIBED_BROADCASTS)
        let customFont1 = UIFont.systemFont(ofSize: 22.0)
        textTitle.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont1)
        textTitle.adjustsFontForContentSizeCategory = true
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTheTop), name: Notification.Name(MyRadioViewController.EVENT_SCROLL_TO_TOP_MYRADIO), object: nil)
    }

    @objc func scrollToTheTop() {
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            self?.mainScrollView.setContentOffset(.zero, animated: false)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch(segue.identifier ?? "") {
        case StoryboardsHelper.SEGUE_EMBED_DYNAMIC_BLOCK_PRESENTATION_TYPE_3:
            self.dynamicBlockPresentationType3ViewController = (segue.destination as! DynamicBlockPresentationType3ViewController)
            
            break
        case StoryboardsHelper.SEGUE_EMBED_MY_RADIO_TABS_NAVIGATION:
            self.myRadioTabsNavigationViewController = (segue.destination as! MyRadioTabsNavigationViewController)

            break
        case StoryboardsHelper.SEGUE_EMBED_MY_RADIO_TABS_PAGE:
            self.myRadioTabsPageViewController = (segue.destination as! MyRadioTabsPageViewController)

            break
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reset scrolls.
        if (MyRadioViewController.needsScrollReset) {
            MyRadioViewController.needsScrollReset = false
            
            resetScrolls()
        }

        if (MyRadioViewController.subscribedBroadcastsListNeedsUpdate) {
            MyRadioViewController.subscribedBroadcastsListNeedsUpdate = false
            
            performRequestUserSubscribedBroadcasts()
        }
    }
    
    deinit {
        GeneralUtils.log(MyRadioViewController.TAG, "deinit")
        
        MyRadioViewController.needsScrollReset = false
        MyRadioViewController.subscribedBroadcastsListNeedsUpdate = true
    }
    
    // MARK: UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // process scrolling only between main scroll view and active tabs list scroll view
        var innerScrollView: UICollectionViewBase!

        let index = myRadioTabsPageViewController.getCurrentPageIndex()
        
        switch(index) {
        case MyRadioTabsPageViewController.PAGE_INDEX_NEW_EPISODES_FROM_SUBSCRIBED_BROADCASTS:
            let newEpisodesFromSubscribedBroadcastsViewController = myRadioTabsPageViewController.orderedViewControllers[index] as! NewEpisodesFromSubscribedBroadcastsViewController
            
            innerScrollView = (newEpisodesFromSubscribedBroadcastsViewController.episodesCollectionViewController.collectionView as! UICollectionViewBase)
            
            break
        case MyRadioTabsPageViewController.PAGE_INDEX_SUBSCRIBED_EPISODES:
            let subscribedEpisodesViewController = myRadioTabsPageViewController.orderedViewControllers[index] as! SubscribedEpisodesViewController
            
            innerScrollView = (subscribedEpisodesViewController.episodesCompactDraggableCollectionViewController.collectionView as! UICollectionViewBase)
            
            break
        case MyRadioTabsPageViewController.PAGE_INDEX_DOWNLOADS:
            let downloadsViewController = myRadioTabsPageViewController.orderedViewControllers[index] as! DownloadsViewController
            
            innerScrollView = (downloadsViewController.episodesCollectionViewController.collectionView as! UICollectionViewBase)
            
            break
        default:
            break
        }
        
        if (innerScrollView != nil) {
            CollaborativeScrollViewHelper.scrollViewDidScroll(scrollView, mainScrollView, innerScrollView)
        }
    }
    
    // MARK: MyRadioTabsNavigationDelegate
    
    func onNavigationItemClicked(_ position: Int) {
        navigateToPage(position)
    }
    
    // MARK: MyRadioTabsPageDelegate
    
    func onDidSwitchToPage(_ position: Int) {
        myRadioTabsNavigationViewController.setActiveNavigationIndex(position)
    }
    
    // MARK: Custom
    
    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonSettings) {
            let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_SETTINGS, bundle: nil)
                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_SETTINGS) as! SettingsViewController)
            
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func navigateToPage(_ position: Int) {
        var direction: UIPageViewController.NavigationDirection = .forward

        let currentPageIndex = myRadioTabsPageViewController.getCurrentPageIndex()

        if (position < currentPageIndex) {
            direction = .reverse
        }

        myRadioTabsPageViewController.setViewControllers([myRadioTabsPageViewController.orderedViewControllers[position]], direction: direction, animated: true, completion: nil)

        // update navigation button visuals
        myRadioTabsNavigationViewController.setActiveNavigationIndex(position)
        
        // scroll scrollViews to top to avoid "being stuck" scenario
        var innerScrollView: UICollectionViewBase!

        switch(position) {
        case MyRadioTabsPageViewController.PAGE_INDEX_NEW_EPISODES_FROM_SUBSCRIBED_BROADCASTS:
            let newEpisodesFromSubscribedBroadcastsViewController = myRadioTabsPageViewController.orderedViewControllers[position] as! NewEpisodesFromSubscribedBroadcastsViewController
            
            innerScrollView = (newEpisodesFromSubscribedBroadcastsViewController.episodesCollectionViewController.collectionView as! UICollectionViewBase)
            
            break
        case MyRadioTabsPageViewController.PAGE_INDEX_SUBSCRIBED_EPISODES:
            let subscribedEpisodesViewController = myRadioTabsPageViewController.orderedViewControllers[position] as! SubscribedEpisodesViewController
            
            innerScrollView = (subscribedEpisodesViewController.episodesCompactDraggableCollectionViewController.collectionView as! UICollectionViewBase)
            
            break
        case MyRadioTabsPageViewController.PAGE_INDEX_DOWNLOADS:
            let downloadsViewController = myRadioTabsPageViewController.orderedViewControllers[position] as! DownloadsViewController
            
            innerScrollView = (downloadsViewController.episodesCollectionViewController.collectionView as! UICollectionViewBase)
            
            break
        default:
            break
        }
        
        if (innerScrollView != nil) {
            innerScrollView.lastContentOffset = CGPoint.zero
            innerScrollView.setContentOffset(CGPoint.zero, animated: false)
        }
    }
    
    func setViewStateNormal() {
        containerSubscribedBroadcasts.setVisibility(UIView.VISIBILITY_VISIBLE)
        containerSubscribedBroadcasts.isHidden = false
        subscribedBroadcastsActivityIndicator.setVisibility(UIView.VISIBILITY_GONE)
    }
    
    func setViewStateLoading() {
        containerSubscribedBroadcasts.setVisibility(UIView.VISIBILITY_VISIBLE)
        containerSubscribedBroadcasts.isHidden = true
        subscribedBroadcastsActivityIndicator.setVisibility(UIView.VISIBILITY_VISIBLE)
    }
    
    func setViewStateNoSubscribedBroadcasts() {
        containerSubscribedBroadcasts.setVisibility(UIView.VISIBILITY_GONE)
        containerSubscribedBroadcasts.isHidden = true
        subscribedBroadcastsActivityIndicator.setVisibility(UIView.VISIBILITY_GONE)
    }
    
    func performRequestUserSubscribedBroadcasts() {
        setViewStateLoading()
        
        containerSubscribedBroadcastsHeightConstraint.isActive = true

        let userSubscribedBroadcastsRequest = UserSubscribedBroadcastsRequest(appDelegate.dashboardContainerViewController!.notificationViewController)

        userSubscribedBroadcastsRequest.successCallback = { [weak self] (data) -> Void in
            self?.handleUserSubscribedBroadcastsResponse(data)
        }

        userSubscribedBroadcastsRequest.execute()
    }
    
    func handleUserSubscribedBroadcastsResponse(_ data: [String: Any]) {
        let broadcastsJsonArray = data[UserSubscribedBroadcastsRequest.RESPONSE_PARAM_BROADCASTS] as! [NSDictionary]
        
        if (broadcastsJsonArray.count > 0) {
            // generate dynamic block model, to reuse view controller
            let dynamicBlockModel = DynamicBlockModel("subscribed_broadcasts".localized(), "3", ContentSectionRequest.CONTENT_TYPE_BROADCASTS)
            dynamicBlockModel.setItems(broadcastsJsonArray)
            
            containerSubscribedBroadcastsHeightConstraint.isActive = false

            dynamicBlockPresentationType3ViewController.dynamicBlockModel = dynamicBlockModel
            dynamicBlockPresentationType3ViewController.loadDynamicBlock(dynamicBlockModel)

            setViewStateNormal()
        } else {
            setViewStateNoSubscribedBroadcasts()
        }
    }
    
    func resetScrolls() {
        // Before we can reset mainScrollView, we have to reset current tabs inner collection scrollView.
        var innerScrollView: UICollectionViewBase!

        let index = myRadioTabsPageViewController.getCurrentPageIndex()
        
        switch(index) {
        case MyRadioTabsPageViewController.PAGE_INDEX_NEW_EPISODES_FROM_SUBSCRIBED_BROADCASTS:
            let newEpisodesFromSubscribedBroadcastsViewController = myRadioTabsPageViewController.orderedViewControllers[index] as! NewEpisodesFromSubscribedBroadcastsViewController
            
            innerScrollView = (newEpisodesFromSubscribedBroadcastsViewController.episodesCollectionViewController.collectionView as! UICollectionViewBase)
            
            break
        case MyRadioTabsPageViewController.PAGE_INDEX_SUBSCRIBED_EPISODES:
            let subscribedEpisodesViewController = myRadioTabsPageViewController.orderedViewControllers[index] as! SubscribedEpisodesViewController
            
            innerScrollView = (subscribedEpisodesViewController.episodesCompactDraggableCollectionViewController.collectionView as! UICollectionViewBase)
            
            break
        case MyRadioTabsPageViewController.PAGE_INDEX_DOWNLOADS:
            let downloadsViewController = myRadioTabsPageViewController.orderedViewControllers[index] as! DownloadsViewController
            
            innerScrollView = (downloadsViewController.episodesCollectionViewController.collectionView as! UICollectionViewBase)
            
            break
        default:
            break
        }
        
        if (innerScrollView != nil) {
            innerScrollView.setContentOffset(.zero, animated: false)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            self?.mainScrollView.setContentOffset(.zero, animated: false)
        }
    }
}

