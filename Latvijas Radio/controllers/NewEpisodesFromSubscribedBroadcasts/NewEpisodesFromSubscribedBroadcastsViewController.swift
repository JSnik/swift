//
//  NewEpisodesFromSubscribedBroadcastsViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class NewEpisodesFromSubscribedBroadcastsViewController: UIViewController {
    
    static var TAG = String(describing: NewEpisodesFromSubscribedBroadcastsViewController.classForCoder())

    static var subscribedBroadcastsLatestEpisodesListNeedsUpdate = false
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var containerNewEpisodesFromSubscribedBroadcastsCollection: UIView!
    @IBOutlet weak var textTitle: UILabelBase!
    
    weak var episodesCollectionViewController: EpisodesCollectionViewController!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(NewEpisodesFromSubscribedBroadcastsViewController.TAG, "viewDidLoad")

        // UI
        setViewStateLoading()
        
        performRequestUserSubscribedBroadcastsLatestEpisodes()
        let customFont1 = UIFont(name: "FuturaPT-Medium", size: 13.0)
        textTitle.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont1 ?? UIFont.systemFont(ofSize: 13.0))
        textTitle.adjustsFontForContentSizeCategory = true
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTheTop), name: Notification.Name(MyRadioViewController.EVENT_SCROLL_TO_TOP_MYRADIO), object: nil)
    }

    @objc func scrollToTheTop() {
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            self?.episodesCollectionViewController.collectionView.setContentOffset(.zero, animated: false)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (NewEpisodesFromSubscribedBroadcastsViewController.subscribedBroadcastsLatestEpisodesListNeedsUpdate) {
            NewEpisodesFromSubscribedBroadcastsViewController.subscribedBroadcastsLatestEpisodesListNeedsUpdate = false

            performRequestUserSubscribedBroadcastsLatestEpisodes()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch(segue.identifier ?? "") {
        case StoryboardsHelper.SEGUE_EMBED_EPISODES_COLLECTION:
            episodesCollectionViewController = (segue.destination as! EpisodesCollectionViewController)

            if (parent?.parent != nil) {
                self.episodesCollectionViewController.scrollDelegate = (parent!.parent as! MyRadioViewController)
            }

            break
        default:
            break
        }
    }
    
    deinit {
        GeneralUtils.log(NewEpisodesFromSubscribedBroadcastsViewController.TAG, "deinit")
        
        NewEpisodesFromSubscribedBroadcastsViewController.subscribedBroadcastsLatestEpisodesListNeedsUpdate = false
    }
    
    // MARK: Custom
    
    func setViewStateNormal() {
        containerNewEpisodesFromSubscribedBroadcastsCollection.isHidden = false
        activityIndicator.setVisibility(UIView.VISIBILITY_GONE)
        textTitle.setVisibility(UIView.VISIBILITY_GONE)
    }

    func setViewStateLoading() {
        containerNewEpisodesFromSubscribedBroadcastsCollection.isHidden = true
        activityIndicator.setVisibility(UIView.VISIBILITY_VISIBLE)
        textTitle.setVisibility(UIView.VISIBILITY_GONE)
    }
    
    func setViewStateNoResults() {
        containerNewEpisodesFromSubscribedBroadcastsCollection.isHidden = true
        activityIndicator.setVisibility(UIView.VISIBILITY_GONE)
        textTitle.setVisibility(UIView.VISIBILITY_VISIBLE)
    }

    func performRequestUserSubscribedBroadcastsLatestEpisodes() {
        setViewStateLoading()

        let userSubscribedBroadcastsLatestEpisodesRequest = UserSubscribedBroadcastsLatestEpisodesRequest(appDelegate.dashboardContainerViewController!.notificationViewController)

        userSubscribedBroadcastsLatestEpisodesRequest.successCallback = { [weak self] (data) -> Void in
            self?.handleUserSubscribedBroadcastsLatestEpisodesResponse(data)
        }

        userSubscribedBroadcastsLatestEpisodesRequest.execute()
    }
    
    func handleUserSubscribedBroadcastsLatestEpisodesResponse(_ data: [String: Any]) {
        episodesCollectionViewController.dataset.removeAll()
        episodesCollectionViewController.collectionView.reloadData()
        
        let episodesJsonArray = data[UserSubscribedBroadcastsLatestEpisodesRequest.RESPONSE_PARAM_EPISODES] as! [[String: Any]]
        
        if (episodesJsonArray.count > 0) {
            let dataset = EpisodesHelper.getEpisodesListFromJsonArray(episodesJsonArray)
            
            episodesCollectionViewController.updateDataset(dataset)
            
            setViewStateNormal()
        } else {
            setViewStateNoResults()
        }
    }
}

