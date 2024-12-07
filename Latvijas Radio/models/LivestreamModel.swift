//
//  LivestreamModel.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class LivestreamModel: Codable {
    
    let id: String
    private var type: String!
    private var name: String!
    private var title: String!
    private var imageResourceId: String!
    private var wideImageResourceId: String!
    private var largeArtworkImageResourceId: String?
    private var stationIdInMqttService: String?
    private var mediaStreamUrl: String!
    private var fakeLivestream: Bool!

    init(
        _ id: String,
        _ type: String,
        _ name: String,
        _ title: String,
        _ imageResourceId: String,
        _ wideImageResourceId: String,
        _ largeArtworkImageResourceId: String?,
        _ stationIdInMqttService: String?,
        _ mediaStreamUrl: String,
        _ fakeLivestream: Bool
    ){
        self.id = id
        self.type = type
        self.name = name
        self.title = title
        self.imageResourceId = imageResourceId
        self.wideImageResourceId = wideImageResourceId
        self.largeArtworkImageResourceId = largeArtworkImageResourceId
        self.stationIdInMqttService = stationIdInMqttService
        self.mediaStreamUrl = mediaStreamUrl
        self.fakeLivestream = fakeLivestream
    }
    
    func getId() -> String {
        return id
    }
    
    func getType() -> String {
        return type
    }
    
    func getName() -> String {
        return name
    }
   
    func getTitle() -> String {
        return title
    }
    
    func getImageResourceId() -> String {
        return imageResourceId
    }
    
    func getWideImageResourceId() -> String {
        return wideImageResourceId
    }
    
    func getLargeArtworkImageResourceId() -> String? {
        return largeArtworkImageResourceId
    }
    
    func getStationIdInMqttService() -> String? {
        return stationIdInMqttService
    }
    
    func getMediaStreamUrl() -> String {
        return mediaStreamUrl
    }
    
    func getFakeLivestream() -> Bool {
        return fakeLivestream
    }
}
