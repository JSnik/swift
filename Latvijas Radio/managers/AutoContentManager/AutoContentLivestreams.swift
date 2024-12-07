//
//  AutoContentLivestreams.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 09/09/2022.
//

import CarPlay

class AutoContentLivestreams: NSObject {
    
    var TAG = String(describing: AutoContentLivestreams.self)
    
    weak var autoContentManager: AutoContentManager?
    
    // CarPlay use this variable to determine whether or not to show christmas livestream.
    var isChristmasLivestreamCampaignEnabled = false
    
    // Update title on CarPlay livestreams items.
    // When livestreams tab gets loaded, we make a request for campaigns info.
    // We want to skip that request if tab reloads due to a title update.
    var skipCampaignsRequest = false

    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    init(_ autoContentManager: AutoContentManager) {
        self.autoContentManager = autoContentManager
    }
    
    deinit {
        GeneralUtils.log(TAG, "deinit")
    }

    func getTabLivestreams() -> CPListTemplate? {
        var result: CPListTemplate?
        
        if let interfaceController = autoContentManager?.interfaceController {
            if let tabBarTemplate = interfaceController.rootTemplate as? CPTabBarTemplate {
                if (tabBarTemplate.templates.count > 0) {
                    if let tabLivestreams = tabBarTemplate.templates[AutoContentManager.TAB_LIVESTREAMS_INDEX] as? CPListTemplate {
                        result = tabLivestreams
                    }
                }
            }
        }
        
        return result
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
            print("AutoContentLivestreams handleRadioChannelsResponse someDictionaryFromJSON = \(someDictionaryFromJSON)")
//            let json4Swift_Base = try SearchSuccess(someDictionaryFromJSON)
            let jsonDecoder = JSONDecoder()
            let json4Swift_Base = try jsonDecoder.decode(ChannelsSuccess.self, from: data1)

            let radioChannels = json4Swift_Base.results
            //        let hits = data[SearchRequest.RESPONSE_PARAM_HITS] as! [[String: Any]]
            print("AutoContentLivestreams handleRadioChannelsResponse radioChannels = \(radioChannels)")
            if (radioChannels?.count ?? 0 > 0) {
                for i in (0..<(radioChannels?.count ?? 0)) {
                    if let radioChannel = radioChannels?[i] {
                        dataset.append(radioChannel)
                    }
                }

                var fullRadioChannelDataset: [RadioChannel]!
                fullRadioChannelDataset = [RadioChannel]()
                fullRadioChannelDataset.append(contentsOf: dataset)
                var listItemsLivestreams = [CPListItem]()
                let usersManager = UsersManager.getInstance()
                if let currentUser = usersManager.getCurrentUser() {
                   // livestreamsCollectionViewController.updateDataset(fullRadioChannelDataset)
                    let onlyPlayableLivestreamsDataset = LivestreamsManager.getOnlyPlayableLivestreams(fullRadioChannelDataset)

                                for i in (0..<onlyPlayableLivestreamsDataset.count) {
                                    let livestreamModel = onlyPlayableLivestreamsDataset[i]

                                    let listItemLivestream = createListItemLivestream(livestreamModel)

                                    listItemLivestream.handler = { [weak self] playlistItem, completion in
                                        MediaPlayerManager.getInstance().contentLoadedFromSource = MediaPlayerManager.CONTENT_SOURCE_NAME_AUTO_CONTENT_LIVESTREAMS

                                        MediaPlayerManager.getInstance().performActionLoadAndPlayLivestream(MediaPlayerManager.PLAYBACK_TYPE_STREAM, livestreamModel, onlyPlayableLivestreamsDataset)

                                        let nowPlayingTemplate = CPNowPlayingTemplate.shared

                                        self?.autoContentManager?.interfaceController?.pushTemplate(nowPlayingTemplate, animated: true, completion: nil)

                                        completion()
                                    }

                                    listItemsLivestreams.append(listItemLivestream)
                                }

                }
                if let tabLivestreams = getTabLivestreams() {
                    let sectionItemsLivestreams = CPListSection(items: listItemsLivestreams)
                    tabLivestreams.updateSections([sectionItemsLivestreams])
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

    func performRequestCampaigns() {
        let campaignsRequest = CampaignsRequest(nil)

        campaignsRequest.successCallback = { [weak self] (data) -> Void in
            self?.handleRequestCampaignsResponse(data)
        }
        
        campaignsRequest.errorCallback = { [weak self] in
            self?.handleRequestCampaignsResponse(nil)
        }
        
        campaignsRequest.execute()
    }
    
    func handleRequestCampaignsResponse(_ data: [String: Any]?) {
        isChristmasLivestreamCampaignEnabled = false
        
        if let data = data {
            let campaignsJsonArray = data[CampaignsRequest.RESPONSE_PARAM_CAMPAIGNS] as! [[String: Any]]
            
            if (campaignsJsonArray.count > 0) {
                let campaigns = CampaignsHelper.getCampaignsListFromJsonArray(campaignsJsonArray)
                
                for i in (0..<campaigns.count) {
                    let campaign = campaigns[i]

                    if (campaign.getId() == CampaignModel.ID_CHRISTMAS_LIVESTREAM) {
                        isChristmasLivestreamCampaignEnabled = true
                    }
                }
            }
        }

        if let tabLivestreams = getTabLivestreams() {
            let livestreamsContentView = buildLivestreamsContentView()
            
            tabLivestreams.updateSections(livestreamsContentView)
//            performRequestGetRadioChannels()
        }
    }

    func buildLivestreamsContentView() -> [CPListSection] {
        var listItemsLivestreams = [CPListItem]()
        
        let usersManager = UsersManager.getInstance()
        if let currentUser = usersManager.getCurrentUser() {
            let orderedLivestreamsDataset = LivestreamsManager.getOrderedList(currentUser)
//            performRequestGetRadioChannels()

            let curatedLivestreamsDataset = LivestreamsManager.getCuratedList(orderedLivestreamsDataset, isChristmasLivestreamCampaignEnabled)
            
            let onlyPlayableLivestreamsDataset = LivestreamsManager.getOnlyPlayableLivestreams(curatedLivestreamsDataset)

            for i in (0..<onlyPlayableLivestreamsDataset.count) {
                let livestreamModel = onlyPlayableLivestreamsDataset[i]
            
                let listItemLivestream = createListItemLivestream(livestreamModel)
                
                listItemLivestream.handler = { [weak self] playlistItem, completion in
                    MediaPlayerManager.getInstance().contentLoadedFromSource = MediaPlayerManager.CONTENT_SOURCE_NAME_AUTO_CONTENT_LIVESTREAMS
                    
                    MediaPlayerManager.getInstance().performActionLoadAndPlayLivestream(MediaPlayerManager.PLAYBACK_TYPE_STREAM, livestreamModel, onlyPlayableLivestreamsDataset)

                    let nowPlayingTemplate = CPNowPlayingTemplate.shared

                    self?.autoContentManager?.interfaceController?.pushTemplate(nowPlayingTemplate, animated: true, completion: nil)

                    completion()
                }
                
                listItemsLivestreams.append(listItemLivestream)
            }
        }
        
        let sectionItemsLivestreams = CPListSection(items: listItemsLivestreams)

        return [sectionItemsLivestreams]
    }
 
    func createListItemLivestream(_ livestreamModel: /*LivestreamModel*/ RadioChannel) -> CPListItem {
        let livestreamId = String(describing: livestreamModel.id) // getId()
        let livestreamTitle = MediaPlayerManager.getInstance().mediaPlayerManagerRemoteCommandCenter.getDynamicLivestreamTitle(livestreamModel, true)
        let livestreamName = livestreamModel.name // getName()
        //let livestreamImageResourceId = livestreamModel.image //getImageResourceId()
//        let livestreamImageResourceId1 = livestreamModel.image
        var livestreamImageResourceId = ImagesHelper.LOGO_LATVIJAS_RADIO_1
        if let livestreamImageResourceId1 = livestreamModel.image {
            livestreamImageResourceId = livestreamImageResourceId1
        }

        var placeholderIsVectorImage = true
        
        if (livestreamId == LivestreamsManager.ID_PIECI_ZIEMASSVETKI) {
            placeholderIsVectorImage = false
        }

        let listItemLivestream = CPListItem(
            id: livestreamId,
            text: livestreamName,
            detailText: livestreamTitle,
            remoteImageUrl: nil,
            placeholder: UIImage(named: (livestreamImageResourceId)), //UIImage(named: livestreamImageResourceId),
            placeholderIsVectorImage: placeholderIsVectorImage,
            carTraitCollection: autoContentManager?.interfaceController?.carTraitCollection
        )
        
        listItemLivestream.playingIndicatorLocation = .trailing
        
        if let currentLivestream = MediaPlayerManager.getInstance().currentLivestream {
            if (currentLivestream.id /*getId()*/ == Int(livestreamId)) {
                listItemLivestream.isPlaying = true
            }
        }
        
        return listItemLivestream
    }
}
