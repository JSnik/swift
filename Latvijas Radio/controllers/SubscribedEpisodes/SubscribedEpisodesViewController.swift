//
//  SubscribedEpisodesViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class SubscribedEpisodesViewController: UIViewController, EpisodesCompactDraggableCollectionDatasetChangedDelegate {
    
    static var TAG = String(describing: SubscribedEpisodesViewController.classForCoder())

    static var subscribedEpisodesListNeedsUpdate = false
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var containerEpisodesCompactDraggableCollection: UIView!
    @IBOutlet weak var textTitle: UILabelBase!
    
    weak var episodesCompactDraggableCollectionViewController: EpisodesCompactDraggableCollectionViewController!
    
    private var collectionDatasetObserver: NSKeyValueObservation?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var userSubscribedEpisodes = [EpisodeModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(SubscribedEpisodesViewController.TAG, "viewDidLoad")

        // listeners
        setupMediaPlayerListeners()
        
        // UI
        setViewStateLoading()

        setupLabelNoResults()
        
        performRequestUserSubscribedEpisodes()
        let customFont1 = UIFont(name: "FuturaPT-Medium", size: 13.0)
        textTitle.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont1 ?? UIFont.systemFont(ofSize: 13.0))
        textTitle.adjustsFontForContentSizeCategory = true
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTheTop), name: Notification.Name(MyRadioViewController.EVENT_SCROLL_TO_TOP_MYRADIO), object: nil)
    }

    @objc func scrollToTheTop() {
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            self?.episodesCompactDraggableCollectionViewController.collectionView.setContentOffset(.zero, animated: false)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let userSubscribedEpisodesManager = UserSubscribedEpisodesManager.getInstance()
        
        if (userSubscribedEpisodesManager.episodeItemHasCompletedWithAutoRemoveEnabled) {
            userSubscribedEpisodesManager.episodeItemHasCompletedWithAutoRemoveEnabled = false
            
            SubscribedEpisodesViewController.subscribedEpisodesListNeedsUpdate = true
        }
        
        if (SubscribedEpisodesViewController.subscribedEpisodesListNeedsUpdate) {
            SubscribedEpisodesViewController.subscribedEpisodesListNeedsUpdate = false
            
            performRequestUserSubscribedEpisodes()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch(segue.identifier ?? "") {
        case StoryboardsHelper.SEGUE_EMBED_EPISODES_COMPACT_DRAGGABLE_COLLECTION:
            episodesCompactDraggableCollectionViewController = (segue.destination as! EpisodesCompactDraggableCollectionViewController)

            if (parent?.parent != nil) {
                self.episodesCompactDraggableCollectionViewController.scrollDelegate = (parent!.parent as! MyRadioViewController)
            }
            
            episodesCompactDraggableCollectionViewController.episodesCompactDraggableCollectionDatasetChangedDelegate = self
            
            break
        default:
            break
        }
    }
    
    deinit {
        GeneralUtils.log(SubscribedEpisodesViewController.TAG, "deinit")
        
        SubscribedEpisodesViewController.subscribedEpisodesListNeedsUpdate = false
        
        collectionDatasetObserver?.invalidate()
    }
    
    // MARK: EpisodesCompactDraggableCollectionDatasetChangedDelegate
    
    func onDatasetChanged() {
        if (episodesCompactDraggableCollectionViewController.dataset.count > 0) {
            setViewStateNormal()
        } else {
            setViewStateNoResults()
        }
    }
    
    // MARK: Custom
    
    func setupMediaPlayerListeners() {
        NotificationCenter.default.addObserver(forName: Notification.Name(MediaPlayerManager.EVENT_ON_PLAYBACK_COMPLETED), object: nil, queue: .main) { [weak self] notification in
            GeneralUtils.log(SubscribedEpisodesViewController.TAG, "EVENT_ON_PLAYBACK_COMPLETED")

            if (self != nil) {
                // if auto-removal is enabled, remove subscribed episode item from list while it is visible to the user
                let usersMangager = UsersManager.getInstance()
                let currentUser = usersMangager.getCurrentUser()!
                
                if (currentUser.getAutomaticallyDeleteFinishedEpisodesFromMyList()) {
                    if let completedEpisode = MediaPlayerManager.getInstance().currentEpisode {
                        for i in (0..<self!.episodesCompactDraggableCollectionViewController.dataset.count) {
                            let episodeModel = self!.episodesCompactDraggableCollectionViewController.dataset[i]
                            
                            if (episodeModel.getId() == completedEpisode.getId()) {
                                self!.episodesCompactDraggableCollectionViewController.dataset.remove(at: i)
                                self!.episodesCompactDraggableCollectionViewController.collectionView.reloadItems(at: [IndexPath(row: i, section: 0)])
                                
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setViewStateNormal() {
        containerEpisodesCompactDraggableCollection.isHidden = false
        activityIndicator.setVisibility(UIView.VISIBILITY_GONE)
        textTitle.setVisibility(UIView.VISIBILITY_GONE)
    }

    func setViewStateLoading() {
        containerEpisodesCompactDraggableCollection.isHidden = true
        activityIndicator.setVisibility(UIView.VISIBILITY_VISIBLE)
        textTitle.setVisibility(UIView.VISIBILITY_GONE)
    }
    
    func setViewStateNoResults() {
        containerEpisodesCompactDraggableCollection.isHidden = false
        activityIndicator.setVisibility(UIView.VISIBILITY_GONE)
        textTitle.setVisibility(UIView.VISIBILITY_VISIBLE)
    }
    
    func setupLabelNoResults() {
        let attributedString = NSMutableAttributedString(string: "subscribed_episodes_no_results_description_1".localized())

        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: ImagesHelper.IC_ADD_TO_LIST_DEFAULT)
        imageAttachment.bounds = CGRect(x: 0, y: -1, width: 25.1, height: 16.3)
        attributedString.append(NSAttributedString(attachment: imageAttachment))

        attributedString.append(NSAttributedString(string: "subscribed_episodes_no_results_description_2".localized()))

        textTitle.attributedText = attributedString
    }
    
    func performRequestUserSubscribedEpisodes() {
        setViewStateLoading()

        let userSubscribedEpisodesRequest = UserSubscribedEpisodesRequest(appDelegate.dashboardContainerViewController!.notificationViewController)

        userSubscribedEpisodesRequest.successCallback = { [weak self] (data) -> Void in
            self?.handleUserSubscribedEpisodesResponse(data)
        }

        userSubscribedEpisodesRequest.execute()
    }
    
    func handleUserSubscribedEpisodesResponse(_ data: [String: Any]) {
        episodesCompactDraggableCollectionViewController.dataset.removeAll()
        episodesCompactDraggableCollectionViewController.collectionView.reloadData()
        
        let episodesJsonArray = data[UserSubscribedEpisodesRequest.RESPONSE_PARAM_EPISODES] as! [[String: Any]]
        
        if (episodesJsonArray.count > 0) {
            let dataset = EpisodesHelper.getEpisodesListFromJsonArray(episodesJsonArray)

            episodesCompactDraggableCollectionViewController.updateDataset(dataset)
            
            setViewStateNormal()
        } else {
            setViewStateNoResults()
        }
    }
}

