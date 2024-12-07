//
//  AutoContentHome.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 09/09/2022.
//

import CarPlay

class AutoContentHome: NSObject {
    
    var TAG = String(describing: AutoContentHome.self)
    
    weak var autoContentManager: AutoContentManager?
    
    init(_ autoContentManager: AutoContentManager) {
        self.autoContentManager = autoContentManager
    }
    
    deinit {
        GeneralUtils.log(TAG, "deinit")
    }
    
    func getTabHome() -> CPListTemplate? {
        var result: CPListTemplate?

        if let interfaceController = autoContentManager?.interfaceController {
            if let tabBarTemplate = interfaceController.rootTemplate as? CPTabBarTemplate {
                if (tabBarTemplate.templates.count > 0) {
                    if let tabHome = tabBarTemplate.templates[AutoContentManager.TAB_HOME_INDEX] as? CPListTemplate {
                        result = tabHome
                    }
                }
            }
        }
        
        return result
    }
 
    func performRequestGetBroadcastNewsEpisode() {
        var urlPathParams = ""
        var broadcastId = "news"
        
        let broadcastEpisodesRequest = BroadcastEpisodesRequest(nil, broadcastId, urlPathParams)

        broadcastEpisodesRequest.successCallback = { [weak self] (data) -> Void in
            self?.handleBroadcastNewsEpisodeResponse(data)
        }
        
        broadcastEpisodesRequest.errorCallback = { [weak self] in
            self?.autoContentManager?.handleJwtErrorInCarPlay(broadcastEpisodesRequest.errorMessage, self?.getTabHome())
        }
        
        broadcastEpisodesRequest.execute()
    }
    
    func handleBroadcastNewsEpisodeResponse(_ data: [String: Any]) {
        let episodes = data[BroadcastEpisodesRequest.RESPONSE_PARAM_EPISODES] as! [[String: Any]]
        
        if (episodes.count > 0) {
            let episodeJson = episodes[0]
            
            if let episodeModel = EpisodesHelper.getEpisodeFromJsonObject(episodeJson) {
                if let listItemBroadcastNews = autoContentManager?.createListItemEpisode(episodeModel, false) {
                    listItemBroadcastNews.handler = { [weak self] playlistItem, completion in
                        MediaPlayerManager.getInstance().performActionLoadAndPlayEpisode(MediaPlayerManager.PLAYBACK_TYPE_LOCAL_THEN_STREAM, episodeModel, nil)

                        let nowPlayingTemplate = CPNowPlayingTemplate.shared
                        self?.autoContentManager?.interfaceController?.pushTemplate(nowPlayingTemplate, animated: true, completion: nil)

                        completion()
                    }

                    let groupTitle = "daily_news".localized()
                    let sectionItemsBroadcastNews = CPListSection(items: [listItemBroadcastNews], header: groupTitle, sectionIndexTitle: "")

                    performRequestContentSection(sectionItemsBroadcastNews)
                }
            }
        }
    }
    
    func performRequestContentSection(_ sectionItemsBroadcastNews: CPListSection) {
        let contentSectionRequest = ContentSectionRequest(nil, ContentSectionRequest.SECTION_ID_AUTO_CONTENT)

        contentSectionRequest.successCallback = { [weak self] (data) -> Void in
            self?.handleContentSectionResponse(data, sectionItemsBroadcastNews)
        }
        
        contentSectionRequest.errorCallback = { [weak self] in
            self?.autoContentManager?.handleJwtErrorInCarPlay(contentSectionRequest.errorMessage, self?.getTabHome())
        }

        contentSectionRequest.execute()
    }

    func handleContentSectionResponse(_ data: [String: Any], _ sectionItemsBroadcastNews: CPListSection) {
        var sectionItemsContentSections = [CPListSection]()

        let blocks = data[ContentSectionRequest.RESPONSE_PARAM_BLOCKS] as! [[String: Any]]
        if (blocks.count > 0) {
            for i in (0..<blocks.count) {
                let block = blocks[i]
                
                let contentType = block[ContentSectionRequest.RESPONSE_PARAM_CONTENT_TYPE] as! String
                
                if (contentType == ContentSectionRequest.CONTENT_TYPE_EPISODES) {
                    var episodesListItems = [CPListItem]()
                    
                    let name = block[ContentSectionRequest.RESPONSE_PARAM_NAME] as? String

                    let episodesJsonArray = block[ContentSectionRequest.RESPONSE_PARAM_ITEMS] as! [[String: Any]]
                    let episodes = EpisodesHelper.getEpisodesListFromJsonArray(episodesJsonArray)

                    if (episodes.count > 0) {
                        for k in (0..<episodes.count) {
                            let episodeModel = episodes[k]
                                            
                            if let listItemEpisode = autoContentManager?.createListItemEpisode(episodeModel, true) {
                                listItemEpisode.handler = { [weak self] playlistItem, completion in
                                    MediaPlayerManager.getInstance().performActionLoadAndPlayEpisode(MediaPlayerManager.PLAYBACK_TYPE_LOCAL_THEN_STREAM, episodeModel, episodes)

                                    let nowPlayingTemplate = CPNowPlayingTemplate.shared
                                    self?.autoContentManager?.interfaceController?.pushTemplate(nowPlayingTemplate, animated: true, completion: nil)

                                    completion()
                                }
                                
                                episodesListItems.append(listItemEpisode)
                            }
                        }
                        
                        sectionItemsContentSections.append(CPListSection(items: episodesListItems, header: name, sectionIndexTitle: ""))
                    }
                }
            }
        }
        
        if let tabHome = getTabHome() {
            var sections = [CPListSection]()
            sections.append(sectionItemsBroadcastNews)
            
            if (sectionItemsContentSections.count > 0) {
                sections.append(contentsOf: sectionItemsContentSections)
            }
            
            tabHome.updateSections(sections)
        }
    }
}
