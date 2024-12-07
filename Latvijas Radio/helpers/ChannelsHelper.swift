//
//  ChannelsHelper.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

class ChannelsHelper {

    static let ID_CHANNEL_LATVIJAS_RADIO_1 = "1"
    static let ID_CHANNEL_LATVIJAS_RADIO_2 = "2"
    static let ID_CHANNEL_LATVIJAS_RADIO_3 = "3"
    static let ID_CHANNEL_LATVIJAS_RADIO_4 = "4"
    static let ID_CHANNEL_LATVIJAS_RADIO_5 = "5"
    static let ID_CHANNEL_LATVIJAS_RADIO_6 = "6"
    static let ID_CHANNEL_LATVIJAS_RADIO_RADIOTEATRIS = "9"
    
    static func getImageDrawableIdFromChannelId(_ channelId: String?) -> String? {
        var result: String?
        
        switch (channelId) {
        case ChannelsHelper.ID_CHANNEL_LATVIJAS_RADIO_1:
            result = ImagesHelper.LOGO_LATVIJAS_RADIO_1
            
            break
        case ChannelsHelper.ID_CHANNEL_LATVIJAS_RADIO_2:
            result = ImagesHelper.LOGO_LATVIJAS_RADIO_2
            
            break
        case ChannelsHelper.ID_CHANNEL_LATVIJAS_RADIO_3:
            result = ImagesHelper.LOGO_LATVIJAS_RADIO_3
            
            break
        case ChannelsHelper.ID_CHANNEL_LATVIJAS_RADIO_4:
            result = ImagesHelper.LOGO_LATVIJAS_RADIO_4
            
            break
        case ChannelsHelper.ID_CHANNEL_LATVIJAS_RADIO_5:
            result = ImagesHelper.LOGO_LATVIJAS_RADIO_5
            
            break
        case ChannelsHelper.ID_CHANNEL_LATVIJAS_RADIO_6:
            result = ImagesHelper.LOGO_LATVIJAS_RADIO_6
            
            break
        case ChannelsHelper.ID_CHANNEL_LATVIJAS_RADIO_RADIOTEATRIS:
            result = ImagesHelper.LOGO_LATVIJAS_RADIO_RADIOTEATRIS
            
            break
        default:
            break
        }
        
        return result
    }
    
    static func getColorIdFromChannelId(_ channelId: String?) -> String? {
        var result: String?
        
        switch (channelId) {
        case ChannelsHelper.ID_CHANNEL_LATVIJAS_RADIO_1:
            result = ColorsHelper.CHANNEL_1
            
            break
        case ChannelsHelper.ID_CHANNEL_LATVIJAS_RADIO_2:
            result = ColorsHelper.CHANNEL_2
            
            break
        case ChannelsHelper.ID_CHANNEL_LATVIJAS_RADIO_3:
            result = ColorsHelper.CHANNEL_3
            
            break
        case ChannelsHelper.ID_CHANNEL_LATVIJAS_RADIO_4:
            result = ColorsHelper.CHANNEL_4
            
            break
        case ChannelsHelper.ID_CHANNEL_LATVIJAS_RADIO_5:
            result = ColorsHelper.CHANNEL_5
            
            break
        case ChannelsHelper.ID_CHANNEL_LATVIJAS_RADIO_6:
            result = ColorsHelper.CHANNEL_6
            
            break
        case ChannelsHelper.ID_CHANNEL_LATVIJAS_RADIO_RADIOTEATRIS:
            result = ColorsHelper.CHANNEL_RADIOTEATRIS
            
            break
        default:
            break
        }
        
        return result
    }
    
    static func isChannelIdClassic(_ channelId: String?) -> Bool {
        var result = false
        
        if (channelId == ChannelsHelper.ID_CHANNEL_LATVIJAS_RADIO_1 ||
            channelId == ChannelsHelper.ID_CHANNEL_LATVIJAS_RADIO_2 ||
            channelId == ChannelsHelper.ID_CHANNEL_LATVIJAS_RADIO_3 ||
            channelId == ChannelsHelper.ID_CHANNEL_LATVIJAS_RADIO_4 ||
            channelId == ChannelsHelper.ID_CHANNEL_LATVIJAS_RADIO_5 ||
            channelId == ChannelsHelper.ID_CHANNEL_LATVIJAS_RADIO_6 ||
            channelId == ChannelsHelper.ID_CHANNEL_LATVIJAS_RADIO_RADIOTEATRIS) {
            
            result = true
        }
        
        return result
    }
}
