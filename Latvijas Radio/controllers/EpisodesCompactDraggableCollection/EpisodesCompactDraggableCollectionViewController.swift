//
//  EpisodesCompactDraggableCollectionViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

protocol EpisodesCompactDraggableCollectionDatasetChangedDelegate: AnyObject {
    func onDatasetChanged()
}

class EpisodesCompactDraggableCollectionViewController: UICollectionViewController {
    
    static var TAG = String(describing: EpisodesCompactDraggableCollectionViewController.classForCoder())

    weak var scrollDelegate: UIScrollViewDelegate?
    weak var episodesCompactDraggableCollectionDatasetChangedDelegate: EpisodesCompactDraggableCollectionDatasetChangedDelegate?
    
    var dataset: [EpisodeModel] = [EpisodeModel]() {
        didSet {
            episodesCompactDraggableCollectionDatasetChangedDelegate?.onDatasetChanged()
        }
    }
    
    private let reuseIdentifier = "EpisodesCompactDraggableCollectionViewCell"
    private var longPressGesture: UILongPressGestureRecognizer!
    private var imagePanGesture: UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(EpisodesCompactDraggableCollectionViewController.TAG, "viewDidLoad")

        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        collectionView.addGestureRecognizer(longPressGesture)
        self.collectionView.scrollsToTop = true
    }

    deinit {
        GeneralUtils.log(EpisodesCompactDraggableCollectionViewController.TAG, "deinit")
    }

    override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedItem = dataset[sourceIndexPath.row]
        dataset.remove(at: sourceIndexPath.row)
        dataset.insert(movedItem, at: destinationIndexPath.row)
        
        UIView.performWithoutAnimation {
            self.collectionView.reloadData()
        }

        performRequestUserSubscribedEpisodesOrder()
    }

    // MARK: UIScrollViewDelegate

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidScroll?(scrollView)
    }
    
    // MARK: Custom

    func updateDataset(_ dataset: [EpisodeModel]) {
        GeneralUtils.log(EpisodesCompactDraggableCollectionViewController.TAG, "setupDataset")
        
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        config.backgroundColor = UIColor.clear
        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            guard let self = self else { return nil }

            let actionHandler: UIContextualAction.Handler = { action, view, completion in
                let episodeModel = self.dataset[indexPath.row]
                
                UserSubscribedEpisodesManager.getInstance().performRequestSetEpisodeSubscriptionStatus(episodeModel, false, {})

                self.dataset.remove(at: indexPath.row)
                
                completion(true)
                
                UIView.performWithoutAnimation {
                    self.collectionView.reloadData()
                    self.collectionView.layoutIfNeeded()
                    
                    self.collectionView.reloadItems(at: [indexPath])
                }
            }

            let action = UIContextualAction(style: .normal, title: "", handler: actionHandler)
            action.image = UIImage(systemName: "trash")
            action.backgroundColor = UIColor(named: ColorsHelper.RED)

            return UISwipeActionsConfiguration(actions: [action])
        }

        let layout = UICollectionViewCompositionalLayout.list(using: config)

        collectionView.collectionViewLayout = layout

        self.dataset = dataset

        UIView.performWithoutAnimation {
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
        }
    }

    func performRequestUserSubscribedEpisodesOrder() {
        // params
        var urlQueryItems = [URLQueryItem]()
        
        for i in (0..<dataset.count) {
            let episodeModel = dataset[i]
            
            urlQueryItems.append(URLQueryItem(name: UserSubscribedEpisodesOrderRequest.REQUEST_PARAM_IDS + "[" + String(i) + "]", value: episodeModel.getId()))
        }

        let userSubscribedEpisodesOrderRequest = UserSubscribedEpisodesOrderRequest(urlQueryItems)

        userSubscribedEpisodesOrderRequest.execute()
    }
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {

        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }

            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    @objc func handleImagePanGesture(gesture: UIPanGestureRecognizer) {
        switch(gesture.state) {

        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension EpisodesCompactDraggableCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataset.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! EpisodesCompactDraggableCollectionViewCell

        // variables
        let episodeModel = dataset[indexPath.row]
        
        // listeners
        for recognizer in cell.imageDragger.gestureRecognizers ?? [] {
            cell.imageDragger.removeGestureRecognizer(recognizer)
        }

        imagePanGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleImagePanGesture(gesture:)))
        cell.imageDragger.addGestureRecognizer(imagePanGesture)

        // update broadcast name
        let broadcastName = episodeModel.getBroadcastName()
        cell.textBroadcastName.setText(broadcastName)

        // update episode title
        let title = episodeModel.getTitle()
        cell.textTitle.setText(title)

        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let episodeModel = dataset[indexPath.row]

        let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_EPISODE, bundle: nil)
                                .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_EPISODE) as! EpisodeViewController)
        
        viewController.episodeModel = episodeModel
        viewController.listOfEpisodes = dataset
        
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
