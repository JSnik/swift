//
//  ChannelsCollectionViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class ChannelsCollectionViewController: UICollectionViewController {
    
    static var TAG = String(describing: ChannelsCollectionViewController.classForCoder())

    private let reuseIdentifier = "ChannelsCollectionViewCell"
    private var dataset: [ChannelModel] = []
    private var collectionContentSizeObserver: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(ChannelsCollectionViewController.TAG, "viewDidLoad")
        
        view.translatesAutoresizingMaskIntoConstraints = false

        collectionContentSizeObserver = collectionView.observe(\.contentSize, options: .new) { (collView, change) in
            if let containerView = self.view.superview {
                ContainedCollectionViewHeightHelper.updateCollectionContainerHeightConstraint(view: containerView, collectionView: self.collectionView)
            }
        }
        self.collectionView.scrollsToTop = true
    }

    deinit {
        GeneralUtils.log(ChannelsCollectionViewController.TAG, "deinit")
    }
    
    // MARK: Custom

    func updateDataset(_ dataset: [ChannelModel]) {
        GeneralUtils.log(ChannelsCollectionViewController.TAG, "setupDataset")

        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        config.backgroundColor = UIColor.clear
        
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        
        collectionView.collectionViewLayout = layout

        self.dataset = dataset

        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }
    
    @objc func buttonChannelClickHandler(_ sender: UIView) {
        let channelModel = dataset[sender.tag]
        
        let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_BROADCASTS_FILTERED, bundle: nil)
                                .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_BROADCASTS_FILTERED) as! BroadcastsFilteredViewController)
        
        viewController.channelModel = channelModel
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension ChannelsCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataset.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ChannelsCollectionViewCell

        // variables
        let channelModel = dataset[indexPath.row]
        
        // listeners
        cell.buttonChannel.tag = indexPath.row
        cell.buttonChannel.addTarget(self, action: #selector(buttonChannelClickHandler), for: .touchUpInside)
        
        // update name
        let name = channelModel.getName()
        cell.buttonChannel.setText(name, false)
        
        // update image
        let imageResourceId = channelModel.getImageResourceId()
        cell.imageChannel.image = UIImage(named: imageResourceId)
        
        return cell
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
