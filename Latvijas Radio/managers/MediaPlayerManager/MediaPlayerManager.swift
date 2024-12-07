//
//  MediaPlayerManager.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit
import AVFoundation

class MediaPlayerManager {
    
    static let TAG = String(describing: MediaPlayerManager.self)

    static let EVENT_DATA_SOURCE_CHANGED = "EVENT_DATA_SOURCE_CHANGED"
    static let EVENT_MEDIA_PLAYER_PREPARED = "EVENT_MEDIA_PLAYER_PREPARED"
    static let EVENT_UPDATE_MEDIA_PLAYER_STATE = "EVENT_UPDATE_MEDIA_PLAYER_STATE"
    static let EVENT_UPDATE_MEDIA_PLAYER_PROGRESS = "EVENT_UPDATE_MEDIA_PLAYER_PROGRESS"
    static let EVENT_ON_PLAYBACK_COMPLETED = "EVENT_ON_PLAYBACK_COMPLETED"
    static let EVENT_ON_PLAYBACK_ERROR = "EVENT_ON_PLAYBACK_ERROR"
    static let EVENT_ON_PLAYBACK_SPEED_CHANGED = "EVENT_ON_PLAYBACK_SPEED_CHANGED"
    
    static let PLAYBACK_TYPE_STREAM = "PLAYBACK_TYPE_STREAM"
    static let PLAYBACK_TYPE_LOCAL_THEN_STREAM = "PLAYBACK_TYPE_LOCAL_THEN_STREAM"
    
    static let MEDIA_PLAYER_STATE_PLAYING_AND_SEEKING = "MEDIA_PLAYER_STATE_PLAYING_AND_SEEKING"
    static let MEDIA_PLAYER_STATE_PLAYING = "MEDIA_PLAYER_STATE_PLAYING"
    static let MEDIA_PLAYER_STATE_PAUSED = "MEDIA_PLAYER_STATE_PAUSED"

    static let NOTIFICATION_PARAMS_DEFAULT_KEY = "NOTIFICATION_PARAMS_DEFAULT_KEY"
    
    static let CONTENT_SOURCE_NAME_APP_DASHBOARD_HORIZONTAL_SLIDER = "CONTENT_SOURCE_NAME_APP_DASHBOARD_HORIZONTAL_SLIDER"
    static let CONTENT_SOURCE_NAME_APP_LIVESTREAMS_VERTICAL_SLIDER = "CONTENT_SOURCE_NAME_APP_LIVESTREAMS_VERTICAL_SLIDER"
    static let CONTENT_SOURCE_NAME_AUTO_CONTENT_LIVESTREAMS = "CONTENT_SOURCE_NAME_AUTO_CONTENT_LIVESTREAMS"
    
    private static var instance: MediaPlayerManager!

    var mediaPlayer: AVPlayer!
    private var isMediaPlayerPreparing = false
    var isMediaPlayerPrepared = false
    var mediaPlayerState = MediaPlayerManager.MEDIA_PLAYER_STATE_PAUSED
    private var playerSourceObserver: NSKeyValueObservation?
    private var playerStatusObserver: NSKeyValueObservation?
    let playbackRates: [NSNumber] = [NSNumber](arrayLiteral: 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2)
    var playbackSpeed: Float = 1
    private var currentPlaybackType: String!
    private var currentMediaPathIsLocalFile = false
    
    // Represents the ACTUAL media player current position.
    // If we are currently seeking, this value holds the "currently seeking to position" value.
    var currentPositionInMilliseconds: Double!
    
    // The problem with seeking in iOS is that if we are, for an example, at 00:30 and we start seeking to 01:00,
    // players time internally is set to the destination time 01:00, which is good - we are notifying user the destination time.
    // However, before the seeking is complete, the players' time might still jump back to the original 00:30, causing jumping in UI.
    // Solution - set currentPositionInMilliseconds only when seeking is not in progress.
    
    var seekInProgress = false
    
    var currentEpisode: EpisodeModel?
    var currentLivestream: RadioChannel? //LivestreamModel?
    var listOfEpisodes: [EpisodeModel]?
    var listOfLivestreams: [RadioChannel]? //[LivestreamModel]?

    // This helps us to know if we need to refresh list of livestreams if user changes order on the phone app.
    // Currently we only track this if content is livestream.
    var contentLoadedFromSource: String?
    
    private var mediaPlayerUiUpdateTimer = Timer()
    private var playerItemObservers: [NSKeyValueObservation?]?
    private var steppingProcedureElapsedTime = -1000
    var steppingProcedureTask: DispatchWorkItem?
    
    var mediaPlayerManagerRemoteCommandCenter: MediaPlayerManagerRemoteCommandCenter!
    private var mediaPlayerManagerMQTTClient: MediaPlayerManagerMQTTClient!
    private var mediaPlayerManagerMediaPlaybackStateRecorder: MediaPlayerManagerMediaPlaybackStateRecorder!
    var mediaPlayerManagerTimeoutManager: MediaPlayerManagerTimeoutManager!
    private var networkConnectivityManager: NetworkConnectivityManager!
    private var mediaPlayerManagerAudioSession: MediaPlayerManagerAudioSession!
    private var broadcastInfoPoller: LivestreamInfoPoller!
    var playerWasInterruptedDueToNetworkConnectivityIssue = false
    
    private init() {
        GeneralUtils.log(MediaPlayerManager.TAG, "init")
        
        mediaPlayer = AVPlayer()
        
        // Required for playing audio while app is in background (initial call will always fail which is ok)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowAirPlay])
            //try AVAudioSession.sharedInstance().setActive(true)
            
        } catch {
            GeneralUtils.log(MediaPlayerManager.TAG, "Error setting the AVAudioSession:", error.localizedDescription)
        }
        
        setupStateObservers()
        
        mediaPlayerManagerRemoteCommandCenter = MediaPlayerManagerRemoteCommandCenter(self)
        
        mediaPlayerManagerMQTTClient = MediaPlayerManagerMQTTClient()
        
        mediaPlayerManagerMediaPlaybackStateRecorder = MediaPlayerManagerMediaPlaybackStateRecorder(self)
        
        mediaPlayerManagerTimeoutManager = MediaPlayerManagerTimeoutManager()
        
        networkConnectivityManager = NetworkConnectivityManager(self)
        networkConnectivityManager.registerNetworkCallback()
        
        mediaPlayerManagerAudioSession = MediaPlayerManagerAudioSession(self)
        
        broadcastInfoPoller = LivestreamInfoPoller()
        broadcastInfoPoller.startPollingProcedure()
    }
    
    @discardableResult static func getInstance() -> MediaPlayerManager {
        if (instance == nil) {
            instance = MediaPlayerManager()
        }
        
        return instance
    }
    
    deinit {
        GeneralUtils.log(MediaPlayerManager.TAG, "deinit")
        
        networkConnectivityManager.unregisterNetworkCallback()
        
        broadcastInfoPoller.stopPollingProcedure()
    }

    func setupStateObservers() {
        playerSourceObserver = mediaPlayer?.observe(\.currentItem?.status, options: []) { (player, change) in
            var errorEncountered = false
            
            switch (player.currentItem?.status) {
            case .readyToPlay:
                self.isMediaPlayerPrepared = true
                self.isMediaPlayerPreparing = false
                
                self.notifyPlayerMediaPrepared()
                
                if (MediaPlayerManagerMQTTClient.canShowAdditionalPlaybackInfo()) {
                    self.mediaPlayerManagerMQTTClient.connect()
                }

                self.startMediaPlayback()

                break
            case .failed:
                GeneralUtils.log(MediaPlayerManager.TAG, "Status: Failed: ", player.currentItem?.error as Any)

                errorEncountered = true

                if let error = player.currentItem?.error as? URLError {
                    if (error.code == .notConnectedToInternet ||
                        error.code == .networkConnectionLost ||
                        error.code == .timedOut) {
                        
                        self.playerWasInterruptedDueToNetworkConnectivityIssue = true
                    }
                }

                break
            case .unknown:
                // When you first create a player item, its status value is AVPlayerItem.Status.unknown,
                // meaning its media hasn’t been loaded or been enqueued for playback.
                
                // When the current "currentItem" (old) gets replaced with new "currentItem" (new),
                // the "currentItem" (new) status becomes "Unknown".
                
                GeneralUtils.log(MediaPlayerManager.TAG, "Status: Unknown")
                
                // When stream starts to buffer, this is the order of events we get:
                // MediaPlayerManager | PlayerItem: Done buffering
                // MediaPlayerManager | PlayerItem: Buffering
                // MediaPlayerManager | Media player event: AVPlayerItemPlaybackStalled
                // MediaPlayerManager | Player: Waiting to play at specified rate

                // When stream is done buffering, this is the order of events we get:
                // MediaPlayerManager | PlayerItem: Done buffering
                // MediaPlayerManager | Player: Playing

                let currentItemBufferEmptyObserver = self.mediaPlayer.currentItem!.observe(\.isPlaybackBufferEmpty) { (object, observedChange) in
                    GeneralUtils.log(MediaPlayerManager.TAG, "PlayerItem: Buffering")
                }

                let currentItemBufferKeepUpObserver = self.mediaPlayer.currentItem!.observe(\.isPlaybackLikelyToKeepUp) { [weak self] (object, observedChange) in

                    GeneralUtils.log(MediaPlayerManager.TAG, "PlayerItem: Done buffering")
                    
                    if (self?.mediaPlayer.timeControlStatus == .playing) {
                        self?.startMediaPlayerUiUpdater()
                    }
                }

                self.playerItemObservers = [currentItemBufferEmptyObserver, currentItemBufferKeepUpObserver]
                
                break
            case .none:
                // When the current "currentItem" (old) gets replaced with new "currentItem" (new),
                // the "currentItem" (old) status becomes "None".
                
                GeneralUtils.log(MediaPlayerManager.TAG, "Status: None")

                break
            @unknown default:
                GeneralUtils.log(MediaPlayerManager.TAG, "Status: Unrecognized")
                
                errorEncountered = true

                break
            }
            
            if (errorEncountered) {
                self.fullyResetMediaPlayer()
                
                self.notifyUpdatePlayerState()
                
                var errorString = "playback_error_unknown".localized()
                if (player.error != nil) {
                    errorString = player.error!.localizedDescription
                }
                
                self.notifyOnPlaybackError(errorString)
            }
        }
        
        playerStatusObserver = mediaPlayer?.observe(\.timeControlStatus, options: []) { (player, change) in
            
            switch(player.timeControlStatus) {
            case .playing:
                GeneralUtils.log(MediaPlayerManager.TAG, "Player: Playing")
                
                self.mediaPlayerState = MediaPlayerManager.MEDIA_PLAYER_STATE_PLAYING
                
                // If we were playing, network drops, network comes back - need to start updater manually.
                self.startMediaPlayerUiUpdater()
                
                break
            case .paused:
                GeneralUtils.log(MediaPlayerManager.TAG, "Player: Paused")
                
                self.mediaPlayerState = MediaPlayerManager.MEDIA_PLAYER_STATE_PAUSED
                
                break
            case .waitingToPlayAtSpecifiedRate:
                GeneralUtils.log(MediaPlayerManager.TAG, "Player: Waiting to play at specified rate")
                
                self.mediaPlayerState = MediaPlayerManager.MEDIA_PLAYER_STATE_PLAYING_AND_SEEKING
                
                break
            default:
                break
            }
            
            self.mediaPlayerManagerRemoteCommandCenter.updatePlaybackState()
            
            self.notifyUpdatePlayerState()
        }
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.mediaPlayer.currentItem, queue: .main) { [weak self] _ in
            
            GeneralUtils.log(MediaPlayerManager.TAG, "Media player event: AVPlayerItemDidPlayToEndTime")

            var newEpisodeToAutoplay: EpisodeModel?
            var newLivestreamToAutoplay: RadioChannel? //LivestreamModel?

            
            let usersManager = UsersManager.getInstance()
            if let currentUser = usersManager.getCurrentUser() {
                // Acquire next items before we are removing current one from the list.
                var nextEpisode = self?.getNextEpisode()
                let nextLivestream = self?.getNextLivestream()

                // Check auto-removal from "my subscribed episodes" list.
                if (currentUser.getAutomaticallyDeleteFinishedEpisodesFromMyList()) {
                    if let currentEpisode = self?.currentEpisode {
                        // Remove episode from currentListOfEpisodes.
                        
                        if let listOfEpisodes = self?.listOfEpisodes {
                            for i in (0..<listOfEpisodes.count) {
                                let episodeModel = listOfEpisodes[i]
                                if (episodeModel.getId() == currentEpisode.getId()) {
                                    self?.listOfEpisodes?.remove(at: i)
                                }
                            }
                        }
                        
                        // Access list a new.
                        if let listOfEpisodes = self?.listOfEpisodes {
                            // If we auto-removed last item in the list, nullify the list,
                            // otherwise the last item will be played once more.
                            if (listOfEpisodes.count == 0) {
                                self?.listOfEpisodes = nil
                                
                                // We acquired next episode before we removed the last item, so there is no next episode.
                                nextEpisode = nil
                            }
                        }

                        let userSubscribedEpisodesManager = UserSubscribedEpisodesManager.getInstance()
                        
                        userSubscribedEpisodesManager.episodeItemHasCompletedWithAutoRemoveEnabled = true
                        
                        userSubscribedEpisodesManager.performRequestSetEpisodeSubscriptionStatus(currentEpisode, false, {})
                    }
                }
                
                // Check autoplay.
                if (currentUser.getIsAutoplayEnabled()) {
                    if (self?.currentEpisode != nil && self?.listOfEpisodes != nil) {
                        newEpisodeToAutoplay = nextEpisode
                    }
                    
                    if (self?.currentLivestream != nil && self?.listOfLivestreams != nil) {
                        newLivestreamToAutoplay = nextLivestream
                    }
                }
            }

            self?.stopMediaUpdater()
            self?.mediaPlayerManagerMediaPlaybackStateRecorder.removeCurrentMediaPlaybackStateRecord()
            self?.mediaPlayerManagerMediaPlaybackStateRecorder.stopRecordingProcedure(true)
            
            self?.notifyOnPlaybackCompleted()
            
            if (newEpisodeToAutoplay != nil || newLivestreamToAutoplay != nil) {
                if (newEpisodeToAutoplay != nil) {
                    self?.currentEpisode = newEpisodeToAutoplay
                }
                
                if (newLivestreamToAutoplay != nil) {
                    self?.currentLivestream = newLivestreamToAutoplay
                }
                
                self?.notifyDataSourceChanged(true)
                
                self?.loadAndPlay()
            } else {
                self?.fullyResetMediaPlayer()
                self?.stopMediaUpdater()
                
                // reset fast-forward/backward buttons
                self?.notifyDataSourceChanged(true)
                
                self?.mediaPlayerState = MediaPlayerManager.MEDIA_PLAYER_STATE_PAUSED
                
                self?.notifyUpdatePlayerState()
                
                self?.notifyUpdatePlayerProgress()
            }
        }
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemPlaybackStalled, object: self.mediaPlayer.currentItem, queue: .main) { _ in
            GeneralUtils.log(MediaPlayerManager.TAG, "Media player event: AVPlayerItemPlaybackStalled")
        }

        NotificationCenter.default.addObserver(forName: .AVPlayerItemFailedToPlayToEndTime, object: self.mediaPlayer.currentItem, queue: .main) { [weak self] _ in
            GeneralUtils.log(MediaPlayerManager.TAG, "Media player event: AVPlayerItemFailedToPlayToEndTime")

            self?.fullyResetMediaPlayer()
        }

        NotificationCenter.default.addObserver(forName: .AVPlayerItemNewErrorLogEntry, object: self.mediaPlayer.currentItem, queue: .main) { _ in
            GeneralUtils.log(MediaPlayerManager.TAG, "Media player event: AVPlayerItemNewErrorLogEntry")
        }

        // leaving for reference: gets called only for ".m3u8" items
//        NotificationCenter.default.addObserver(forName: .AVPlayerItemNewAccessLogEntry, object: self.player.currentItem, queue: .main) { [weak self] _ in
//            GeneralUtils.log(MediaPlayerManager.TAG, "Media player event: AVPlayerItemNewAccessLogEntry")
//
////            self?.player?.seek(to: CMTime.zero)
////            self?.player?.play()
//        }
    }
    
    func performActionLoadAndPlayEpisode(_ currentPlaybackType: String, _ episode: EpisodeModel, _ listOfEpisodes: [EpisodeModel]?) {
        currentEpisode = nil
        currentLivestream = nil
        
        self.currentPlaybackType = currentPlaybackType

        currentEpisode = episode
        
        self.listOfEpisodes = listOfEpisodes
        self.listOfLivestreams = nil

        // for ios, we need to reset "isMediaPlayerPrepared" before we notify listeners of data source change
        fullyResetMediaPlayer()
        stopMediaUpdater()
        
        notifyDataSourceChanged(true)
        
        loadAndPlay()

        processMediaPlayerCurrentPosition()
        notifyUpdatePlayerProgress()
    }
    
    func performActionLoadAndPlayLivestream(_ currentPlaybackType: String, _ livestream: RadioChannel /*LivestreamModel*/, _ listOfLivestreams: /*[LivestreamModel]?*/ [RadioChannel]?) {
        currentEpisode = nil
        currentLivestream = nil
        
        self.currentPlaybackType = currentPlaybackType

        currentLivestream = livestream
        
        self.listOfEpisodes = nil
        self.listOfLivestreams = listOfLivestreams
        
        // notify all who are listening about the data we are preparing to listen to
        // we call "DATA_SOUCE_CHANGED" first, so the panel gets opened (can be seperated if need be)
        notifyDataSourceChanged(true)
        
        loadAndPlay()
        
        processMediaPlayerCurrentPosition()
        notifyUpdatePlayerProgress()
    }
    
    func performActionToggleMediaPlayback() {
        if (isMediaPlayerPrepared) {
            if (mediaPlayer.timeControlStatus == .playing) {
                pauseMediaPlayback()
            } else {
                // We prevent livestreams to be resumed, so the additional info (artist and song)
                // would match what user actually hears.
                if (currentLivestream != nil) {
                    loadAndPlay()
                } else {
                    startMediaPlayback()
                }
            }
        } else {
            if (isMediaPlayerPreparing) {
                stopMediaPlayback()
            } else {
                loadAndPlay()
            }
        }
    }
    
    func performActionSeekMedia(_ seekToPositionInMilliseconds: Double) {
        GeneralUtils.log(MediaPlayerManager.TAG, "performActionSeekMedia")
        
        let seekToPositionInSeconds: Double = seekToPositionInMilliseconds / 1000
        
        if let currentItem = mediaPlayer.currentItem {
            let totalDurationInSeconds: Double = currentItem.asset.duration.seconds.rounded()
            //let totalDurationInSeconds: Double = await currentItem.asset.load(.duration).seconds.rounded()

            if (seekToPositionInSeconds >= totalDurationInSeconds) {
                currentPositionInMilliseconds = totalDurationInSeconds * 1000 - 1000
            } else if (seekToPositionInSeconds < 0) {
                currentPositionInMilliseconds = 0
            } else {
                currentPositionInMilliseconds = seekToPositionInMilliseconds
            }
        } else {
            currentPositionInMilliseconds = 0
        }
        
        // If we are dragging timeline slider for episode (in app, in media widget),
        // we need to save the user dragged position to be the last played position,
        // so on play it would start from this position.
        if let currentEpisode = currentEpisode {
            let usersManager = UsersManager.getInstance()
            if let currentUser = usersManager.getCurrentUser() {
                let mediaPlaybackStateModels = currentUser.getMediaPlaybackStates()
                
                if let mediaPlaybackStateModel = MediaPlayerManagerMediaPlaybackStateRecorder.getMediaPlaybackStateById(mediaPlaybackStateModels, currentEpisode.getId()) {
                    mediaPlaybackStateModel.setPlayedTimeInMilliseconds(currentPositionInMilliseconds)
                    
                    MediaPlayerManagerMediaPlaybackStateRecorder.saveCurrentEpisodeMediaPlaybackState(mediaPlaybackStateModel, false)
                }
            }
        }

        let currentPositionInSeconds = currentPositionInMilliseconds / 1000

        // prevents jumping
        stopMediaUpdater()
        
        seekInProgress = true
                
        mediaPlayer.seek(to: CMTimeMakeWithSeconds(currentPositionInSeconds, preferredTimescale: 1), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero, completionHandler: { [weak self] (completed: Bool) -> Void in
            GeneralUtils.log(MediaPlayerManager.TAG, "Seek done")

            self?.seekInProgress = false
            
            self?.mediaPlayerManagerMediaPlaybackStateRecorder.autoSeekInProgress = false
        })
        
        if (!mediaPlayerManagerMediaPlaybackStateRecorder.autoSeekInProgress) {
            notifyUpdatePlayerProgress()
            
            // Update elapsed time on MPRemoteCommandCenter.
            mediaPlayerManagerRemoteCommandCenter.updatePlaybackState()
        }
    }
    
    func performActionDataSourceChanged() {
        notifyDataSourceChanged(false)

        notifyUpdatePlayerState()
    }
    
    func performActionUpdateMediaPlayerProgress() {
        processMediaPlayerCurrentPosition()
        notifyUpdatePlayerProgress()
    }
    
    func performActionStopMediaPlayer() {
        fullyResetMediaPlayer()
        
        // Clear media items.
        currentEpisode = nil
        currentLivestream = nil
        listOfEpisodes = nil
        listOfLivestreams = nil
        
        mediaPlayerManagerRemoteCommandCenter.reset()
    }
    
    func performActionGetTimeout() {
        mediaPlayerManagerTimeoutManager.broadcastCurrentPlaybackTimeoutModel()
    }
    
    func performActionSetTimeout(_ playbackTimeoutModel: PlaybackTimeoutModel) {
        mediaPlayerManagerTimeoutManager.setTimeoutProcedure(playbackTimeoutModel)
    }

    /*
        If we stop or pause, the rate is 0.
     */
    func getPlayerPlaybackSpeed() -> Float {
        return mediaPlayer.rate
    }
    
    func performActionCyclePlaybackSpeed(_ performAutoStopIfStateAllows: Bool) {
        if (currentEpisode != nil) {
            let playbackSpeedAsNumber = playbackSpeed as NSNumber
            
            if let indexOfCurrentPlaybackSpeed = playbackRates.firstIndex(of: playbackSpeedAsNumber) {
                var indexOfNextPlaybackSpeed = indexOfCurrentPlaybackSpeed + 1
                
                if (indexOfNextPlaybackSpeed == playbackRates.count) {
                    indexOfNextPlaybackSpeed = 0
                }
                
                let nextPlaybackSpeed = playbackRates[indexOfNextPlaybackSpeed]
                
                GeneralUtils.log(MediaPlayerManager.TAG, "cyclePlaybackRate: ", String(playbackSpeed) + " >> " + String(describing: nextPlaybackSpeed))
                
                // changing speed to non-zero is equivalent to calling .start()
                playbackSpeed = nextPlaybackSpeed.floatValue
                mediaPlayer.rate = playbackSpeed
                
                notifyOnPlaybackSpeedChanged()

                if (performAutoStopIfStateAllows) {
                    if (mediaPlayer.timeControlStatus != .playing) {
                        pauseMediaPlayback()
                    }
                }
            }
        }
    }
    
    func resetPlaybackSpeed() {
        playbackSpeed = 1
        mediaPlayer.rate = playbackSpeed
    }

    func triggerAllPlayersUiSetupOrUpdate() {
        if (currentEpisode != nil || currentLivestream != nil) {
            performActionDataSourceChanged()
            
            performActionUpdateMediaPlayerProgress()
        }
    }

    func loadAndPlay() {
        var mediaPath: String!
        
        currentMediaPathIsLocalFile = false
        
        // Notify CarPlay to update list items.
        if let carPlaySceneDelegate = CarPlaySceneDelegate.getCarPlaySceneDelegate() {
            carPlaySceneDelegate.autoContentManager?.refreshListItemsPlayingStateIfNecessary()
        }
        
        if (currentEpisode != nil) {
            if (currentPlaybackType == MediaPlayerManager.PLAYBACK_TYPE_LOCAL_THEN_STREAM) {
                let usersManager = UsersManager.getInstance()
                
                let offlineEpisode = usersManager.getOfflineEpisodeById(currentEpisode!.getId())
                if (offlineEpisode != nil) {
                    // not actually being used to get the source
                    mediaPath = offlineEpisode!.getDownloadedMediaPath()
                    
                    currentMediaPathIsLocalFile = true
                } else {
                    mediaPath = currentEpisode?.getMediaStreamUrl()
                }
            }
        }
        
        if (currentLivestream != nil) {
            mediaPath = currentLivestream?.getMediaStreamUrl()

            // When playing livestreams, force playback speed to normal.
            // Can't be set on "readyToPlay", have to reset rate in here.

            resetPlaybackSpeed()
        }

        // If we play new media from list either manually or with autoplay, update data in notification.
        // At this point, "asset" still hasn't loaded, meaning we won't have timeline info.
        // That's why update notification when media item is ready to be played.

        mediaPlayerManagerRemoteCommandCenter.updateNowPlayingInfo()
        mediaPlayerManagerRemoteCommandCenter.updatePlaybackActions()

        // mediaPlayer state: idle
        fullyResetMediaPlayer()
        stopMediaUpdater()

        // Reset MQTT connection, if any.
        mediaPlayerManagerMQTTClient.disconnect()

        // for safety
        if (mediaPath != nil) {
            GeneralUtils.log(MediaPlayerManager.TAG, "mediaPath:", mediaPath!)
            
            isMediaPlayerPreparing = true

            // Haven't seen that this helps physically, but logically can help
            self.mediaPlayer.currentItem?.cancelPendingSeeks()
            self.mediaPlayer.currentItem?.asset.cancelLoading()

            // mediaPlayer state: preparing
            let url = URL(string: mediaPath)!
            var playerItem: AVPlayerItem!

            if (currentMediaPathIsLocalFile) {
                if let localAssetForStream = AssetPersistenceManager.sharedManager.localAssetForEpisodeModel(withEpisodeModel: currentEpisode!) {
                    let urlAsset = localAssetForStream.urlAsset
                    playerItem = AVPlayerItem(asset: urlAsset)
                }
            } else {
                playerItem = AVPlayerItem(url: url)
            }

            self.mediaPlayer.replaceCurrentItem(with: playerItem) // same as prepareSync in android

            mediaPlayerManagerMediaPlaybackStateRecorder.applyMediaPlaybackStateOfCurrentEpisodeIfAny()

            // Setting current item will cause ".none" event on previous item (if any) and
            // ".unknown" event on this new current item.
            // So, on this ".unknown" event we set things that depend on it, like custom buffering listeners (optional) and "Now Playing" info.
            // After ".unknown" event, player will immediately get ".paused" status, which would show "play" button for user, but that is not what we want - we want to show "pause" button with loader next to it.
            // So we set the mediaPlayerState here, after ".unknown" + "mediaPlayer.paused" events have happened.

            self.mediaPlayerState = MediaPlayerManager.MEDIA_PLAYER_STATE_PLAYING_AND_SEEKING

            self.notifyUpdatePlayerState()
            
            // We might have been logged out which has reset our action listeners.
            // Apply them if necessary.
            mediaPlayerManagerRemoteCommandCenter.setupPlaybackActionsIfNecessary()
        } else {
            GeneralUtils.log(MediaPlayerManager.TAG, "mediaPath: null")
        }
    }
    
    func startMediaPlayback() {
        startMediaPlayerUiUpdater()
        
        if (currentEpisode != nil) {
            mediaPlayerManagerMediaPlaybackStateRecorder.startRecordingProcedure()
        }
        
        // play/resume
        mediaPlayer.playImmediately(atRate: playbackSpeed)
        
        mediaPlayerState = MediaPlayerManager.MEDIA_PLAYER_STATE_PLAYING
        
        notifyUpdatePlayerState()
        
        mediaPlayerManagerRemoteCommandCenter.updateLivestreamTitle()
    }
    
    func pauseMediaPlayback() {
        mediaPlayer.pause()
        
        stopMediaUpdater()
        mediaPlayerManagerMediaPlaybackStateRecorder.stopRecordingProcedure(false)
        
        mediaPlayerState = MediaPlayerManager.MEDIA_PLAYER_STATE_PAUSED
        
        notifyUpdatePlayerState()
    }
    
    func stopMediaPlayback() {
        fullyResetMediaPlayer()
        
        mediaPlayerState = MediaPlayerManager.MEDIA_PLAYER_STATE_PAUSED
        
        notifyUpdatePlayerState()
    }
    
    func fullyResetMediaPlayer() {
        stopMediaUpdater()
        mediaPlayerManagerMediaPlaybackStateRecorder.stopRecordingProcedure(true)
        
        isMediaPlayerPreparing = false
        isMediaPlayerPrepared = false
        currentPositionInMilliseconds = 0
        seekInProgress = false

        mediaPlayer.replaceCurrentItem(with: nil)
    }

    func startMediaPlayerUiUpdater() {
        // Timer is more precise than DispatchQueue.main.asyncAfter(),
        // because it doesn't require the rebuild of the callback
        
        mediaPlayerUiUpdateTimer.invalidate()
        
        mediaPlayerUiUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            GeneralUtils.log(MediaPlayerManager.TAG, "Updating")
            
            if let self = self {
                self.notifyUpdatePlayerState()
                
                self.processMediaPlayerCurrentPosition()
            
                if (!self.mediaPlayerManagerMediaPlaybackStateRecorder.autoSeekInProgress) {
                    self.notifyUpdatePlayerProgress()
                }
            }
        })
    }
    
    func stopMediaUpdater() {
        mediaPlayerUiUpdateTimer.invalidate()
    }
    
    func getPreviousEpisode() -> EpisodeModel? {
        var result: EpisodeModel?
        
        if let currentEpisode = currentEpisode, let listOfEpisodes = listOfEpisodes {
            if (listOfEpisodes.count > 0) {
                let currentEpisodeIndexInList = getEpisodeIndexInList(currentEpisode)
                var newEpisodeIndex = currentEpisodeIndexInList - 1
                
                // if we are currently at start, switch to last index
                if (newEpisodeIndex == -1) {
                    newEpisodeIndex = listOfEpisodes.count - 1
                }
                
                result = listOfEpisodes[newEpisodeIndex]
            }
        }
        
        return result
    }
    
    func getNextEpisode() -> EpisodeModel? {
        var result: EpisodeModel?
        
        if let currentEpisode = currentEpisode, let listOfEpisodes = listOfEpisodes {
            if (listOfEpisodes.count > 0) {
                let currentEpisodeIndexInList = getEpisodeIndexInList(currentEpisode)
                var newEpisodeIndex = currentEpisodeIndexInList + 1
                
                // if we are currently at an end, switch to first index
                if (newEpisodeIndex == listOfEpisodes.count) {
                    newEpisodeIndex = 0
                }
                
                result = listOfEpisodes[newEpisodeIndex]
            }
        }
        
        return result
    }
    
    func getPreviousLivestream() -> /*LivestreamModel*/ RadioChannel? {
        var result: /*LivestreamModel*/ RadioChannel?

        if let currentLivestream = currentLivestream, let listOfLivestreams = listOfLivestreams {
            if (listOfLivestreams.count > 0) {
                let currentLivestreamIndexInList = getLivestreamIndexInList(currentLivestream)
                var newLivestreamIndex = currentLivestreamIndexInList - 1
                
                // if we are currently at start, switch to last index
                if (newLivestreamIndex == -1) {
                    newLivestreamIndex = listOfLivestreams.count - 1
                }
                
                result = listOfLivestreams[newLivestreamIndex]
            }
        }
        
        return result
    }
    
    func getNextLivestream() -> /*LivestreamModel*/ RadioChannel? {
        var result: /*LivestreamModel*/ RadioChannel?

        if let currentLivestream = currentLivestream, let listOfLivestreams = listOfLivestreams {
            if (listOfLivestreams.count > 0) {
                let currentLivestreamIndexInList = getLivestreamIndexInList(currentLivestream)
                var newLivestreamIndex = currentLivestreamIndexInList + 1
                
                // if we are currently at an end, switch to first index
                if (newLivestreamIndex == listOfLivestreams.count) {
                    newLivestreamIndex = 0
                }
                
                result = listOfLivestreams[newLivestreamIndex]
            }
        }
        
        return result
    }
    
    func getEpisodeIndexInList(_ episodeToLookUp: EpisodeModel) -> Int {
        var result = -1
        
        for i in (0..<listOfEpisodes!.count) {
            let episodeModel = listOfEpisodes![i]
            
            if (episodeModel.getId() == episodeToLookUp.getId()) {
                result = i
                
                break
            }
        }
        
        return result
    }
    
    func getLivestreamIndexInList(_ livestreamToLookUp: /*LivestreamModel*/ RadioChannel) -> Int {
        var result = -1
        
        for i in (0..<listOfLivestreams!.count) {
            let livestreamModel = listOfLivestreams![i]
            
            if (livestreamModel.id /*getId()*/ == livestreamToLookUp.id /*getId()*/) {
                result = i
                
                break
            }
        }
        
        return result
    }
    
    func notifyDataSourceChanged(_ preemptivelyDisconnectFromMqttService: Bool) {
        // If we are skipping to next/previous livestream, we want mqtt service to have its contents cleared,
        // so the previous stations artist and song would not show on the new livestream while it is loading.
        // However, this function is also called when we open a view and trigger all player UI update.
        // So control the disconnect from mqtt with a flag.
        
        if (preemptivelyDisconnectFromMqttService) {
            // Due to notification being sent before loadAndPlay call,
            // we have to reset the reset MQTT connection here as well, if any.
            mediaPlayerManagerMQTTClient.disconnect()
        }
        
        NotificationCenter.default.post(
            name: Notification.Name(MediaPlayerManager.EVENT_DATA_SOURCE_CHANGED),
            object: nil,
            userInfo: nil
        )
    }
    
    func notifyPlayerMediaPrepared() {
        NotificationCenter.default.post(
            name: Notification.Name(MediaPlayerManager.EVENT_MEDIA_PLAYER_PREPARED),
            object: nil,
            userInfo: nil
        )
    }
    
    func notifyUpdatePlayerState() {
        NotificationCenter.default.post(
            name: Notification.Name(MediaPlayerManager.EVENT_UPDATE_MEDIA_PLAYER_STATE),
            object: nil,
            userInfo: [MediaPlayerManager.NOTIFICATION_PARAMS_DEFAULT_KEY: self.mediaPlayerState]
        )
    }
    
    func getMediaPlayerActualCurrentPosition() -> Double {
        var result: Double = 0
        
        if let currentItem = mediaPlayer.currentItem {
            result = currentItem.currentTime().seconds.rounded() * 1000
        }
        
        return result
    }
    
    func processMediaPlayerCurrentPosition() {
        // Make sure that if we are currently seeking, we do not touch "currentPositionInMilliseconds",
        // because it is already set in the seek call.
        
        if (!seekInProgress) {
            currentPositionInMilliseconds = getMediaPlayerActualCurrentPosition()
            
            // If we are preparing to play an episode that will be seeked to xx:xx automatically,
            // we have to provide its actual last played moment, otherwise it would only be seen when auto-seek begins.

            if (!isMediaPlayerPrepared) {
                if (currentEpisode != nil) {
                    if let episodePlayedTimeInMilliseconds = MediaPlayerManagerMediaPlaybackStateRecorder.getSpecificEpisodePlayedTime(currentEpisode!.getId()) {
                        currentPositionInMilliseconds = episodePlayedTimeInMilliseconds
                    }
                }
            }
        }
    }
    
    func startSteppingProcedure(forward: Bool) {
        steppingProcedureTask = DispatchWorkItem {
            self.steppingProcedureElapsedTime += 1000
            
            var secondsToStepBy = 15
            
            if (self.steppingProcedureElapsedTime >= 6000) {
                secondsToStepBy = 1800
            } else if (self.steppingProcedureElapsedTime >= 4000) {
                secondsToStepBy = 600
            } else if (self.steppingProcedureElapsedTime >= 2000) {
                secondsToStepBy = 60
            }

            if (forward) {
                self.playbackStepForward(secondsToStepBy)
            } else {
                self.playbackStepBackward(secondsToStepBy)
            }
            
            if let steppingProcedureTask = self.steppingProcedureTask {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: steppingProcedureTask)
            }
        }
        
        steppingProcedureTask?.perform()
    }

    func stopSteppingProcedure() {
        steppingProcedureElapsedTime = -1000
        
        steppingProcedureTask?.cancel()
    }
    
    func playbackStepBackward(_ secondsToStepBackwardBy: Int) {
        let currentElapsedDurationInSeconds = Int(currentPositionInMilliseconds / 1000)
        let positionInSecondsToSeekTo = currentElapsedDurationInSeconds - secondsToStepBackwardBy
        let positionInMillisecondsToSeekTo = Double(positionInSecondsToSeekTo * 1000)

        if (currentEpisode != nil) {
            performActionSeekMedia(positionInMillisecondsToSeekTo)
        }
    }
    
    func playbackStepForward(_ secondsToStepForwardBy: Int) {
        let currentElapsedDurationInSeconds = Int(currentPositionInMilliseconds / 1000)
        let positionInSecondsToSeekTo = currentElapsedDurationInSeconds + secondsToStepForwardBy
        let positionInMillisecondsToSeekTo = Double(positionInSecondsToSeekTo * 1000)

        if (currentEpisode != nil) {
            performActionSeekMedia(positionInMillisecondsToSeekTo)
        }
    }
    
    func notifyUpdatePlayerProgress() {
        NotificationCenter.default.post(
            name: Notification.Name(MediaPlayerManager.EVENT_UPDATE_MEDIA_PLAYER_PROGRESS),
            object: nil,
            userInfo: [MediaPlayerManager.NOTIFICATION_PARAMS_DEFAULT_KEY: currentPositionInMilliseconds as Any]
        )
    }
    
    func notifyOnPlaybackSpeedChanged() {
        NotificationCenter.default.post(
            name: Notification.Name(MediaPlayerManager.EVENT_ON_PLAYBACK_SPEED_CHANGED),
            object: nil,
            userInfo: [MediaPlayerManager.NOTIFICATION_PARAMS_DEFAULT_KEY: playbackSpeed as Any]
        )
    }
    
    func notifyOnPlaybackCompleted() {
        NotificationCenter.default.post(
            name: Notification.Name(MediaPlayerManager.EVENT_ON_PLAYBACK_COMPLETED),
            object: nil,
            userInfo: [MediaPlayerManager.NOTIFICATION_PARAMS_DEFAULT_KEY: currentEpisode as Any]
        )
    }
    
    func notifyOnPlaybackError(_ error: String) {
        NotificationCenter.default.post(
            name: Notification.Name(MediaPlayerManager.EVENT_ON_PLAYBACK_ERROR),
            object: nil,
            userInfo: [MediaPlayerManager.NOTIFICATION_PARAMS_DEFAULT_KEY: error]
        )
    }
}
