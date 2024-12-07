//
//  NewsCollectionViewController.swift
//  Latvijas Radio
//
//  Created by Sergey on 23.10.2024.
//  Copyright © 2024 Latvijas Radio. All rights reserved.
//

import Foundation
import UIKit
class NewsCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    static var TAG = String(describing: NewsCollectionViewController.classForCoder())
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    var downloadProgress: Float = 0
    var currentPageIndex = 0
    var currentPlayingIndex = 0
    private var dataset: [EpisodeModel] = []
    var playPauseImage: UIImage!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let reuseIdentifier = "NewsCell" // also enter this string as the cell identifier in the storyboard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(NewsCollectionViewController.TAG, "viewDidLoad")
        
        setViewStateLoading()
        setupMediaPlayerListeners()
        
        // UI
        view.translatesAutoresizingMaskIntoConstraints = false
        
        performRequestGetEpisodes()
        
        pageControl.numberOfPages = 3
        pageControl.currentPage = currentPageIndex
        pageControl.alpha = 0.7
        playPauseImage = UIImage(named: ImagesHelper.IC_PLAY_EXTRUDED)
        self.collectionView.scrollsToTop = true
    }

    @objc func clickPlay(_ sender: UIView) {
        currentPlayingIndex = sender.tag
        startOrTogglePlayback()
    }
            
    func setupMediaPlayerListeners() {
        NotificationCenter.default.addObserver(forName: Notification.Name(MediaPlayerManager.EVENT_DATA_SOURCE_CHANGED), object: nil, queue: .main) { [weak self] notification in
            GeneralUtils.log(NewsCollectionViewController.TAG, "EVENT_DATA_SOURCE_CHANGED")
            
            var setMediaPlayerStatePaused = true
            
            if (MediaPlayerManager.getInstance().currentEpisode != nil) {
                if (self?.dataset.isEmpty == false) {
                    // If currentEpisode is the same as the one represented by this fragment,
                    // then update media player state.
                    // Otherwise set state to paused.
                    if (self?.dataset[self!.currentPlayingIndex].getId() == MediaPlayerManager.getInstance().currentEpisode!.getId()) {
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
            GeneralUtils.log(NewsCollectionViewController.TAG, "EVENT_UPDATE_MEDIA_PLAYER_STATE")
            
            if (MediaPlayerManager.getInstance().currentEpisode != nil) {
                if (self?.dataset.isEmpty == false) {
                    // If currentEpisode is the same as the one represented by this fragment,
                    // then update media player state.
                    // Otherwise set state to paused.
                    if (self?.dataset[self!.currentPlayingIndex].getId() == MediaPlayerManager.getInstance().currentEpisode!.getId()) {
                        if let data = notification.userInfo as NSDictionary? {
                            let mediaPlayerState = data[MediaPlayerManager.NOTIFICATION_PARAMS_DEFAULT_KEY] as! String
            
                            self?.updateMediaPlayerState(mediaPlayerState)
                        }
                    }
                }
            }
        }
    }
    
    func setViewStateNormal() {
        pageControl.isHidden = false
        loadingView.isHidden = true
    }
    
    func setViewStateLoading() {
        pageControl.isHidden = true
        loadingView.isHidden = false
    }
    
    func performRequestGetEpisodes() {
        setViewStateLoading()
    
        let broadcastEpisodesRequest = BroadcastEpisodesRequest(appDelegate.dashboardContainerViewController!.notificationViewController, "news", "")

        broadcastEpisodesRequest.successCallback = { [weak self] (data) -> Void in
            self?.handleBroadcastEpisodesResponse(data)
        }
        
        broadcastEpisodesRequest.execute()
    }
    
    func handleBroadcastEpisodesResponse(_ data: [String: Any]) {
        let episodes = data[BroadcastEpisodesRequest.RESPONSE_PARAM_RESULTS] as! [[String: Any]]
        
        if (episodes.count > 0) {
            for e in episodes {
                if let episodeModel = EpisodesHelper.getEpisodeFromJsonObject(e) {
                    self.dataset.append(episodeModel)
                }
                if (self.dataset.isEmpty == false) {
                    pageControl.numberOfPages = self.dataset.count
                    collectionView.reloadData()
                    collectionView.layoutIfNeeded()
                    setViewStateNormal()
                }
            }
        }
    }
    
    func startOrTogglePlayback() {
        // determine to start or toggle playback
        var toggleEpisodePlayback = false
        
        if (MediaPlayerManager.getInstance().currentEpisode != nil) {
            if (MediaPlayerManager.getInstance().currentEpisode!.getId() == dataset[currentPageIndex].getId()) {
                toggleEpisodePlayback = true
            }
        }
        
        if (toggleEpisodePlayback) {
            MediaPlayerManager.getInstance().performActionToggleMediaPlayback()
        } else {
            MediaPlayerManager.getInstance().performActionLoadAndPlayEpisode(MediaPlayerManager.PLAYBACK_TYPE_LOCAL_THEN_STREAM, dataset[currentPageIndex], dataset)
        }
    }
    
    func updateMediaPlayerState(_ mediaPlayerState: String) {
        switch (mediaPlayerState) {
        case MediaPlayerManager.MEDIA_PLAYER_STATE_PLAYING,
             MediaPlayerManager.MEDIA_PLAYER_STATE_PLAYING_AND_SEEKING:
            playPauseImage = UIImage(named: ImagesHelper.IC_PAUSE_EXTRUDED)
            break
        case MediaPlayerManager.MEDIA_PLAYER_STATE_PAUSED:
            playPauseImage = UIImage(named: ImagesHelper.IC_PLAY_EXTRUDED)
            break
        default:
            break
        }
        playPauseImage = playPauseImage.withRenderingMode(.automatic)
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }
    
    
    // MARK: - UICollectionViewDataSource protocol
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataset.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! NewsCell
        
        if (cell.broadcastNewsViewControllerButtonDownloadHelper == nil) {
            cell.broadcastNewsViewControllerButtonDownloadHelper = BroadcastNewsViewControllerButtonDownloadHelper()
            cell.broadcastNewsViewControllerButtonDownloadHelper.viewController = cell
            cell.broadcastNewsViewControllerButtonDownloadHelper.setupEpisodeDownloadButton(dataset[indexPath.row])
        }
        cell.buttonTogglePlay.overrideUserInterfaceStyle = .light
        cell.buttonTogglePlay.tag = indexPath.row
        cell.buttonTogglePlay.addTarget(self, action: #selector(clickPlay), for: .touchUpInside)
        
        if (currentPlayingIndex == indexPath.row) {
            cell.buttonTogglePlay.setImage(playPauseImage, for: .normal)
        } else {
            cell.buttonTogglePlay.setImage(UIImage(named: ImagesHelper.IC_PLAY_EXTRUDED), for: .normal)
        }
        let imageUrl = dataset[indexPath.row].getImageUrl()
        cell.imageView.sd_setImage(with: URL(string: imageUrl), completed: nil)
        cell.backgroundColor = UIColor(named: ColorsHelper.WHITE)
        cell.backgroundColor = hexStringToUIColor(hex: dataset[indexPath.row].getColor()!)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .full

        let date =
        Date(timeIntervalSince1970: dataset[indexPath.row].getDateInMillis())
        let date1 = Date(timeIntervalSinceReferenceDate: dataset[indexPath.row].getDateInMillis())
        let date2 = Date(timeIntervalSinceReferenceDate: dataset[indexPath.row].getDateInMillis() / 1000)
        dateFormatter.locale = Locale(identifier: "en_US")
        print(dateFormatter.string(from: date))
        print(dateFormatter.string(from: date1))
        print(dateFormatter.string(from: date2))
        cell.textEpisodeTitle.text = DateUtils.getAppDateFromMillis(dataset[indexPath.row].getDateInMillis())
        let customFont = UIFont(name: "FuturaPT-Demi", size: 20.0)
        cell.textEpisodeTitle.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont ?? UIFont.systemFont(ofSize: 35.0))
        cell.textEpisodeTitle.adjustsFontForContentSizeCategory = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return  CGSize(width: collectionView.frame.size.width, height: (collectionView.frame.size.width / 3))
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
        currentPageIndex = indexPath.row
        pageControl.currentPage = currentPageIndex
    }
}
