//
//  ButtonTogglePlaybackHelper.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class ButtonTogglePlaybackHelper {

    static let TOGGLE_PLAYBACK_BUTTON_STATE_NORMAL_DEFAULT_TINT = ColorsHelper.BLACK
    static let TOGGLE_PLAYBACK_BUTTON_STATE_ACTIVE_DEFAULT_TINT = ColorsHelper.RED

    static func setTint(_ buttonTogglePlayback: UIButton, _ validStateForTinting: Bool, _ validChannelTypeForTinting: Bool, _ hexStringColor: String) {
        // default tint color
        var colorId = TOGGLE_PLAYBACK_BUTTON_STATE_NORMAL_DEFAULT_TINT
        
        if (validStateForTinting) {
            if (validChannelTypeForTinting) {
                var channelId: String?
                
                if (MediaPlayerManager.getInstance().currentEpisode != nil) {
                    channelId = MediaPlayerManager.getInstance().currentEpisode!.getChannelId()
                }
                
                if (MediaPlayerManager.getInstance().currentLivestream != nil) {
                    if let colorId = MediaPlayerManager.getInstance().currentLivestream?.color as? String {
                        buttonTogglePlayback.tintColor = hexStringToUIColor(hex: colorId)
                        return
                    }
                    channelId = String(describing:  MediaPlayerManager.getInstance().currentLivestream!.id) // getId()
                }
                
                if (channelId != nil) {
                    let channelColor = ChannelsHelper.getColorIdFromChannelId(channelId!)
                    if (channelColor != nil) {
                        colorId = channelColor!
                    }
                }
            } else {
                colorId = TOGGLE_PLAYBACK_BUTTON_STATE_ACTIVE_DEFAULT_TINT
            }
        }
        
        buttonTogglePlayback.tintColor = UIColor(named: colorId)
//        if hexStringColor.count > 0 {
//            buttonTogglePlayback.tintColor = hexStringToUIColor(hex: colorId)
//        }
    }
}
