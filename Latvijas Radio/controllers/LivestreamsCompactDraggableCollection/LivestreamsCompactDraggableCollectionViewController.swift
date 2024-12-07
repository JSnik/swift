//
//  LivestreamsCompactDraggableCollectionViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 23/08/2022.
//

import UIKit

protocol LivestreamsCompactDraggableCollectionDatasetChangedDelegate: AnyObject {
    func onDatasetChanged()
}

class LivestreamsCompactDraggableCollectionViewController: UICollectionViewController {
    
    var TAG = String(describing: LivestreamsCompactDraggableCollectionViewController.classForCoder())

    weak var scrollDelegate: UIScrollViewDelegate?
    weak var episodesCompactDraggableCollectionDatasetChangedDelegate: EpisodesCompactDraggableCollectionDatasetChangedDelegate?
    
    var dataset: [/*LivestreamModel*/RadioChannel] = [/*LivestreamModel*/RadioChannel]() {
        didSet {
            episodesCompactDraggableCollectionDatasetChangedDelegate?.onDatasetChanged()
        }
    }
    
    private let reuseIdentifier = "LivestreamsCompactDraggableCollectionViewCell"
    private var longPressGesture: UILongPressGestureRecognizer!
    private var imagePanGesture: UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(TAG, "viewDidLoad")

        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        collectionView.addGestureRecognizer(longPressGesture)
        self.collectionView.scrollsToTop = true
    }

    deinit {
        GeneralUtils.log(TAG, "deinit")
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
    }

    // MARK: UIScrollViewDelegate

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidScroll?(scrollView)
    }
    
    // MARK: Custom

    func updateDataset(_ dataset: [/*LivestreamModel*/RadioChannel]) {
        GeneralUtils.log(TAG, "setupDataset")
        
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        config.backgroundColor = UIColor.clear

        let layout = UICollectionViewCompositionalLayout.list(using: config)

        collectionView.collectionViewLayout = layout

        self.dataset = dataset

        UIView.performWithoutAnimation {
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
        }
    }
    
    func getLivestreamIdsInCurrentOrder() -> [String] {
        var result = [String]()
        
        for livestreamModel in dataset {
            result.append(String(describing: livestreamModel.id!) /*getId()*/)
        }
        
        return result
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
extension LivestreamsCompactDraggableCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataset.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LivestreamsCompactDraggableCollectionViewCell

        // Variables
        let livestreamModel = dataset[indexPath.row]
        
        // Listeners
        for recognizer in cell.imageDragger.gestureRecognizers ?? [] {
            cell.imageDragger.removeGestureRecognizer(recognizer)
        }

        imagePanGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleImagePanGesture(gesture:)))
        cell.imageDragger.addGestureRecognizer(imagePanGesture)

        // Update image
//        let imageResourceId = livestreamModel.getImageResourceId()
//        cell.imageLivestream.image = UIImage(named: imageResourceId)
        if (livestreamModel.image != nil) {
            cell.imageLivestream.sd_setImage(with: URL(string: livestreamModel.image ?? ""))
        } else {
            cell.imageLivestream.image = nil
        }

        // Update title
        let title = livestreamModel.name //getName()
        cell.textLivestreamTitle.setText(title)

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
