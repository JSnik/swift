//
//  AutoContentBroadcasts.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 09/09/2022.
//

import CarPlay

class AutoContentBroadcasts: NSObject {
    
    var TAG = String(describing: AutoContentBroadcasts.self)
    
    weak var autoContentManager: AutoContentManager?
    
    init(_ autoContentManager: AutoContentManager) {
        self.autoContentManager = autoContentManager
    }
    
    deinit {
        GeneralUtils.log(TAG, "deinit")
    }

    func getTabBroadcasts() -> CPListTemplate? {
        var result: CPListTemplate?
        
        if let interfaceController = autoContentManager?.interfaceController {
            if let tabBarTemplate = interfaceController.rootTemplate as? CPTabBarTemplate {
                if (tabBarTemplate.templates.count > 0) {
                    if let tabBroadcasts = tabBarTemplate.templates[AutoContentManager.TAB_BROADCASTS_INDEX] as? CPListTemplate {
                        result = tabBroadcasts
                    }
                }
            }
        }
        
        return result
    }
    
    func performRequestBroadcastByCategory() {
        let broadcastByCategoryRequest = BroadcastByCategoryRequest(nil)

        broadcastByCategoryRequest.successCallback = { [weak self] (data) -> Void in
            self?.handleBroadcastsByCategoryResponse(data)
        }

        broadcastByCategoryRequest.errorCallback = { [weak self] in
            self?.autoContentManager?.handleJwtErrorInCarPlay(broadcastByCategoryRequest.errorMessage, self?.getTabBroadcasts())
        }

        broadcastByCategoryRequest.execute()
    }
    
    func handleBroadcastsByCategoryResponse(_ data: [String: Any]) {
        let categories = data[BroadcastByCategoryRequest.RESPONSE_PARAM_CATEGORIES] as! [[String: Any]]
        print("handleBroadcastsByCategoryResponse categories = \(categories)")
        if (categories.count > 0) {
            var broadcastsByCategory = [BroadcastsByCategoryModel]()
            var listItemsBroadcastCategories = [CPListItem]()
            
            for i in (0..<categories.count) {
                let category = categories[i]

                let id = category[BroadcastByCategoryRequest.RESPONSE_PARAM_ID] as! String
                let name = category[BroadcastByCategoryRequest.RESPONSE_PARAM_TITLE] as! String
                let broadcasts = category[BroadcastByCategoryRequest.RESPONSE_PARAM_BROADCASTS] as! [NSDictionary]

                let broadcastsByCategoryModel = BroadcastsByCategoryModel(String(id), name)
                broadcastsByCategoryModel.setBroadcasts(broadcasts)

                broadcastsByCategory.append(broadcastsByCategoryModel)

                let listItemBroadcastCategory = createListItemBroadcastCategory(broadcastsByCategoryModel)
                
                listItemBroadcastCategory.handler = { [weak self] playlistItem, completion in
                    if let self = self {
                        let listBroadcastCategoryBroadcasts = self.buildBroadcastCategoryBroadcastsContentView(broadcastsByCategoryModel, listItemBroadcastCategory.text)
                        
                        // Leaving for reference:
                        // A way to customize back button text:
//                        listBroadcastCategoryBroadcasts.backButton = CPBarButton(title: "Back", handler: {_ in
//
//                        })

                        self.autoContentManager?.interfaceController?.pushTemplate(listBroadcastCategoryBroadcasts, animated: true, completion: nil)
                    }

                    completion()
                }
                
                listItemsBroadcastCategories.append(listItemBroadcastCategory)
            }

            let groupTitle = "categories".localized()
            let sectionItemsBroadcastCategories = CPListSection(items: listItemsBroadcastCategories, header: groupTitle, sectionIndexTitle: "")
            
            if let tabBroadcasts = getTabBroadcasts() {
                tabBroadcasts.updateSections([sectionItemsBroadcastCategories])
            }
        }
    }
    
    func buildBroadcastCategoryBroadcastsContentView(_ broadcastsByCategoryModel: BroadcastsByCategoryModel, _ categoryTitle: String?) -> CPListTemplate {
        var listItemsBroadcastCategoryBroadcasts = [CPListItem]()

        let broadcastsJsonArray = broadcastsByCategoryModel.getBroadcasts()
        let broadcasts = BroadcastsHelper.getBroadcastsListFromJsonArray(broadcastsJsonArray)

        for i in (0..<broadcasts.count) {
            let broadcastModel = broadcasts[i]
            
            let broadcastId = broadcastModel.getId()
            let broadcastTitle = broadcastModel.getTitle()

            if let listItemBroadcast = autoContentManager?.createListItemBroadcast(broadcastModel) {
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
                
                listItemsBroadcastCategoryBroadcasts.append(listItemBroadcast)
            }
        }

        let sectionItemsBroadcastCategoryBroadcasts = CPListSection(items: listItemsBroadcastCategoryBroadcasts)

        let listBroadcastCategoryBroadcasts: CPListTemplate = CPListTemplate(title: categoryTitle, sections: [sectionItemsBroadcastCategoryBroadcasts])

        return listBroadcastCategoryBroadcasts
    }

    func createListItemBroadcastCategory(_ broadcastsByCategoryModel: BroadcastsByCategoryModel) -> CPListItem {
        let broadcastsByCategoryId = broadcastsByCategoryModel.getId()
        let broadcastsByCategoryName = broadcastsByCategoryModel.getName()

        let listItemBroadcastByCategoryModel = CPListItem(
            id: broadcastsByCategoryId,
            text: broadcastsByCategoryName,
            detailText: "",
            remoteImageUrl: nil,
            placeholder: nil,
            placeholderIsVectorImage: false,
            carTraitCollection: autoContentManager?.interfaceController?.carTraitCollection
        )
        
        // Chevron.
        listItemBroadcastByCategoryModel.accessoryType = .disclosureIndicator
        
        return listItemBroadcastByCategoryModel
    }
}
