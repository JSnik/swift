//
//  BroadcastViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class BroadcastViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    static var TAG = String(describing: BroadcastViewController.classForCoder())

    @IBOutlet weak var containerPlayerMini: UIView!
    @IBOutlet weak var containerPlayerMiniBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerSharingPanel: UIView!
    @IBOutlet weak var containerSharingPanelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerNotification: UIView!
    @IBOutlet weak var mainScrollView: UIScrollViewCollaborative!
    @IBOutlet weak var wrapperActivityIndicator: UIView!
    @IBOutlet weak var buttonBack: UIButtonQuinary!
    @IBOutlet weak var buttonShare: UIButtonGenericWithCustomBackground!
    @IBOutlet weak var imageBroadcast: UIImageView!
    @IBOutlet weak var imageChannel: UIImageView!
    @IBOutlet weak var textCategory: UILabelBase!
    @IBOutlet weak var textTitle: UILabelH1!
    @IBOutlet weak var buttonSubscribe: UIButtonTertiaryFluid!
    @IBOutlet weak var buttonUnsubscribe: UIButtonTertiaryFluid!
    @IBOutlet weak var subscriptionActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var textDescription: UILabelHtml!
    @IBOutlet weak var textBroadcastHosts: UILabelH3!
    @IBOutlet weak var textHosts: UILabelP1!
    @IBOutlet weak var textAvailableEpisodes: UILabelH3!
    @IBOutlet weak var episodesActivityIndicator: UIActivityIndicatorView!

    weak var notificationViewController: NotificationViewController!
    weak var playerMiniViewController: PlayerMiniViewController!
    weak var sharingPanelViewController: SharingPanelViewController!
    weak var episodesCollectionViewController: EpisodesCollectionViewController!
    
    var broadcastModel: BroadcastModel!
    var broadcastIdToQuery: String!
    var channelModel: ChannelModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let swipeLeftToRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(moveToBack(_:)))
        mainScrollView.addGestureRecognizer(swipeLeftToRightGesture)
        GeneralUtils.log(BroadcastViewController.TAG, "viewDidLoad")

        // listeners
        buttonBack.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonShare.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonSubscribe.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonUnsubscribe.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)

        // delegates
        mainScrollView.delegate = self

        // UI
        setViewStateLoading()

        MediaPlayerManager.getInstance().triggerAllPlayersUiSetupOrUpdate()

        if (broadcastModel != nil) {
            continueWithAcquiredBroadcastData()
        } else {
            performRequestGetBroadcastData()
        }
        let customFont = UIFont(name: "FuturaPT-Book", size: 11.0)
        textCategory.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont ?? UIFont.systemFont(ofSize: 11.0))
        textCategory.adjustsFontForContentSizeCategory = true
        let customFont1 = UIFont.systemFont(ofSize: 17.0)
        textTitle.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont1 ?? UIFont.systemFont(ofSize: 17.0))
        textTitle.adjustsFontForContentSizeCategory = true
        let customFont2 = UIFont(name: "FuturaPT-Book", size: 13.0)
        textDescription.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont2 ?? UIFont.systemFont(ofSize: 13.0))
        textDescription.adjustsFontForContentSizeCategory = true
        let customFont3 = UIFont(name: "FuturaPT-Book", size: 10.0)
        textBroadcastHosts.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont3 ?? UIFont.systemFont(ofSize: 10.0))
        textBroadcastHosts.adjustsFontForContentSizeCategory = true
        textHosts.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont3 ?? UIFont.systemFont(ofSize: 10.0))
        textHosts.adjustsFontForContentSizeCategory = true
        textAvailableEpisodes.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont3 ?? UIFont.systemFont(ofSize: 10.0))
        textAvailableEpisodes.adjustsFontForContentSizeCategory = true
        let tapScrollUp = UITapGestureRecognizer(target: self, action: #selector(scrollToTheTop(_:)))
        textAvailableEpisodes.isUserInteractionEnabled = true
        textAvailableEpisodes.addGestureRecognizer(tapScrollUp)
        mainScrollView.scrollsToTop = true
    }

    @objc func moveToBack(_ sender:UISwipeGestureRecognizer) {
        switch sender.direction{
        case .left:
            navigationController?.popViewController(animated: true)
            break
            //left swipe action
        case .right:
            navigationController?.popViewController(animated: true)
            break
            //right swipe action
        default: //default
            break
        }
    }

    @objc func scrollToTheTop(_ sender: UITapGestureRecognizer) {
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            self?.mainScrollView.setContentOffset(.zero, animated: false)
        }
        if (episodesCollectionViewController.dataset.count > 0) {
            episodesCollectionViewController.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
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
        GeneralUtils.log(BroadcastViewController.TAG, "deinit")
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
        if (sender == buttonShare) {
            sharingPanelViewController.togglePanel()
        }
        if (sender == buttonSubscribe) {
            performRequestSetBroadcastSubscriptionStatus(subscribed: true)
        }
        if (sender == buttonUnsubscribe) {
            performRequestSetBroadcastSubscriptionStatus(subscribed: false)
        }
    }

    func continueWithAcquiredBroadcastData() {
        performRequestGetBroadcastSubscriptionStatus()

        performRequestGetEpisodes()
        
        populateViewWithData()

        setViewStateNormal()
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
    }

    func setViewStateEpisodesLoading() {
        episodesActivityIndicator.setVisibility(UIView.VISIBILITY_VISIBLE)
    }
    
    func populateViewWithData() {
        // update image
        if let imageUrl = broadcastModel.getImageUrl() {
            imageBroadcast.sd_setImage(with: URL(string: imageUrl), completed: nil)
        }
        
        // update channel image
        let channelId = broadcastModel.getChannelId()
        if let imageDrawableId = ChannelsHelper.getImageDrawableIdFromChannelId(channelId) {
            imageChannel.image = UIImage(named: imageDrawableId)
        }
        
        // category name
        let categoryName = "#" + broadcastModel.getCategoryName()
        textCategory.setText(categoryName)
        
        // title
        let title = broadcastModel.getTitle()
        textTitle.setText(title)
        
        // description
        if let descriptionHtml = broadcastModel.getDescription() {
            textDescription.setText(descriptionHtml.htmlToAttributedString!)
        }
        
        // hosts
        var hosts = ""
        let hostsJsonArray = broadcastModel.getHosts()
        
        if (hostsJsonArray.count == 0) {
            textBroadcastHosts.setVisibility(UIView.VISIBILITY_GONE)
            textHosts.setVisibility(UIView.VISIBILITY_GONE)
        } else {
            for i in (0..<hostsJsonArray.count) {
                let host = hostsJsonArray[i]
                
                let name = host[ContentSectionRequest.RESPONSE_PARAM_NAME] as! String
                
                if (i > 0) {
                    hosts = hosts + ", " + name
                } else {
                    hosts = hosts + name
                }
            }
            
            textHosts.setText(hosts)
        }

        // If broadcastModel contains url, then allow sharing.
        if (broadcastModel.getUrl() != nil) {
            buttonShare.isHidden = false

            sharingPanelViewController.setBroadcastModel(broadcastModel)
            sharingPanelViewController.updateSharingPanel()
        }
    }
    
    func performRequestGetBroadcastData() {
        setViewStateLoading()

        let broadcastDataRequest = BroadcastDataRequest(notificationViewController, broadcastIdToQuery)

        broadcastDataRequest.successCallback = { [weak self] (data) -> Void in
            let broadcastJson = data[BroadcastDataRequest.RESPONSE_PARAM_BROADCAST] as! [String: Any]
            
            self?.broadcastModel = BroadcastsHelper.getBroadcastFromJsonObject(broadcastJson)
            
            self?.continueWithAcquiredBroadcastData()
        }

        broadcastDataRequest.execute()
    }
    
    func performRequestGetBroadcastSubscriptionStatus() {
        setViewStateSubscriptionStatusLoading()
        
        // params
        let broadcastId = broadcastModel.getId()

        let broadcastSubscriptionStatusGetRequest = BroadcastSubscriptionStatusGetRequest(notificationViewController, broadcastId)

        broadcastSubscriptionStatusGetRequest.successCallback = { [weak self] (data) -> Void in
            self?.setViewStateSubscriptionStatusNotSubscribed()

            if let subscribed = data[BroadcastSubscriptionStatusGetRequest.RESPONSE_PARAM_SUBSCRIBED] as? Bool {
                if (subscribed) {
                    self?.setViewStateSubscriptionStatusSubscribed()
                }
            }
        }
        
        broadcastSubscriptionStatusGetRequest.errorCallback = { [weak self] in
            self?.setViewStateSubscriptionStatusNotSubscribed()
        }

        broadcastSubscriptionStatusGetRequest.execute()
    }
    
    func performRequestSetBroadcastSubscriptionStatus(subscribed: Bool) {
//        setViewStateSubscriptionStatusLoading()
        
        // params
        let broadcastId = broadcastModel.getId()

        let urlQueryItems = [
            URLQueryItem(name: BroadcastSubscriptionStatusPostRequest.REQUEST_PARAM_SUBSCRIBED, value: String(subscribed))
        ]

        let broadcastSubscriptionStatusPostRequest = BroadcastSubscriptionStatusPostRequest(notificationViewController, broadcastId, urlQueryItems)

        broadcastSubscriptionStatusPostRequest.successCallback = { [weak self] (data) -> Void in
            MyRadioViewController.subscribedBroadcastsListNeedsUpdate = true
            NewEpisodesFromSubscribedBroadcastsViewController.subscribedBroadcastsLatestEpisodesListNeedsUpdate = true
            
            if (subscribed) {
                self?.setViewStateSubscriptionStatusSubscribed()
            } else {
                self?.setViewStateSubscriptionStatusNotSubscribed()
            }
        }

        broadcastSubscriptionStatusPostRequest.execute()
    }

    func performRequestGetEpisodes() {
        setViewStateEpisodesLoading()

        // params
        let broadcastId = broadcastModel.getId()
        
        var urlPathParams = ""
        
        if let channelModel = channelModel {
            // If current broadcast belongs to channel "Radioteatris", then reverse episode order.
            if (channelModel.getId() == ChannelsManager.ID_LATVIJAS_RADIO_RADIOTEATRIS) {
                urlPathParams = "?"
                urlPathParams = urlPathParams + BroadcastEpisodesRequest.REQUEST_PARAM_SORT_BY_OLDEST + "=true"
            }
        }

        let broadcastEpisodesRequest = BroadcastEpisodesRequest(notificationViewController, broadcastId, urlPathParams)

        broadcastEpisodesRequest.successCallback = { [weak self] (data) -> Void in
            self?.handleBroadcastEpisodesResponse(data)
        }

        broadcastEpisodesRequest.execute()
    }

    func handleBroadcastEpisodesResponse(_ data: [String: Any]) {
        let episodesJsonArray = data[BroadcastEpisodesRequest.RESPONSE_PARAM_EPISODES] as! [[String: Any]]
        let episodes = EpisodesHelper.getEpisodesListFromJsonArray(episodesJsonArray)

        episodesCollectionViewController.updateDataset(episodes)

        setViewStateEpisodesNormal()
    }
}

