//
//  MediaPlayerManagerTimeoutManager.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 22/08/2022.
//

import UIKit

class MediaPlayerManagerTimeoutManager {
    
    static let TAG = String(describing: MediaPlayerManagerTimeoutManager.self)

    static let EVENT_ON_BROADCAST_CURRENT_PLAYBACK_TIMEOUT_MODEL = "EVENT_ON_BROADCAST_CURRENT_PLAYBACK_TIMEOUT_MODEL"
    
    static var options: [PlaybackTimeoutModel]!
    
    private var timer = Timer()
    var currentPlaybackTimeoutModel: PlaybackTimeoutModel!
    
    init() {
        currentPlaybackTimeoutModel = getOptionById(PlaybackTimeoutModel.ID_TURN_OFF)!
    }
    
    func setTimeoutProcedure(_ playbackTimeoutModel: PlaybackTimeoutModel) {
        currentPlaybackTimeoutModel = playbackTimeoutModel
        
        if (playbackTimeoutModel.getId() == PlaybackTimeoutModel.ID_TURN_OFF) {
            stopTimeoutProcedure()
        } else {
            startTimeoutProcedure()
        }
    }

    func startTimeoutProcedure() {
        stopTimeoutProcedure()
        
        let timeoutInSeconds: Double = Double(currentPlaybackTimeoutModel.getTimeoutInMilliseconds()) / 1000
        
        timer = Timer.scheduledTimer(withTimeInterval: timeoutInSeconds, repeats: false, block: { [weak self] _ in
            self?.currentPlaybackTimeoutModel = self?.getOptionById(PlaybackTimeoutModel.ID_TURN_OFF)
            
            self?.broadcastCurrentPlaybackTimeoutModel()
            
            MediaPlayerManager.getInstance().pauseMediaPlayback()
        })
    }
    
    func stopTimeoutProcedure() {
        timer.invalidate()
    }
    
    func broadcastCurrentPlaybackTimeoutModel() {
        NotificationCenter.default.post(
            name: Notification.Name(MediaPlayerManagerTimeoutManager.EVENT_ON_BROADCAST_CURRENT_PLAYBACK_TIMEOUT_MODEL),
            object: nil,
            userInfo: [MediaPlayerManager.NOTIFICATION_PARAMS_DEFAULT_KEY: currentPlaybackTimeoutModel as Any]
        )
    }

    static func getOptions() -> [PlaybackTimeoutModel] {
        if (options == nil) {
            var dataset = [PlaybackTimeoutModel]()
            
            // Turn off
            var id = PlaybackTimeoutModel.ID_TURN_OFF
            var titleResourceId = "turn_off"
            var timeoutInMilliseconds = 0
            
            var playbackTimeoutModel = PlaybackTimeoutModel(id, titleResourceId, timeoutInMilliseconds)
            dataset.append(playbackTimeoutModel)

            // After 30m
            id = PlaybackTimeoutModel.ID_AFTER_30M
            titleResourceId = "after_30m"
            timeoutInMilliseconds = 1000 * 60 * 30
            
            playbackTimeoutModel = PlaybackTimeoutModel(id, titleResourceId, timeoutInMilliseconds)
            dataset.append(playbackTimeoutModel)
            
            // After 1h
            id = PlaybackTimeoutModel.ID_AFTER_1H
            titleResourceId = "after_1h"
            timeoutInMilliseconds = 1000 * 60 * 60
            
            playbackTimeoutModel = PlaybackTimeoutModel(id, titleResourceId, timeoutInMilliseconds)
            dataset.append(playbackTimeoutModel)
            
            // After 30m
            id = PlaybackTimeoutModel.ID_AFTER_1H30M
            titleResourceId = "after_1h30m"
            timeoutInMilliseconds = 1000 * 60 * 90
            
            playbackTimeoutModel = PlaybackTimeoutModel(id, titleResourceId, timeoutInMilliseconds)
            dataset.append(playbackTimeoutModel)
            
            options = dataset
        }
        
        return options
    }
    
    private func getOptionById(_ lookupId: String) -> PlaybackTimeoutModel? {
        var result: PlaybackTimeoutModel?
        
        let options = MediaPlayerManagerTimeoutManager.getOptions()
        
        for i in (0..<options.count) {
            let playbackTimeoutModel = options[i]
            
            if (playbackTimeoutModel.getId() == lookupId) {
                result = playbackTimeoutModel
                
                break
            }
        }
        
        return result
    }
}

