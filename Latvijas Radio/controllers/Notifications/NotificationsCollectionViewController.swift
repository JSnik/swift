//
//  NotificationsCollectionViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class NotificationsCollectionViewController: UICollectionViewController {
    
    static var TAG = String(describing: NotificationsCollectionViewController.classForCoder())

    private let reuseIdentifier = "NotificationsCollectionViewCell"
    private var dataset: [NotificationModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(NotificationsCollectionViewController.TAG, "viewDidLoad")
    }

    deinit {
        GeneralUtils.log(NotificationsCollectionViewController.TAG, "deinit")
    }
    
    // MARK: Custom

    func updateDataset(_ dataset: [NotificationModel]) {
        GeneralUtils.log(NotificationsCollectionViewController.TAG, "setupDataset")

        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        config.backgroundColor = UIColor.clear
        
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        
        collectionView.collectionViewLayout = layout

        self.dataset = dataset

        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }
}

// MARK: - UICollectionViewDataSource
extension NotificationsCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataset.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! NotificationsCollectionViewCell

        // variables
        let notificationModel = dataset[indexPath.row]
        
        // update primary title
        let broadcastName = notificationModel.getBroadcastName()
        let titlePrimary = "new_episode_for_broadcast".localized() + " " + broadcastName
        
        cell.textTitlePrimary.setText(titlePrimary)
        
        // update secondary title
        let titleSecondary = notificationModel.getEpisodeTitle()
        cell.textTitleSecondary.setText(titleSecondary)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let notificationModel = dataset[indexPath.row]
        
        let episodeId = notificationModel.getEpisodeId()
        let deepLinkSharedEpisodeModel = DeepLinkSharedEpisodeModel(episodeId)

        let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_EPISODE, bundle: nil)
                                .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_EPISODE) as! EpisodeViewController)
        
        viewController.deepLinkSharedEpisodeModel = deepLinkSharedEpisodeModel
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            CollectionViewCellHelper.setHighlightedStyle(cell)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            CollectionViewCellHelper.setUnhighlightedStyle(cell)
        }
    }
}
