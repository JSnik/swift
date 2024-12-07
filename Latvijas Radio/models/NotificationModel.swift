//
//  NotificationModel.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class NotificationModel: Codable {
    
    private var broadcastId: String!
    private var broadcastName: String!
    private var episodeId: String!
    private var episodeTitle: String!
    private var isRead: Bool = false

    init() {
        
    }
    
    func getBroadcastId() -> String {
        return broadcastId
    }
    
    func setBroadcastId(_ broadcastId: String) {
        self.broadcastId = broadcastId
    }
    
    func getBroadcastName() -> String {
        return broadcastName
    }
    
    func setBroadcastName(_ broadcastName: String) {
        self.broadcastName = broadcastName
    }
    
    func getEpisodeId() -> String {
        return episodeId
    }
    
    func setEpisodeId(_ episodeId: String) {
        self.episodeId = episodeId
    }
   
    func getEpisodeTitle() -> String {
        return episodeTitle
    }
    
    func setEpisodeTitle(_ episodeTitle: String) {
        self.episodeTitle = episodeTitle
    }
    
    func getIsRead() -> Bool {
        return isRead
    }
    
    func setIsRead(_ isRead: Bool) {
        self.isRead = isRead
    }
}
