//
//  DashboardContainerViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class DashboardContainerViewController: UIViewController, MainPageDelegate, NavigationDelegate {
    
    var TAG = String(describing: DashboardContainerViewController.classForCoder())

    @IBOutlet weak var containerContent: UIView!
    @IBOutlet weak var containerPlayerMini: UIView!
    @IBOutlet weak var containerPlayerMiniBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerNotification: UIView!
    
    weak var notificationViewController: NotificationViewController!
    weak var mainPageViewController: MainPageViewController!
    weak var playerMiniViewController: PlayerMiniViewController!
    weak var navigationViewController: NavigationViewController!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: ColorsHelper.WHITE)
        GeneralUtils.log(TAG, "viewDidLoad")
        
        // listeners
        navigationViewController.delegate = self
        mainPageViewController.mainPageDelegate = self
        
        // UI
        appDelegate.dashboardContainerViewController = self
        
        // Calling this for the first time initializes it.
        MediaPlayerManager.getInstance()
        
        // Notify CarPlay to reload root item only if it is currently showing unauthenticated state.
        if let carPlaySceneDelegate = CarPlaySceneDelegate.getCarPlaySceneDelegate() {
            if let autoContentManager = carPlaySceneDelegate.autoContentManager {
                if (autoContentManager.isAutoInterfaceStateAuthenticationNeeded) {
                    autoContentManager.loadRootTemplate()
                }
            }
        }
        
        // navigate
        navigateToPage(NavigationViewController.NAVIGATION_ITEM_INDEX_DASHBOARD)
        
        do {
            if let deepLinkSharedEpisodeModel = try GeneralUtils.getUserDefaults().getCustomObject(forKey: DeepLinkManager.DEEP_LINK_DATA_SHARED_EPISODE, as: DeepLinkSharedEpisodeModel.self) {
                // remove temp deep link data from app data
                GeneralUtils.getUserDefaults().removeObject(forKey: DeepLinkManager.DEEP_LINK_DATA_SHARED_EPISODE)
                
                let episodeViewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_EPISODE, bundle: nil)
                                        .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_EPISODE) as! EpisodeViewController)

                episodeViewController.deepLinkSharedEpisodeModel = deepLinkSharedEpisodeModel

                navigationController?.pushViewController(episodeViewController, animated: true)
            }
            
            if let deepLinkSharedLivestreamModel = try GeneralUtils.getUserDefaults().getCustomObject(forKey: DeepLinkManager.DEEP_LINK_DATA_SHARED_LIVESTREAM, as: DeepLinkSharedLivestreamModel.self) {
                // remove temp deep link data from app data
                GeneralUtils.getUserDefaults().removeObject(forKey: DeepLinkManager.DEEP_LINK_DATA_SHARED_LIVESTREAM)
                
                let livestreamId = deepLinkSharedLivestreamModel.getLivestreamId()
                
                if let livestreamModel = LivestreamsManager.getLivestreamByIdFromAllChannels(livestreamId) {
                    MediaPlayerManager.getInstance().performActionLoadAndPlayLivestream(MediaPlayerManager.PLAYBACK_TYPE_STREAM, livestreamModel, nil)
                    
                    // switch to livestreams tab
                    navigateToPage(NavigationViewController.NAVIGATION_ITEM_INDEX_LIVESTREAMS)
                }
            }
            
            if let deepLinkSharedBroadcastModel = try GeneralUtils.getUserDefaults().getCustomObject(forKey: DeepLinkManager.DEEP_LINK_DATA_SHARED_BROADCAST, as: DeepLinkSharedBroadcastModel.self) {
                // remove temp deep link data from app data
                GeneralUtils.getUserDefaults().removeObject(forKey: DeepLinkManager.DEEP_LINK_DATA_SHARED_BROADCAST)
                
                let broadcastViewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_BROADCAST, bundle: nil)
                                        .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_BROADCAST) as! BroadcastViewController)

                broadcastViewController.broadcastIdToQuery = deepLinkSharedBroadcastModel.getBroadcastId()

                navigationController?.pushViewController(broadcastViewController, animated: true)
            }
            
        } catch {
            GeneralUtils.log(TAG, "Error: ", error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch(segue.identifier ?? "") {
        case StoryboardsHelper.SEGUE_EMBED_NOTIFICATION:
            self.notificationViewController = (segue.destination as! NotificationViewController)
            self.notificationViewController.setContainerView(containerNotification)

            break
        case StoryboardsHelper.SEGUE_EMBED_MAIN_PAGE:
            self.mainPageViewController = (segue.destination as! MainPageViewController)

            break
        case StoryboardsHelper.SEGUE_EMBED_PLAYER_MINI:
            self.playerMiniViewController = (segue.destination as! PlayerMiniViewController)
            self.playerMiniViewController.setContainerView(containerPlayerMini)
            self.playerMiniViewController.setContainerBottomConstraintReference(containerPlayerMiniBottomConstraint)

            break
        case StoryboardsHelper.SEGUE_EMBED_NAVIGATION:
            self.navigationViewController = (segue.destination as! NavigationViewController)

            break
        default:
            break
        }
    }
    
    deinit {
        GeneralUtils.log(TAG, "deinit")
    }
    
    // MARK: MainPageDelegate
    
    func onDidSwitchToPage(_ position: Int) {
        navigationViewController.setActiveNavigationIndex(position)
    }
    
    // MARK: NavigationDelegate
    
    func onNavigationItemClicked(_ position: Int) {
        // Set viewController scrolls to be reset upon viewWillAppear.
        if (mainPageViewController.getCurrentPageIndex() != position) {
            switch (position) {
            case NavigationViewController.NAVIGATION_ITEM_INDEX_DASHBOARD:
                DashboardViewController.needsScrollReset = true
                
                break
            case NavigationViewController.NAVIGATION_ITEM_INDEX_LIVESTREAMS:
                LivestreamsViewController.needsScrollReset = true
                
                break
            case NavigationViewController.NAVIGATION_ITEM_INDEX_BROADCASTS:
                BroadcastsViewController.needsScrollReset = true
                
                break
            case NavigationViewController.NAVIGATION_ITEM_INDEX_SEARCH:
                SearchViewController.needsScrollReset = true
                
                break
            case NavigationViewController.NAVIGATION_ITEM_INDEX_MY_RADIO:
                MyRadioViewController.needsScrollReset = true
                
                break
            default:
                break
            }
        } else {
            switch (position) {
            case NavigationViewController.NAVIGATION_ITEM_INDEX_DASHBOARD:
                DashboardViewController.needsScrollReset = true
                NotificationCenter.default.post(
                    name: Notification.Name(DashboardViewController.EVENT_SCROLL_TO_TOP_DASCHBOARD),
                    object: nil,
                    userInfo: nil
                )

                break
            case NavigationViewController.NAVIGATION_ITEM_INDEX_LIVESTREAMS:
                LivestreamsViewController.needsScrollReset = true
                NotificationCenter.default.post(
                    name: Notification.Name(LivestreamsViewController.EVENT_SCROLL_TO_TOP_LIVESTREAMS),
                    object: nil,
                    userInfo: nil
                )

                break
            case NavigationViewController.NAVIGATION_ITEM_INDEX_BROADCASTS:
                BroadcastsViewController.needsScrollReset = true
                NotificationCenter.default.post(
                    name: Notification.Name(BroadcastsViewController.EVENT_SCROLL_TO_TOP_BROADCASTS),
                    object: nil,
                    userInfo: nil
                )

                break
            case NavigationViewController.NAVIGATION_ITEM_INDEX_SEARCH:
                SearchViewController.needsScrollReset = true
                NotificationCenter.default.post(
                    name: Notification.Name(SearchViewController.EVENT_SCROLL_TO_TOP_SEARCH),
                    object: nil,
                    userInfo: nil
                )

                break
            case NavigationViewController.NAVIGATION_ITEM_INDEX_MY_RADIO:
                MyRadioViewController.needsScrollReset = true
                NotificationCenter.default.post(
                    name: Notification.Name(MyRadioViewController.EVENT_SCROLL_TO_TOP_MYRADIO),
                    object: nil,
                    userInfo: nil
                )

                break
            default:
                break
            }

        }

        // Pan the pager.
        navigateToPage(position)
    }
    
    // MARK: Custom
    
    func navigateToPage(_ position: Int) {
        var direction: UIPageViewController.NavigationDirection = .forward

        let currentPageIndex = mainPageViewController.getCurrentPageIndex()
        
        if (position < currentPageIndex) {
            direction = .reverse
        }

        mainPageViewController.setViewControllers([mainPageViewController.orderedViewControllers[position]], direction: direction, animated: true, completion: nil)
        
        // update navigation button visuals
        navigationViewController.setActiveNavigationIndex(position)
    }
}
