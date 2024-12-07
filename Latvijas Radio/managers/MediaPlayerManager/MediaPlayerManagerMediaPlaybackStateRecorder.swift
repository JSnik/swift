//
//  MediaPlayerManagerMediaPlaybackStateRecorder.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit
import MediaPlayer

/*
    1. When we START to PREPARE:
    1.1. We need to know the playedTimeInMilliseconds. So currentEpisodeMediaPlaybackState needs to be set.
    1.2. We must not start the recording procedure when preparing, because mediaPlayer currentPosition will be 0. We don't want that to be written in currentEpisodeMediaPlaybackState.

    2. When we start PLAYING:
    2.1. We start recording procedure.

    3. When we STOP, PAUSE or PREPARE playing another media:
    3.1. We stop recording procedure.
 */

class MediaPlayerManagerMediaPlaybackStateRecorder: NSObject {
    
    let TAG = String(describing: MediaPlayerManagerMediaPlaybackStateRecorder.self)

    private var mediaPlayerManager: MediaPlayerManager!
    private var timer = Timer()
    private var currentEpisodeMediaPlaybackState: MediaPlaybackStateModel?
    
    // Prevents us from accidentally recording value "0" when initialising playback.
    public var autoSeekInProgress = false
    
    init(_ mediaPlayerManager: MediaPlayerManager) {
        super.init()
        
        self.mediaPlayerManager = mediaPlayerManager
    }
    
    func applyMediaPlaybackStateOfCurrentEpisodeIfAny() {
        // Look for media record.
        // If doesn't exist, create it.
        // If exists, seek to the last known played moment.
        let usersManager = UsersManager.getInstance()
        if let currentUser = usersManager.getCurrentUser() {
            // Playback media recording only function for episodes.
            if let currentEpisode = mediaPlayerManager.currentEpisode {
                var mediaPlaybackStateModels = currentUser.getMediaPlaybackStates()
                
                let mediaId = currentEpisode.getId()
                
                var mediaPlaybackStateModel = MediaPlayerManagerMediaPlaybackStateRecorder.getMediaPlaybackStateById(mediaPlaybackStateModels, mediaId)
                
                if (mediaPlaybackStateModel == nil) {
                    // Episode hasn't been played before.
                    // Create record of it.
                    mediaPlaybackStateModel = MediaPlaybackStateModel(mediaId)
                    
                    // Save the record.
                    mediaPlaybackStateModels.append(mediaPlaybackStateModel!)
                    
                    currentUser.setMediaPlaybackStates(mediaPlaybackStateModels)
                    
                    usersManager.saveCurrentUserData()
                }
                
                currentEpisodeMediaPlaybackState = mediaPlaybackStateModel
            }
        }
    }
    
    func startRecordingProcedure() {
        // We don't seek to fresh/completed episodes.
        if let currentEpisodeMediaPlaybackState = self.currentEpisodeMediaPlaybackState {
            if (currentEpisodeMediaPlaybackState.getPlayedTimeInMilliseconds() != 0) {
                // We don't seek to paused episodes.
                // Must compare to ACTUAL mediaPlayer current position, because currentPositionInMilliseconds will hold the target time,
                // which in this case is the same as "getPlayerTimeInMilliseconds".
                
                if (currentEpisodeMediaPlaybackState.getPlayedTimeInMilliseconds() != mediaPlayerManager.getMediaPlayerActualCurrentPosition()) {
                    autoSeekInProgress = true
                    
                    seekToMoment(currentEpisodeMediaPlaybackState.getPlayedTimeInMilliseconds())
                }
            }
        }
        
        // Observed rare scenario where the timer was not stopped.
        // Most likely the old reference wasn't invalidated.
        // So, to be sure, invalidate it, before losing reference to it.
        timer.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            if let self = self {
                if let currentEpisodeMediaPlaybackState = self.currentEpisodeMediaPlaybackState {
                    // Only record current time if "autoSeekInProgress" is false.
                    // Otherwise we might record "currentPositionInMilliseconds" as 0 which would cause visual jumping in progress bars.
                    
                    if (!self.autoSeekInProgress) {
                        // Apply current elapsed time and save it.
                        currentEpisodeMediaPlaybackState.setPlayedTimeInMilliseconds(self.mediaPlayerManager.currentPositionInMilliseconds)
                        
                        self.currentEpisodeMediaPlaybackState = currentEpisodeMediaPlaybackState
                        
                        MediaPlayerManagerMediaPlaybackStateRecorder.saveCurrentEpisodeMediaPlaybackState(currentEpisodeMediaPlaybackState, false)
                    }
                }
            }
        })
    }
    
    func stopRecordingProcedure(_ clearCurrentEpisodeMediaPlaybackState: Bool) {
        if (clearCurrentEpisodeMediaPlaybackState) {
            currentEpisodeMediaPlaybackState = nil
        }

        timer.invalidate()
    }
    
    func removeCurrentMediaPlaybackStateRecord() {
        if let currentEpisodeMediaPlaybackState = currentEpisodeMediaPlaybackState {
            MediaPlayerManagerMediaPlaybackStateRecorder.saveCurrentEpisodeMediaPlaybackState(currentEpisodeMediaPlaybackState, true)
        }
    }
    
    static func saveCurrentEpisodeMediaPlaybackState(_ mediaPlaybackStateModel: MediaPlaybackStateModel, _ removeRecord: Bool) {
        let usersManager = UsersManager.getInstance()
        if let currentUser = usersManager.getCurrentUser() {
            var mediaPlaybackStateModels = currentUser.getMediaPlaybackStates()
            
            // At this point, record is already in the list. Update it.
            if let currentMediaPlaybackStateIndex = MediaPlayerManagerMediaPlaybackStateRecorder.getMediaPlaybackStateIndex(mediaPlaybackStateModels, mediaPlaybackStateModel.getEpisodeId()) {
                if (removeRecord) {
                    mediaPlaybackStateModels.remove(at: currentMediaPlaybackStateIndex)
                } else {
                    mediaPlaybackStateModels[currentMediaPlaybackStateIndex] = mediaPlaybackStateModel
                }
                
                currentUser.setMediaPlaybackStates(mediaPlaybackStateModels)
                
                usersManager.saveCurrentUserData()
            }
        }
    }
    
    static func getMediaPlaybackStateById(_ mediaPlaybackStateModels: [MediaPlaybackStateModel], _ lookupId: String) -> MediaPlaybackStateModel? {
        var result: MediaPlaybackStateModel?
        
        for i in (0..<mediaPlaybackStateModels.count) {
            let mediaPlaybackStateModel = mediaPlaybackStateModels[i]
            
            if (mediaPlaybackStateModel.getEpisodeId() == lookupId) {
                result = mediaPlaybackStateModel
                
                break
            }
        }
        
        return result
    }
    
    static func getSpecificEpisodePlayedTime(_ episodeId: String) -> Double? {
        var result: Double?
        
        let usersManager = UsersManager.getInstance()
        if let currentUser = usersManager.getCurrentUser() {
            let mediaPlaybackStateModels = currentUser.getMediaPlaybackStates()
            
            if let mediaPlaybackStateModel = MediaPlayerManagerMediaPlaybackStateRecorder.getMediaPlaybackStateById(mediaPlaybackStateModels, episodeId) {
                result = mediaPlaybackStateModel.getPlayedTimeInMilliseconds()
            }
        }

        return result
    }
    
    private static func getMediaPlaybackStateIndex(_ mediaPlaybackStateModels: [MediaPlaybackStateModel], _ lookupId: String) -> Int? {
        var result: Int?
        
        for i in (0..<mediaPlaybackStateModels.count) {
            let mediaPlaybackStateModel = mediaPlaybackStateModels[i]
            
            if (mediaPlaybackStateModel.getEpisodeId() == lookupId) {
                result = i
                
                break
            }
        }
        
        return result
    }
    
    private func seekToMoment(_ positionInMillisecondsToSeekTo: Double) {
        mediaPlayerManager.performActionSeekMedia(positionInMillisecondsToSeekTo)
    }
}
