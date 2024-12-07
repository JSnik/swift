//
//  CoversCollectionViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class CoversCollectionViewController: UICollectionViewController {
    
    static var TAG = String(describing: CoversCollectionViewController.classForCoder())

    private static let DURATION = 0.2
    private static let TRANSFORM_CELL_VALUE = CGAffineTransform(scaleX: 0.85, y: 0.85)
    
    private let reuseIdentifier = "CoversCollectionViewCell"
    private let sectionInsets = UIEdgeInsets(
        top: 0.0,
        left: 43.0,
        bottom: 0.0,
        right: 43.0
    )
    let spacingBetweenCells:CGFloat = 0
    
    private var dataset: [GenericPreviewModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        GeneralUtils.log(CoversCollectionViewController.TAG, "viewDidLoad")
        self.collectionView.scrollsToTop = true
    }

    deinit {
        GeneralUtils.log(CoversCollectionViewController.TAG, "deinit")
    }
    
    // MARK: Custom

    func updateDataset(_ dataset: [GenericPreviewModel]) {
        GeneralUtils.log(CoversCollectionViewController.TAG, "setupDataset")

        self.dataset = dataset
        
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }
}

// MARK: - UICollectionViewDataSource
extension CoversCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataset.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CoversCollectionViewCell
        
        // variables
        let genericPreviewModel = dataset[indexPath.row]

        let viewController = UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_COVER, bundle: nil)
            .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_COVER) as! CoverViewController
        
        viewController.genericPreviewModel = genericPreviewModel
        
        // remove previous views
        for subview in cell.frameLayout.subviews {
            subview.removeFromSuperview()
        }

        // Add Child View Controller
        addChild(viewController)

        // Add Child View as Subview
        cell.frameLayout.addSubview(viewController.view)

        // Configure Child View
        viewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            viewController.view.leadingAnchor.constraint(equalTo: cell.frameLayout.leadingAnchor, constant: 0),
            viewController.view.trailingAnchor.constraint(equalTo: cell.frameLayout.trailingAnchor, constant: 0),
            viewController.view.topAnchor.constraint(equalTo: cell.frameLayout.topAnchor, constant: 0),
            viewController.view.bottomAnchor.constraint(equalTo: cell.frameLayout.bottomAnchor, constant: 0)
        ])

        // Notify Child View Controller
        viewController.didMove(toParent: self)
        
        // initial scaling
        if (indexPath.row != 0) {
            cell.wrapperItem.transform = CoversCollectionViewController.TRANSFORM_CELL_VALUE
        }

        // constrain item width from here as well, because "sizeForItemAt" definition is not enough, large content will keep expanding the cell
        var constraintWidth: NSLayoutConstraint?

        for constraint in cell.wrapperItem.constraints {
            if (constraint.firstAttribute == .width) {
                constraintWidth = constraint
            }
        }

        let itemWidth = UIScreen.main.bounds.size.width - sectionInsets.left - sectionInsets.right - 5 - 5 // 5 - custom padding in IB

        if (constraintWidth != nil) {
            constraintWidth!.constant = CGFloat(itemWidth)
        } else {
            cell.wrapperItem.widthAnchor.constraint(equalToConstant: CGFloat(itemWidth)).isActive = true
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // When testing on iOS13, "collectionView.bounds.width" suddenly started giving "414" instead of "390".
        // So get the real value from screen width value.
        let itemWidth = UIScreen.main.bounds.size.width - sectionInsets.left - sectionInsets.right
       
        return CGSize(width: itemWidth, height: collectionView.bounds.height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let genericPreviewModel = dataset[indexPath.row]

        if (genericPreviewModel.getType() == GenericPreviewModel.TYPE_BROADCAST) {
            let broadcastModel = genericPreviewModel.getBroadcastModel()
            
            let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_BROADCAST, bundle: nil)
                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_BROADCAST) as! BroadcastViewController)
            
            viewController.broadcastModel = broadcastModel
            
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            let episodeModel = genericPreviewModel.getEpisodeModel()

            let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_EPISODE, bundle: nil)
                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_EPISODE) as! EpisodeViewController)
            
            viewController.episodeModel = episodeModel
            
            navigationController?.pushViewController(viewController, animated: true)
        }
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
extension CoversCollectionViewController: UICollectionViewDelegateFlowLayout {

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

// MARK: UIScrollViewDelegate

extension CoversCollectionViewController {
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Simulate "Page" Function
        let pageWidth: Float = Float(self.collectionView.frame.width - sectionInsets.left - sectionInsets.right)

        let currentOffset: Float = Float(scrollView.contentOffset.x)
        let targetOffset: Float = Float(targetContentOffset.pointee.x)
        var newTargetOffset: Float = 0
        if targetOffset > currentOffset {
            newTargetOffset = ceilf(currentOffset / pageWidth) * pageWidth
        }
        else {
            newTargetOffset = floorf(currentOffset / pageWidth) * pageWidth
        }
        if newTargetOffset < 0 {
            newTargetOffset = 0
        }
        else if (newTargetOffset > Float(scrollView.contentSize.width)){
            newTargetOffset = Float(Float(scrollView.contentSize.width))
        }

        targetContentOffset.pointee.x = CGFloat(currentOffset)
        scrollView.setContentOffset(CGPoint(x: CGFloat(newTargetOffset), y: scrollView.contentOffset.y), animated: true)

        // Set transforms
        let index: Int = Int(newTargetOffset / pageWidth)

        // current cell
        var cell = collectionView.cellForItem(at: IndexPath.init(row: index, section: 0)) as? CoversCollectionViewCell
        
        UIView.animate(withDuration: CoversCollectionViewController.DURATION, animations: {
            cell?.wrapperItem.transform = CGAffineTransform.identity
        })

        // right cell
        cell = collectionView.cellForItem(at: IndexPath.init(row: index + 1, section: 0)) as? CoversCollectionViewCell

        UIView.animate(withDuration: CoversCollectionViewController.DURATION, animations: {
            cell?.wrapperItem.transform = CoversCollectionViewController.TRANSFORM_CELL_VALUE
        })

        // left cell, which is not necessary at index 0
        if (index != 0) {
            cell = collectionView.cellForItem(at: IndexPath.init(row: index - 1, section: 0)) as? CoversCollectionViewCell
            
            UIView.animate(withDuration: CoversCollectionViewController.DURATION, animations: {
                cell?.wrapperItem.transform = CoversCollectionViewController.TRANSFORM_CELL_VALUE
            })
        }
    }
}
