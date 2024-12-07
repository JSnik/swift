//
//  PlayerMiniViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class PlayerMiniViewController: UIViewController {
    
    static var TAG = String(describing: PlayerMiniViewController.classForCoder())

    @IBOutlet weak var buttonPlayerLarge: UIButtonPlayerMini!
    @IBOutlet weak var wrapperPlayerMini: UIView!
    @IBOutlet weak var sliderTimeline: UISliderBase!
    @IBOutlet weak var imageChannel: UIImageView!
    @IBOutlet weak var textTitlePrimary: UILabelLabel5!
    @IBOutlet weak var textTitleSecondary: UILabelLabel2!
    @IBOutlet weak var buttonTogglePlayback: UIButtonGenericWithImage!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var containerPlayerMini: UIView!
    var containerPlayerMiniBottomConstraint: NSLayoutConstraint!
    var containerPlayerMiniBottomConstraintOriginalConstant: CGFloat!
    var isOpened = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(PlayerMiniViewController.TAG, "viewDidLoad")
        
        // listeners
        buttonPlayerLarge.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonTogglePlayback.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        
        setupMediaPlayerListeners()
        
        // UI
        view.translatesAutoresizingMaskIntoConstraints = false

        setupSliderTimeline()
    }

    deinit {
        GeneralUtils.log(PlayerMiniViewController.TAG, "deinit")
    }
    
    // MARK: Custom
    
    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonPlayerLarge) {
            if (MediaPlayerManager.getInstance().currentEpisode?.getNewsBlocks().count ?? 0 > 0 ) || (MediaPlayerManager.getInstance().listOfLivestreams?.count ?? 0 > 0 ) {
                let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_PLAYER_LARGE, bundle: nil)
                                        .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_PLAYER_LARGE) as! PlayerLargeViewController)

                navigationController?.pushViewController(viewController, animated: true)
            }
        }
        if (sender == buttonTogglePlayback) {
            MediaPlayerManager.getInstance().performActionToggleMediaPlayback()
        }
    }
    
    func setContainerView(_ containerPlayerMini: UIView) {
        self.containerPlayerMini = containerPlayerMini
    }
    
    func setContainerBottomConstraintReference(_ containerPlayerMiniBottomConstraint: NSLayoutConstraint) {
        self.containerPlayerMiniBottomConstraint = containerPlayerMiniBottomConstraint
        
        containerPlayerMiniBottomConstraintOriginalConstant = containerPlayerMiniBottomConstraint.constant
    }
    
    func openPanel() {
        isOpened = true
        
        // Since panel can be opened in view controlled that has just launched,
        // it might not have finished laying out its layout,
        // meaning there would be wrong initial sizes and positions for animation.
        // So, force layout.

        // Run on UI thread to avoid iOS bug:
        // https://stackoverflow.com/questions/20004310/invalid-parameter-exception-thrown-by-uiqueuingscrollview/20973822#20973822
        DispatchQueue.main.async { [weak self] in
            if (self != nil) {
                self!.containerPlayerMini.superview!.layoutIfNeeded()
                
                // setup constraints
                var constraintHeight: NSLayoutConstraint!
                
                for constraint in self!.wrapperPlayerMini.constraints {
                    if (constraint.firstAttribute == .height) {
                        constraintHeight = constraint
                    }
                }
                
                let height = constraintHeight.constant

                UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
                    let newConstant = self!.containerPlayerMiniBottomConstraintOriginalConstant + CGFloat(height)

                    self!.containerPlayerMiniBottomConstraint.constant = newConstant

                    self!.containerPlayerMini.superview!.setNeedsLayout()
                    self!.containerPlayerMini.superview!.layoutIfNeeded()
                })
            }
        }

//        // leaving for reference:
//        // translating Y value:
//
//        containerPlayerMini.transform = CGAffineTransform.identity
//
//        UIView.animate(withDuration: 0.3, animations: {
//            self.containerPlayerMini.transform = self.containerPlayerMini.transform.translatedBy(x: 0.0, y: -self.wrapperPlayerMini.frame.size.height)
//        })
    }
    
    func closePanel() {
        isOpened = false

        UIView.animate(withDuration: 0.3, animations: {
            self.containerPlayerMiniBottomConstraint.constant = self.containerPlayerMiniBottomConstraintOriginalConstant
            self.containerPlayerMini.superview!.layoutIfNeeded()
        })
    }
    
    func setupMediaPlayerListeners() {
        NotificationCenter.default.addObserver(forName: Notification.Name(MediaPlayerManager.EVENT_DATA_SOURCE_CHANGED), object: nil, queue: .main) { [weak self] notification in
            GeneralUtils.log(PlayerMiniViewController.TAG, "EVENT_DATA_SOURCE_CHANGED")

            if (self != nil) {
                if (MediaPlayerManager.getInstance().currentEpisode != nil) {
                    let episodeModel = MediaPlayerManager.getInstance().currentEpisode
                    let broadcastName = episodeModel!.getBroadcastName()
                    let episodeName = episodeModel!.getTitle()
                    let mediaDurationInSeconds = episodeModel!.getMediaDurationInSeconds()
                    
                    let channelId = episodeModel!.getChannelId()
                    let imageDrawableId = ChannelsHelper.getImageDrawableIdFromChannelId(channelId)
                    if (imageDrawableId != nil) {
                        self?.imageChannel.image = UIImage(named: imageDrawableId!)
                    }
                    
                    self?.textTitlePrimary.setText(broadcastName)
                    self?.textTitleSecondary.setText(episodeName)
                    self?.sliderTimeline.maximumValue = Float(mediaDurationInSeconds)
                }
                
                if (MediaPlayerManager.getInstance().currentLivestream != nil) {
                    let livestreamModel = MediaPlayerManager.getInstance().currentLivestream
//                    let imageResourceId = livestreamModel!.getImageResourceId()
                    let livestreamName = livestreamModel!.name // getName()

//                    self?.imageChannel.image = UIImage(named: imageResourceId)
                    let imageResourceId = livestreamModel!.image
                    self?.imageChannel.sd_setImage(with: URL(string: imageResourceId ?? ""))
                    self?.textTitlePrimary.setText(livestreamName)
                    self?.sliderTimeline.maximumValue = Float(1)
                    self?.sliderTimeline.value = Float(0)
                    
                    self?.updateTitle()
                }

                if (self!.isOpened == false) {
                    self?.openPanel()
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name(MediaPlayerManager.EVENT_UPDATE_MEDIA_PLAYER_STATE), object: nil, queue: .main) { [weak self] notification in
            GeneralUtils.log(PlayerMiniViewController.TAG, "EVENT_UPDATE_MEDIA_PLAYER_STATE")
            
            if (self != nil) {
                if (self!.isOpened) {
                    if let data = notification.userInfo as NSDictionary? {
                        let mediaPlayerState = data[MediaPlayerManager.NOTIFICATION_PARAMS_DEFAULT_KEY] as! String
        
                        self?.updateMediaPlayerState(mediaPlayerState)
                    }
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name(MediaPlayerManager.EVENT_UPDATE_MEDIA_PLAYER_PROGRESS), object: nil, queue: .main) { [weak self] notification in
            GeneralUtils.log(PlayerMiniViewController.TAG, "EVENT_UPDATE_MEDIA_PLAYER_PROGRESS")
            
            if (self != nil) {
                if (self!.isOpened) {
                    if (MediaPlayerManager.getInstance().currentEpisode != nil) {
                        if let data = notification.userInfo as NSDictionary? {
                            let positionInMillis = data[MediaPlayerManager.NOTIFICATION_PARAMS_DEFAULT_KEY] as! Double
            
                            let positionInSeconds: Double = Double(positionInMillis / 1000)

                            self?.sliderTimeline.value = Float(positionInSeconds)
                        }
                    }
                }
            }
        }

        NotificationCenter.default.addObserver(forName: Notification.Name(MediaPlayerManager.EVENT_ON_PLAYBACK_ERROR), object: nil, queue: .main) { [weak self] notification in
            GeneralUtils.log(PlayerMiniViewController.TAG, "EVENT_ON_PLAYBACK_ERROR")

            if (self != nil) {
                if let data = notification.userInfo as NSDictionary? {
                    let errorString = data[MediaPlayerManager.NOTIFICATION_PARAMS_DEFAULT_KEY] as! String

                    Toast.show(message: errorString, controller: self!)
                    
                    self?.updateMediaPlayerState(MediaPlayerManager.MEDIA_PLAYER_STATE_PAUSED)
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name(LivestreamInfoPoller.EVENT_ON_LIVESTREAM_PROGRAMS_UDPATED), object: nil, queue: .main) { [weak self] notification in
            GeneralUtils.log(PlayerMiniViewController.TAG, "EVENT_ON_BROADCAST_PROGRAMS_UDPATED")

            self?.updateTitle()
        }
    }
    
    func setupSliderTimeline() {
        sliderTimeline.setRectangleCorners()
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
        if (currentLivestream != nil /*&& currentLivestream!.getType() == LivestreamsManager.TYPE_CLASSIC*/) {
            validChannelTypeForTinting = true
        }
        if let colorId = ChannelsHelper.getColorIdFromChannelId(currentEpisode?.getChannelId()) {
            ButtonTogglePlaybackHelper.setTint(buttonTogglePlayback, validStateForTinting, validChannelTypeForTinting, colorId)
        }

//        ButtonTogglePlaybackHelper.setTint(buttonTogglePlayback, validStateForTinting, validChannelTypeForTinting)
        if let colorId = currentLivestream?.color as? String {
            ButtonTogglePlaybackHelper.setTint(buttonTogglePlayback, validStateForTinting, validChannelTypeForTinting, colorId)
        }
        if let colorId = currentEpisode?.getColor() as? String {
            ButtonTogglePlaybackHelper.setTint(buttonTogglePlayback, validStateForTinting, validChannelTypeForTinting, colorId)
        }
        buttonTogglePlayback.setImage(image, for: .normal)
    }
    
    func updateTitle() {
        if let currentLivestream = MediaPlayerManager.getInstance().currentLivestream {
            // By default, it is the moto of livestream.
            var finalLivestreamTitle = currentLivestream.name // getTitle()

            // Check for broadcast title
            let broadcastTitle = LivestreamInfoPoller.getLivestreamBroadcastTitleWithLivestreamId(String(describing:  currentLivestream.id) /*getId()*/)
            if (broadcastTitle != nil) {
                finalLivestreamTitle = broadcastTitle!
            }
            
            textTitleSecondary.text = finalLivestreamTitle
        }
    }
}
