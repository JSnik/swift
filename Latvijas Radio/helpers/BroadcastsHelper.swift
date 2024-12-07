//
//  BroadcastsHelper.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class BroadcastsHelper {

    static func getBroadcastsListFromJsonArray(_ broadcasts: [[String: Any]]) -> [BroadcastModel] {
        var dataset = [BroadcastModel]()
        
        for broadcastJson in broadcasts {
            let broadcastModel = getBroadcastFromJsonObject(broadcastJson)
            if (broadcastModel != nil) {
                dataset.append(broadcastModel!)
            }
        }

        return dataset
    }
    
    static func getBroadcastFromJsonObject(_ broadcastJson: [String: Any]) -> BroadcastModel? {
        var broadcastModel: BroadcastModel? = nil
        
        // Since many endpoints return BroadcastJsonObjectModel,
        // we keep the field names here.

        let id = broadcastJson["id"] as! Int
        
        let imageUrl = broadcastJson["imageUrl"] as? String

        let title = broadcastJson["title"] as! String
        let description = broadcastJson["description"] as? String
        
        var categoryName = title
        
        let categories = broadcastJson["categories"] as? [[String: Any]]
        print("BroadcastsHelper categories = \(categories)")

        if (categories != nil) {

            if (categories!.count > 0) {
                categoryName = ""

                for i in 0...categories!.count - 1 {
                    let category = categories![i]
                    var categoryTitle = category["title"] as? String
                    if (categoryTitle == nil) {
                        categoryTitle = "null"
                    }

                    categoryName = categoryName + categoryTitle!

                    if (i < categories!.count - 1) {
                        categoryName = categoryName + ", "
                    }
                }
            }
        }
        
        let channelId = broadcastJson["channelId"] as! String
        let hosts = broadcastJson["hosts"] as! [NSDictionary]
        let url = broadcastJson["url"] as? String
        
        broadcastModel = BroadcastModel(String(id))
        
        if (imageUrl != nil) {
            broadcastModel?.setImageUrl(imageUrl!)
        }

        broadcastModel?.setTitle(title)
        broadcastModel?.setDescription(description)
        broadcastModel?.setCategoryName(categoryName)
        broadcastModel?.setChannelId(channelId)
        broadcastModel?.setHosts(hosts)
        broadcastModel?.setUrl(url)
        
        return broadcastModel
    }
}
