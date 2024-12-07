//
//  AutoContentManager.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 09/09/2022.
//

import CarPlay

class AutoContentManager: NSObject {
    
    var TAG = String(describing: AutoContentManager.self)

    static let TAB_ID = "TAB_ID"
    static let TAB_HOME_ID = "TAB_HOME_ID"
    static let TAB_MY_RADIO_ID = "TAB_MY_RADIO_ID"
    static let TAB_LIVESTREAMS_ID = "TAB_LIVESTREAMS_ID"
    static let TAB_BROADCASTS_ID = "TAB_BROADCASTS_ID"
    
    static let TAB_HOME_INDEX = 0
    static let TAB_LIVESTREAMS_INDEX = 1
    static let TAB_BROADCASTS_INDEX = 2
    static let TAB_MY_RADIO_INDEX = 3
    
    static let TEMPLATE_ID = "TEMPLATE_ID"
    static let BROADCAST_TEMPLATE_ID = "BROADCAST_TEMPLATE_ID"
    static let QUEUE_TEMPLATE_ID = "QUEUE_TEMPLATE_ID"
    
    static let BROADCAST_ID = "BROADCAST_ID"
    
    static let MAX_EPISODE_AMOUNT = 350
    
    var interfaceController: CPInterfaceController?
    var autoContentHome: AutoContentHome!
    var autoContentMyRadio: AutoContentMyRadio!
    var autoContentLivestreams: AutoContentLivestreams!
    var autoContentBroadcasts: AutoContentBroadcasts!
    var isAutoInterfaceStateAuthenticationNeeded = false
    
    override init() {
        super.init()
        
        setupNowPlayingTemplateQueueButton()
        updateNowPlayingTemplateButtons()
        
        autoContentHome = AutoContentHome(self)
        autoContentMyRadio = AutoContentMyRadio(self)
        autoContentLivestreams = AutoContentLivestreams(self)
        autoContentBroadcasts = AutoContentBroadcasts(self)
    }
    
    deinit {
        GeneralUtils.log(TAG, "deinit")
    }

    func loadRootTemplate() {
        let usersManager = UsersManager.getInstance()
        let currentUser = usersManager.getCurrentUser()
        
        if (currentUser != nil && currentUser?.getAccessToken() != nil) {
            GeneralUtils.log(TAG, "User object exists (but his token might not be valid anymore). Consider this to be an authenticated state.");
            
            isAutoInterfaceStateAuthenticationNeeded = false

            buildTopLevelTabNavigation()
        } else {
            GeneralUtils.log(TAG, "User needs to authenticate.");
            
            isAutoInterfaceStateAuthenticationNeeded = true
            
            let authenticationNeededContentView = buildAuthenticationNeededContentView()

            // It is very important to first popToRootTemplate before we refresh it.
            // Otherwise, if NowPlaying template was pushed previously, the pushing it again will cause an exception (even though it does not show up in .templates)
            interfaceController?.popToRootTemplate(animated: true, completion: { [weak self] _,_ in
                self?.interfaceController?.setRootTemplate(authenticationNeededContentView, animated: true, completion: nil)
            })
        }
    }
    
    func buildTopLevelTabNavigation() {
        // Home tab
        let tabHome: CPListTemplate = CPListTemplate(title: "start".localized(), sections: [])
        tabHome.tabImage = UIImage(named: ImagesHelper.IC_HOME)

        var userInfo = [String: Any]()
        userInfo[AutoContentManager.TAB_ID] = AutoContentManager.TAB_HOME_ID
        tabHome.userInfo = userInfo
        
        // Livestreams tab
        let tabLivestreams: CPListTemplate = CPListTemplate(title: "livestreams".localized(), sections: [])
        tabLivestreams.tabImage = UIImage(named: ImagesHelper.IC_BROADCASTS)

        userInfo = [String: Any]()
        userInfo[AutoContentManager.TAB_ID] = AutoContentManager.TAB_LIVESTREAMS_ID
        tabLivestreams.userInfo = userInfo
        
        // Broadcasts tab
        let tabBroadcasts: CPListTemplate = CPListTemplate(title: "broadcasts".localized(), sections: [])
        tabBroadcasts.tabImage = UIImage(named: ImagesHelper.IC_MICROPHONE)

        userInfo = [String: Any]()
        userInfo[AutoContentManager.TAB_ID] = AutoContentManager.TAB_BROADCASTS_ID
        tabBroadcasts.userInfo = userInfo
        
        // My radio tab
        let tabMyRadio: CPListTemplate = CPListTemplate(title: "my_radio".localized(), sections: [])
        tabMyRadio.tabImage = UIImage(named: ImagesHelper.IC_STAR)

        userInfo = [String: Any]()
        userInfo[AutoContentManager.TAB_ID] = AutoContentManager.TAB_MY_RADIO_ID
        tabMyRadio.userInfo = userInfo
        
        // Set root template.
        // Note: content index is set in index variables, ex. TAB_HOME_INDEX.
        let tabBarTemplate = CPTabBarTemplate(templates: [tabHome, tabLivestreams, tabBroadcasts, tabMyRadio])
        tabBarTemplate.delegate = self

        // It is very important to first popToRootTemplate before we refresh it.
        // Otherwise, if NowPlaying template was pushed previously, the pushing it again will cause an exception (even though it does not show up in .templates)
        interfaceController?.popToRootTemplate(animated: true, completion: { [weak self] _,_ in
            self?.interfaceController?.setRootTemplate(tabBarTemplate, animated: true, completion: nil)
        })
    }
    
    func buildAuthenticationNeededContentView() -> CPListTemplate {
        let listItemAuthenticationNeeded = CPListItem(text: "to_continue_authenticate".localized(), detailText: "", image: nil)
        listItemAuthenticationNeeded.handler = { playlistItem, completion in
            completion()
        }
        
        let sectionItemsAuthenticationNeeded = CPListSection(items: [listItemAuthenticationNeeded])

        let authenticationNeededContentView: CPListTemplate = CPListTemplate(title: Bundle.main.displayName, sections: [sectionItemsAuthenticationNeeded])
        
        return authenticationNeededContentView
    }
    
    func updateLivestreamsTabContent() {
        if let tabLivestreams = autoContentLivestreams.getTabLivestreams() {
            if (autoContentLivestreams.skipCampaignsRequest) {
                autoContentLivestreams.skipCampaignsRequest = false
                
                let livestreamsContentView = autoContentLivestreams.buildLivestreamsContentView()
                tabLivestreams.updateSections(livestreamsContentView)
//                autoContentLivestreams.performRequestGetRadioChannels()
            } else {
                autoContentLivestreams.performRequestCampaigns()
            }
        }
    }
    
    func updateQueueTemplateContentIfPossible() {
        if let topMostListTemplate = getTopMostListTemplate() {
            if let userInfo = topMostListTemplate.userInfo as? [String: Any] {
                if let templateId = userInfo[AutoContentManager.TEMPLATE_ID] as? String {
                    if (templateId == AutoContentManager.QUEUE_TEMPLATE_ID) {
                        let queueContentView: CPListTemplate = buildQueueContentView()
                        
                        topMostListTemplate.updateSections(queueContentView.sections)
                    }
                }
            }
        }
    }
    
    func buildNoConnectivityContentView() -> CPListSection {
        let listItemNoConnectivity = CPListItem(text: "no_internet_connection".localized(), detailText: "", image: nil)
        listItemNoConnectivity.handler = { playlistItem, completion in
            completion()
        }
        
        let sectionItemsNoConnectivity = CPListSection(items: [listItemNoConnectivity])

        return sectionItemsNoConnectivity
    }
    
    func buildLoadingContentView() -> CPListSection {
        let listItemLoading = CPListItem(text: "loading".localized(), detailText: "", image: nil)
        listItemLoading.handler = { playlistItem, completion in
            completion()
        }
        
        let sectionItemsLoading = CPListSection(items: [listItemLoading])

        return sectionItemsLoading
    }
    
    func performRequestGetEpisodes(_ broadcastModel: BroadcastModel) {
        // params
        var urlPathParams = "?"
        urlPathParams = urlPathParams + BroadcastEpisodesRequest.REQUEST_PARAM_LIMIT + "=" + String(AutoContentManager.MAX_EPISODE_AMOUNT)
        
        let broadcastId = broadcastModel.getId()
        
        let broadcastEpisodesRequest = BroadcastEpisodesRequest(nil, broadcastId, urlPathParams)

        broadcastEpisodesRequest.successCallback = { [weak self] (data) -> Void in
            self?.handleBroadcastEpisodesResponse(data, broadcastModel)
        }

        broadcastEpisodesRequest.execute()
    }

    func handleBroadcastEpisodesResponse(_ data: [String: Any], _ broadcastModel: BroadcastModel) {
        let broadcastId = broadcastModel.getId()
        
        let episodesJsonArray = data[BroadcastEpisodesRequest.RESPONSE_PARAM_EPISODES] as! [[String: Any]]
        let episodes = EpisodesHelper.getEpisodesListFromJsonArray(episodesJsonArray)

        if (episodes.count > 0) {
            var episodesListItems = [CPListItem]()
            
            for i in (0..<episodes.count) {
                let episodeModel = episodes[i]
                                
                let listItemEpisode = createListItemEpisode(episodeModel, false)
                
                listItemEpisode.handler = { [weak self] playlistItem, completion in
                    MediaPlayerManager.getInstance().performActionLoadAndPlayEpisode(MediaPlayerManager.PLAYBACK_TYPE_LOCAL_THEN_STREAM, episodeModel, episodes)

                    let nowPlayingTemplate = CPNowPlayingTemplate.shared
                    self?.interfaceController?.pushTemplate(nowPlayingTemplate, animated: true, completion: nil)

                    completion()
                }
                
                episodesListItems.append(listItemEpisode)
            }
            
            let sectionItemsBroadcastEpisodes = CPListSection(items: episodesListItems)
            
            // Check if the current top template is still the one that expects this requests callback.
            if let topMostOrPreTopMostListTemplate = getTopMostOrPreTopMostListTemplate() {
                if let userInfo = topMostOrPreTopMostListTemplate.userInfo as? [String: Any] {
                    if let templateId = userInfo[AutoContentManager.TEMPLATE_ID] as? String {
                        if (templateId == AutoContentManager.BROADCAST_TEMPLATE_ID) {
                            if let templateRepresentedBroadcastId = userInfo[AutoContentManager.BROADCAST_ID] as? String {
                                if (templateRepresentedBroadcastId == broadcastId) {
                                    topMostOrPreTopMostListTemplate.updateSections([sectionItemsBroadcastEpisodes])
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func createListItemBroadcast(_ broadcastModel: BroadcastModel) -> CPListItem {
        let broadcastId = broadcastModel.getId()
        let broadcastCategoryName = broadcastModel.getTitle()
        let broadcastImageUrl = broadcastModel.getImageUrl() ?? ""
        
        let listItemBroadcast = CPListItem(
            id: broadcastId,
            text: broadcastCategoryName,
            detailText: "",
            remoteImageUrl: URL(string: broadcastImageUrl),
            placeholder: nil,
            placeholderIsVectorImage: false,
            carTraitCollection: interfaceController?.carTraitCollection
        )
        
        // Chevron.
        listItemBroadcast.accessoryType = .disclosureIndicator
        
        return listItemBroadcast
    }
    
    func createListItemEpisode(_ episodeModel: EpisodeModel, _ withSubtitle: Bool) -> CPListItem {
        let episodeId = episodeModel.getId()
        let episodeTitle = episodeModel.getTitle()
        let episodeImageUrlString = episodeModel.getImageUrl()
        
        var episodeSubtitle = ""
        
        if (withSubtitle) {
            episodeSubtitle = episodeModel.getBroadcastName()
        }
        
        let listItemEpisode = CPListItem(
            id: episodeId,
            text: episodeTitle,
            detailText: episodeSubtitle,
            remoteImageUrl: URL(string: episodeImageUrlString),
            placeholder: nil,
            placeholderIsVectorImage: false,
            carTraitCollection: interfaceController?.carTraitCollection
        )
        
        listItemEpisode.playingIndicatorLocation = .trailing
        
        if let currentEpisode = MediaPlayerManager.getInstance().currentEpisode {
            if (currentEpisode.getId() == episodeId) {
                listItemEpisode.isPlaying = true
            }
        }
        
        return listItemEpisode
    }
    
    func getTopMostOrPreTopMostListTemplate() -> CPListTemplate? {
        var topMostOrPreTopMostListTemplate = getTopMostListTemplate()

        // User might have opened "Now Playing" template through shortcut button,
        // moving the list template to pre-top most position. Check for it.
        if let interfaceController = interfaceController {
            if (interfaceController.topTemplate is CPNowPlayingTemplate) {
                var preTopMostListTemplate: CPListTemplate?
                
                if (interfaceController.templates.count > 1) {
                    let preTopMostTemplate = interfaceController.templates[interfaceController.templates.count - 2]

                    if (preTopMostTemplate is CPListTemplate) {
                        preTopMostListTemplate = preTopMostTemplate as? CPListTemplate
                    }
                }
                
                if let preTopMostListTemplate = preTopMostListTemplate {
                    topMostOrPreTopMostListTemplate = preTopMostListTemplate
                }
            }
        }
        
        return topMostOrPreTopMostListTemplate
    }
    
    func getTopMostListTemplate() -> CPListTemplate? {
        var topMostListTemplate: CPListTemplate?
        
        if let interfaceController = interfaceController {
            if let topTemplate = interfaceController.topTemplate {
                if (topTemplate is CPListTemplate) {
                    topMostListTemplate = topTemplate as? CPListTemplate
                } else {
                    if let tabBarTemplate = topTemplate as? CPTabBarTemplate {
                        if (tabBarTemplate.selectedTemplate is CPListTemplate) {
                            topMostListTemplate = tabBarTemplate.selectedTemplate as? CPListTemplate
                        }
                    }
                }
            }
        }
        
        return topMostListTemplate
    }
    
    func refreshListItemsPlayingStateIfNecessary() {
        if let topMostListTemplate = getTopMostListTemplate() {
            GeneralUtils.log(TAG, "topMostListTemplate: ", topMostListTemplate)
            
            var containsPlayableItems = false
            
            if let userInfo = topMostListTemplate.userInfo as? [String: Any] {
                if let tabId = userInfo[AutoContentManager.TAB_ID] as? String {
                    if (tabId == AutoContentManager.TAB_HOME_ID ||
                        tabId == AutoContentManager.TAB_LIVESTREAMS_ID) {
                        containsPlayableItems = true
                    }
                }
                
                if userInfo[AutoContentManager.TEMPLATE_ID] is String {
                    containsPlayableItems = true
                }
            }
            
            GeneralUtils.log(TAG, "containsPlayableItems: ", containsPlayableItems)
                
            if (containsPlayableItems) {
                // At this point, we know we need to refresh list,
                // because template ids are only given to lists containing playable items.

                var currentContentId: String?
                
                if let currentEpisode = MediaPlayerManager.getInstance().currentEpisode {
                    currentContentId = currentEpisode.getId()
                }
                
                if let currentLivestream = MediaPlayerManager.getInstance().currentLivestream {
                    if let cId = currentLivestream.id {

                        currentContentId = String(describing:  cId) // getId()

                    }
//                    currentContentId = String(describing:  Int(currentLivestream.id)) ?? "" // getId()
                }

                for section in topMostListTemplate.sections {
                    for item in section.items {
                        // Item is CPListTemplateItem, which is a protocol and doesn't let us update the item.
                        // So access CPListItem instead.
                        
                        if let editableItem = item as? CPListItem {
                            if let currentContentId = currentContentId {
                                if (editableItem.identifier == currentContentId) {
                                    editableItem.isPlaying = true
                                } else {
                                    editableItem.isPlaying = false
                                }
                            } else {
                                editableItem.isPlaying = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setupNowPlayingTemplateQueueButton() {
        let nowPlayingTemplate = CPNowPlayingTemplate.shared
        
        // Add self as listener for up next button tapped event.
        nowPlayingTemplate.add(self)
        
        updateNowPlayingTemplateQueueButtonTitle()
    }
    
    func updateNowPlayingTemplateQueueButtonTitle() {
        let nowPlayingTemplate = CPNowPlayingTemplate.shared
        
        nowPlayingTemplate.upNextTitle = "playlist".localized()
    }
    
    func updateNowPlayingTemplateButtons() {
        let nowPlayingTemplate = CPNowPlayingTemplate.shared
        
        // Update isUpNextButtonEnabled.
        var isUpNextButtonEnabled = false

        if MediaPlayerManager.getInstance().listOfEpisodes != nil {
            isUpNextButtonEnabled = true
        }
        
        if MediaPlayerManager.getInstance().listOfLivestreams != nil {
            isUpNextButtonEnabled = true
        }
        
        nowPlayingTemplate.isUpNextButtonEnabled = isUpNextButtonEnabled
        
        // Update other nowPlayingButtons.
        var nowPlayingButtons = [CPNowPlayingButton]()
        
        if MediaPlayerManager.getInstance().currentEpisode != nil {
            let playbackRateButton = CPNowPlayingPlaybackRateButton(handler: { (button) in
                MediaPlayerManager.getInstance().performActionCyclePlaybackSpeed(false)
            })

            nowPlayingButtons.append(playbackRateButton)
        }
        
        nowPlayingTemplate.updateNowPlayingButtons(nowPlayingButtons)
    }

    func buildQueueContentView() -> CPListTemplate {
        var listQueue: CPListTemplate!
        var listItemsQueue = [CPListItem]()

        if let listOfEpisodes = MediaPlayerManager.getInstance().listOfEpisodes {
            for i in (0..<listOfEpisodes.count) {
                let episodeModel = listOfEpisodes[i]
                                
                let listItemEpisode = createListItemEpisode(episodeModel, false)
                
                listItemEpisode.handler = { playlistItem, completion in
                    MediaPlayerManager.getInstance().performActionLoadAndPlayEpisode(MediaPlayerManager.PLAYBACK_TYPE_LOCAL_THEN_STREAM, episodeModel, listOfEpisodes)

                    completion()
                }
                
                listItemsQueue.append(listItemEpisode)
            }
        }
        
        if let listOfLivestreams = MediaPlayerManager.getInstance().listOfLivestreams {
            for i in (0..<listOfLivestreams.count) {
                let livestreamModel = listOfLivestreams[i]
                
//                if (!livestreamModel.getFakeLivestream()) {
                  if (livestreamModel.name?.contains("Radioteātris") == false) {
                    let listItemLivestream = autoContentLivestreams.createListItemLivestream(livestreamModel)
                    
                    listItemLivestream.handler = { playlistItem, completion in
                        MediaPlayerManager.getInstance().performActionLoadAndPlayLivestream(MediaPlayerManager.PLAYBACK_TYPE_STREAM, livestreamModel, listOfLivestreams)

                        completion()
                    }
                    
                    listItemsQueue.append(listItemLivestream)
                }
            }
        }
        
        let sectionItemsQueue = CPListSection(items: listItemsQueue)
        
        listQueue = CPListTemplate(title: "playlist".localized(), sections: [sectionItemsQueue])
        
        var userInfo = [String: Any]()
        userInfo[AutoContentManager.TEMPLATE_ID] = AutoContentManager.QUEUE_TEMPLATE_ID
        listQueue.userInfo = userInfo

        return listQueue
    }
    
    func handleJwtErrorInCarPlay(_ errorMessage: String?, _ tab: CPListTemplate?) {
        if let errorMessage = errorMessage {
            if (errorMessage == RequestManager.ERROR_NETWORK_ERROR_NO_CONNECTION) {
                if let tab = tab {
                    let sectionItemsNoConnectivity = buildNoConnectivityContentView()
                    tab.updateSections([sectionItemsNoConnectivity])
                }
            } else {
                // accessToken invalid, has to be refreshed by re-login.
                // Clear current accessToken, so that refreshing root shows "authentication needed" state.
                
                let usersManager = UsersManager.getInstance()
                if let currentUser = usersManager.getCurrentUser() {
                    currentUser.setAccessToken(nil)

                    loadRootTemplate()
                }
            }
        }
    }
}

extension AutoContentManager: CPNowPlayingTemplateObserver {
    func nowPlayingTemplateUpNextButtonTapped(_ nowPlayingTemplate: CPNowPlayingTemplate) {
        let queueContentView: CPListTemplate = buildQueueContentView()
        interfaceController?.pushTemplate(queueContentView, animated: true, completion: nil)
    }
}

extension AutoContentManager: CPTabBarTemplateDelegate {
    
    func tabBarTemplate(_ tabBarTemplate: CPTabBarTemplate, didSelect selectedTemplate: CPTemplate) {
        GeneralUtils.log(TAG, "didSelect", selectedTemplate)
        
        let userInfo = selectedTemplate.userInfo as! [String: Any]
        let tabId = userInfo[AutoContentManager.TAB_ID] as! String
        
        GeneralUtils.log(TAG, "Selected tabId: ", tabId)
        
        switch (tabId) {
        case AutoContentManager.TAB_HOME_ID:
            if let tabHome = autoContentHome.getTabHome() {
                let loadingContentView = buildLoadingContentView()
                tabHome.updateSections([loadingContentView])
            }

            // First get latest news episode and then general latest episodes.
            autoContentHome.performRequestGetBroadcastNewsEpisode()

            break
        case AutoContentManager.TAB_MY_RADIO_ID:
            if let tabMyRadio = autoContentMyRadio.getTabMyRadio() {
                let myRadioContentView = autoContentMyRadio.buildMyRadioContentView()
                
                tabMyRadio.updateSections(myRadioContentView)
            }

            break
        case AutoContentManager.TAB_LIVESTREAMS_ID:
            updateLivestreamsTabContent()

            break
        case AutoContentManager.TAB_BROADCASTS_ID:
            if let tabBroadcasts = autoContentBroadcasts.getTabBroadcasts() {
                let loadingContentView = buildLoadingContentView()
                tabBroadcasts.updateSections([loadingContentView])
            }
            
            autoContentBroadcasts.performRequestBroadcastByCategory()
            
            break
        default:
            break
        }
    }
}
