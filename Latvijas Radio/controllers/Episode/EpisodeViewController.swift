//
//  EpisodeViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class EpisodeViewController: UIViewController, UIScrollViewDelegate {
    
    static var TAG = String(describing: EpisodeViewController.classForCoder())

    @IBOutlet weak var textMoreAboutThisTopic: UILabelH4!
    @IBOutlet weak var containerPlayerMini: UIView!
    @IBOutlet weak var containerPlayerMiniBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerSharingPanel: UIView!
    @IBOutlet weak var containerSharingPanelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainScrollView: UIScrollViewCollaborative!
    @IBOutlet weak var containerNotification: UIView!
    @IBOutlet weak var wrapperActivityIndicator: UIView!
    @IBOutlet weak var buttonBack: UIButtonQuinary!
    @IBOutlet weak var textCategoryName: UILabelBase!
    @IBOutlet weak var buttonSubscribe: UIButtonQuinary!
    @IBOutlet weak var buttonUnsubscribe: UIButtonQuinary!
    @IBOutlet weak var subscriptionActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var textDate: UILabelLabel6!
    @IBOutlet weak var textTitle: UILabelH2!
    @IBOutlet weak var buttonBroadcastName: UIButtonIBCustomizable!
    @IBOutlet weak var textHosts: UILabelLabel7!
    @IBOutlet weak var buttonTogglePlayback: UIButtonGenericWithImage!
    @IBOutlet weak var textTotalDuration: UILabelBase!
    @IBOutlet weak var textDescription: UILabelHtml!
    @IBOutlet weak var buttonShare: UIButtonGenericWithImage!
    @IBOutlet weak var buttonDownload: UIButtonGenericWithImage!
    @IBOutlet weak var downloadProgress: CustomProgressView!
    @IBOutlet weak var textNoEpisodes: UILabelLabel1!
    @IBOutlet weak var episodesActivityIndicator: UIActivityIndicatorView!
    
    weak var notificationViewController: NotificationViewController!
    weak var playerMiniViewController: PlayerMiniViewController!
    weak var sharingPanelViewController: SharingPanelViewController!
    weak var episodesCollectionViewController: EpisodesCollectionViewController!
    
    var episodeModel: EpisodeModel!
    var listOfEpisodes: [EpisodeModel]?
    var deepLinkSharedEpisodeModel: DeepLinkSharedEpisodeModel?
    var episodeViewControllerButtonDownloadHelper: EpisodeViewControllerButtonDownloadHelper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(EpisodeViewController.TAG, "viewDidLoad")
        
        // variables
        episodeViewControllerButtonDownloadHelper = EpisodeViewControllerButtonDownloadHelper()
        episodeViewControllerButtonDownloadHelper.viewController = self
                
        // listeners
        buttonBack.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonSubscribe.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonUnsubscribe.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonBroadcastName.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonTogglePlayback.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonShare.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonDownload.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)

        setupMediaPlayerListeners()
        
        // delegates
        mainScrollView.delegate = self

        // UI
        setViewStateLoading()
        
        MediaPlayerManager.getInstance().triggerAllPlayersUiSetupOrUpdate()

        if (episodeModel != nil) {
            continueWithAcquiredEpisodeData()
        } else {
            performRequestGetEpisodeData()
        }
        let customFont = UIFont(name: "FuturaPT-Book", size: 20.0)
        textMoreAboutThisTopic.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont ?? UIFont.systemFont(ofSize: 35.0))
        textMoreAboutThisTopic.adjustsFontForContentSizeCategory = true
        let customFont1 = UIFont(name: "FuturaPT-Book", size: 13.0) //UIFont.systemFont(ofSize: 13.0)
        textCategoryName.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont1 ?? UIFont.systemFont(ofSize: 13.0))
        textCategoryName.adjustsFontForContentSizeCategory = true
        let customFont2 = UIFont.systemFont(ofSize: 17.0)
        textDate.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont2 ?? UIFont.systemFont(ofSize: 17.0))
        textDate.adjustsFontForContentSizeCategory = true
        textTitle.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont2 ?? UIFont.systemFont(ofSize: 17.0))
        textTitle.adjustsFontForContentSizeCategory = true
        textHosts.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont2 ?? UIFont.systemFont(ofSize: 17.0))
        textHosts.adjustsFontForContentSizeCategory = true
        let customFont3 = UIFont(name: "FuturaPT-Book", size: 10.0)
        textTotalDuration.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont3 ?? UIFont.systemFont(ofSize: 10.0))
        textTotalDuration.adjustsFontForContentSizeCategory = true
        textDescription.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont1 ?? UIFont.systemFont(ofSize: 13.0))
        textDescription.adjustsFontForContentSizeCategory = true
        textMoreAboutThisTopic.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont3 ?? UIFont.systemFont(ofSize: 10.0))
        textMoreAboutThisTopic.adjustsFontForContentSizeCategory = true
        textNoEpisodes.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont3 ?? UIFont.systemFont(ofSize: 10.0))
        textNoEpisodes.adjustsFontForContentSizeCategory = true
        let tapScrollUp = UITapGestureRecognizer(target: self, action: #selector(scrollToTheTop(_:)))
        textMoreAboutThisTopic.isUserInteractionEnabled = true
        textMoreAboutThisTopic.addGestureRecognizer(tapScrollUp)
    }

    @objc func scrollToTheTop(_ sender: UITapGestureRecognizer) {
            DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
                self?.mainScrollView.setContentOffset(.zero, animated: false)
            }
            if (episodesCollectionViewController.dataset.count > 0) {
                episodesCollectionViewController.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
        }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (episodeModel != nil) {
            performRequestGetEpisodeSubscriptionStatus()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch(segue.identifier ?? "") {
        case StoryboardsHelper.SEGUE_EMBED_NOTIFICATION:
            self.notificationViewController = (segue.destination as! NotificationViewController)
            self.notificationViewController.setContainerView(containerNotification)
            
            break
        case StoryboardsHelper.SEGUE_EMBED_PLAYER_MINI:
            self.playerMiniViewController = (segue.destination as! PlayerMiniViewController)
            self.playerMiniViewController.setContainerView(containerPlayerMini)
            self.playerMiniViewController.setContainerBottomConstraintReference(containerPlayerMiniBottomConstraint)

            break
        case StoryboardsHelper.SEGUE_EMBED_SHARING_PANEL:
            self.sharingPanelViewController = (segue.destination as! SharingPanelViewController)
            self.sharingPanelViewController.setContainerView(containerSharingPanel)
            self.sharingPanelViewController.setContainerBottomConstraintReference(containerSharingPanelBottomConstraint)
            
            break
        case StoryboardsHelper.SEGUE_EMBED_EPISODES_COLLECTION:
            self.episodesCollectionViewController = (segue.destination as! EpisodesCollectionViewController)
            self.episodesCollectionViewController.scrollDelegate = self
            self.episodesCollectionViewController.collectionView.scrollsToTop = true
            break
        default:
            break
        }
    }
    
    deinit {
        GeneralUtils.log(EpisodeViewController.TAG, "deinit")
    }
    
    // MARK: UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        CollaborativeScrollViewHelper.scrollViewDidScroll(scrollView, mainScrollView, (self.episodesCollectionViewController.collectionView as! UICollectionViewBase))
    }

    // MARK: Custom
    
    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonBack) {
            navigationController?.popViewController(animated: true)
        }
        if (sender == buttonSubscribe) {
            performRequestSetEpisodeSubscriptionStatus(subscribed: true)
        }
        if (sender == buttonUnsubscribe) {
            performRequestSetEpisodeSubscriptionStatus(subscribed: false)
        }
        if (sender == buttonBroadcastName) {
            let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_BROADCAST, bundle: nil)
                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_BROADCAST) as! BroadcastViewController)
            viewController.broadcastIdToQuery = episodeModel.getCategoryId()
            
            navigationController?.pushViewController(viewController, animated: true)
        }
        if (sender == buttonTogglePlayback) {
            startOrTogglePlayback()
        }
        if (sender == buttonShare) {
            sharingPanelViewController.togglePanel()
        }
        if (sender == buttonDownload) {
            episodeViewControllerButtonDownloadHelper.initDownloadOfEpisodeMediaFile()
        }
    }
    
    func setupMediaPlayerListeners() {
        NotificationCenter.default.addObserver(forName: Notification.Name(MediaPlayerManager.EVENT_UPDATE_MEDIA_PLAYER_STATE), object: nil, queue: .main) { [weak self] notification in
            GeneralUtils.log(EpisodeViewController.TAG, "EVENT_UPDATE_MEDIA_PLAYER_STATE")
            
            if (MediaPlayerManager.getInstance().currentEpisode != nil) {
                if let data = notification.userInfo as NSDictionary? {
                    var mediaPlayerState = data[MediaPlayerManager.NOTIFICATION_PARAMS_DEFAULT_KEY] as! String
                    
                    // We might be viewing specific episode from deep link, which hasn't loaded yet.
                    if (self?.episodeModel != nil) {
                        // If currentEpisode is the same as the one represented by this view controller,
                        // then update media player state.
                        // Otherwise set state to paused.
                        if (self?.episodeModel.getId() != MediaPlayerManager.getInstance().currentEpisode?.getId()) {
                            mediaPlayerState = MediaPlayerManager.MEDIA_PLAYER_STATE_PAUSED
                        }
                        
                        self?.updateMediaPlayerState(mediaPlayerState)
                    }
                }
            }
        }
    }
    
    func continueWithAcquiredEpisodeData() {
        populateViewWithData()
        
        episodeViewControllerButtonDownloadHelper.setupEpisodeDownloadButton(episodeModel)
        
        setViewStateNormal()
        
        performRequestGetEpisodeSubscriptionStatus()
        
        performRequestGetEpisodes()
    }
    
    func setViewStateNormal() {
        wrapperActivityIndicator.setVisibility(UIView.VISIBILITY_GONE)
    }

    func setViewStateLoading() {
        wrapperActivityIndicator.setVisibility(UIView.VISIBILITY_VISIBLE)
    }
    
    func setViewStateSubscriptionStatusNotSubscribed() {
        buttonSubscribe.isHidden = false
        buttonUnsubscribe.isHidden = true
        subscriptionActivityIndicator.setVisibility(UIView.VISIBILITY_GONE)
    }

    func setViewStateSubscriptionStatusSubscribed() {
        buttonSubscribe.isHidden = true
        buttonUnsubscribe.isHidden = false
        subscriptionActivityIndicator.setVisibility(UIView.VISIBILITY_GONE)
    }

    func setViewStateSubscriptionStatusLoading() {
        buttonSubscribe.isHidden = true
        buttonUnsubscribe.isHidden = true
        subscriptionActivityIndicator.setVisibility(UIView.VISIBILITY_VISIBLE)
    }
    
    func setViewStateEpisodesNormal() {
        episodesActivityIndicator.setVisibility(UIView.VISIBILITY_GONE)
        
        textNoEpisodes.setVisibility(UIView.VISIBILITY_GONE)
    }

    func setViewStateEpisodesLoading() {
        episodesActivityIndicator.setVisibility(UIView.VISIBILITY_VISIBLE)
        
        textNoEpisodes.setVisibility(UIView.VISIBILITY_GONE)
    }
    
    func setViewStateEpisodesNotFound() {
        episodesActivityIndicator.setVisibility(UIView.VISIBILITY_GONE)
        
        textNoEpisodes.setVisibility(UIView.VISIBILITY_VISIBLE)
    }

    func populateViewWithData() {
        // category name
        let categoryName = episodeModel.getCategoryName()
        let categoryNameParts = categoryName.components(separatedBy: ", ")
        
        var categoryNameModified = ""
        
        for i in (0..<categoryNameParts.count) {
            let categoryNamePart = categoryNameParts[i]
            
            categoryNameModified = categoryNameModified + "#" + categoryNamePart
            
            if (i < categoryNameParts.count - 1) {
                categoryNameModified = categoryNameModified + "\n"
            }
        }
        
        textCategoryName.setText(categoryNameModified)
        
        // date
        let dateInMillis = episodeModel.getDateInMillis()
        let formattedDate = DateUtils.getAppDateFromMillis(dateInMillis)
        textDate.setText(formattedDate)
        
        // title
        let title = episodeModel.getTitle()
        textTitle.setText(title)
        
        // broadcast name
        let broadcastName = episodeModel.getBroadcastName()
        buttonBroadcastName.setText(broadcastName, false)
        
        // hosts
        var hosts = ""
        let hostsJsonArray = episodeModel.getHosts()
        
        for i in (0..<hostsJsonArray.count) {
            let host = hostsJsonArray[i]
            
            let name = host["name"] as! String
            
            if (i > 0) {
                hosts = hosts + ", " + name
            } else {
                hosts = hosts + name
            }
        }
        
        textHosts.setText(hosts)
        
        // description
        let descriptionHtml = episodeModel.getDescription() ?? ""
        textDescription.setText(descriptionHtml.htmlToAttributedString!)
        
        // duration
        let mediaDurationInSeconds = episodeModel.getMediaDurationInSeconds()
        let formattedDuration = DateUtils.getTimelineFromSeconds(mediaDurationInSeconds)
        
        textTotalDuration.setText(formattedDuration)
        
        sharingPanelViewController.setEpisodeModel(episodeModel)
        sharingPanelViewController.updateSharingPanel()
    }
    
    func performRequestGetEpisodeSubscriptionStatus() {
        setViewStateSubscriptionStatusLoading()
        
        // params
        let episodeId = episodeModel.getId()

        let episodeSubscriptionStatusGetRequest = EpisodeSubscriptionStatusGetRequest(notificationViewController, episodeId)

        episodeSubscriptionStatusGetRequest.successCallback = { [weak self] (data) -> Void in
            self?.setViewStateSubscriptionStatusNotSubscribed()

            if let subscribed = data[EpisodeSubscriptionStatusGetRequest.RESPONSE_PARAM_SUBSCRIBED] as? Bool {
                if (subscribed) {
                    self?.setViewStateSubscriptionStatusSubscribed()
                }
            }
        }
        
        episodeSubscriptionStatusGetRequest.errorCallback = { [weak self] in
            self?.setViewStateSubscriptionStatusNotSubscribed()
        }

        episodeSubscriptionStatusGetRequest.execute()
    }
    
    func performRequestSetEpisodeSubscriptionStatus(subscribed: Bool) {
        setViewStateSubscriptionStatusLoading()
        
        UserSubscribedEpisodesManager.getInstance().performRequestSetEpisodeSubscriptionStatus(episodeModel, subscribed, { [weak self] in
            SubscribedEpisodesViewController.subscribedEpisodesListNeedsUpdate = true

            if (subscribed) {
                self?.setViewStateSubscriptionStatusSubscribed()
            } else {
                self?.setViewStateSubscriptionStatusNotSubscribed()
            }
        })
    }
    
    func performRequestGetEpisodes() {
        setViewStateEpisodesLoading()

        // params
        var urlPathParams = ""
        
        let newsBlocksJsonArray = episodeModel.getNewsBlocks()
        
        if (newsBlocksJsonArray.count > 0) {
            for i in (0..<newsBlocksJsonArray.count) {
                let newsBlock = newsBlocksJsonArray[i]
                let id = newsBlock["id"] as! String
                
                if (i == 0) {
                    urlPathParams = urlPathParams + "?"
                } else {
                    urlPathParams = urlPathParams + "&"
                }
                
                urlPathParams = urlPathParams + EpisodesByLsmTagsRequest.REQUEST_PARAM_LSM_TAGS + "=" + String(id)
            }
            
            urlPathParams = urlPathParams + "&episode_id_to_exclude=" + episodeModel.getId()
            
            let episodesByLsmTagsRequest = EpisodesByLsmTagsRequest(notificationViewController, urlPathParams)

            episodesByLsmTagsRequest.successCallback = { [weak self] (data) -> Void in
                self?.handleEpisodesByLsmTagsResponse(data)
            }

            episodesByLsmTagsRequest.execute()
        } else {
            setViewStateEpisodesNotFound()
        }
    }

    func handleEpisodesByLsmTagsResponse(_ data: [String: Any]) {
        let episodesJsonArray = data[EpisodesByLsmTagsRequest.RESPONSE_PARAM_EPISODES] as! [[String: Any]]
        let episodes = EpisodesHelper.getEpisodesListFromJsonArray(episodesJsonArray)

        if (episodes.count > 0) {
            episodesCollectionViewController.updateDataset(episodes)

            setViewStateEpisodesNormal()
        } else {
            setViewStateEpisodesNotFound()
        }
    }
    
    func performRequestGetEpisodeData() {
        setViewStateLoading()

        // params
        let episodeId = deepLinkSharedEpisodeModel!.getEpisodeId()  //"198042"

        let episodeDataRequest = EpisodeDataRequest(notificationViewController, episodeId)

        episodeDataRequest.successCallback = { [weak self] (data) -> Void in
            self?.episodeModel = EpisodesHelper.getEpisodeFromJsonObject(data)
            
            self?.continueWithAcquiredEpisodeData()
        }

        episodeDataRequest.execute()
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
            MediaPlayerManager.getInstance().performActionLoadAndPlayEpisode(MediaPlayerManager.PLAYBACK_TYPE_LOCAL_THEN_STREAM, episodeModel, listOfEpisodes)
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

