//
//  BroadcastsFilteredCollectionViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class BroadcastsFilteredCollectionViewController: UICollectionViewController {
    
    static var TAG = String(describing: BroadcastsFilteredCollectionViewController.classForCoder())

    private let reuseIdentifier = "BroadcastsFilteredCollectionViewCell"
    private var dataset: [BroadcastModel] = []
    public var channelModel: ChannelModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(BroadcastsFilteredCollectionViewController.TAG, "viewDidLoad")
        self.collectionView.scrollsToTop = true
    }

    deinit {
        GeneralUtils.log(BroadcastsFilteredCollectionViewController.TAG, "deinit")
    }
    
    // MARK: Custom

    func updateDataset(_ dataset: [BroadcastModel]) {
        GeneralUtils.log(BroadcastsFilteredCollectionViewController.TAG, "setupDataset")

        self.dataset = dataset

        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }
}

// MARK: - UICollectionViewDataSource
extension BroadcastsFilteredCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataset.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BroadcastsFilteredCollectionViewCell

        // variables
        let broadcastModel = dataset[indexPath.row]
        
        // update image
        if (broadcastModel.getImageUrl() != nil) {
            cell.imageGenericPreview.sd_setImage(with: URL(string: broadcastModel.getImageUrl()!))
        } else {
            cell.imageGenericPreview.image = nil
        }
        
        // update title
        let title = broadcastModel.getTitle()
        cell.textGenericPreview.setText(title)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let broadcastModel = dataset[indexPath.row]

        let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_BROADCAST, bundle: nil)
                                .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_BROADCAST) as! BroadcastViewController)
        
        viewController.broadcastModel = broadcastModel
        viewController.channelModel = channelModel
        
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

// MARK: - Collection View Flow Layout Delegate

private let sectionInsets = UIEdgeInsets(
    top: 0.0,
    left: 16.0,
    bottom: 0.0,
    right: 16.0
)
let spacingBetweenCells: CGFloat = 0

extension BroadcastsFilteredCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacingBetweenCells
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacingBetweenCells
    }
}
