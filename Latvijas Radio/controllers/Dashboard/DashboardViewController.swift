//
//  DashboardViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit
import FirebaseAnalytics

class DashboardViewController: UIViewController, UIScrollViewDelegate {
    
    static var TAG = String(describing: DashboardViewController.classForCoder())

    static var needsScrollReset = false
    static var needsUpdate = false
    static var livestreamsCompactListNeedsUpdate = false
    static let EVENT_SCROLL_TO_TOP_DASCHBOARD = "EVENT_SCROLL_TO_TOP_DASCHBOARD"

    @IBOutlet weak var mainScrollView: UIScrollViewCollaborative!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonViewAllLivestreams: UIButtonIBCustomizable!
    @IBOutlet weak var wrapperCampaignRadioteatris: UIView!
    @IBOutlet weak var containerDynamicBlocks: UIView!
    @IBOutlet weak var dynamicBlocksActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var wrapperLatestEpisodes: UIView!
    @IBOutlet weak var wrapperLatestEpisodesEqualHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textLatestEpisodes: UILabelH3!
    @IBOutlet weak var textNewestEpisodes: UILabelH3!
    @IBOutlet weak var containerEpisodesCollection: UIView!
    
    @IBOutlet weak var customViewRadio: UIView!
    @IBOutlet weak var customViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var newsHeightConstrain: NSLayoutConstraint!
    @IBOutlet weak var textTitleLivestreams: UILabelH3!

    weak var livestreamsCollectionViewController: LivestreamsCompactCollectionViewController!
    weak var dynamicBlocksCollectionViewController: DynamicBlocksCollectionViewController!
    weak var episodesCollectionViewController: EpisodesCollectionViewController!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var latestEpisodesCurrentPage = -1
    var isLoadMoreInProgress = false
    
    var customImageUrlLink = ""
    var customImageDeepLink = ""
    var customBigImageIsShow = false
    
    // Phone app use this variable to determine whether or not to show christmas livestream.
    var isChristmasLivestreamCampaignEnabled = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(DashboardViewController.TAG, "viewDidLoad")
        
        newsHeightConstrain.constant = (self.view.frame.size.width / 3)
        
        customBigImageIsShow = GeneralUtils.getUserDefaults().bool(forKey: Configuration.IS_BIG_IMAGE_POPUP_SHOW)

        // listeners
        buttonViewAllLivestreams.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTheTop), name: Notification.Name(DashboardViewController.EVENT_SCROLL_TO_TOP_DASCHBOARD), object: nil)

        setupCampaigns()
        
        configureMainScrollViewRefreshControl()
        
        performRequestCampaigns()

        performRequestContentSection()
        
        performRequestEpisodeLatest()
        
        // delegates
        mainScrollView.delegate = self
        
        refreshLivestreamsCompactList()
        let customFont = UIFont(name: "FuturaPT-Book", size: 20.0)
        textTitleLivestreams.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont ?? UIFont.systemFont(ofSize: 35.0))
        textTitleLivestreams.adjustsFontForContentSizeCategory = true
        textLatestEpisodes.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont ?? UIFont.systemFont(ofSize: 35.0))
        textLatestEpisodes.adjustsFontForContentSizeCategory = true
        let tapScrollUp = UITapGestureRecognizer(target: self, action: #selector(scrollToTheTop(_:)))
        textLatestEpisodes.isUserInteractionEnabled = true
        textLatestEpisodes.addGestureRecognizer(tapScrollUp)
    }

    @objc func scrollToTheTop(_ sender: UITapGestureRecognizer) {
//        let topOffest = CGPoint(x: 0, y: -(self.mainScrollView?.contentInset.top ?? 0))
//        self.mainScrollView.setContentOffset(topOffest, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            self?.mainScrollView.setContentOffset(.zero, animated: false)
        }
        if (episodesCollectionViewController.dataset.count > 0) {
            episodesCollectionViewController.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
//        let topOffest1 = CGPoint(x: 0, y: -(self.livestreamsCollectionViewController.collectionView?.contentInset.top ?? 0))
//        self.livestreamsCollectionViewController.collectionView.setContentOffset(topOffest1, animated: true)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch(segue.identifier ?? "") {
        case StoryboardsHelper.SEGUE_EMBED_LIVESTREAMS_COMPACT_COLLECTION:
            self.livestreamsCollectionViewController = (segue.destination as! LivestreamsCompactCollectionViewController)
            self.livestreamsCollectionViewController.collectionView.scrollsToTop = true
            break
        case StoryboardsHelper.SEGUE_EMBED_DYNAMIC_BLOCKS_COLLECTION:
            self.dynamicBlocksCollectionViewController = (segue.destination as! DynamicBlocksCollectionViewController)
            
            break
        case StoryboardsHelper.SEGUE_EMBED_EPISODES_COLLECTION:
            self.episodesCollectionViewController = (segue.destination as! EpisodesCollectionViewController)
            self.episodesCollectionViewController.scrollDelegate = self
            self.episodesCollectionViewController.episodesCollectionLoadMoreDelegate = self
            self.episodesCollectionViewController.isLoadMoreEnabled = true
            self.episodesCollectionViewController.collectionView.scrollsToTop = true
            break
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reset scrolls.
        if (DashboardViewController.needsScrollReset) {
            DashboardViewController.needsScrollReset = false
            
            DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
                self?.mainScrollView.setContentOffset(.zero, animated: false)
            }

            if (episodesCollectionViewController.dataset.count > 0) {
                episodesCollectionViewController.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
        }
        
        if (DashboardViewController.livestreamsCompactListNeedsUpdate) {
            DashboardViewController.livestreamsCompactListNeedsUpdate = false
            
            refreshLivestreamsCompactList()
        }

        checkIfViewControllerNeedsUpdate()
    }

    deinit {
        GeneralUtils.log(DashboardViewController.TAG, "deinit")
        
        DashboardViewController.needsScrollReset = false
        DashboardViewController.needsUpdate = false
        DashboardViewController.livestreamsCompactListNeedsUpdate = false
    }
    
    // MARK: UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        CollaborativeScrollViewHelper.scrollViewDidScroll(scrollView, mainScrollView, (self.episodesCollectionViewController.collectionView as! UICollectionViewBase))
        
        // We need to enable bounce for top side to enable pull-to-refresh,
        // but keep it disabled for bottom side for ux.

        if (scrollView.contentOffset.y <= 0) {
            scrollView.bounces = true
        } else {
            scrollView.bounces = false
        }
    }
    
    // MARK: Custom
    
    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonViewAllLivestreams) {
            appDelegate.dashboardContainerViewController?.navigateToPage(NavigationViewController.NAVIGATION_ITEM_INDEX_LIVESTREAMS)
        }
    }
    
    @objc func appMovedToForeground() {
        checkIfViewControllerNeedsUpdate()
    }

    func setupCampaigns() {
//        buttonCampaignRadioteatris.addTarget(self, action: #selector(handleClickButtonCampaignRadioteatris), for: .touchUpInside)
    }
    
    func configureMainScrollViewRefreshControl() {
        mainScrollView.refreshControl = UIRefreshControl()
        mainScrollView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }

    @objc func handleRefreshControl() {
        mainScrollView.refreshControl?.endRefreshing()
        
        DashboardViewController.needsUpdate = true
        
        checkIfViewControllerNeedsUpdate()
    }
    
    @objc func handleClickButtonCampaignRadioteatris(_ sender: UIView) {
        let channelModel = ChannelsManager.getChannelById(ChannelsManager.ID_LATVIJAS_RADIO_RADIOTEATRIS)
        
        let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_BROADCASTS_FILTERED, bundle: nil)
                                .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_BROADCASTS_FILTERED) as! BroadcastsFilteredViewController)
        
        viewController.channelModel = channelModel
        
        navigationController?.pushViewController(viewController, animated: true)
    }

    func performRequestGetRadioChannels() {
        let channelId = ""
        let channelRadioRequest = ChannelRadioRequest(appDelegate.dashboardContainerViewController!.notificationViewController, channelId)


        channelRadioRequest.successCallback = { [weak self] (data, data1) -> Void in
            print("channelRadioRequest data = \(data),  data1 = \(data1)")
                    self?.handleRadioChannelsResponse(data, data1)
                }
        channelRadioRequest.errorCallback = { [weak self] in
            print("channelRadioRequest.errorCallback")
        }

        channelRadioRequest.execute()
    }

    func handleRadioChannelsResponse(_ data: [String: Any], _ data1: Data) {

        var dataset = [RadioChannel]()
//        saveJsonFromData(data: data1, name: "radioChannels1.json")
        do {
            let someDictionaryFromJSON = try JSONSerialization.jsonObject(with: data1, options: .allowFragments) as! [String: Any]
            print("DashboardViewController handleRadioChannelsResponse someDictionaryFromJSON = \(someDictionaryFromJSON)")
//            let json4Swift_Base = try SearchSuccess(someDictionaryFromJSON)
            let jsonDecoder = JSONDecoder()
            let json4Swift_Base = try jsonDecoder.decode(ChannelsSuccess.self, from: data1)

            let radioChannels = json4Swift_Base.results
            //        let hits = data[SearchRequest.RESPONSE_PARAM_HITS] as! [[String: Any]]
            print("DashboardViewController handleRadioChannelsResponse radioChannels = \(String(describing: radioChannels))")
            if (radioChannels?.count ?? 0 > 0) {
                for i in (0..<(radioChannels?.count ?? 0)) {
                    if let radioChannel = radioChannels?[i] {
                        dataset.append(radioChannel)
                    }
                }

                var fullRadioChannelDataset: [RadioChannel]!
                fullRadioChannelDataset = [RadioChannel]()
                fullRadioChannelDataset.append(contentsOf: dataset)

                let usersManager = UsersManager.getInstance()
                if let currentUser = usersManager.getCurrentUser() {
                    let orderedLivestreamsDataset = LivestreamsManager.getOrderedList(currentUser)

                    let curatedLivestreamsDataset = LivestreamsManager.getCuratedList(orderedLivestreamsDataset, isChristmasLivestreamCampaignEnabled)
                    if let r1 = saveJsonFromData(data: data1, name: "radioChannels1") as? Bool,
                       r1 == true {
                        let orderedLivestreamsDataset = LivestreamsManager.getOrderedList(currentUser)
                        let curatedLivestreamsDataset = LivestreamsManager.getCuratedList(orderedLivestreamsDataset, isChristmasLivestreamCampaignEnabled)

                        livestreamsCollectionViewController.updateDataset(curatedLivestreamsDataset)
                        livestreamsCollectionViewController.updateDataset(curatedLivestreamsDataset)
                    }

//                    livestreamsCollectionViewController.updateDataset(fullRadioChannelDataset)
                }
            }
        } catch DecodingError.keyNotFound(let key, let context) {
            fatalError("Failed to decode due to missing key '\(key.stringValue)' not found – \(context.debugDescription)")
        } catch DecodingError.typeMismatch(let type, let context) {
            fatalError("Failed to decode due to type mismatch '\(type)' – \(context.codingPath) - \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type, let context) {
            fatalError("Failed to decode due to missing \(type) value – \(context.debugDescription)")
        } catch DecodingError.dataCorrupted(_) {
            fatalError("Failed to decode because it appears to be invalid JSON")
        } catch {
            fatalError("Failed to decode: \(error.localizedDescription)")
        }
    }

    func saveJsonFromData(data: Data, name: String) -> Bool {

        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        var saved = false
        if let n = "\(name).json" as? String,
           let url1 = URL(string: n)
        {
//            DispatchQueue(label: "\(Bundle.main.bundleIdentifier ?? "").backgrounds.saveRadioChannels", qos: DispatchQoS.background).async {[weak self] () -> Void in

                let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("\(name).json")
                print(paths)

                do {
                    try data.write(to: (directory.appendingPathComponent("\(url1.absoluteString)") ?? nil)!, options: [.atomicWrite])
                    saved = true
                    DispatchQueue.main.async {
//                        reload data ui
                    }
                } catch {
                    print(error.localizedDescription)
                    saved = false
                }
//            }
            return saved
        } else {
            return saved
        }
    }


    func refreshLivestreamsCompactList() {
        let usersManager = UsersManager.getInstance()
        if let currentUser = usersManager.getCurrentUser() {
            let orderedLivestreamsDataset = LivestreamsManager.getOrderedList(currentUser)
            if orderedLivestreamsDataset.count == 0 {
                performRequestGetRadioChannels()
                return
            }
            let curatedLivestreamsDataset = LivestreamsManager.getCuratedList(orderedLivestreamsDataset, isChristmasLivestreamCampaignEnabled)
            
            livestreamsCollectionViewController.updateDataset(curatedLivestreamsDataset)
            performRequestGetRadioChannels()
        }
    }
    
    func checkIfViewControllerNeedsUpdate() {
        if (DashboardViewController.needsUpdate) {
            DashboardViewController.needsUpdate = false

            if let dashboardContainerViewController = appDelegate.dashboardContainerViewController {
                if let mainPageViewController = dashboardContainerViewController.mainPageViewController {
                    // Has to be read before vc is replaced.
                    let currentPageIndex = mainPageViewController.getCurrentPageIndex()
                    
                    let viewController = UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_DASHBOARD, bundle: nil)
                        .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_DASHBOARD) as! DashboardViewController
                    
                    mainPageViewController.orderedViewControllers[NavigationViewController.NAVIGATION_ITEM_INDEX_DASHBOARD] = viewController
                    
                    // If this view controller IS the current active tab, reload it.
                    if (currentPageIndex == NavigationViewController.NAVIGATION_ITEM_INDEX_DASHBOARD) {
                        mainPageViewController.setViewControllers([mainPageViewController.orderedViewControllers[NavigationViewController.NAVIGATION_ITEM_INDEX_DASHBOARD]], direction: .forward, animated: false, completion: nil)
                    }
                }
            }
        }
    }
        
    func setViewStateCampaignRadioteatrisNormal() {
        wrapperCampaignRadioteatris.setVisibility(UIView.VISIBILITY_VISIBLE)
    }
    
    func setViewStateCampaignRadioteatrisHidden() {
        wrapperCampaignRadioteatris.setVisibility(UIView.VISIBILITY_GONE)
    }

    func setViewStateContentSectionNormal() {
        containerDynamicBlocks.isHidden = false
        dynamicBlocksActivityIndicator.setVisibility(UIView.VISIBILITY_GONE)
    }

    func setViewStateContentSectionLoading() {
        containerDynamicBlocks.isHidden = true
        dynamicBlocksActivityIndicator.setVisibility(UIView.VISIBILITY_VISIBLE)
    }
    
    func setViewStateContentSectionNoResults() {
        containerDynamicBlocks.setVisibility(UIView.VISIBILITY_GONE)
        dynamicBlocksActivityIndicator.setVisibility(UIView.VISIBILITY_GONE)
    }
    
    func setViewStateLatestEpisodesNormal() {
        textLatestEpisodes.setVisibility(UIView.VISIBILITY_VISIBLE)
        containerEpisodesCollection.setVisibility(UIView.VISIBILITY_VISIBLE)
    }

    func setViewStateLatestEpisodesInitialLoading() {
        textLatestEpisodes.setVisibility(UIView.VISIBILITY_VISIBLE)
        containerEpisodesCollection.setVisibility(UIView.VISIBILITY_VISIBLE)
    }
    
    func setViewStateLatestEpisodesInitialNoResults() {
        wrapperLatestEpisodesEqualHeightConstraint.isActive = false
        
        wrapperLatestEpisodes.setVisibility(UIView.VISIBILITY_GONE)
    }
        
    func performRequestCampaigns() {
        setViewStateCampaignRadioteatrisHidden()
        
        let campaignsRequest = CampaignsRequest(nil)

        campaignsRequest.successCallback = { [weak self] (data) -> Void in
            self?.handleRequestCampaignsResponse(data)
        }
        
        campaignsRequest.errorCallback = { [weak self] in
            self?.setViewStateCampaignRadioteatrisHidden()
        }
        
        campaignsRequest.execute()
    }
    
    func handleRequestCampaignsResponse(_ data: [String: Any]) {
        // Reset states to defaults.
        setViewStateCampaignRadioteatrisHidden()
        isChristmasLivestreamCampaignEnabled = false
        
       // Analytics.logEvent("car_connect", parameters: [:])
        
        let campaignsJsonArray = data[CampaignsRequest.RESPONSE_PARAM_CAMPAIGNS] as! [[String: Any]]
        
        if (campaignsJsonArray.count > 0) {
            let campaigns = CampaignsHelper.getCampaignsListFromJsonArray(campaignsJsonArray)
            
            var containerHeight: CGFloat = 0
            
            for i in (0..<campaigns.count) {
                let campaign = campaigns[i]
                
                customViewRadio.backgroundColor = .clear
                
                if (campaign.getId() == CampaignModel.ID_RADIOTEATRIS) {
                    containerHeight = 124
                    
                    let imageCampaignRadioteatris = UIImageView()
                    imageCampaignRadioteatris.sd_setImage(
                        with: URL(string: campaign.getImageUrl()),
                        placeholderImage: nil
                    )
                    imageCampaignRadioteatris.translatesAutoresizingMaskIntoConstraints = false
                    
                    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleClickButtonCampaignRadioteatris))
                    imageCampaignRadioteatris.isUserInteractionEnabled = true
                    imageCampaignRadioteatris.addGestureRecognizer(tapGestureRecognizer)
                    
                    imageCampaignRadioteatris.contentMode = .scaleToFill
                    customViewRadio.addSubview(imageCampaignRadioteatris)
                    
                    NSLayoutConstraint.activate([
                        imageCampaignRadioteatris.topAnchor.constraint(equalTo: customViewRadio.topAnchor, constant: 0),
                        //imageCampaignRadioteatris.bottomAnchor.constraint(equalTo: customViewRadio.bottomAnchor, constant: 0),
                        imageCampaignRadioteatris.leftAnchor.constraint(equalTo: customViewRadio.leftAnchor, constant: 0),
                        imageCampaignRadioteatris.rightAnchor.constraint(equalTo: customViewRadio.rightAnchor, constant: 0),
                        imageCampaignRadioteatris.heightAnchor.constraint(equalToConstant: 100)
                    ])
                }
                
                if (campaign.getId() == CampaignModel.NEW_CUSTOM && campaign.publishedFrom != "" && campaign.publishedTo != "") {
                    
                    let dateFormatterFrom = DateFormatter()
                    dateFormatterFrom.dateFormat = "dd'.'MM'.'yyyy'"
                    let fromDate = dateFormatterFrom.date(from: campaign.publishedFrom)
                    let toDate = dateFormatterFrom.date(from: campaign.publishedTo)
                    
                    if (fromDate != nil && toDate != nil) {
                        let fromDateToCheck = fromDate!.timeIntervalSinceNow
                        let toDateToCheck = toDate!.timeIntervalSinceNow
                        let isTodayFrom = Calendar.current.isDateInToday(fromDate!)
                        let isTodayTo = Calendar.current.isDateInToday(toDate!)
                        
                        if (fromDateToCheck < 0 && toDateToCheck > 0 || isTodayFrom || isTodayTo) {
                            if (campaign.displayType == "none" || campaign.displayType == "both" || (campaign.displayType == "car_only" && CarPlaySceneDelegate.getCarPlaySceneDelegate() != nil)) {
                                containerHeight = containerHeight + 100
                                customImageUrlLink = campaign.link
                                
                                let imageCustomImage = UIImageView()
                                imageCustomImage.sd_setImage(
                                    with: URL(string: campaign.getImageUrl()),
                                    placeholderImage: nil
                                )
                                imageCustomImage.translatesAutoresizingMaskIntoConstraints = false
                                
                                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleClickCustomImage))
                                imageCustomImage.isUserInteractionEnabled = true
                                imageCustomImage.addGestureRecognizer(tapGestureRecognizer)
                                
                                customViewRadio.addSubview(imageCustomImage)
                                imageCustomImage.contentMode = .scaleToFill
                                
                                NSLayoutConstraint.activate([
                                    imageCustomImage.heightAnchor.constraint(equalToConstant: 100),
                                    imageCustomImage.bottomAnchor.constraint(equalTo: customViewRadio.bottomAnchor, constant: 0),
                                    imageCustomImage.leftAnchor.constraint(equalTo: customViewRadio.leftAnchor, constant: 0),
                                    imageCustomImage.rightAnchor.constraint(equalTo: customViewRadio.rightAnchor, constant: 0),
                                ])
                            }
                            
                            //"none", "both", "car_only"
                            if (customBigImageIsShow == false) {
                                if (campaign.displayType == "both" || (campaign.displayType == "car_only" && CarPlaySceneDelegate.getCarPlaySceneDelegate() != nil)) {
                                    customBigImageIsShow = true
                                    showPopupWithImage(imageUrl: campaign.bigImageUrl, urlLink: campaign.link)
                                }
                            }
                        }
                    }
                }
                
                if (campaign.getId() == CampaignModel.ID_CHRISTMAS_LIVESTREAM) {
                    isChristmasLivestreamCampaignEnabled = true
                }
            }
            customViewHeightConstraint.constant = containerHeight
            setViewStateCampaignRadioteatrisNormal()
        }

        // Refresh livestreams horizontal slider.
        refreshLivestreamsCompactList()
        
        // Refresh livestreams fragment.
        if let dashboardContainerViewController = appDelegate.dashboardContainerViewController {
            if let mainPageViewController = dashboardContainerViewController.mainPageViewController {
                // Has to be read before vc is replaced.
                let currentPageIndex = mainPageViewController.getCurrentPageIndex()
                
                let viewController = UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_LIVESTREAMS, bundle: nil)
                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_LIVESTREAMS) as! LivestreamsViewController
                
                mainPageViewController.orderedViewControllers[NavigationViewController.NAVIGATION_ITEM_INDEX_LIVESTREAMS] = viewController
                
                // If this view controller IS the current active tab, reload it.
                if (currentPageIndex == NavigationViewController.NAVIGATION_ITEM_INDEX_LIVESTREAMS) {
                    mainPageViewController.setViewControllers([mainPageViewController.orderedViewControllers[NavigationViewController.NAVIGATION_ITEM_INDEX_LIVESTREAMS]], direction: .forward, animated: false, completion: nil)
                }
            }
        }
    }
    
    @objc func handleClickCustomImage() {
        if (customImageUrlLink != "") {
            if (customImageUrlLink.contains("deeplink")) {
                let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
                userActivity.webpageURL = URL(string: customImageUrlLink)
                DeepLinkManager.validateAndExtractDataFromDeepLink(userActivity)
            } else {
                if let url = URL(string: customImageUrlLink) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    func showPopupWithImage(imageUrl: String, urlLink: String) {
        let vc = DashboardPopupViewController()
        vc.imageLink = imageUrl
        vc.urlLink = urlLink
        vc.view.backgroundColor = UIColor(named: ColorsHelper.WHITE)
        vc.modalPresentationStyle = .popover
        self.present(vc, animated: true, completion: nil)
    }
    
    func performRequestContentSection() {
        setViewStateContentSectionLoading()
        
        let contentSectionRequest = ContentSectionRequest(appDelegate.dashboardContainerViewController!.notificationViewController, ContentSectionRequest.SECTION_ID_DASHBOARD)

        contentSectionRequest.successCallback = { [weak self] (data) -> Void in
            self?.handleContentSectionResponse(data)
        }
        
        contentSectionRequest.errorCallback = { [weak self] in
            self?.setViewStateContentSectionNoResults()
        }
        
        contentSectionRequest.execute()
    }
    
    func handleContentSectionResponse(_ data: [String: Any]) {
        var dataset = [DynamicBlockModel]()
        
        let blocks = data[ContentSectionRequest.RESPONSE_PARAM_BLOCKS] as! [[String: Any]]
        
        if (blocks.count > 0) {
            for i in (0..<blocks.count) {
                let block = blocks[i]
                
                let name = block[ContentSectionRequest.RESPONSE_PARAM_NAME] as? String
                let presentationTypeId = block[ContentSectionRequest.RESPONSE_PARAM_PRESENTATION_TYPE_ID] as! Int
                let contentType = block[ContentSectionRequest.RESPONSE_PARAM_CONTENT_TYPE] as! String
                let items = block[ContentSectionRequest.RESPONSE_PARAM_ITEMS] as! [NSDictionary]
                
                let dynamicBlockModel = DynamicBlockModel(name, String(presentationTypeId), contentType)
                dynamicBlockModel.setItems(items)
                
                dataset.append(dynamicBlockModel)
            }
            
            dynamicBlocksCollectionViewController.updateDataset(dataset)
            
            setViewStateContentSectionNormal()
        } else {
            setViewStateContentSectionNoResults()
        }
    }
    
    func performRequestEpisodeLatest() {
        isLoadMoreInProgress = true
        
        latestEpisodesCurrentPage = latestEpisodesCurrentPage + 1
        
        if (latestEpisodesCurrentPage == 0) {
            setViewStateLatestEpisodesInitialLoading()
        }
        
        // params
        var urlPathParams = "?"
        urlPathParams = urlPathParams + "page=" + String(latestEpisodesCurrentPage)
        
        let episodeLatestRequest = EpisodeLatestRequest(appDelegate.dashboardContainerViewController!.notificationViewController, urlPathParams)

        episodeLatestRequest.successCallback = { [weak self] (data) -> Void in
            self?.isLoadMoreInProgress = false
            
            self?.handleEpisodeLatestResponse(data)
        }
        
        episodeLatestRequest.errorCallback = { [weak self] in
            self?.isLoadMoreInProgress = false
            
            if (self?.latestEpisodesCurrentPage == 0) {
                self?.setViewStateLatestEpisodesInitialNoResults()
            } else {
                self?.setEpisodesCollectionStateNoMoreToLoad()
            }
        }

        episodeLatestRequest.execute()
    }

    func handleEpisodeLatestResponse(_ data: [String: Any]) {
        let episodes = data[EpisodeLatestRequest.RESPONSE_PARAM_EPISODES] as! [[String: Any]]
        
        if (episodes.count > 0) {
            let dataset: [EpisodeModel] = EpisodesHelper.getEpisodesListFromJsonArray(episodes)
            
            episodesCollectionViewController.updateDataset(dataset)

            setViewStateLatestEpisodesNormal()
        } else {
            if (latestEpisodesCurrentPage == 0) {
                setViewStateLatestEpisodesInitialNoResults()
            } else {
                setEpisodesCollectionStateNoMoreToLoad()
            }
        }
    }
    
    func setEpisodesCollectionStateNoMoreToLoad() {
        episodesCollectionViewController.generateLoadMoreItem = false
        
        let datasetCount = episodesCollectionViewController.dataset.count
        
        episodesCollectionViewController.collectionView.reloadItems(at: [IndexPath(row: datasetCount, section: 0)])
        
        episodesCollectionViewController.collectionView.scrollToItem(at: IndexPath(row: datasetCount - 1, section: 0), at: .top, animated: false)
    }
}

extension DashboardViewController: EpisodesCollectionLoadMoreDelegate {
    func getIsLoadMoreInProgress() -> Bool {
        return isLoadMoreInProgress
    }
    
    func onClickButtonLoadMore() {
        performRequestEpisodeLatest()
    }
}
