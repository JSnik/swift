//
//  LivestreamsCollectionViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class LivestreamsCollectionViewController: UICollectionViewController {
    
    static var TAG = String(describing: LivestreamsCollectionViewController.classForCoder())

    private let reuseIdentifier = "LivestreamsCollectionViewCell"
    private var dataset: [/*LivestreamModel*/RadioChannel] = [/*LivestreamModel*/RadioChannel]()
    private var collectionContentSizeObserver: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(LivestreamsCollectionViewController.TAG, "viewDidLoad")
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        collectionContentSizeObserver = collectionView.observe(\.contentSize, options: .new) { (collView, change) in
            if let containerView = self.view.superview {
                ContainedCollectionViewHeightHelper.updateCollectionContainerHeightConstraint(view: containerView, collectionView: self.collectionView)
            }
        }
        self.collectionView.scrollsToTop = true
    }

    deinit {
        GeneralUtils.log(LivestreamsCollectionViewController.TAG, "deinit")
    }
    
    // MARK: Custom

    func updateDataset(_ dataset: [/*LivestreamModel*/RadioChannel]) {
        GeneralUtils.log(LivestreamsCollectionViewController.TAG, "setupDataset")
        
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        config.backgroundColor = UIColor.clear
        
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        
        collectionView.collectionViewLayout = layout
        var dataset1 = [RadioChannel]()
        for el in dataset {
            dataset1.append(el)
            if el.name?.contains("Naba") == true {
                var rEl = el
                rEl.name = "Radioteātris"
                rEl.display_name = "Iestudējumi bērniem un pieaugušajiem"
                rEl.id = Int(LivestreamsManager.ID_LATVIJAS_RADIO_RADIOTEATRIS)
                rEl.image =  ImagesHelper.LOGO_WIDE_LATVIJAS_RADIO_RADIOTEATRIS
                rEl.mobile?.square_image =  ImagesHelper.LOGO_LATVIJAS_RADIO_RADIOTEATRIS
                dataset1.append(rEl)
            }
        }
        self.dataset = dataset1

//        self.dataset = dataset

        collectionView.reloadData()
        collectionView.layoutIfNeeded()

        setupMediaPlayerListeners()
    }
    
    @objc func buttonTogglePlaybackClickHandler(_ sender: UIView) {
        let livestreamModel = dataset[sender.tag]
//livestreamModel.name?.contains("Radioteātris") == false

//        if (!livestreamModel.getFakeLivestream()) {
        if (livestreamModel.name?.contains("Radioteātris") == false) {
            if let serviceLivestream = MediaPlayerManager.getInstance().currentLivestream {
                if (serviceLivestream.id /*getId()*/ == livestreamModel.id /*getId()*/) {
                    MediaPlayerManager.getInstance().performActionToggleMediaPlayback()

                    return
                }
            }
            
            let playableLivestreams = LivestreamsManager.getOnlyPlayableLivestreams(dataset)

            MediaPlayerManager.getInstance().contentLoadedFromSource = MediaPlayerManager.CONTENT_SOURCE_NAME_APP_LIVESTREAMS_VERTICAL_SLIDER
            
            MediaPlayerManager.getInstance().performActionLoadAndPlayLivestream(MediaPlayerManager.PLAYBACK_TYPE_STREAM, livestreamModel, playableLivestreams)
        } else {
            if (livestreamModel.id /*getId()*/ == Int(LivestreamsManager.ID_LATVIJAS_RADIO_RADIOTEATRIS)) {
                let channelModel = ChannelsManager.getChannelById(ChannelsManager.ID_LATVIJAS_RADIO_RADIOTEATRIS)
                
                let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_BROADCASTS_FILTERED, bundle: nil)
                                        .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_BROADCASTS_FILTERED) as! BroadcastsFilteredViewController)
                
                viewController.channelModel = channelModel
                
                navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    func setupMediaPlayerListeners() {
        NotificationCenter.default.addObserver(forName: Notification.Name(MediaPlayerManager.EVENT_DATA_SOURCE_CHANGED), object: nil, queue: .main) { [weak self] notification in
            GeneralUtils.log(LivestreamsCollectionViewController.TAG, "EVENT_DATA_SOURCE_CHANGED")

            self?.collectionView.reloadData()
        }

        NotificationCenter.default.addObserver(forName: Notification.Name(MediaPlayerManager.EVENT_UPDATE_MEDIA_PLAYER_STATE), object: nil, queue: .main) { [weak self] notification in
            GeneralUtils.log(LivestreamsCollectionViewController.TAG, "EVENT_UPDATE_MEDIA_PLAYER_STATE")

            if (MediaPlayerManager.getInstance().currentLivestream != nil) {
                if let data = notification.userInfo as NSDictionary? {
                    let mediaPlayerState = data[MediaPlayerManager.NOTIFICATION_PARAMS_DEFAULT_KEY] as! String

                    let livestreamModel = MediaPlayerManager.getInstance().currentLivestream!

                    let index = self!.getLivestreamItemIndexById(String(describing:  livestreamModel.id /*getId()*/ ))
                    if (index != -1) {
                        let indexPath = IndexPath(row: index, section: 0)

                        if let cell = self?.collectionView.cellForItem(at: indexPath) as? LivestreamsCollectionViewCell {
                            self?.updateMediaPlayerState(mediaPlayerState, cell)
                        }
                    }
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name(LivestreamInfoPoller.EVENT_ON_LIVESTREAM_PROGRAMS_UDPATED), object: nil, queue: .main) { [weak self] notification in
            GeneralUtils.log(LivestreamsCollectionViewController.TAG, "EVENT_ON_BROADCAST_PROGRAMS_UDPATED")

            self?.updateTitles()
        }
    }

    func getLivestreamItemIndexById(_ livestreamId: String) -> Int {
        var result = -1

        for i in (0..<dataset.count) {
            let livestreamModel = dataset[i]

            if (livestreamModel.id /*getId()*/ == Int(livestreamId)) {
                result = i

                break
            }
        }

        return result
    }

    func updateMediaPlayerState(_ mediaPlayerState: String, _ cell: LivestreamsCollectionViewCell) {
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

        let currentLivestream = MediaPlayerManager.getInstance().currentLivestream
        if (currentLivestream != nil /*&& currentLivestream?.getType() == LivestreamsManager.TYPE_CLASSIC*/) {
            validChannelTypeForTinting = true
        }

//        ButtonTogglePlaybackHelper.setTint(cell.buttonTogglePlayback, validStateForTinting, validChannelTypeForTinting)
        if let colorId = currentLivestream?.color as? String {
//            cell.buttonTogglePlayback.tintColor = hexStringToUIColor(hex: colorId)
            ButtonTogglePlaybackHelper.setTint(cell.buttonTogglePlayback, validStateForTinting, validChannelTypeForTinting, colorId)
        }

        cell.buttonTogglePlayback.setImage(image, for: .normal)
    }
    
    func updateTitles() {
        for i in (0..<dataset.count) {
            let indexPath = IndexPath(row: i, section: 0)

            if let cell = collectionView.cellForItem(at: indexPath) as? LivestreamsCollectionViewCell {
                let livestreamModel = dataset[i]
                
                updateTitle(cell, livestreamModel)
            }
        }
    }
    
    func updateTitle(_ cell: LivestreamsCollectionViewCell, _ livestreamModel: /*LivestreamModel*/RadioChannel) {
        let finalLivestreamTitle = MediaPlayerManager.getInstance().mediaPlayerManagerRemoteCommandCenter.getDynamicLivestreamTitle(livestreamModel, true)

        cell.textTitleSecondary.setText(finalLivestreamTitle)
    }
}

// MARK: - UICollectionViewDataSource
extension LivestreamsCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataset.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LivestreamsCollectionViewCell

        // variables
        let livestreamModel = dataset[indexPath.row]
        
        // listeners
        cell.buttonTogglePlayback.tag = indexPath.row
        cell.buttonTogglePlayback.addTarget(self, action: #selector(buttonTogglePlaybackClickHandler), for: .touchUpInside)

        // update livestream image
//        let wideImageResourceId = livestreamModel.getWideImageResourceId()
        //        cell.imageLivestream.image = UIImage(named: wideImageResourceId)

        if livestreamModel.name == "Radioteātris" {
            cell.imageLivestream.image = UIImage(named: "logo_latvijas_radio_radioteatris")
        } else {
            if (livestreamModel.image != nil) {
                cell.imageLivestream.sd_setImage(with: URL(string: livestreamModel.image ?? ""))
            } else {
                cell.imageLivestream.image = nil
            }
        }
        // update title primary
        let primaryTitle = livestreamModel.name // getName()
        cell.textTitlePrimary.setText(primaryTitle)
        
        // update title secondary
        updateTitle(cell, livestreamModel)
        
        // update toggle button state
        updateMediaPlayerState(MediaPlayerManager.MEDIA_PLAYER_STATE_PAUSED, cell)

        // Ask player manager what livestream it is currently playing.
        // If current cell represents the managers livestream, then immediately update its play state.
        if let serviceLivestream = MediaPlayerManager.getInstance().currentLivestream {
            if (serviceLivestream.id /*getId()*/ == livestreamModel.id /*getId()*/) {
                updateMediaPlayerState(MediaPlayerManager.getInstance().mediaPlayerState, cell)
            }
        }
        let customFont = UIFont(name: "FuturaPT-Medium", size: 10.0)
        cell.textTitlePrimary.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont ?? UIFont.systemFont(ofSize: 10.0))
        cell.textTitlePrimary.adjustsFontForContentSizeCategory = true
        let customFont1 = UIFont(name: "FuturaPT-Medium", size: 13.0)
        cell.textTitleSecondary.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont1 ?? UIFont.systemFont(ofSize: 13.0))
        cell.textTitleSecondary.adjustsFontForContentSizeCategory = true

        return cell
    }
}
