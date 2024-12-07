//
//  CoverViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class CoverViewController: UIViewController {
    
    static var TAG = String(describing: CoverViewController.classForCoder())

    @IBOutlet weak var imageCover: UIImageView!
    @IBOutlet weak var wrapperTitles: UIView!
    @IBOutlet weak var buttonTogglePlayback: UIButtonGenericWithImage!
    @IBOutlet weak var textBroadcastName: UILabelLabel5!
    @IBOutlet weak var textEpisodeTitle: UILabelLabel2!
    
    var genericPreviewModel: GenericPreviewModel!
    private var episodeModel: EpisodeModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(CoverViewController.TAG, "viewDidLoad")
        
        // listeners
        // on image
        buttonTogglePlayback.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        
        setupMediaPlayerListeners()
        
        // UI
        updateViewWithMediaData()
        let customFont = UIFont(name: "FuturaPT-Medium", size: 10.0) //UIFont.systemFont(ofSize: 10.0)
        textBroadcastName.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont ?? UIFont.systemFont(ofSize: 10.0))
        textBroadcastName.adjustsFontForContentSizeCategory = true
        let customFont1 = UIFont(name: "FuturaPT-Medium", size: 13.0) //UIFont.systemFont(ofSize: 13.0)
        textEpisodeTitle.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont1 ?? UIFont.systemFont(ofSize: 13.0))
        textEpisodeTitle.adjustsFontForContentSizeCategory = true
    }
    
    deinit {
        GeneralUtils.log(CoverViewController.TAG, "deinit")
    }
    
    // MARK: Custom
    
    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonTogglePlayback) {
            startOrTogglePlayback()
        }
    }

    func setupMediaPlayerListeners() {
        NotificationCenter.default.addObserver(forName: Notification.Name(MediaPlayerManager.EVENT_DATA_SOURCE_CHANGED), object: nil, queue: .main) { [weak self] notification in
            GeneralUtils.log(CoverViewController.TAG, "EVENT_DATA_SOURCE_CHANGED")

            var setMediaPlayerStatePaused = true

            if (MediaPlayerManager.getInstance().currentEpisode != nil) {
                if (self?.episodeModel != nil) {
                    // If currentEpisode is the same as the one represented by this fragment,
                    // then update media player state.
                    // Otherwise set state to paused.
                    if (self?.episodeModel.getId() == MediaPlayerManager.getInstance().currentEpisode!.getId()) {
                        if let data = notification.userInfo as NSDictionary? {
                            let mediaPlayerState = data[MediaPlayerManager.NOTIFICATION_PARAMS_DEFAULT_KEY] as! String

                            self?.updateMediaPlayerState(mediaPlayerState)

                            setMediaPlayerStatePaused = false
                        }
                    }
                }
            }

            if (setMediaPlayerStatePaused) {
                self?.updateMediaPlayerState(MediaPlayerManager.MEDIA_PLAYER_STATE_PAUSED)
            }
        }

        NotificationCenter.default.addObserver(forName: Notification.Name(MediaPlayerManager.EVENT_UPDATE_MEDIA_PLAYER_STATE), object: nil, queue: .main) { [weak self] notification in
            GeneralUtils.log(CoverViewController.TAG, "EVENT_UPDATE_MEDIA_PLAYER_STATE")

            if (MediaPlayerManager.getInstance().currentEpisode != nil) {
                if (self?.episodeModel != nil) {
                    // If currentEpisode is the same as the one represented by this fragment,
                    // then update media player state.
                    // Otherwise set state to paused.
                    if (self?.episodeModel.getId() == MediaPlayerManager.getInstance().currentEpisode!.getId()) {
                        if let data = notification.userInfo as NSDictionary? {
                            let mediaPlayerState = data[MediaPlayerManager.NOTIFICATION_PARAMS_DEFAULT_KEY] as! String

                            self?.updateMediaPlayerState(mediaPlayerState)
                        }
                    }
                }
            }
        }
    }
    
    func updateViewWithMediaData() {
        if (genericPreviewModel.getType() == GenericPreviewModel.TYPE_EPISODE) {
            episodeModel = genericPreviewModel.getEpisodeModel()
        }

        // update image
        var imageUrl: String!

        if (genericPreviewModel.getType() == GenericPreviewModel.TYPE_BROADCAST) {
            let broadcastModel = genericPreviewModel.getBroadcastModel()

            imageUrl = broadcastModel!.getImageUrl()
        } else {
            let episodeModel = genericPreviewModel.getEpisodeModel()

            imageUrl = episodeModel!.getImageUrl()
        }

        imageCover.sd_setImage(with: URL(string: imageUrl))

        // update titles
        if (genericPreviewModel.getType() == GenericPreviewModel.TYPE_EPISODE) {
            let episodeModel = genericPreviewModel.getEpisodeModel()
            let broadcastName = episodeModel!.getBroadcastName()
            let episodeTitle = episodeModel!.getTitle()

            textBroadcastName.setText(broadcastName)
            textEpisodeTitle.setText(episodeTitle)
            textBroadcastName.sizeToFit()
            textEpisodeTitle.sizeToFit()
            wrapperTitles.setVisibility(UIView.VISIBILITY_VISIBLE)
        } else {
            wrapperTitles.setVisibility(UIView.VISIBILITY_GONE)
        }
    }
    
    func startOrTogglePlayback() {
        // determine to start or toggle playback
        var toggleEpisodePlayback = false
        
        if (MediaPlayerManager.getInstance().currentEpisode != nil) {
            if (MediaPlayerManager.getInstance().currentEpisode!.getId() == episodeModel.getId()) {
                toggleEpisodePlayback = true
            }
        }
        
        if (toggleEpisodePlayback) {
            MediaPlayerManager.getInstance().performActionToggleMediaPlayback()
        } else {
            MediaPlayerManager.getInstance().performActionLoadAndPlayEpisode(MediaPlayerManager.PLAYBACK_TYPE_LOCAL_THEN_STREAM, episodeModel, nil)
        }
    }
    
    func updateMediaPlayerState(_ mediaPlayerState: String) {
        var validStateForTinting = false
        var validChannelTypeForTinting = false
        var image: UIImage!

        switch (mediaPlayerState) {
        case MediaPlayerManager.MEDIA_PLAYER_STATE_PLAYING,
             MediaPlayerManager.MEDIA_PLAYER_STATE_PLAYING_AND_SEEKING:

            image = UIImage(named: ImagesHelper.IC_PAUSE_EXTRUDED)
            
            validStateForTinting = true
            
            break
        case MediaPlayerManager.MEDIA_PLAYER_STATE_PAUSED:
            image = UIImage(named: ImagesHelper.IC_PLAY_EXTRUDED)
            
            break
        default:
            break
        }

        let currentEpisode = MediaPlayerManager.getInstance().currentEpisode
        if (currentEpisode != nil && ChannelsHelper.isChannelIdClassic(currentEpisode!.getChannelId())) {
            validChannelTypeForTinting = true
        }

        ButtonTogglePlaybackHelper.setTint(buttonTogglePlayback, validStateForTinting, validChannelTypeForTinting, "")

        buttonTogglePlayback.setImage(image, for: .normal)
    }
}
