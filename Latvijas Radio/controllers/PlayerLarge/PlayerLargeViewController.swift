//
//  PlayerLargeViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit
import MediaPlayer
import SDWebImage
import MessageUI

class PlayerLargeViewController: UIViewController {
    
    static var TAG = String(describing: PlayerLargeViewController.classForCoder())
    
    @IBOutlet weak var containerNotification: UIView!
    @IBOutlet weak var containerSharingPanel: UIView!
    @IBOutlet weak var containerSharingPanelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerSendMessagePanel: UIView!
    @IBOutlet weak var containerSendMessagePanelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerCurrentMediaOptionsPanel: UIView!
    @IBOutlet weak var containerCurrentMediaOptionsPanelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var buttonShare: UIButtonGenericWithCustomBackground!
    @IBOutlet weak var buttonSendMessage: UIButtonGenericWithCustomBackground!
    @IBOutlet weak var wrapperMediaImage: UIView!
    @IBOutlet weak var imageMedia: UIImageView!
    @IBOutlet weak var imageChannel: UIImageView!
    @IBOutlet weak var textCategory: UILabelLabel5!
    @IBOutlet weak var textTitle: UILabel!
    @IBOutlet weak var wrapperButtonDownload: UIView!
    @IBOutlet weak var buttonDownload: UIButtonGenericWithImage!
    @IBOutlet weak var downloadProgress: CustomProgressView!
    @IBOutlet weak var wrapperButtonPlaybackStepForward: UIView!
    @IBOutlet weak var buttonPlaybackStepBackward: UIButtonGenericWithCustomBackground!
    @IBOutlet weak var buttonGoToPrevMedia: UIButtonGenericWithImage!
    @IBOutlet weak var buttonTogglePlayback: UIButtonGenericWithImage!
    @IBOutlet weak var buttonPlaybackStepForward: UIButtonGenericWithCustomBackground!
    @IBOutlet weak var buttonGoToNextMedia: UIButtonGenericWithImage!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var wrapperTimelineControl: UIView!
    @IBOutlet weak var sliderTimeline: UISliderWithHandle!
    @IBOutlet weak var textElapsedDuration: UILabelBase!
    @IBOutlet weak var textTotalDuration: UILabelLabel6!
    @IBOutlet weak var buttonSubscribe: UIButtonGenericWithImage!
    @IBOutlet weak var buttonUnsubscribe: UIButtonGenericWithImage!
    @IBOutlet weak var activityIndicatorSubscription: UIActivityIndicatorView!
    @IBOutlet weak var buttonMenu: UIButtonGenericWithImage!
    
    weak var notificationViewController: NotificationViewController!
    weak var sharingPanelViewController: SharingPanelViewController!
    weak var sendMessagePanelViewController: SendMessagePanelViewController!
    weak var currentMediaOptionsPanelViewController: CurrentMediaOptionsPanelViewController!
    
    var playerLargeViewControllerButtonDownloadHelper: PlayerLargeViewControllerButtonDownloadHelper!
    private var currentLivestreamPhoneNumber: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(PlayerLargeViewController.TAG, "viewDidLoad")
        
        // variables
        playerLargeViewControllerButtonDownloadHelper = PlayerLargeViewControllerButtonDownloadHelper()
        playerLargeViewControllerButtonDownloadHelper.viewController = self
        
        // listeners
        buttonBack.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonShare.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonSendMessage.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonGoToPrevMedia.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonGoToNextMedia.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonDownload.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonTogglePlayback.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonSubscribe.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonUnsubscribe.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonMenu.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        
        setupMediaPlayerListeners()
        
        setupSliderTimeline()
        
        setupButtonPlaybackStepBackward()
        setupButtonPlaybackStepForward()

        // UI
        wrapperMediaImage.layer.cornerRadius = 100
        
        MediaPlayerManager.getInstance().triggerAllPlayersUiSetupOrUpdate()
        
        updateViewWithMediaData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch(segue.identifier ?? "") {
        case StoryboardsHelper.SEGUE_EMBED_NOTIFICATION:
            self.notificationViewController = (segue.destination as! NotificationViewController)
            self.notificationViewController.setContainerView(containerNotification)
            
            break
        case StoryboardsHelper.SEGUE_EMBED_SHARING_PANEL:
            self.sharingPanelViewController = (segue.destination as! SharingPanelViewController)
            self.sharingPanelViewController.setContainerView(containerSharingPanel)
            self.sharingPanelViewController.setContainerBottomConstraintReference(containerSharingPanelBottomConstraint)

            break
        case StoryboardsHelper.SEGUE_EMBED_SEND_MESSAGE_PANEL:
            self.sendMessagePanelViewController = (segue.destination as! SendMessagePanelViewController)
            self.sendMessagePanelViewController.setContainerView(containerSendMessagePanel)
            self.sendMessagePanelViewController.setContainerBottomConstraintReference(containerSendMessagePanelBottomConstraint)
            self.sendMessagePanelViewController.notificationViewController = notificationViewController

            break
        case StoryboardsHelper.SEGUE_EMBED_CURRENT_MEDIA_OPTIONS_PANEL:
            self.currentMediaOptionsPanelViewController = (segue.destination as! CurrentMediaOptionsPanelViewController)
            self.currentMediaOptionsPanelViewController.setContainerView(containerCurrentMediaOptionsPanel)
            self.currentMediaOptionsPanelViewController.setContainerBottomConstraintReference(containerCurrentMediaOptionsPanelBottomConstraint)

            break
        default:
            break
        }
    }

    deinit {
        GeneralUtils.log(PlayerLargeViewController.TAG, "deinit")
    }
    
    // MARK: Custom
    
    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonBack) {
            navigationController?.popViewController(animated: true)
        }
        if (sender == buttonShare) {
            sharingPanelViewController.togglePanel()
            
            if (sendMessagePanelViewController.isOpened) {
                sendMessagePanelViewController.closePanel()
            }
            
            if (currentMediaOptionsPanelViewController.isOpened) {
                currentMediaOptionsPanelViewController.closePanel()
            }
        }
        if (sender == buttonSendMessage) {
            if (MediaPlayerManager.getInstance().currentEpisode != nil) {
                sendMessagePanelViewController.togglePanel()
                
                if (sharingPanelViewController.isOpened) {
                    sharingPanelViewController.closePanel()
                }
                
                if (currentMediaOptionsPanelViewController.isOpened) {
                    currentMediaOptionsPanelViewController.closePanel()
                }
            } else {
                if (MFMessageComposeViewController.canSendText()) {
                    let controller = MFMessageComposeViewController()
                    controller.recipients = [currentLivestreamPhoneNumber!]
                    controller.messageComposeDelegate = self
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
        if (sender == buttonGoToPrevMedia) {
            playPreviousMedia()
            
            if (sharingPanelViewController.isOpened) {
                sharingPanelViewController.closePanel()
            }
            
            if (sendMessagePanelViewController.isOpened) {
                sendMessagePanelViewController.closePanel()
            }
            
            if (currentMediaOptionsPanelViewController.isOpened) {
                currentMediaOptionsPanelViewController.closePanel()
            }
        }
        if (sender == buttonGoToNextMedia) {
            playNextMedia()
            
            if (sharingPanelViewController.isOpened) {
                sharingPanelViewController.closePanel()
            }
            
            if (sendMessagePanelViewController.isOpened) {
                sendMessagePanelViewController.closePanel()
            }
            
            if (currentMediaOptionsPanelViewController.isOpened) {
                currentMediaOptionsPanelViewController.closePanel()
            }
        }
        if (sender == buttonDownload) {
            playerLargeViewControllerButtonDownloadHelper.initDownloadOfEpisodeMediaFile()
        }
        if (sender == buttonTogglePlayback) {
            startOrTogglePlayback()
        }
        if (sender == buttonSubscribe) {
            performRequestSetEpisodeSubscriptionStatus(subscribed: true)
        }
        if (sender == buttonUnsubscribe) {
            performRequestSetEpisodeSubscriptionStatus(subscribed: false)
        }
        if (sender == buttonMenu) {
            currentMediaOptionsPanelViewController.togglePanel()
            
            if (sharingPanelViewController.isOpened) {
                sharingPanelViewController.closePanel()
            }
            
            if (sendMessagePanelViewController.isOpened) {
                sendMessagePanelViewController.closePanel()
            }
        }
    }

    func setupMediaPlayerListeners() {
        NotificationCenter.default.addObserver(forName: Notification.Name(MediaPlayerManager.EVENT_DATA_SOURCE_CHANGED), object: nil, queue: .main) { [weak self] notification in
            GeneralUtils.log(PlayerLargeViewController.TAG, "EVENT_DATA_SOURCE_CHANGED")

            if (self != nil) {
                // update playback step button
                var enableButtons = false

                if (MediaPlayerManager.getInstance().isMediaPlayerPrepared) {
                    if (MediaPlayerManager.getInstance().currentEpisode != nil) {
                        enableButtons = true
                    }
                }
                
                if (enableButtons) {
                    self?.enablePlaybackStepButtons()
                } else {
                    self?.disablePlaybackStepButtons()
                }
                
                self?.updateViewWithMediaData()
                
                if let currentEpisode = MediaPlayerManager.getInstance().currentEpisode {
                    self?.sharingPanelViewController.setEpisodeModel(currentEpisode)
                    self?.sendMessagePanelViewController.setEpisodeModel(currentEpisode)
                }
                
                if let currentLivestream = MediaPlayerManager.getInstance().currentLivestream {
                    self?.sharingPanelViewController.setLivestreamModel(currentLivestream)
                    self?.sendMessagePanelViewController.setEpisodeModel(nil)
                }
                
                self?.sharingPanelViewController.updateSharingPanel()
                self?.sendMessagePanelViewController.updateSendMessagePanel()
                self?.currentMediaOptionsPanelViewController.updateCurrentMediaOptionsPanel()
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name(MediaPlayerManager.EVENT_MEDIA_PLAYER_PREPARED), object: nil, queue: .main) { [weak self] notification in
            GeneralUtils.log(PlayerLargeViewController.TAG, "EVENT_MEDIA_PLAYER_PREPARED")
            
            if (MediaPlayerManager.getInstance().currentEpisode != nil) {
                self?.enablePlaybackStepButtons()
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name(MediaPlayerManager.EVENT_UPDATE_MEDIA_PLAYER_STATE), object: nil, queue: .main) { [weak self] notification in
            GeneralUtils.log(PlayerLargeViewController.TAG, "EVENT_UPDATE_MEDIA_PLAYER_STATE")
            
            if let data = notification.userInfo as NSDictionary? {
                let mediaPlayerState = data[MediaPlayerManager.NOTIFICATION_PARAMS_DEFAULT_KEY] as! String

                self?.updateMediaPlayerState(mediaPlayerState)
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name(MediaPlayerManager.EVENT_UPDATE_MEDIA_PLAYER_PROGRESS), object: nil, queue: .main) { [weak self] notification in
            GeneralUtils.log(PlayerLargeViewController.TAG, "EVENT_UPDATE_MEDIA_PLAYER_PROGRESS")
            
            if let self = self {
                if (MediaPlayerManager.getInstance().currentEpisode != nil) {
                    if let data = notification.userInfo as NSDictionary? {
                        let positionInMillis = data[MediaPlayerManager.NOTIFICATION_PARAMS_DEFAULT_KEY] as! Double
                        let positionInSeconds = Int(positionInMillis / 1000)

                        var userCurrentlyInteractingWithSlider = false
                        
                        if let userCurrentlyInteractingWithSliderValue = self.sliderTimeline.layer.value(forKey: "USER_CURRENTLY_INTERACTING_WITH_SLIDER") as? Bool {
                            userCurrentlyInteractingWithSlider = userCurrentlyInteractingWithSliderValue
                        }
                        
                        if (!userCurrentlyInteractingWithSlider) {
                            self.sliderTimeline.value = Float(positionInSeconds)
                            
                            let formattedTimelineDuration = DateUtils.getTimelineFromSeconds(positionInSeconds)
                            self.textElapsedDuration.setText(formattedTimelineDuration)
                        }
                    }
                }
            }
        }

        NotificationCenter.default.addObserver(forName: Notification.Name(MediaPlayerManager.EVENT_ON_PLAYBACK_ERROR), object: nil, queue: .main) { [weak self] notification in
            GeneralUtils.log(PlayerLargeViewController.TAG, "EVENT_ON_PLAYBACK_ERROR")

            if (self != nil) {
                if let data = notification.userInfo as NSDictionary? {
                    let errorString = data[MediaPlayerManager.NOTIFICATION_PARAMS_DEFAULT_KEY] as! String

                    Toast.show(message: errorString, controller: self!)
                    
                    self?.updateMediaPlayerState(MediaPlayerManager.MEDIA_PLAYER_STATE_PAUSED)
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name(MediaPlayerManagerMQTTClient.EVENT_ON_MQTT_NEW_INFORMATION_RECEIVED), object: nil, queue: .main) { [weak self] notification in
            GeneralUtils.log(PlayerLargeViewController.TAG, "EVENT_ON_MQTT_NEW_INFORMATION_RECEIVED")

            self?.updateTitle()
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name(LivestreamInfoPoller.EVENT_ON_LIVESTREAM_PROGRAMS_UDPATED), object: nil, queue: .main) { [weak self] notification in
            GeneralUtils.log(PlayerLargeViewController.TAG, "EVENT_ON_BROADCAST_PROGRAMS_UDPATED")

            self?.updateTitle()
        }
    }
    
    func setViewStateSubscriptionStatusNotSubscribed() {
        buttonSubscribe.isHidden = false
        buttonUnsubscribe.isHidden = true
        activityIndicatorSubscription.isHidden = true
        
        buttonUnsubscribe.tintColor = UIColor(named: ColorsHelper.BLACK)
    }
    
    func setViewStateSubscriptionStatusSubscribed() {
        buttonSubscribe.isHidden = true
        buttonUnsubscribe.isHidden = false
        activityIndicatorSubscription.isHidden = true
        
        buttonUnsubscribe.tintColor = UIColor(named: ColorsHelper.RED)
    }
    
    func setViewStateSubscriptionStatusLoading() {
        buttonSubscribe.isHidden = true
        buttonUnsubscribe.isHidden = true
        activityIndicatorSubscription.isHidden = false
    }
    
    func setViewStateSubscriptionStatusDisabled() {
        buttonSubscribe.isHidden = true
        buttonUnsubscribe.isHidden = true
        activityIndicatorSubscription.isHidden = true
    }

    func setupSliderTimeline() {
        sliderTimeline.minimumValue = 0
        sliderTimeline.addTarget(self, action: #selector(onSliderTimelineValueChanged(slider:event:)), for: .valueChanged)
    }
    
    @objc func onSliderTimelineValueChanged(slider: UISlider, event: UIEvent) {
        // perform snapping
        let timelineStep: Float = 1.0 / slider.maximumValue
        let roundedValue = round(slider.value / timelineStep) * timelineStep

        slider.value = roundedValue

        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began, .moved:
                sliderTimeline.layer.setValue(true, forKey: "USER_CURRENTLY_INTERACTING_WITH_SLIDER")
                
                let newValueOfSeconds = Int(slider.value)
                
                let formattedTimelineDuration = DateUtils.getTimelineFromSeconds(newValueOfSeconds)
                
                textElapsedDuration.setText(formattedTimelineDuration)
                
                break
            case .ended:
                sliderTimeline.layer.setValue(false, forKey: "USER_CURRENTLY_INTERACTING_WITH_SLIDER")
                
                let newValueOfSeconds = Int(slider.value)

                let positionInSecondsToSeekTo = newValueOfSeconds
                let positionInMillisecondsToSeekTo = Double(positionInSecondsToSeekTo * 1000)

                if (MediaPlayerManager.getInstance().currentEpisode != nil) {
                    MediaPlayerManager.getInstance().performActionSeekMedia(positionInMillisecondsToSeekTo)
                }

                break
            default:
                break
            }
        }
    }

    func setupButtonPlaybackStepBackward() {
        buttonPlaybackStepBackward.addTarget(self, action: #selector(buttonPlaybackStepTouchDownHandler), for: .touchDown)
        buttonPlaybackStepBackward.addTarget(self, action: #selector(buttonPlaybackStepTouchCancelHandler), for: [.touchUpInside, .touchCancel, .touchDragOutside])
    }
    
    func setupButtonPlaybackStepForward() {
        buttonPlaybackStepForward.addTarget(self, action: #selector(buttonPlaybackStepTouchDownHandler), for: .touchDown)
        buttonPlaybackStepForward.addTarget(self, action: #selector(buttonPlaybackStepTouchCancelHandler), for: [.touchUpInside, .touchCancel, .touchDragOutside])
    }
    
    @objc func buttonPlaybackStepTouchDownHandler(_ sender: UIView) {
        if (sender == buttonPlaybackStepBackward) {
            MediaPlayerManager.getInstance().startSteppingProcedure(forward: false)
        }
        if (sender == buttonPlaybackStepForward) {
            MediaPlayerManager.getInstance().startSteppingProcedure(forward: true)
        }
    }
    
    @objc func buttonPlaybackStepTouchCancelHandler(_ sender: UIView) {
        MediaPlayerManager.getInstance().stopSteppingProcedure()
    }
    
    func updateViewWithMediaData() {
        var colorId = ButtonTogglePlaybackHelper.TOGGLE_PLAYBACK_BUTTON_STATE_ACTIVE_DEFAULT_TINT
        
        // Update playback controls.
        buttonGoToPrevMedia.isHidden = false
        buttonGoToNextMedia.isHidden = false
        
        // Update send message button.
        buttonSendMessage.setVisibility(UIView.VISIBILITY_VISIBLE)
        
        // Update subscribe buttons.
        setViewStateSubscriptionStatusDisabled()

        if let currentEpisode = MediaPlayerManager.getInstance().currentEpisode {
            // Update playback controls.
            buttonGoToPrevMedia.isHidden = true
            
            if (MediaPlayerManager.getInstance().listOfEpisodes == nil) {
                buttonGoToNextMedia.isHidden = true
            }
            
            buttonPlaybackStepBackward.isHidden = false
            wrapperButtonPlaybackStepForward.isHidden = false
            
            // update image
            let transformer = SDImageResizingTransformer(
                size: CGSize(
                    width: GeneralUtils.dpToPixels(CGFloat(200)),
                    height: GeneralUtils.dpToPixels(CGFloat(200))),
                scaleMode: .aspectFill
            )
            
            imageMedia.sd_setImage(
                with: URL(string: currentEpisode.getImageUrl()),
                placeholderImage: nil,
                context: [.imageTransformer: transformer]
            )
            
            // Update elapsed duration by looking for media record.
            var elapsedSeconds = 0
            
            if let episodePlayedTimeInMilliseconds = MediaPlayerManagerMediaPlaybackStateRecorder.getSpecificEpisodePlayedTime(currentEpisode.getId()) {
                elapsedSeconds = Int(episodePlayedTimeInMilliseconds / 1000)
            }
            
            let formattedTimelineDuration = DateUtils.getTimelineFromSeconds(elapsedSeconds)
            textElapsedDuration.setText(formattedTimelineDuration)
            
            // Update total duration.
            // Timeline seekable positions are the same as duration in seconds (ms would give too many positions).
            let totalDurationInSeconds = currentEpisode.getMediaDurationInSeconds()
            
            let formattedTimelineTotalDuration = DateUtils.getTimelineFromSeconds(totalDurationInSeconds)
            textTotalDuration.setText(formattedTimelineTotalDuration)

            // update slider progress & max value
            // It is important to set max value BEFORE progress.
            sliderTimeline.maximumValue = Float(totalDurationInSeconds)
            sliderTimeline.value = Float(elapsedSeconds)
            
            wrapperTimelineControl.setVisibility(UIView.VISIBILITY_VISIBLE)

            // update channel image
            let channelId = currentEpisode.getChannelId()
            if let imageDrawableId = ChannelsHelper.getImageDrawableIdFromChannelId(channelId) {
                imageChannel.image = UIImage(named: imageDrawableId)
            }
            
            // category name
            let categoryName = "#" + currentEpisode.getBroadcastName()
            textCategory.setText(categoryName)
            
            // title
            let title = currentEpisode.getTitle()
            textTitle.text = title
            
            // Update subscribe buttons.
            if (UserSubscribedEpisodesManager.getInstance().isUserSubscribedToEpisode(currentEpisode)) {
                setViewStateSubscriptionStatusSubscribed()
            } else {
                setViewStateSubscriptionStatusNotSubscribed()
            }
            
            // update some colors to match channel theme
            if (ChannelsHelper.isChannelIdClassic(channelId)) {
                if let channelColorId = ChannelsHelper.getColorIdFromChannelId(channelId) {
                    colorId = channelColorId
                    //hexStringToUIColor(hex: dataset[indexPath.row].getColor()!)
                }
            }
            
            playerLargeViewControllerButtonDownloadHelper.setupEpisodeDownloadButton(currentEpisode)
        }
        
        if let currentLivestream = MediaPlayerManager.getInstance().currentLivestream {
            // Update playback controls.
            if (MediaPlayerManager.getInstance().listOfLivestreams == nil) {
                buttonGoToPrevMedia.isHidden = true
                buttonGoToNextMedia.isHidden = true
            }
            
            buttonPlaybackStepBackward.isHidden = true
            wrapperButtonPlaybackStepForward.isHidden = true
            
            // update image
//            var largeArtworkImageResourceId = currentLivestream.getWideImageResourceId()
//
//            if let largeArtwork = currentLivestream.getLargeArtworkImageResourceId() {
//                largeArtworkImageResourceId = largeArtwork
//            }
            
//            imageMedia.image = UIImage(named: largeArtworkImageResourceId)
            if (currentLivestream.image != nil) {
                imageMedia.sd_setImage(with: URL(string: currentLivestream.image ?? ""))
            } else {
                imageMedia.image = nil
            }

            // Update duration.
            wrapperTimelineControl.setVisibility(UIView.VISIBILITY_GONE)
            
            // update channel image
//            let imageResourceId = currentLivestream.getImageResourceId()
//            imageChannel.image = UIImage(named: imageResourceId)
            if (currentLivestream.image != nil) {
                imageChannel.sd_setImage(with: URL(string: currentLivestream.image ?? ""))
            } else {
                imageChannel.image = nil
            }

            // category name
            let categoryName = currentLivestream.name // getName()
            textCategory.setText(categoryName)
            
            // title
            updateTitle()
            
            // update some colors to match channel theme
            //if (currentLivestream.getType() == LivestreamsManager.TYPE_CLASSIC) {
//                if let channelColorId = ChannelsHelper.getColorIdFromChannelId(currentLivestream.getId()) {
            colorId = currentLivestream.color!
                    //hexStringToUIColor(hex: dataset[indexPath.row].getColor()!)
                    //channelColorId
//                }
            //}

            playerLargeViewControllerButtonDownloadHelper.setupEpisodeDownloadButton(nil)
            
            // If there is associated phone number from setting, then allow user to send sms to it.
            currentLivestreamPhoneNumber = nil
            buttonSendMessage.setVisibility(UIView.VISIBILITY_GONE)
            
            if let settingsFromApi = GeneralUtils.getUserDefaults().object(forKey: AuthenticationViewController.SETTINGS_FROM_API) as? String {
                if let settingsFromApiAsData = settingsFromApi.data(using: .utf8) {
                    let settingsFromApiJson = try? JSONSerialization.jsonObject(with: settingsFromApiAsData, options: [])
                    if let settingsFromApiJson = settingsFromApiJson as? [String: Any] {
                        if let livestreamsContactInfo = settingsFromApiJson[SettingsRequest.RESPONSE_PARAM_LIVESTREAMS_CONTACT_INFO] as? [String: Any] {
                            let livestreamId = MediaPlayerManager.getInstance().currentLivestream!.id // getId()
                            let key = "lr" + String(describing: livestreamId)

                            if let currentLiveStreamPhoneNumberJson = livestreamsContactInfo[key] as? [String: Any] {
                                if let currentLivestreamPhoneNumberValue = currentLiveStreamPhoneNumberJson[SettingsRequest.RESPONSE_PARAM_PHONE_NUMBER] as? String {
                                    currentLivestreamPhoneNumber = currentLivestreamPhoneNumberValue
                                    buttonSendMessage.setVisibility(UIView.VISIBILITY_VISIBLE)
                                }
                            }
                        }
                    }
                }
            }
        }

        // update volume slider color
        sliderTimeline.minimumTrackTintColor = .red //hexStringToUIColor(hex: colorId)
        //UIColor(named: colorId)
        //sliderTimeline.thumbColor = hexStringToUIColor(hex: colorId) //UIColor(named: colorId)!
    }
    
    func startOrTogglePlayback() {
        MediaPlayerManager.getInstance().performActionToggleMediaPlayback()
    }
    
    func playPreviousMedia() {
        if let episodeModel = MediaPlayerManager.getInstance().getPreviousEpisode() {
            playEpisode(episodeModel)
        }
        
        if let livestreamModel = MediaPlayerManager.getInstance().getPreviousLivestream() {
            playLivestream(livestreamModel)
        }
    }
    
    func playNextMedia() {
        if let episodeModel = MediaPlayerManager.getInstance().getNextEpisode() {
            playEpisode(episodeModel)
        }
        
        if let livestreamModel = MediaPlayerManager.getInstance().getNextLivestream() {
            playLivestream(livestreamModel)
        }
    }
    
    func playEpisode(_ episodeModel: EpisodeModel) {
        MediaPlayerManager.getInstance().performActionLoadAndPlayEpisode(MediaPlayerManager.PLAYBACK_TYPE_LOCAL_THEN_STREAM, episodeModel, MediaPlayerManager.getInstance().listOfEpisodes)
    }
    
    func playLivestream(_ livestreamModel: /*LivestreamModel*/ RadioChannel) {
        MediaPlayerManager.getInstance().performActionLoadAndPlayLivestream(MediaPlayerManager.PLAYBACK_TYPE_LOCAL_THEN_STREAM, livestreamModel, MediaPlayerManager.getInstance().listOfLivestreams)
    }
    
    func updateMediaPlayerState(_ mediaPlayerState: String) {
        var validStateForTinting = false
        var validChannelTypeForTinting = false
        var image: UIImage!
        
        switch (mediaPlayerState) {
        case MediaPlayerManager.MEDIA_PLAYER_STATE_PLAYING:

            image = UIImage(named: ImagesHelper.IC_PAUSE_EXTRUDED)
            activityIndicator.setVisibility(UIView.VISIBILITY_GONE)
            
            validStateForTinting = true
            
            break
        case MediaPlayerManager.MEDIA_PLAYER_STATE_PAUSED:
            
            image = UIImage(named: ImagesHelper.IC_PLAY_EXTRUDED)
            activityIndicator.setVisibility(UIView.VISIBILITY_GONE)
            
            break
        case MediaPlayerManager.MEDIA_PLAYER_STATE_PLAYING_AND_SEEKING:

            image = UIImage(named: ImagesHelper.IC_PAUSE_EXTRUDED)
            activityIndicator.setVisibility(UIView.VISIBILITY_VISIBLE)
            
            validStateForTinting = true
            
            break
        default:
            break
        }
        
        let currentEpisode = MediaPlayerManager.getInstance().currentEpisode
        if (currentEpisode != nil && ChannelsHelper.isChannelIdClassic(currentEpisode!.getChannelId())) {
            validChannelTypeForTinting = true
        }
        
        let currentLivestream = MediaPlayerManager.getInstance().currentLivestream
//        if (currentLivestream != nil && currentLivestream!.getType() == LivestreamsManager.TYPE_CLASSIC) {
            validChannelTypeForTinting = true
//        }
        
//        ButtonTogglePlaybackHelper.setTint(buttonTogglePlayback, validStateForTinting, validChannelTypeForTinting)
        if let colorId = currentLivestream?.color as? String {
//            cell.buttonTogglePlayback.tintColor = hexStringToUIColor(hex: colorId)
            ButtonTogglePlaybackHelper.setTint(buttonTogglePlayback, validStateForTinting, validChannelTypeForTinting, colorId)
        }

        buttonTogglePlayback.setImage(image, for: .normal)
    }
    
    func enablePlaybackStepButtons() {
        buttonPlaybackStepBackward.isEnabled = true
        buttonPlaybackStepForward.isEnabled = true
    }
    
    func disablePlaybackStepButtons() {
        buttonPlaybackStepBackward.isEnabled = false
        buttonPlaybackStepForward.isEnabled = false
    }
    
    func updateTitle() {
        if let currentLivestream = MediaPlayerManager.getInstance().currentLivestream {
            // By default, it is the moto of livestream.
            var finalLivestreamTitle = currentLivestream.name //getTitle()

            // Check for broadcast title
            var broadcastTitle = LivestreamInfoPoller.getLivestreamBroadcastTitleWithLivestreamId(String(describing:  currentLivestream.id) /*getId()*/)
            if (broadcastTitle != nil) {
                broadcastTitle = broadcastTitle!.uppercased()
            }
            
            // Check for artist and song name.
            var artistAndSongTitle: String?
            if (MediaPlayerManagerMQTTClient.canShowAdditionalPlaybackInfo()) {
                artistAndSongTitle = MediaPlayerManagerMQTTClient.getPlaybackAdditionalDataFromPayload(MediaPlayerManagerMQTTClient.lastKnownReceivedPayload)
            }

            if (broadcastTitle != nil && artistAndSongTitle != nil) {
                finalLivestreamTitle = broadcastTitle! + "\n" + artistAndSongTitle!
            } else {
                if (broadcastTitle != nil) {
                    finalLivestreamTitle = broadcastTitle!
                }
                
                if (artistAndSongTitle != nil) {
                    finalLivestreamTitle = artistAndSongTitle!
                }
            }

            textTitle.text = finalLivestreamTitle
        }
    }
    
    func performRequestSetEpisodeSubscriptionStatus(subscribed: Bool) {
        if let currentEpisode = MediaPlayerManager.getInstance().currentEpisode {
            setViewStateSubscriptionStatusLoading()
            
            UserSubscribedEpisodesManager.getInstance().performRequestSetEpisodeSubscriptionStatus(currentEpisode, subscribed, { [weak self] in
                SubscribedEpisodesViewController.subscribedEpisodesListNeedsUpdate = true

                if (subscribed) {
                    self?.setViewStateSubscriptionStatusSubscribed()
                } else {
                    self?.setViewStateSubscriptionStatusNotSubscribed()
                }
            })
        }
    }
}

extension PlayerLargeViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
}
