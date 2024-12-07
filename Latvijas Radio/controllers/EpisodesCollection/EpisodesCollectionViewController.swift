//
//  EpisodesCollectionViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit
import AVFoundation
import SDWebImage

protocol EpisodesCollectionDatasetChangedDelegate: AnyObject {
    func onDatasetChanged()
}

protocol EpisodesCollectionLoadMoreDelegate: AnyObject {
    func getIsLoadMoreInProgress() -> Bool
    func onClickButtonLoadMore()
}

class EpisodesCollectionViewController: UICollectionViewController {
    
    static var TAG = String(describing: EpisodesCollectionViewController.classForCoder())

    weak var scrollDelegate: UIScrollViewDelegate?
    weak var episodesCollectionDatasetChangedDelegate: EpisodesCollectionDatasetChangedDelegate?
    weak var episodesCollectionLoadMoreDelegate: EpisodesCollectionLoadMoreDelegate?
    
    var dataset: [EpisodeModel] = [EpisodeModel]() {
        didSet {
            episodesCollectionDatasetChangedDelegate?.onDatasetChanged()
        }
    }
    
    private let reuseIdentifier = "EpisodesCollectionViewCell"
    private var collectionContentSizeObserver: NSKeyValueObservation?
    var fluidHeight = false
    var isOfflineList = false
    var openItemInExpandedViewEnabled = true
    var isLoadMoreEnabled = false
    var generateLoadMoreItem = true // is used only if "isMoreEnabled" is true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(EpisodesCollectionViewController.TAG, "viewDidLoad")
        
        if (fluidHeight) {
            view.translatesAutoresizingMaskIntoConstraints = false

            collectionContentSizeObserver = collectionView.observe(\.contentSize, options: .new) { (collView, change) in
                if let containerView = self.view.superview {
                    ContainedCollectionViewHeightHelper.updateCollectionContainerHeightConstraint(view: containerView, collectionView: self.collectionView)
                }
            }
        }
        
        setupMediaPlayerListeners()
        
        updateDataset([])
        self.collectionView.scrollsToTop = true
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTheTop), name: Notification.Name(MyRadioViewController.EVENT_SCROLL_TO_TOP_MYRADIO), object: nil)
    }

    @objc func scrollToTheTop() {
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            self?.collectionView.setContentOffset(.zero, animated: false)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reload collection onResume, so subscription buttons would
        // show correct state.
        collectionView.reloadData()
    }

    deinit {
        GeneralUtils.log(EpisodesCollectionViewController.TAG, "deinit")
    }
    
    // MARK: UIScrollViewDelegate

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidScroll?(scrollView)
    }
    
    // MARK: Custom

    func updateDataset(_ dataset: [EpisodeModel]) {
        GeneralUtils.log(EpisodesCollectionViewController.TAG, "setupDataset")
        
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        config.backgroundColor = UIColor.clear

        let layout = UICollectionViewCompositionalLayout.list(using: config)

        collectionView.collectionViewLayout = layout

        self.dataset.append(contentsOf: dataset)

        UIView.performWithoutAnimation {
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
        }
        print("EpisodesCollectionViewController dataset = \(dataset)")
//        collectionView.reloadData()
//        collectionView.layoutIfNeeded()
    }
    
    func setupSliderTimeline(_ cell: EpisodesCollectionViewCell, _ position: Int) {
        cell.sliderTimeline.minimumValue = 0
        
        cell.sliderTimeline.tag = position
        cell.sliderTimeline.layer.setValue(cell, forKey: "CELL")
        cell.sliderTimeline.addTarget(self, action: #selector(onSliderTimelineValueChanged(slider:event:)), for: .valueChanged)
        
//        // leaving for reference:
//        // closure type, have an immediate access to cell, but can't get reference to event
//        cell.sliderTimeline.addAction(UIAction { (action: UIAction) in
//            print("closure, ", cell)
//        }, for: .valueChanged)
        
        // by default, disable all sliders except the for the current episode which is prepared in service
        // every item gets refreshed when we receive "on prepared" intent,
        // but also when data source changes (we might switch from episode to livestream)

        let episodeModel = dataset[position]
        
        cell.sliderTimeline.isUserInteractionEnabled = false
        
        if (MediaPlayerManager.getInstance().currentEpisode != nil && MediaPlayerManager.getInstance().isMediaPlayerPrepared) {
            if (MediaPlayerManager.getInstance().currentEpisode!.getId() == episodeModel.getId()) {
                cell.sliderTimeline.isUserInteractionEnabled = true
            }
        }
    }
    
    @objc func onSliderTimelineValueChanged(slider: UISlider, event: UIEvent) {
        // perform snapping
        let timelineStep: Float = 1.0 / slider.maximumValue
        let roundedValue = round(slider.value / timelineStep) * timelineStep

        slider.value = roundedValue
        
        let cell = slider.layer.value(forKey: "CELL") as! EpisodesCollectionViewCell
        
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began, .moved:
                cell.sliderTimeline.layer.setValue(true, forKey: "USER_CURRENTLY_INTERACTING_WITH_SLIDER")
                
                let newValueOfSeconds = Int(slider.value)
                
                let formattedTimelineDuration = DateUtils.getTimelineFromSeconds(newValueOfSeconds)
                
                cell.textElapsedDuration.setText(formattedTimelineDuration)
                
                break
            case .ended:
                cell.sliderTimeline.layer.setValue(false, forKey: "USER_CURRENTLY_INTERACTING_WITH_SLIDER")
                
                let newValueOfSeconds = Int(slider.value)

                let positionInSecondsToSeekTo = newValueOfSeconds
                let positionInMillisecondsToSeekTo = Double(positionInSecondsToSeekTo * 1000)
                
                MediaPlayerManager.getInstance().performActionSeekMedia(positionInMillisecondsToSeekTo)

                break
            default:
                break
            }
        }
    }
    
    @objc func buttonTogglePlaybackClickHandler(_ sender: UIView) {
        let episodeModel = dataset[sender.tag]
        
        if let serviceEpisode = MediaPlayerManager.getInstance().currentEpisode {
            if (serviceEpisode.getId() == episodeModel.getId()) {
                MediaPlayerManager.getInstance().performActionToggleMediaPlayback()
                
                return
            }
        }

        MediaPlayerManager.getInstance().performActionLoadAndPlayEpisode(MediaPlayerManager.PLAYBACK_TYPE_LOCAL_THEN_STREAM, episodeModel, dataset)
    }
    
    @objc func buttonDownloadClickHandler(_ sender: UIView) {
        let indexPath = IndexPath(row: sender.tag, section: 0)

        if let cell = collectionView.cellForItem(at: indexPath) as? EpisodesCollectionViewCell {
            let usersManager = UsersManager.getInstance()
            let currentUser =  usersManager.getCurrentUser()!
            
            if (currentUser.getDownloadOnlyWithWifi() && !Reachability.isConnectedToNetwork()) {
                Toast.show(message: "no_connection_to_wifi".localized(), controller: self)
                
                return
            }

            AssetPersistenceManager.sharedManager.downloadStream(for: cell.asset!)
        }
    }
    
    @objc func buttonRemoveClickHandler(_ sender: UIView) {
        let episodeModel = dataset[sender.tag]
        
        setEpisodeSubscriptionStatus(episodeModel, false)
    }
    
    @objc func buttonAddClickHandler(_ sender: UIView) {
        let episodeModel = dataset[sender.tag]
        
        setEpisodeSubscriptionStatus(episodeModel, true)
    }
    
    @objc func buttonLoadMoreClickHandler(_ sender: UIView) {
        episodesCollectionLoadMoreDelegate?.onClickButtonLoadMore()
        
        // For unknown reason, reloading the "loader item" makes it slightly scroll up,
        // so we force scroll to the bottom.
        UIView.performWithoutAnimation { [weak self] in
            self?.collectionView.reloadItems(at: [IndexPath(row: self?.dataset.count ?? 0, section: 0)])
        }

        collectionView.scrollToItem(at: IndexPath(row: dataset.count, section: 0), at: .top, animated: false)
    }
    
    @objc func buttonRemoveOfflineEpisodeClickHandler(_ sender: UIView) {
        guard sender.tag >= 0, sender.tag < dataset.count else { return }
        let episodeModel = dataset[sender.tag]
        
        let usersManager = UsersManager.getInstance()
        let currentUser = usersManager.getCurrentUser()!
        
        if let offlineEpisode = usersManager.getOfflineEpisodeById(episodeModel.getId()) {
            // access file and delete it
            let urlAsset = AVURLAsset(url: URL(string: offlineEpisode.getMediaStreamUrl())!)
            let asset = Asset(episodeModel: offlineEpisode, urlAsset: urlAsset)
            
            AssetPersistenceManager.sharedManager.deleteAsset(asset)
        }
        
        // Find the index to remove in offline episodes
        var indexToRemoveInOfflineEpisodes: Int?
        for i in 0..<currentUser.getOfflineEpisodes().count {
            if currentUser.getOfflineEpisodes()[i].getId() == episodeModel.getId() {
                indexToRemoveInOfflineEpisodes = i
                break
            }
        }
        
        // Find the index to remove in dataset
        var indexToRemoveInDataset: Int?
        for i in 0..<dataset.count {
            if dataset[i].getId() == episodeModel.getId() {
                indexToRemoveInDataset = i
                break
            }
        }
        
        // Ensure both indices are valid
        guard let indexToRemoveInOfflineEpisodes = indexToRemoveInOfflineEpisodes,
              let indexToRemoveInDataset = indexToRemoveInDataset else {
            return
        }
        
        // Synchronize the removal process to prevent index out of range errors
        DispatchQueue.main.async {
            // Update offline episodes
            var offlineEpisodes = currentUser.getOfflineEpisodes()
            offlineEpisodes.remove(at: indexToRemoveInOfflineEpisodes)
            currentUser.setOfflineEpisodes(offlineEpisodes)
            usersManager.saveCurrentUserData()
            
            // Remove episode record from dataset and update collection view
            self.dataset.remove(at: indexToRemoveInDataset)
            
            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: [IndexPath(row: indexToRemoveInDataset, section: 0)])
            }, completion: nil)
        }
    }
    
    func setupMediaPlayerListeners() {
        NotificationCenter.default.addObserver(forName: Notification.Name(MediaPlayerManager.EVENT_DATA_SOURCE_CHANGED), object: nil, queue: .main) { [weak self] notification in
            GeneralUtils.log(EpisodesCollectionViewController.TAG, "EVENT_DATA_SOURCE_CHANGED")

            // We might have been playing episode, able to seek it, and we switched to playing livestream.
            // So, episode shouldn't be draggable anymore.
            // This updates slider interactivity.
            
            UIView.performWithoutAnimation {
                self?.collectionView.reloadData()
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name(MediaPlayerManager.EVENT_MEDIA_PLAYER_PREPARED), object: nil, queue: .main) { [weak self] notification in
            GeneralUtils.log(EpisodesCollectionViewController.TAG, "EVENT_MEDIA_PLAYER_PREPARED")

            // Block previous item slider and enable current episode item slider.
            UIView.performWithoutAnimation {
                self?.collectionView.reloadData()
            }
        }

        NotificationCenter.default.addObserver(forName: Notification.Name(MediaPlayerManager.EVENT_UPDATE_MEDIA_PLAYER_STATE), object: nil, queue: .main) { [weak self] notification in
            GeneralUtils.log(EpisodesCollectionViewController.TAG, "EVENT_UPDATE_MEDIA_PLAYER_STATE")
            
            if (self != nil) {
                if (MediaPlayerManager.getInstance().currentEpisode != nil) {
                    if let data = notification.userInfo as NSDictionary? {
                        let mediaPlayerState = data[MediaPlayerManager.NOTIFICATION_PARAMS_DEFAULT_KEY] as! String

                        let episodeModel = MediaPlayerManager.getInstance().currentEpisode!
                        
                        let index = self!.getEpisodeItemIndexById(episodeModel.getId())
                        if (index != -1) {
                            let indexPath = IndexPath(row: index, section: 0)

                            if let cell = self?.collectionView.cellForItem(at: indexPath) as? EpisodesCollectionViewCell {
                                self?.updateMediaPlayerState(mediaPlayerState, cell)
                            }
                        }
                    }
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name(MediaPlayerManager.EVENT_UPDATE_MEDIA_PLAYER_PROGRESS), object: nil, queue: .main) { [weak self] notification in
            GeneralUtils.log(EpisodesCollectionViewController.TAG, "EVENT_UPDATE_MEDIA_PLAYER_PROGRESS")
            
            if (self != nil) {
                if (MediaPlayerManager.getInstance().currentEpisode != nil) {
                    if let data = notification.userInfo as NSDictionary? {
                        let positionInMillis = data[MediaPlayerManager.NOTIFICATION_PARAMS_DEFAULT_KEY] as! Double
        
                        let episodeModel = MediaPlayerManager.getInstance().currentEpisode!
                        
                        let index = self!.getEpisodeItemIndexById(episodeModel.getId())
                        
                        if (index != -1) {
                            let positionInSeconds = Int(positionInMillis / 1000)

                            let indexPath = IndexPath(row: index, section: 0)

                            if let cell = self?.collectionView.cellForItem(at: indexPath) as? EpisodesCollectionViewCell
                            {
                                var userCurrentlyInteractingWithSlider = false
                                
                                if let userCurrentlyInteractingWithSliderValue = cell.sliderTimeline.layer.value(forKey: "USER_CURRENTLY_INTERACTING_WITH_SLIDER") as? Bool {
                                    userCurrentlyInteractingWithSlider = userCurrentlyInteractingWithSliderValue
                                }
                                
                                if (!userCurrentlyInteractingWithSlider) {
                                    cell.sliderTimeline.value = Float(positionInSeconds)
                                    
                                    let formattedTimelineDuration = DateUtils.getTimelineFromSeconds(positionInSeconds)
                                    
                                    cell.textElapsedDuration.setText(formattedTimelineDuration)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name(MediaPlayerManager.EVENT_ON_PLAYBACK_COMPLETED), object: nil, queue: .main) { [weak self] notification in
            GeneralUtils.log(EpisodesCollectionViewController.TAG, "EVENT_ON_PLAYBACK_COMPLETED")

            if (self != nil) {
                if let data = notification.userInfo as NSDictionary? {
                    if let completedEpisode = data[MediaPlayerManager.NOTIFICATION_PARAMS_DEFAULT_KEY] as? EpisodeModel {
                        let index = self!.getEpisodeItemIndexById(completedEpisode.getId())
                        
                        if (index != -1) {
                            let indexPath = IndexPath(row: index, section: 0)

                            if let cell = self?.collectionView.cellForItem(at: indexPath) as? EpisodesCollectionViewCell {
                                cell.sliderTimeline.value = 0
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getEpisodeItemIndexById(_ episodeId: String) -> Int {
        var result = -1
        
        for i in (0..<dataset.count) {
            let episodeModel = dataset[i]
            
            if (episodeModel.getId() == episodeId) {
                result = i
                
                break
            }
        }
        
        return result
    }
    
    func updateMediaPlayerState(_ mediaPlayerState: String, _ cell: EpisodesCollectionViewCell) {
        var validStateForTinting = false
        var validChannelTypeForTinting = false
        var image: UIImage!
        
        switch (mediaPlayerState) {
        case MediaPlayerManager.MEDIA_PLAYER_STATE_PLAYING:

            image = UIImage(named: ImagesHelper.IC_PAUSE_EXTRUDED)
            
            validStateForTinting = true
            
            break
        case MediaPlayerManager.MEDIA_PLAYER_STATE_PAUSED:
            
            image = UIImage(named: ImagesHelper.IC_PLAY_EXTRUDED)
            
            break
        case MediaPlayerManager.MEDIA_PLAYER_STATE_PLAYING_AND_SEEKING:

            image = UIImage(named: ImagesHelper.IC_PAUSE_EXTRUDED)
            
            validStateForTinting = true
            
            break
        default:
            break
        }
        
        let currentEpisode = MediaPlayerManager.getInstance().currentEpisode
        if (currentEpisode != nil && ChannelsHelper.isChannelIdClassic(currentEpisode!.getChannelId())) {
            validChannelTypeForTinting = true
        }

        ButtonTogglePlaybackHelper.setTint(cell.buttonTogglePlayback, validStateForTinting, validChannelTypeForTinting, "")

        cell.buttonTogglePlayback.setImage(image, for: .normal)
    }
    
    func setEpisodeSubscriptionStatus(_ episodeModel: EpisodeModel, _ subscribed: Bool) {
        UserSubscribedEpisodesManager.getInstance().performRequestSetEpisodeSubscriptionStatus(episodeModel, subscribed, { [weak self] in
            guard let self = self else {return}
            
            SubscribedEpisodesViewController.subscribedEpisodesListNeedsUpdate = true

            let index = self.getEpisodeItemIndexById(episodeModel.getId())
            if (index != -1) {
                self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
            }
        })
    }
}

// MARK: - UICollectionViewDataSource
extension EpisodesCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var result = dataset.count
        
        if (isLoadMoreEnabled && generateLoadMoreItem) {
            result = result + 1
        }
        
        return result
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! EpisodesCollectionViewCell

        // If list supports "load more" functionality,
        // determine which layout to show - episode or load more.
        
        var isCurrentItemLoadMore = false
        
        if (isLoadMoreEnabled) {
            if (indexPath.row == dataset.count) {
                isCurrentItemLoadMore = true
            }
        }
        
        if (isCurrentItemLoadMore) {
            cell.wrapperItem.setVisibility(UIView.VISIBILITY_GONE)
            cell.wrapperItemLoadMore.setVisibility(UIView.VISIBILITY_VISIBLE)
            
            cell.buttonLoadMore.removeTarget(self, action: #selector(buttonLoadMoreClickHandler), for: .touchUpInside)
            cell.buttonLoadMore.addTarget(self, action: #selector(buttonLoadMoreClickHandler), for: .touchUpInside)
            
            // show button or loader
            if (episodesCollectionLoadMoreDelegate!.getIsLoadMoreInProgress()) {
                cell.buttonLoadMore.isHidden = true
                cell.activityIndicator.isHidden = false
                cell.activityIndicator.startAnimating()
            } else {
                cell.buttonLoadMore.isHidden = false
                cell.activityIndicator.isHidden = true
            }
        } else {
            cell.wrapperItem.setVisibility(UIView.VISIBILITY_VISIBLE)
            cell.wrapperItemLoadMore.setVisibility(UIView.VISIBILITY_GONE)
            
            // variables
            let episodeModel = dataset[indexPath.row]
            
            // Update button add/remove for subscription list.
            cell.buttonAdd.isHidden = true
            cell.buttonAdd.removeTarget(self, action: #selector(buttonAddClickHandler), for: .touchUpInside)

            cell.buttonRemove.isHidden = true
            cell.buttonRemove.removeTarget(self, action: #selector(buttonRemoveClickHandler), for: .touchUpInside)
            
            // Update button remove, for offline list.
            if (isOfflineList) {
                cell.buttonRemove.isHidden = false
                
                cell.buttonRemove.tag = indexPath.row
                cell.buttonRemove.addTarget(self, action: #selector(buttonRemoveOfflineEpisodeClickHandler), for: .touchUpInside)
            } else {
                let userSubscribedEpisodesManager = UserSubscribedEpisodesManager.getInstance()
                let isUserSubscribedToCurrentEpisode = userSubscribedEpisodesManager.isUserSubscribedToEpisode(episodeModel)
                
                if (isUserSubscribedToCurrentEpisode) {
                    cell.buttonRemove.isHidden = false
                    
                    cell.buttonRemove.tag = indexPath.row
                    cell.buttonRemove.addTarget(self, action: #selector(buttonRemoveClickHandler), for: .touchUpInside)
                } else {
                    cell.buttonAdd.isHidden = false
                    
                    cell.buttonAdd.tag = indexPath.row
                    cell.buttonAdd.addTarget(self, action: #selector(buttonAddClickHandler), for: .touchUpInside)
                }
            }

            // update button download
            if (!isOfflineList && EpisodesHelper.isEpisodeAllowedToBeDownloaded(episodeModel)) {
                cell.wrapperButtonDownload.setVisibility(UIView.VISIBILITY_VISIBLE)
                cell.downloadProgress.setVisibility(UIView.VISIBILITY_VISIBLE)
                
                cell.buttonDownload.tag = indexPath.row
                cell.buttonDownload.addTarget(self, action: #selector(buttonDownloadClickHandler), for: .touchUpInside)

                cell.delegate = self
                
                let urlAsset = AVURLAsset(url: URL(string: episodeModel.getMediaStreamUrl())!)
                var asset = Asset(episodeModel: episodeModel, urlAsset: urlAsset)
                
                // In the future: check if episode gets downloaded when we close the app.
                // And when we come back to app, check if its picked up by urlSession and calls didCompleteWithError (thats where binding happens).

                // update download button state
                let usersManager = UsersManager.getInstance()

                if (usersManager.getOfflineEpisodeById(episodeModel.getId()) != nil) {
                    // already downloaded and bound
                    cell.buttonDownload.setImage(UIImage(named: ImagesHelper.IC_CHECKMARK_IN_CIRCLE), for: .normal)
                    cell.buttonDownload.removeTarget(self, action: #selector(buttonDownloadClickHandler), for: .touchUpInside)
                    
                    cell.downloadProgress.setVisibility(UIView.VISIBILITY_GONE)
                } else {
                    // not downloaded, check state
                    if let localAssetForStream = AssetPersistenceManager.sharedManager.localAssetForEpisodeModel(withEpisodeModel: episodeModel) {
                        // shouldn't happen, means binding hasn't happened after download
                        
                        asset = localAssetForStream
                        
                        cell.downloadProgress.setVisibility(UIView.VISIBILITY_GONE)
                    } else {
                        if let assetForStream = AssetPersistenceManager.sharedManager.assetForEpisodeModel(withId: episodeModel.getId()) {
                            // currently being downloaded
                            asset = assetForStream

                            cell.buttonDownload.setImage(UIImage(named: ImagesHelper.IC_DOWNLOAD), for: .normal)
                            cell.buttonDownload.removeTarget(self, action: #selector(buttonDownloadClickHandler), for: .touchUpInside)
                            
                            cell.downloadProgress.setVisibility(UIView.VISIBILITY_VISIBLE)
                        } else {
                            // currently not downloaded
                            cell.buttonDownload.setImage(UIImage(named: ImagesHelper.IC_DOWNLOAD), for: .normal)
                            
                            cell.downloadProgress.setVisibility(UIView.VISIBILITY_GONE)
                        }
                    }
                }

                cell.asset = asset
            } else {
                cell.wrapperButtonDownload.setVisibility(UIView.VISIBILITY_GONE)
                cell.downloadProgress.setVisibility(UIView.VISIBILITY_GONE)
            }
            
            // listeners
            cell.buttonTogglePlayback.tag = indexPath.row
            cell.buttonTogglePlayback.addTarget(self, action: #selector(buttonTogglePlaybackClickHandler), for: .touchUpInside)
            
            setupSliderTimeline(cell, indexPath.row)

            // update image
            let transformer = SDImageResizingTransformer(
                size: CGSize(
                    width: GeneralUtils.dpToPixels(CGFloat(120)),
                    height: GeneralUtils.dpToPixels(CGFloat(80))),
                scaleMode: .aspectFill
            )

            cell.imageEpisode.sd_setImage(
                with: URL(string: episodeModel.getImageUrl()),
                placeholderImage: nil,
                context: [.imageTransformer: transformer]
            )
            
            // update broadcast name
            let broadcastName = episodeModel.getBroadcastName()
            cell.textBroadcastName.setText(broadcastName)
            let customFont = UIFont(name: "FuturaPT-Medium", size: 10.0)
            cell.textBroadcastName.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont ?? UIFont.systemFont(ofSize: 10.0))
            cell.textBroadcastName.adjustsFontForContentSizeCategory = true
            let customFont1 = UIFont(name: "FuturaPT-Book", size: 10.0)
            cell.textDate.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont1 ?? UIFont.systemFont(ofSize: 10.0))
            cell.textDate.adjustsFontForContentSizeCategory = true
            let customFont2 = UIFont(name: "FuturaPT-Medium", size: 13.0)
            cell.textTitle.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont2 ?? UIFont.systemFont(ofSize: 13.0))
            cell.textTitle.adjustsFontForContentSizeCategory = true
            let customFont3 = UIFont(name: "FuturaPT-Book", size: 10.0)
            cell.textTotalDuration.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont3 ?? UIFont.systemFont(ofSize: 10.0))
            cell.textTotalDuration.adjustsFontForContentSizeCategory = true
            cell.textElapsedDuration.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont1 ?? UIFont.systemFont(ofSize: 10.0))
            cell.textElapsedDuration.adjustsFontForContentSizeCategory = true
            cell.textElapsedDuration.setText(broadcastName)
            // update date
            let dateInMillis = episodeModel.getDateInMillis()
            let formattedDate = DateUtils.getAppDateFromMillis(dateInMillis)
            cell.textDate.setText(formattedDate)
            
            // update title
            let title = episodeModel.getTitle()
            cell.textTitle.setText(title)
            
            // Update elapsed duration by looking for media record.
            var elapsedSeconds = 0
            
            if let episodePlayedTimeInMilliseconds = MediaPlayerManagerMediaPlaybackStateRecorder.getSpecificEpisodePlayedTime(episodeModel.getId()) {
                elapsedSeconds = Int(episodePlayedTimeInMilliseconds / 1000)
            }
            
            // update elapsed duration
            let formattedTimelineDuration = DateUtils.getTimelineFromSeconds(elapsedSeconds)
            
            cell.textElapsedDuration.setText(formattedTimelineDuration)
            
            // update total duration
            // timeline seekable positions are the same as duration in seconds (ms would give too many positions)
            let totalDurationInSeconds = episodeModel.getMediaDurationInSeconds()
            
            let formattedTimelineTotalDuration = DateUtils.getTimelineFromSeconds(totalDurationInSeconds)
            cell.textTotalDuration.setText(formattedTimelineTotalDuration)

            // update slider progress & max value
            // It is important to set max value BEFORE progress.
            cell.sliderTimeline.maximumValue = Float(totalDurationInSeconds)
            cell.sliderTimeline.value = Float(elapsedSeconds)
            
            // update slider color
            var colorId = ColorsHelper.RED
            
            let channelId = episodeModel.getChannelId()
            
            if (ChannelsHelper.isChannelIdClassic(channelId)) {
                if let channelColor = ChannelsHelper.getColorIdFromChannelId(channelId) {
                    colorId = channelColor
                }
            }
            
            cell.sliderTimeline.minimumTrackTintColor = UIColor(named: colorId)
            
            // update toggle button state
            updateMediaPlayerState(MediaPlayerManager.MEDIA_PLAYER_STATE_PAUSED, cell)
            
            // Ask player manager what episode it is currently playing.
            // If current cell represents the managers episode, then immediately update its play state.
            if let serviceEpisode = MediaPlayerManager.getInstance().currentEpisode {
                if (serviceEpisode.getId() == episodeModel.getId()) {
                    updateMediaPlayerState(MediaPlayerManager.getInstance().mediaPlayerState, cell)
                }
            }
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (openItemInExpandedViewEnabled) {
            // User might tap on the "Load more" item (not on the button itself).
            // Guard against it.
            
            if (indexPath.row <= dataset.count - 1) {
                let episodeModel = dataset[indexPath.row]

                let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_EPISODE, bundle: nil)
                                        .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_EPISODE) as! EpisodeViewController)
                
                viewController.episodeModel = episodeModel
                
                navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if (openItemInExpandedViewEnabled) {
            if let cell = collectionView.cellForItem(at: indexPath) {
                CollectionViewCellHelper.setHighlightedStyle(cell)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if (openItemInExpandedViewEnabled) {
            if let cell = collectionView.cellForItem(at: indexPath) {
                CollectionViewCellHelper.setUnhighlightedStyle(cell)
            }
        }
    }
}

/**
 Extend `EpisodesCollectionViewController` to conform to the `EpisodesCollectionViewCellDelegate` protocol.
 */
extension EpisodesCollectionViewController: EpisodesCollectionViewCellDelegate {

    func episodesCollectionViewCell(_ cell: EpisodesCollectionViewCell, downloadStateDidChange newState: Asset.DownloadState) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }

        collectionView.reloadItems(at: [indexPath])
    }
}

// MARK: - Collection View Flow Layout Delegate
// leaving for reference:
// Since we are setting layout programmatically, this is not necessary:
//private let sectionInsets = UIEdgeInsets(
//    top: 0.0,
//    left: 0.0,
//    bottom: 0.0,
//    right: 0.0
//)
//let spacingBetweenCells: CGFloat = 0
//
//extension EpisodesCollectionViewController: UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return sectionInsets
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return spacingBetweenCells
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return spacingBetweenCells
//    }
//}
