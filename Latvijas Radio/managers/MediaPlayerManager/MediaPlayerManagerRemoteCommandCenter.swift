//
//  MediaPlayerManagerRemoteCommandCenter.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit
import MediaPlayer

class MediaPlayerManagerRemoteCommandCenter: NSObject {
    
    let TAG = String(describing: MediaPlayerManagerRemoteCommandCenter.self)

    var mediaPlayerManager: MediaPlayerManager!
    
    // This helps us to apply action targets when needed,
    // giving us the ability to remove "NowPlaying" shortcut button on log out.
    var isPlaybackActionsSet = false
    
    var playCommandTarget: Any!
    var pauseCommandTarget: Any!
    var stopCommandTarget: Any!
    var togglePlayPauseCommandTarget: Any!
    var nextTrackCommandTarget: Any!
    var previousTrackCommandTarget: Any!
    var changePlaybackPositionCommandTarget: Any!
    var changePlaybackRateCommandTarget: Any!
    var seekForwardCommandTarget: Any!
    var seekBackwardCommandTarget: Any!

    init(_ mediaPlayerManager: MediaPlayerManager) {
        super.init()
        
        self.mediaPlayerManager = mediaPlayerManager
        
        setupPlaybackActionsIfNecessary()
        
        setupLivestreamInfoPollerListener()
        
        setupMqttNewInformationListener()
    }
    
    func setupLivestreamInfoPollerListener() {
        NotificationCenter.default.addObserver(forName: Notification.Name(LivestreamInfoPoller.EVENT_ON_LIVESTREAM_PROGRAMS_UDPATED), object: nil, queue: .main) { [weak self] notification in
            if let self = self {
                GeneralUtils.log(self.TAG, "EVENT_ON_BROADCAST_PROGRAMS_UDPATED")

                self.updateLivestreamTitle()
            }
        }
    }
    
    func setupMqttNewInformationListener() {
        NotificationCenter.default.addObserver(forName: Notification.Name(MediaPlayerManagerMQTTClient.EVENT_ON_MQTT_NEW_INFORMATION_RECEIVED), object: nil, queue: .main) { [weak self] notification in
            if let self = self {
                GeneralUtils.log(self.TAG, "EVENT_ON_MQTT_NEW_INFORMATION_RECEIVED")

                self.updateLivestreamTitle()
            }
        }
    }
    
    func updateLivestreamTitle() {
        // Notify CarPlay to update livestreams items.
        if let carPlaySceneDelegate = CarPlaySceneDelegate.getCarPlaySceneDelegate() {
            carPlaySceneDelegate.autoContentManager?.autoContentLivestreams.skipCampaignsRequest = true
            
            carPlaySceneDelegate.autoContentManager?.updateLivestreamsTabContent()
        }
        
        if let currentLivestream = mediaPlayerManager.currentLivestream {
            if var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo {
                nowPlayingInfo[MPMediaItemPropertyArtist] = getDynamicLivestreamTitle(currentLivestream, false)
                
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
        }
    }

    func getDynamicLivestreamTitle(_ currentLivestream: /*LivestreamModel*/RadioChannel, _ skipArtistAndSongCheck: Bool) -> String {
        // By default, it is the moto of livestream.
        var finalLivestreamTitle = currentLivestream.slogan /*getTitle()*/

        // Check for broadcast title
        var broadcastTitle = LivestreamInfoPoller.getLivestreamBroadcastTitleWithLivestreamId(String(describing: currentLivestream.id) /*getId()*/)
        if (broadcastTitle != nil) {
            broadcastTitle = broadcastTitle!.uppercased()
        }
        
        if (!skipArtistAndSongCheck) {
            // Check for artist and song name.
            var artistAndSongTitle: String?
            if (MediaPlayerManagerMQTTClient.canShowAdditionalPlaybackInfo()) {
                artistAndSongTitle = MediaPlayerManagerMQTTClient.getPlaybackAdditionalDataFromPayload(MediaPlayerManagerMQTTClient.lastKnownReceivedPayload)
            }
            
            if (broadcastTitle != nil) {
                finalLivestreamTitle = broadcastTitle!
            }
            
            if (artistAndSongTitle != nil) {
                finalLivestreamTitle = artistAndSongTitle!
            }
        }
        
        return finalLivestreamTitle ?? ""
    }
    
    func setupPlaybackActionsIfNecessary() {
        if (!isPlaybackActionsSet) {
            isPlaybackActionsSet = true
            
            GeneralUtils.log(TAG, "setupPlaybackActionsIfNecessary")
            
            let commandCenter = MPRemoteCommandCenter.shared()
            
            commandCenter.playCommand.isEnabled = true
            playCommandTarget = commandCenter.playCommand.addTarget { [weak self] event in
                if let self = self {
                    // We prevent livestreams to be resumed (we hard reset them), so the additional info (artist and song)
                    // would match what user actually hears.
                    if (self.mediaPlayerManager.currentLivestream != nil) {
                        self.mediaPlayerManager.loadAndPlay()
                    } else {
                        self.mediaPlayerManager.startMediaPlayback()
                    }
                }
                
                return .success
            }
            
            commandCenter.pauseCommand.isEnabled = true
            pauseCommandTarget = commandCenter.pauseCommand.addTarget { [weak self] event in
                if let self = self {
                    self.mediaPlayerManager.pauseMediaPlayback()
                }
                
                return .success
            }
            
            // Required, if we are going to set parameter "MPNowPlayingInfoPropertyIsLiveStream".
            commandCenter.stopCommand.isEnabled = true
            stopCommandTarget = commandCenter.stopCommand.addTarget { [weak self] event in
                if let self = self {
                    self.mediaPlayerManager.stopMediaPlayback()
                }
                
                return .success
            }
            
            // For wired media controllers.
            commandCenter.togglePlayPauseCommand.isEnabled = true
            togglePlayPauseCommandTarget = commandCenter.togglePlayPauseCommand.addTarget { [weak self] event in
                if let self = self {
                    self.mediaPlayerManager.performActionToggleMediaPlayback()
                }
                
                return .success
            }

            nextTrackCommandTarget = commandCenter.nextTrackCommand.addTarget { [weak self] event in
                if let self = self {
                    if (self.mediaPlayerManager.currentEpisode != nil && self.mediaPlayerManager.listOfEpisodes != nil) {
                        if let episodeModel = self.mediaPlayerManager.getNextEpisode() {
                            self.mediaPlayerManager.performActionLoadAndPlayEpisode(MediaPlayerManager.PLAYBACK_TYPE_LOCAL_THEN_STREAM, episodeModel, self.mediaPlayerManager.listOfEpisodes)
                        }
                    }
                    
                    if (self.mediaPlayerManager.currentLivestream != nil && self.mediaPlayerManager.listOfLivestreams != nil) {
                        if let livestreamModel = self.mediaPlayerManager.getNextLivestream() {
                            self.mediaPlayerManager.performActionLoadAndPlayLivestream(MediaPlayerManager.PLAYBACK_TYPE_LOCAL_THEN_STREAM, livestreamModel, self.mediaPlayerManager.listOfLivestreams)
                        }
                    }
                }
                
                return .success
            }
            
            previousTrackCommandTarget = commandCenter.previousTrackCommand.addTarget { [weak self] event in
                if let self = self {
                    if (self.mediaPlayerManager.currentEpisode != nil && self.mediaPlayerManager.listOfEpisodes != nil) {
                        if let episodeModel = self.mediaPlayerManager.getPreviousEpisode() {
                            self.mediaPlayerManager.performActionLoadAndPlayEpisode(MediaPlayerManager.PLAYBACK_TYPE_LOCAL_THEN_STREAM, episodeModel, self.mediaPlayerManager.listOfEpisodes)
                        }
                    }
                    
                    if (self.mediaPlayerManager.currentLivestream != nil && self.mediaPlayerManager.listOfLivestreams != nil) {
                        if let livestreamModel = self.mediaPlayerManager.getPreviousLivestream() {
                            self.mediaPlayerManager.performActionLoadAndPlayLivestream(MediaPlayerManager.PLAYBACK_TYPE_LOCAL_THEN_STREAM, livestreamModel, self.mediaPlayerManager.listOfLivestreams)
                        }
                    }
                }
                
                return .success
            }
            
            seekForwardCommandTarget = commandCenter.seekForwardCommand.addTarget { event in
                var startSteppingProcedureTask = true
                
                if let steppingProcedureTask = MediaPlayerManager.getInstance().steppingProcedureTask {
                    if (!steppingProcedureTask.isCancelled) {
                        startSteppingProcedureTask = false
                    }
                }
                
                if (startSteppingProcedureTask) {
                    MediaPlayerManager.getInstance().startSteppingProcedure(forward: true)
                } else {
                    MediaPlayerManager.getInstance().stopSteppingProcedure()
                }

                return .success
            }
            
            seekBackwardCommandTarget = commandCenter.seekBackwardCommand.addTarget { event in
                var startSteppingProcedureTask = true
                
                if let steppingProcedureTask = MediaPlayerManager.getInstance().steppingProcedureTask {
                    if (!steppingProcedureTask.isCancelled) {
                        startSteppingProcedureTask = false
                    }
                }
                
                if (startSteppingProcedureTask) {
                    MediaPlayerManager.getInstance().startSteppingProcedure(forward: false)
                } else {
                    MediaPlayerManager.getInstance().stopSteppingProcedure()
                }

                return .success
            }
            
            commandCenter.changePlaybackPositionCommand.isEnabled = true
            changePlaybackPositionCommandTarget = commandCenter.changePlaybackPositionCommand.addTarget { event in
                if let event = event as? MPChangePlaybackPositionCommandEvent {
                    let seconds: Double = event.positionTime
                    
                    let positionInMillisecondsToSeekTo = seconds * 1000
        
                    MediaPlayerManager.getInstance().performActionSeekMedia(positionInMillisecondsToSeekTo)
                }
                
                return .success
            }

            commandCenter.changePlaybackRateCommand.isEnabled = true
            commandCenter.changePlaybackRateCommand.supportedPlaybackRates = mediaPlayerManager.playbackRates
            
            // This has to be set.
            changePlaybackRateCommandTarget = commandCenter.changePlaybackRateCommand.addTarget { event in
                return .success
            }
        }
    }

    func updatePlaybackActions() {
        GeneralUtils.log(TAG, "updatePlaybackActions")
        
        let commandCenter = MPRemoteCommandCenter.shared()
                
        commandCenter.nextTrackCommand.isEnabled = false
        commandCenter.previousTrackCommand.isEnabled = false
        commandCenter.seekForwardCommand.isEnabled = false
        commandCenter.seekBackwardCommand.isEnabled = false

        if (mediaPlayerManager.currentEpisode != nil && mediaPlayerManager.listOfEpisodes != nil) {
            if mediaPlayerManager.getNextEpisode() != nil {
                commandCenter.nextTrackCommand.isEnabled = true
            }
            
            if mediaPlayerManager.getPreviousEpisode() != nil {
                commandCenter.previousTrackCommand.isEnabled = true
            }
        }
        
        if (mediaPlayerManager.currentLivestream != nil && mediaPlayerManager.listOfLivestreams != nil) {
            if mediaPlayerManager.getNextLivestream() != nil {
                commandCenter.nextTrackCommand.isEnabled = true
            }
            
            if mediaPlayerManager.getPreviousLivestream() != nil {
                commandCenter.previousTrackCommand.isEnabled = true
            }
        }
        
        if (mediaPlayerManager.currentEpisode != nil) {
            commandCenter.seekForwardCommand.isEnabled = true
            commandCenter.seekBackwardCommand.isEnabled = true
        }
    }
    
    func updateNowPlayingInfo() {
        GeneralUtils.log(TAG, "updateNowPlayingInfo")
        
        var contentTitle: String?
        var contentText: String?
        var iconResourceId: String?
        
        if (mediaPlayerManager.currentEpisode != nil) {
            contentTitle = mediaPlayerManager.currentEpisode?.getBroadcastName()
            contentText = mediaPlayerManager.currentEpisode?.getTitle()
            
            let channelId = mediaPlayerManager.currentEpisode!.getChannelId()
            iconResourceId = ChannelsHelper.getImageDrawableIdFromChannelId(channelId)
        }
        
        if (mediaPlayerManager.currentLivestream != nil) {
            contentTitle = mediaPlayerManager.currentLivestream?.name // getName()

            if (mediaPlayerManager.mediaPlayer.timeControlStatus != .paused) {
                contentText = getDynamicLivestreamTitle(mediaPlayerManager.currentLivestream!, false)
            }
            
//            iconResourceId = mediaPlayerManager.currentLivestream?.getImageResourceId()
//            
//            if (mediaPlayerManager.currentLivestream?.getLargeArtworkImageResourceId() != nil) {
//                iconResourceId = mediaPlayerManager.currentLivestream?.getLargeArtworkImageResourceId()
//            }
        }
        
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = contentTitle
        nowPlayingInfo[MPMediaItemPropertyArtist] = contentText

        if (iconResourceId != nil) {
            // When we begin loading an episode, this function might be called multiple times.
            // Meaning, first notification would set default artwork, then dynamic image would download and would be displayed.
            // Immediately after that we get second notification (for the same episode) and it would again set default artwork, then dynamic image would download and would be displayed.
            // To prevent this "switcharoo", we keep custom field in notification - "notification_expects_following_image_url".
            // If we are playing an episode, its imageUrl will be placed in that field.
            // So, when the subsequent notifications come in, we will check if current notifications expected imageUrl matches the one we are about to set.
            // If it mathes, then we don't initialize new artwork object - we use the already created one.
            
            if (mediaPlayerManager.currentEpisode != nil) {
                let imageUrl = self.mediaPlayerManager.currentEpisode!.getImageUrl()
                
                var loadImage = true
                
                if let currentNowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo {
                    if let notificationExpectsFollowingImageUrl = currentNowPlayingInfo["notification_expects_following_image_url"] as? String {
                        if (notificationExpectsFollowingImageUrl == imageUrl) {
                            loadImage = false
                            nowPlayingInfo[MPMediaItemPropertyArtwork] = currentNowPlayingInfo[MPMediaItemPropertyArtwork]
                        }
                    }
                }
                
                if (loadImage) {
                    // Get and apply local image.
                    let image = UIImage(named: iconResourceId!)!

                    let artwork = MPMediaItemArtwork.init(boundsSize: image.size, requestHandler: { _ -> UIImage in
                        return image
                    })
                    nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                    
                    // Get and apply remote image.
                    let imageView = UIImageView()

                    nowPlayingInfo["notification_expects_following_image_url"] = imageUrl

                    imageView.sd_setImage(with: URL(string: imageUrl)!, completed: { _,_,_,_ in
                        if let networkImage = imageView.image {
                            if self.mediaPlayerManager.currentEpisode != nil {
                                let artwork = MPMediaItemArtwork.init(boundsSize: networkImage.size, requestHandler: { _ -> UIImage in
                                    return networkImage
                                })

                                // For when the image is downloaded BEFORE current nowPlayingInfo has already been built and applied
                                // (image might have been in cache, or user might have just been logged out and nowPlayingInfo is empty).
                                nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                            
                                // For when the image is downloaded AFTER current nowPlayingInfo has already been built and applied.
                                if var currentNowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo {
                                    currentNowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                                    
                                    MPNowPlayingInfoCenter.default().nowPlayingInfo = currentNowPlayingInfo
                                }
                            }
                        }
                    })
                }
            }
            
            if (mediaPlayerManager.currentLivestream != nil) {
                let image = UIImage(named: iconResourceId!)!

                let artwork = MPMediaItemArtwork.init(boundsSize: image.size, requestHandler: { _ -> UIImage in
                    return image
                })
                nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
            }
        }

        if (mediaPlayerManager.currentEpisode != nil) {
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = mediaPlayerManager.currentEpisode?.getMediaDurationInSeconds()
        }

        if (mediaPlayerManager.currentLivestream != nil) {
            nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = true
        }

        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo

        if (mediaPlayerManager.currentLivestream != nil) {
            updateLivestreamTitle()
        }
        
        // Notify CarPlay NowPlaying buttons.
        if let carPlaySceneDelegate = CarPlaySceneDelegate.getCarPlaySceneDelegate() {
            carPlaySceneDelegate.autoContentManager?.updateNowPlayingTemplateButtons()
        }
    }
    
    func updatePlaybackState() {
        GeneralUtils.log(TAG, "updatePlaybackState")
        
        if var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo {
            var newRate: Float = 0
            
            if (mediaPlayerManager.mediaPlayer.timeControlStatus == .playing) {
                newRate = mediaPlayerManager.mediaPlayer.rate
            }
            
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = newRate
            
            // Updating rate will reset elapsed playback time, so set it excplicitly.
            let positionInSeconds = Int(mediaPlayerManager.currentPositionInMilliseconds / 1000)
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = positionInSeconds

            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
    }
    
    func reset() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Only reset commands that we dynamically update later.
        commandCenter.nextTrackCommand.isEnabled = false
        commandCenter.previousTrackCommand.isEnabled = false
        commandCenter.seekForwardCommand.isEnabled = false
        commandCenter.seekBackwardCommand.isEnabled = false
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil

        // Notify CarPlay NowPlaying buttons.
        if let carPlaySceneDelegate = CarPlaySceneDelegate.getCarPlaySceneDelegate() {
            carPlaySceneDelegate.autoContentManager?.updateNowPlayingTemplateButtons()
        }
        
        // By removing targets, we remove "NowPlaying" shortcut button.
        commandCenter.playCommand.removeTarget(playCommandTarget)
        commandCenter.pauseCommand.removeTarget(pauseCommandTarget)
        commandCenter.stopCommand.removeTarget(stopCommandTarget)
        commandCenter.togglePlayPauseCommand.removeTarget(togglePlayPauseCommandTarget)
        commandCenter.nextTrackCommand.removeTarget(nextTrackCommandTarget)
        commandCenter.previousTrackCommand.removeTarget(previousTrackCommandTarget)
        commandCenter.seekForwardCommand.removeTarget(seekForwardCommandTarget)
        commandCenter.seekBackwardCommand.removeTarget(seekBackwardCommandTarget)
        commandCenter.changePlaybackPositionCommand.removeTarget(changePlaybackPositionCommandTarget)
        commandCenter.changePlaybackRateCommand.removeTarget(changePlaybackRateCommandTarget)

        isPlaybackActionsSet = false
    }
}
