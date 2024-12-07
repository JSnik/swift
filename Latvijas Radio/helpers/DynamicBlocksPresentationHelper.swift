//
//  DynamicBlocksPresentationHelper.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

class DynamicBlocksPresentationHelper {

    static func getGenericPreviewsFromDynamicBlock(_ dynamiBlockModel: DynamicBlockModel) -> [GenericPreviewModel] {
        var dataset = [GenericPreviewModel]()
        
        let items = dynamiBlockModel.getItems()
        
        let contentType = dynamiBlockModel.getContentType()
        
        if (contentType == ContentSectionRequest.CONTENT_TYPE_BROADCASTS) {
            let broadcasts = BroadcastsHelper.getBroadcastsListFromJsonArray(items)
            
            for i in (0..<broadcasts.count) {
                let genericPreviewModel = GenericPreviewModel(GenericPreviewModel.TYPE_BROADCAST, broadcasts[i], nil)
                
                dataset.append(genericPreviewModel)
            }
        }
        
        if (contentType == ContentSectionRequest.CONTENT_TYPE_EPISODES) {
            let episodes = EpisodesHelper.getEpisodesListFromJsonArray(items)
            
            for i in (0..<episodes.count) {
                let genericPreviewModel = GenericPreviewModel(GenericPreviewModel.TYPE_EPISODE, nil, episodes[i])
                
                dataset.append(genericPreviewModel)
            }
        }
        
        return dataset
    }
}
