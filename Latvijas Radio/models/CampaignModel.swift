//
//  CampaignModel.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 09/08/2022.
//

import UIKit

class CampaignModel: Codable {
    
    static let ID_RADIOTEATRIS = "radioteatris"
    static let ID_CHRISTMAS_LIVESTREAM = "christmasLivestream"
    static let NEW_CUSTOM = "newCustom"
    
    let id: String
    let imageUrl: String!
    let bigImageUrl: String
    let link: String
    let publishedFrom: String
    let publishedTo: String
    let displayType: String

    init(
         id: String,
         imageUrl: String,
         bigImageUrl: String,
         link: String,
         publishedFrom: String,
         publishedTo: String,
         displayType: String
    ){
        self.id = id
        self.imageUrl = imageUrl
        self.bigImageUrl = bigImageUrl
        self.link = link
        self.publishedFrom = publishedFrom
        self.publishedTo = publishedTo
        self.displayType = displayType
    }
    
    func getId() -> String {
        return id
    }

    func getImageUrl() -> String {
        return imageUrl
    }
}
