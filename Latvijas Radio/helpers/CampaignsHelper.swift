//
//  CampaignsHelper.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 09/08/2022.
//

import UIKit

class CampaignsHelper {

    static func getCampaignsListFromJsonArray(_ campaigns: [[String: Any]]) -> [CampaignModel] {
        var dataset = [CampaignModel]()
        
        for campaignJson in campaigns {
            let campaignModel = getCampaignFromJsonObject(campaignJson)
            if (campaignModel != nil) {
                dataset.append(campaignModel!)
            }
        }
        
        return dataset
    }
    
    static func getCampaignFromJsonObject(_ campaignJson: [String: Any]) -> CampaignModel? {
        var campaignModel: CampaignModel? = nil
        
        let id = campaignJson["id"] as! String
        let imageUrl = campaignJson["imageUrl"] as! String
        let bigImageUrl = campaignJson["bigImageUrl"] as? String
        let link = campaignJson["link"] as? String
        let publishedFrom = campaignJson["publishedFrom"] as? String
        let publishedTo = campaignJson["publishedTo"] as? String
        let displayType = campaignJson["displayType"] as? String

        campaignModel = CampaignModel(
            id: id,
            imageUrl: imageUrl,
            bigImageUrl: bigImageUrl ?? "",
            link: link ?? "",
            publishedFrom: publishedFrom ?? "",
            publishedTo: publishedTo ?? "",
            displayType: displayType ?? ""
        )
        
        return campaignModel
    }
}
