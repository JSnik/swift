//
//  AutoContentMyRadio.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 09/09/2022.
//

import CarPlay

class AutoContentMyRadio: NSObject {
    
    var TAG = String(describing: AutoContentMyRadio.self)
    
    // Simply helps identifying templates.
    static let LATEST_EPISODES_TEMPLATE_ID = "LATEST_EPISODES_TEMPLATE_ID"
    static let MY_LIST_TEMPLATE_ID = "MY_LIST_TEMPLATE_ID"
    static let DOWNLOADS_TEMPLATE_ID = "DOWNLOADS_TEMPLATE_ID"
    
    let MEDIA_ITEM_SUBSCRIBED_BROADCASTS_ID = "MEDIA_ITEM_SUBSCRIBED_BROADCASTS_ID"
    let MEDIA_ITEM_NEW_EPISODES_FROM_SUBSCRIBED_BROADCASTS_ID = "MEDIA_ITEM_NEW_EPISODES_FROM_SUBSCRIBED_BROADCASTS_ID"
    let MEDIA_ITEM_MY_LIST_ID = "MEDIA_ITEM_MY_LIST_ID"
    let MEDIA_ITEM_DOWNLOADS_ID = "MEDIA_ITEM_DOWNLOADS_ID"
    
    weak var autoContentManager: AutoContentManager?
    
    init(_ autoContentManager: AutoContentManager) {
        self.autoContentManager = autoContentManager
    }
    
    deinit {
        GeneralUtils.log(TAG, "deinit")
    }

    func getTabMyRadio() -> CPListTemplate? {
        var result: CPListTemplate?
        
        if let interfaceController = autoContentManager?.interfaceController {
            if let tabBarTemplate = interfaceController.rootTemplate as? CPTabBarTemplate {
                if (tabBarTemplate.templates.count > 0) {
                    if let tabMyRadio = tabBarTemplate.templates[AutoContentManager.TAB_MY_RADIO_INDEX] as? CPListTemplate {
                        result = tabMyRadio
                    }
                }
            }
        }
        
        return result
    }
    
    func buildMyRadioContentView() -> [CPListSection] {
        var listItemsMyRadio = [CPListItem]()
        
        // Subscribed broadcasts
        let listItemSubscribedBroadcasts = createListItemSubscribedBroadcasts()
        
        listItemSubscribedBroadcasts.handler = { [weak self] playlistItem, completion in
            if let self = self {
                if let autoContentManager = self.autoContentManager {
                    let loadingContentView = autoContentManager.buildLoadingContentView()
                    
                    let listSubscribedBroadcasts: CPListTemplate = CPListTemplate(title: "subscribed_broadcasts".localized(), sections: [loadingContentView])
                    
                    var userInfo = [String: Any]()
                    userInfo[AutoContentManager.TEMPLATE_ID] = AutoContentManager.BROADCAST_TEMPLATE_ID
                    listSubscribedBroadcasts.userInfo = userInfo
                    
                    autoContentManager.interfaceController?.pushTemplate(listSubscribedBroadcasts, animated: true, completion: nil)
                }

                self.performRequestUserSubscribedBroadcasts()
            }
            
            completion()
        }
        
        // Chevron.
        listItemSubscribedBroadcasts.accessoryType = .disclosureIndicator
        
        listItemsMyRadio.append(listItemSubscribedBroadcasts)
        
        
        
        // New episodes from subscribed broadcasts
        let listItemNewEpisodesFromSubscribedBroadcasts = createListItemNewEpisodesFromSubscribedBroadcasts()
        
        listItemNewEpisodesFromSubscribedBroadcasts.handler = { [weak self] playlistItem, completion in
            if let self = self {
                if let autoContentManager = self.autoContentManager {
                    let loadingContentView = autoContentManager.buildLoadingContentView()
                    
                    let listNewEpisodesFromSubscribedBroadcasts: CPListTemplate = CPListTemplate(title: "newest_episodes".localized(), sections: [loadingContentView])
                    
                    var userInfo = [String: Any]()
                    userInfo[AutoContentManager.TEMPLATE_ID] = AutoContentMyRadio.LATEST_EPISODES_TEMPLATE_ID
                    listNewEpisodesFromSubscribedBroadcasts.userInfo = userInfo
                    
                    autoContentManager.interfaceController?.pushTemplate(listNewEpisodesFromSubscribedBroadcasts, animated: true, completion: nil)
                }

                self.performRequestUserSubscribedBroadcastsLatestEpisodes()
            }
            
            completion()
        }
        
        // Chevron.
        listItemNewEpisodesFromSubscribedBroadcasts.accessoryType = .disclosureIndicator
        
        listItemsMyRadio.append(listItemNewEpisodesFromSubscribedBroadcasts)
        
        
        
        // MyList
        let listItemMyList = createListItemMyList()
        
        listItemMyList.handler = { [weak self] playlistItem, completion in
            if let self = self {
                if let autoContentManager = self.autoContentManager {
                    let loadingContentView = autoContentManager.buildLoadingContentView()
                    
                    let listSubscribedEpisodes: CPListTemplate = CPListTemplate(title: "my_list".localized(), sections: [loadingContentView])
                    
                    var userInfo = [String: Any]()
                    userInfo[AutoContentManager.TEMPLATE_ID] = AutoContentMyRadio.MY_LIST_TEMPLATE_ID
                    listSubscribedEpisodes.userInfo = userInfo
                    
                    autoContentManager.interfaceController?.pushTemplate(listSubscribedEpisodes, animated: true, completion: nil)
                }
                
                self.performRequestUserSubscribedEpisodes()
            }
            
            completion()
        }
        
        // Chevron.
        listItemMyList.accessoryType = .disclosureIndicator
        
        listItemsMyRadio.append(listItemMyList)
        
        
        
        // Downloads
        let listItemDownloads = createListItemDownloads()
        
        listItemDownloads.handler = { [weak self] playlistItem, completion in
            completion()
            
            if let listDownloads = self?.buildDownloadsContentView() {
                self?.autoContentManager?.interfaceController?.pushTemplate(listDownloads, animated: true, completion: nil)
            }
        }
        
        // Chevron.
        listItemDownloads.accessoryType = .disclosureIndicator
        
        listItemsMyRadio.append(listItemDownloads)
        
        
        
        let sectionItemsMyRadio = CPListSection(items: listItemsMyRadio)

        return [sectionItemsMyRadio]
    }
    
    func createListItemSubscribedBroadcasts() -> CPListItem {
        let listItemSubscribedBroadcasts = CPListItem(
            id: MEDIA_ITEM_SUBSCRIBED_BROADCASTS_ID,
            text: "subscribed_broadcasts".localized(),
            detailText: "",
            remoteImageUrl: nil,
            placeholder: nil,
            placeholderIsVectorImage: false,
            carTraitCollection: autoContentManager?.interfaceController?.carTraitCollection
        )
        
        return listItemSubscribedBroadcasts
    }
    
    func createListItemNewEpisodesFromSubscribedBroadcasts() -> CPListItem {
        let listItemNewEpisodesFromSubscribedBroadcasts = CPListItem(
            id: MEDIA_ITEM_NEW_EPISODES_FROM_SUBSCRIBED_BROADCASTS_ID,
            text: "newest_episodes".localized(),
            detailText: "",
            remoteImageUrl: nil,
            placeholder: nil,
            placeholderIsVectorImage: false,
            carTraitCollection: autoContentManager?.interfaceController?.carTraitCollection
        )
        
        return listItemNewEpisodesFromSubscribedBroadcasts
    }
    
    func createListItemMyList() -> CPListItem {
        let listItemMyList = CPListItem(
            id: MEDIA_ITEM_MY_LIST_ID,
            text: "my_list".localized(),
            detailText: "",
            remoteImageUrl: nil,
            placeholder: nil,
            placeholderIsVectorImage: false,
            carTraitCollection: autoContentManager?.interfaceController?.carTraitCollection
        )
        
        return listItemMyList
    }
    
    func createListItemDownloads() -> CPListItem {
        let listItemDownloads = CPListItem(
            id: MEDIA_ITEM_DOWNLOADS_ID,
            text: "downloads".localized(),
            detailText: "",
            remoteImageUrl: nil,
            placeholder: nil,
            placeholderIsVectorImage: false,
            carTraitCollection: autoContentManager?.interfaceController?.carTraitCollection
        )
        
        return listItemDownloads
    }
    
    func performRequestUserSubscribedBroadcasts() {
        let userSubscribedBroadcastsRequest = UserSubscribedBroadcastsRequest(nil)

        userSubscribedBroadcastsRequest.successCallback = { [weak self] (data) -> Void in
            self?.handleUserSubscribedBroadcastsResponse(data)
        }
        
        userSubscribedBroadcastsRequest.errorCallback = { [weak self] in
            self?.autoContentManager?.handleJwtErrorInCarPlay(userSubscribedBroadcastsRequest.errorMessage, self?.getTabMyRadio())
        }

        userSubscribedBroadcastsRequest.execute()
    }
    
    func handleUserSubscribedBroadcastsResponse(_ data: [String: Any]) {
        var listItemsSubscribedBroadcasts = [CPListItem]()
        
        let broadcastsJsonArray = data[UserSubscribedBroadcastsRequest.RESPONSE_PARAM_BROADCASTS] as! [[String: Any]]
        
        let broadcasts = BroadcastsHelper.getBroadcastsListFromJsonArray(broadcastsJsonArray)

        for i in (0..<broadcasts.count) {
            let broadcastModel = broadcasts[i]
            
            let broadcastId = broadcastModel.getId()
            let broadcastTitle = broadcastModel.getTitle()

            if let listItemBroadcast = self.autoContentManager?.createListItemBroadcast(broadcastModel) {
                listItemBroadcast.handler = { [weak self] playlistItem, completion in
                    if let self = self {
                        if let autoContentManager = self.autoContentManager {
                            let loadingContentView = autoContentManager.buildLoadingContentView()
                            
                            let listBroadcastEpisodes: CPListTemplate = CPListTemplate(title: broadcastTitle, sections: [loadingContentView])
                            
                            var userInfo = [String: Any]()
                            userInfo[AutoContentManager.TEMPLATE_ID] = AutoContentManager.BROADCAST_TEMPLATE_ID
                            userInfo[AutoContentManager.BROADCAST_ID] = broadcastId
                            listBroadcastEpisodes.userInfo = userInfo
                            
                            autoContentManager.interfaceController?.pushTemplate(listBroadcastEpisodes, animated: true, completion: nil)
                        
                            autoContentManager.performRequestGetEpisodes(broadcastModel)
                        }
                    }

                    completion()
                }
                
                listItemsSubscribedBroadcasts.append(listItemBroadcast)
            }
        }

        let sectionItemsSubscribedBroadcasts = CPListSection(items: listItemsSubscribedBroadcasts)

        // Check if the current top template is still the one that expects this requests callback.
        if let topMostOrPreTopMostListTemplate = autoContentManager?.getTopMostOrPreTopMostListTemplate() {
            if let userInfo = topMostOrPreTopMostListTemplate.userInfo as? [String: Any] {
                if let templateId = userInfo[AutoContentManager.TEMPLATE_ID] as? String {
                    if (templateId == AutoContentManager.BROADCAST_TEMPLATE_ID) {
                        topMostOrPreTopMostListTemplate.updateSections([sectionItemsSubscribedBroadcasts])
                    }
                }
            }
        }
    }
    
    func performRequestUserSubscribedBroadcastsLatestEpisodes() {
        let userSubscribedBroadcastsLatestEpisodesRequest = UserSubscribedBroadcastsLatestEpisodesRequest(nil)

        userSubscribedBroadcastsLatestEpisodesRequest.successCallback = { [weak self] (data) -> Void in
            self?.handleUserSubscribedBroadcastsLatestEpisodesResponse(data)
        }
        
        userSubscribedBroadcastsLatestEpisodesRequest.errorCallback = { [weak self] in
            self?.autoContentManager?.handleJwtErrorInCarPlay(userSubscribedBroadcastsLatestEpisodesRequest.errorMessage, self?.getTabMyRadio())
        }

        userSubscribedBroadcastsLatestEpisodesRequest.execute()
    }
    
    func handleUserSubscribedBroadcastsLatestEpisodesResponse(_ data: [String: Any]) {
        let episodesJsonArray = data[UserSubscribedBroadcastsLatestEpisodesRequest.RESPONSE_PARAM_EPISODES] as! [[String: Any]]
        
        let episodes = EpisodesHelper.getEpisodesListFromJsonArray(episodesJsonArray)

        if (episodes.count > 0) {
            var episodesListItems = [CPListItem]()
            
            for i in (0..<episodes.count) {
                if (i < AutoContentManager.MAX_EPISODE_AMOUNT) {
                    let episodeModel = episodes[i]
                                    
                    if let listItemEpisode = autoContentManager?.createListItemEpisode(episodeModel, false) {
                        listItemEpisode.handler = { [weak self] playlistItem, completion in
                            MediaPlayerManager.getInstance().performActionLoadAndPlayEpisode(MediaPlayerManager.PLAYBACK_TYPE_LOCAL_THEN_STREAM, episodeModel, episodes)

                            let nowPlayingTemplate = CPNowPlayingTemplate.shared
                            self?.autoContentManager?.interfaceController?.pushTemplate(nowPlayingTemplate, animated: true, completion: nil)

                            completion()
                        }
                        
                        episodesListItems.append(listItemEpisode)
                    }
                }
            }
            
            let sectionItemsLatestEpisodes = CPListSection(items: episodesListItems)
            
            // Check if the current top template is still the one that expects this requests callback.
            if let topMostOrPreTopMostListTemplate = autoContentManager?.getTopMostOrPreTopMostListTemplate() {
                if let userInfo = topMostOrPreTopMostListTemplate.userInfo as? [String: Any] {
                    if let templateId = userInfo[AutoContentManager.TEMPLATE_ID] as? String {
                        if (templateId == AutoContentMyRadio.LATEST_EPISODES_TEMPLATE_ID) {
                            topMostOrPreTopMostListTemplate.updateSections([sectionItemsLatestEpisodes])
                        }
                    }
                }
            }
        }
    }
    
    func performRequestUserSubscribedEpisodes() {
        let userSubscribedEpisodesRequest = UserSubscribedEpisodesRequest(nil)

        userSubscribedEpisodesRequest.successCallback = { [weak self] (data) -> Void in
            self?.handleUserSubscribedEpisodesResponse(data)
        }
        
        userSubscribedEpisodesRequest.errorCallback = { [weak self] in
            self?.autoContentManager?.handleJwtErrorInCarPlay(userSubscribedEpisodesRequest.errorMessage, self?.getTabMyRadio())
        }

        userSubscribedEpisodesRequest.execute()
    }
    
    func handleUserSubscribedEpisodesResponse(_ data: [String: Any]) {
        let episodesJsonArray = data[UserSubscribedEpisodesRequest.RESPONSE_PARAM_EPISODES] as! [[String: Any]]
        
        let episodes = EpisodesHelper.getEpisodesListFromJsonArray(episodesJsonArray)

        if (episodes.count > 0) {
            var episodesListItems = [CPListItem]()
            
            for i in (0..<episodes.count) {
                if (i < AutoContentManager.MAX_EPISODE_AMOUNT) {
                    let episodeModel = episodes[i]
                                    
                    if let listItemEpisode = autoContentManager?.createListItemEpisode(episodeModel, false) {
                        listItemEpisode.handler = { [weak self] playlistItem, completion in
                            MediaPlayerManager.getInstance().performActionLoadAndPlayEpisode(MediaPlayerManager.PLAYBACK_TYPE_LOCAL_THEN_STREAM, episodeModel, episodes)

                            let nowPlayingTemplate = CPNowPlayingTemplate.shared
                            self?.autoContentManager?.interfaceController?.pushTemplate(nowPlayingTemplate, animated: true, completion: nil)

                            completion()
                        }
                        
                        episodesListItems.append(listItemEpisode)
                    }
                }
            }
            
            let sectionItemsLatestEpisodes = CPListSection(items: episodesListItems)
            
            // Check if the current top template is still the one that expects this requests callback.
            if let topMostOrPreTopMostListTemplate = autoContentManager?.getTopMostOrPreTopMostListTemplate() {
                if let userInfo = topMostOrPreTopMostListTemplate.userInfo as? [String: Any] {
                    if let templateId = userInfo[AutoContentManager.TEMPLATE_ID] as? String {
                        if (templateId == AutoContentMyRadio.MY_LIST_TEMPLATE_ID) {
                            topMostOrPreTopMostListTemplate.updateSections([sectionItemsLatestEpisodes])
                        }
                    }
                }
            }
        }
    }
    
    func buildDownloadsContentView() -> CPListTemplate {
        var listDownloads: CPListTemplate!
        var listItemsDownloads = [CPListItem]()
        
        let usersManager = UsersManager.getInstance()
        if let currentUser = usersManager.getCurrentUser() {
            let offlineEpisodes = currentUser.getOfflineEpisodes()
            
            for i in (0..<offlineEpisodes.count) {
                if (i < AutoContentManager.MAX_EPISODE_AMOUNT) {
                    let episodeModel = offlineEpisodes[i]
                                    
                    if let listItemEpisode = autoContentManager?.createListItemEpisode(episodeModel, false) {
                        listItemEpisode.handler = { [weak self] playlistItem, completion in
                            MediaPlayerManager.getInstance().performActionLoadAndPlayEpisode(MediaPlayerManager.PLAYBACK_TYPE_LOCAL_THEN_STREAM, episodeModel, offlineEpisodes)

                            let nowPlayingTemplate = CPNowPlayingTemplate.shared
                            self?.autoContentManager?.interfaceController?.pushTemplate(nowPlayingTemplate, animated: true, completion: nil)

                            completion()
                        }
                        
                        listItemsDownloads.append(listItemEpisode)
                    }
                }
            }
        }
        
        let sectionItemsDownloads = CPListSection(items: listItemsDownloads)
        
        listDownloads = CPListTemplate(title: "downloads".localized(), sections: [sectionItemsDownloads])
        
        var userInfo = [String: Any]()
        userInfo[AutoContentManager.TEMPLATE_ID] = AutoContentMyRadio.DOWNLOADS_TEMPLATE_ID
        listDownloads.userInfo = userInfo

        return listDownloads
    }
}
