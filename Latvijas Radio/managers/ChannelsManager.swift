//
//  ChannelsManager.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class ChannelsManager {
    
    static let TAG = String(describing: ChannelsManager.self)

    static let ID_LATVIJAS_RADIO_1 = "1"
    static let ID_LATVIJAS_RADIO_2 = "2"
    static let ID_LATVIJAS_RADIO_3 = "3"
    static let ID_LATVIJAS_RADIO_4 = "4"
    static let ID_LATVIJAS_RADIO_5 = "5"
    static let ID_LATVIJAS_RADIO_RADIOTEATRIS = "9"
    
    private static var channels: [ChannelModel]!

    static func getChannels() -> [ChannelModel] {
        if (ChannelsManager.channels == nil) {
            ChannelsManager.channels = [ChannelModel]()
            
            // Latvijas Radio 1
            var id = ChannelsManager.ID_LATVIJAS_RADIO_1
            var name = "Latvijas Radio 1"
            var imageResourceId = ChannelsHelper.getImageDrawableIdFromChannelId(id)!
            
            var channelModel = ChannelModel(id, name, imageResourceId)
            ChannelsManager.channels.append(channelModel)
            
            // Latvijas Radio 2
            id = ChannelsManager.ID_LATVIJAS_RADIO_2
            name = "Latvijas Radio 2"
            imageResourceId = ChannelsHelper.getImageDrawableIdFromChannelId(id)!
            
            channelModel = ChannelModel(id, name, imageResourceId)
            ChannelsManager.channels.append(channelModel)
            
            // Latvijas Radio 3
            id = ChannelsManager.ID_LATVIJAS_RADIO_3
            name = "Latvijas Radio 3"
            imageResourceId = ChannelsHelper.getImageDrawableIdFromChannelId(id)!
            
            channelModel = ChannelModel(id, name, imageResourceId)
            ChannelsManager.channels.append(channelModel)
            
            // Latvijas Radio 4
            id = ChannelsManager.ID_LATVIJAS_RADIO_4
            name = "Latvijas Radio 4"
            imageResourceId = ChannelsHelper.getImageDrawableIdFromChannelId(id)!
            
            channelModel = ChannelModel(id, name, imageResourceId)
            ChannelsManager.channels.append(channelModel)
            
            // Latvijas Radio 5
            id = ChannelsManager.ID_LATVIJAS_RADIO_5
            name = "Latvijas Radio 5"
            imageResourceId = ChannelsHelper.getImageDrawableIdFromChannelId(id)!
            
            channelModel = ChannelModel(id, name, imageResourceId)
            ChannelsManager.channels.append(channelModel)
            
            // Fake channel - Radioteātris
            id = ChannelsManager.ID_LATVIJAS_RADIO_RADIOTEATRIS
            name = "Radioteātris"
            imageResourceId = ChannelsHelper.getImageDrawableIdFromChannelId(id)!
            
            channelModel = ChannelModel(id, name, imageResourceId)
            ChannelsManager.channels.append(channelModel)
        }
        
        return ChannelsManager.channels
    }
    
    static func getChannelById(_ lookUpChannelId: String) -> ChannelModel? {
        var result: ChannelModel?
        
        let channels = getChannels()

        for i in (0..<channels.count) {
            let channelModel = channels[i]
            
            if (channelModel.getId() == lookUpChannelId) {
                result = channelModel
                
                break
            }
        }
        
        return result
    }
}

