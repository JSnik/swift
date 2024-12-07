//
//  DownloadsViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class DownloadsViewController: UIViewController, EpisodesCollectionDatasetChangedDelegate {
    
    static var TAG = String(describing: DownloadsViewController.classForCoder())

    @IBOutlet weak var containerDownloadsCollection: UIView!
    @IBOutlet weak var textTitle: UILabelBase!
    
    weak var episodesCollectionViewController: EpisodesCollectionViewController!
    
    private var collectionDatasetObserver: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(DownloadsViewController.TAG, "viewDidLoad")

        // UI
        populateListEpisodes()
        let customFont1 = UIFont(name: "FuturaPT-Medium", size: 13.0)
        textTitle.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont1 ?? UIFont.systemFont(ofSize: 13.0))
        textTitle.adjustsFontForContentSizeCategory = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        populateListEpisodes()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch(segue.identifier ?? "") {
        case StoryboardsHelper.SEGUE_EMBED_EPISODES_COLLECTION:
            episodesCollectionViewController = (segue.destination as! EpisodesCollectionViewController)
            episodesCollectionViewController.isOfflineList = true
            
            if (parent?.parent != nil) {
                self.episodesCollectionViewController.scrollDelegate = (parent!.parent as! MyRadioViewController)
            }
            
            episodesCollectionViewController.episodesCollectionDatasetChangedDelegate = self
            self.episodesCollectionViewController.collectionView.scrollsToTop = true

            break
        default:
            break
        }
    }
    
    deinit {
        GeneralUtils.log(DownloadsViewController.TAG, "deinit")
        
        collectionDatasetObserver?.invalidate()
    }
    
    // MARK: EpisodesCollectionDatasetChangedDelegate
    
    func onDatasetChanged() {
        updateViewState()
    }
    
    // MARK: Custom

    func populateListEpisodes() {
        let usersManager = UsersManager.getInstance()
        let currentUser = usersManager.getCurrentUser()!

        let dataset = currentUser.getOfflineEpisodes()
        
        episodesCollectionViewController.dataset.removeAll()
        episodesCollectionViewController.updateDataset(dataset)
        
        if (dataset.count > 0) {
            setViewStateNormal()
        } else {
            setViewStateNoResults()
        }
    }
    
    func updateViewState() {
        let usersManager = UsersManager.getInstance()
        let currentUser = usersManager.getCurrentUser()!

        let dataset = currentUser.getOfflineEpisodes()

        if (dataset.count > 0) {
            setViewStateNormal()
        } else {
            setViewStateNoResults()
        }
    }

    func setViewStateNormal() {
        containerDownloadsCollection.isHidden = false
        textTitle.setVisibility(UIView.VISIBILITY_GONE)
    }

    func setViewStateNoResults() {
        containerDownloadsCollection.isHidden = true
        textTitle.setVisibility(UIView.VISIBILITY_VISIBLE)
    }
}

