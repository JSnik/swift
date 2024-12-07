//
//  ChangeLivestreamsOrderViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 23/08/2022.
//

import UIKit

class ChangeLivestreamsOrderViewController: UIViewController {
    
    var TAG = String(describing: ChangeLivestreamsOrderViewController.classForCoder())
    
    @IBOutlet var buttonBack: UIButtonQuinary!
    @IBOutlet var containerLivestreamCompactDraggableCollection: UIView!
    @IBOutlet var buttonSave: UIButtonSecondary!
    
    weak var livestreamsCompactDraggableCollectionViewController: LivestreamsCompactDraggableCollectionViewController?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(TAG, "viewDidLoad")
        
        // Listeners
        buttonBack.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonSave.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)


        // Other
        setupCollectionViewLivestreamsCompactDraggable()
//        performRequestGetRadioChannels()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch(segue.identifier ?? "") {
        case StoryboardsHelper.SEGUE_EMBED_LIVESTREAMS_COMPACT_DRAGGABLE_COLLECTION:
            livestreamsCompactDraggableCollectionViewController = (segue.destination as! LivestreamsCompactDraggableCollectionViewController)

            break
        default:
            break
        }
    }

    deinit {
        GeneralUtils.log(TAG, "deinit")
    }
    
    // MARK: Custom
    
    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonBack) {
            navigationController?.popViewController(animated: true)
        }
        if (sender == buttonSave) {
            saveOrder()
        }
    }

    func performRequestGetRadioChannels() {
        let channelId = ""
        let channelRadioRequest = ChannelRadioRequest(appDelegate.dashboardContainerViewController!.notificationViewController, channelId)


        channelRadioRequest.successCallback = { [weak self] (data, data1) -> Void in
            print("channelRadioRequest data = \(data),  data1 = \(data1)")
                    self?.handleRadioChannelsResponse(data, data1)
                }
        channelRadioRequest.errorCallback = { [weak self] in
            print("channelRadioRequest.errorCallback")
        }

        channelRadioRequest.execute()
    }

    func handleRadioChannelsResponse(_ data: [String: Any], _ data1: Data) {

        var dataset = [RadioChannel]()
        do {
            let someDictionaryFromJSON = try JSONSerialization.jsonObject(with: data1, options: .allowFragments) as! [String: Any]
            print("ChangeLivestreamsOrderViewController handleRadioChannelsResponse someDictionaryFromJSON = \(someDictionaryFromJSON)")
//            let json4Swift_Base = try SearchSuccess(someDictionaryFromJSON)
            let jsonDecoder = JSONDecoder()
            let json4Swift_Base = try jsonDecoder.decode(ChannelsSuccess.self, from: data1)

            let radioChannels = json4Swift_Base.results
            //        let hits = data[SearchRequest.RESPONSE_PARAM_HITS] as! [[String: Any]]
            print("ChangeLivestreamsOrderViewController handleRadioChannelsResponse radioChannels = \(radioChannels)")
            if (radioChannels?.count ?? 0 > 0) {
                for i in (0..<(radioChannels?.count ?? 0)) {
                    if let radioChannel = radioChannels?[i] {
                        dataset.append(radioChannel)
                    }
                }

                var fullRadioChannelDataset: [RadioChannel]!
                fullRadioChannelDataset = [RadioChannel]()
                fullRadioChannelDataset.append(contentsOf: dataset)

                let usersManager = UsersManager.getInstance()
                if let currentUser = usersManager.getCurrentUser() {

                    var isChristmasLivestreamCampaignEnabled = false

                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    if let dashboardContainerViewController = appDelegate.dashboardContainerViewController {
                        if let mainPageViewController = dashboardContainerViewController.mainPageViewController {
                            if let dashboardViewController = mainPageViewController.orderedViewControllers[NavigationViewController.NAVIGATION_ITEM_INDEX_DASHBOARD] as? DashboardViewController {
                                isChristmasLivestreamCampaignEnabled = dashboardViewController.isChristmasLivestreamCampaignEnabled
                            }
                        }
                    }

                    let curatedLivestreamsDataset = LivestreamsManager.getCuratedList(fullRadioChannelDataset, isChristmasLivestreamCampaignEnabled)

                    livestreamsCompactDraggableCollectionViewController?.updateDataset(curatedLivestreamsDataset)
                }
            }
        } catch DecodingError.keyNotFound(let key, let context) {
            fatalError("Failed to decode due to missing key '\(key.stringValue)' not found – \(context.debugDescription)")
        } catch DecodingError.typeMismatch(let type, let context) {
            fatalError("Failed to decode due to type mismatch '\(type)' – \(context.codingPath) - \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type, let context) {
            fatalError("Failed to decode due to missing \(type) value – \(context.debugDescription)")
        } catch DecodingError.dataCorrupted(_) {
            fatalError("Failed to decode because it appears to be invalid JSON")
        } catch {
            fatalError("Failed to decode: \(error.localizedDescription)")
        }
    }


    func setupCollectionViewLivestreamsCompactDraggable() {
        let usersManager = UsersManager.getInstance()
        if let currentUser = usersManager.getCurrentUser() {
            let orderedLivestreamsDataset = LivestreamsManager.getOrderedList(currentUser)
            
            var isChristmasLivestreamCampaignEnabled = false
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if let dashboardContainerViewController = appDelegate.dashboardContainerViewController {
                if let mainPageViewController = dashboardContainerViewController.mainPageViewController {
                    if let dashboardViewController = mainPageViewController.orderedViewControllers[NavigationViewController.NAVIGATION_ITEM_INDEX_DASHBOARD] as? DashboardViewController {
                        isChristmasLivestreamCampaignEnabled = dashboardViewController.isChristmasLivestreamCampaignEnabled
                    }
                }
            }
            
            let curatedLivestreamsDataset = LivestreamsManager.getCuratedList(orderedLivestreamsDataset, isChristmasLivestreamCampaignEnabled)

            livestreamsCompactDraggableCollectionViewController?.updateDataset(curatedLivestreamsDataset)
        }
    }
    
    func saveOrder() {
        if let livestreamIds = livestreamsCompactDraggableCollectionViewController?.getLivestreamIdsInCurrentOrder() {
            let usersManager = UsersManager.getInstance()
            if let currentUser = usersManager.getCurrentUser() {
                currentUser.setLivestreamsOrder(livestreamIds)
                
                usersManager.saveCurrentUserData()
                
                DashboardViewController.livestreamsCompactListNeedsUpdate = true
                
                // Update media player manager content listOfLivestreams list.
                let currentLivestream = MediaPlayerManager.getInstance().currentLivestream
                let listOfLivestreams = MediaPlayerManager.getInstance().listOfLivestreams
                
                if (currentLivestream != nil && listOfLivestreams != nil) {
                    if let contentLoadedFromSource = MediaPlayerManager.getInstance().contentLoadedFromSource {
                        if (contentLoadedFromSource == MediaPlayerManager.CONTENT_SOURCE_NAME_APP_DASHBOARD_HORIZONTAL_SLIDER ||
                            contentLoadedFromSource == MediaPlayerManager.CONTENT_SOURCE_NAME_AUTO_CONTENT_LIVESTREAMS) {
                            // Get livestreams in user specified order.
                            
                            var allLivestreamsInUserSpecifierOrder = [/*LivestreamModel*/RadioChannel]()
                            
                            for livestreamId in livestreamIds {
                                if let livestreamModel = LivestreamsManager.getLivestreamByIdFromAllChannels(livestreamId /*, livestreamsCompactDraggableCollectionViewController?.dataset ?? [RadioChannel]()*/) {
                                    allLivestreamsInUserSpecifierOrder.append(livestreamModel)
                                }
                            }
                            
                            let listOfPlayableOrderedLivestreams = LivestreamsManager.getOnlyPlayableLivestreams(allLivestreamsInUserSpecifierOrder)
                            
                            MediaPlayerManager.getInstance().listOfLivestreams = listOfPlayableOrderedLivestreams
                        }
                    }
                }
                
                // Refresh CarPlay livestreams tab and queue list.
                if let carPlaySceneDelegate = CarPlaySceneDelegate.getCarPlaySceneDelegate() {
                    carPlaySceneDelegate.autoContentManager?.updateLivestreamsTabContent()
                    carPlaySceneDelegate.autoContentManager?.updateQueueTemplateContentIfPossible()
                }
                
                navigationController?.popViewController(animated: true)
                
                if let navigationViewControllers = self.navigationController?.viewControllers {
                    Toast.show(message: "settings_saved".localized(), controller: navigationViewControllers[navigationViewControllers.count - 1])
                }
            }
        }
    }
}

