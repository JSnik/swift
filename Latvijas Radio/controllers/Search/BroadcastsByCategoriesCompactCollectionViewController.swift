//
//  BroadcastsByCategoriesCompactCollectionViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class BroadcastsByCategoriesCompactCollectionViewController: UICollectionViewController {
    
    static var TAG = String(describing: BroadcastsByCategoriesCompactCollectionViewController.classForCoder())

    private let reuseIdentifier = "BroadcastsByCategoriesCompactCollectionViewCell"
    private var dataset: [BroadcastsByCategoryModel] = []
    private var collectionContentSizeObserver: NSKeyValueObservation?
    
    var originalDataset: [BroadcastsByCategoryModel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(BroadcastsByCategoriesCollectionViewController.TAG, "viewDidLoad")
        
        view.translatesAutoresizingMaskIntoConstraints = false

        collectionContentSizeObserver = collectionView.observe(\.contentSize, options: .new) { (collView, change) in
            if let containerView = self.view.superview {
                ContainedCollectionViewHeightHelper.updateCollectionContainerHeightConstraint(view: containerView, collectionView: self.collectionView)
            }
        }
        self.collectionView.scrollsToTop = true
    }

    deinit {
        GeneralUtils.log(BroadcastsByCategoriesCollectionViewController.TAG, "deinit")
    }
    
    // MARK: Custom

    func updateDataset(_ dataset: [BroadcastsByCategoryModel]) {
        GeneralUtils.log(BroadcastsByCategoriesCompactCollectionViewController.TAG, "setupDataset")

        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        config.backgroundColor = UIColor.clear
        
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        
        collectionView.collectionViewLayout = layout

        self.dataset = dataset
        print("BroadcastsByCategoriesCompactCollectionViewController dataset = \(dataset)")
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }
    
    @objc func buttonCategoryClickHandler(_ sender: UIView) {
        let broadcastsByCategoryModel = dataset[sender.tag]
        
        let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_BROADCASTS_FILTERED, bundle: nil)
                                .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_BROADCASTS_FILTERED) as! BroadcastsFilteredViewController)
        
        viewController.broadcastsByCategoryModel = broadcastsByCategoryModel
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension BroadcastsByCategoriesCompactCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataset.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BroadcastsByCategoriesCompactCollectionViewCell
        cell.backgroundColor = UIColor(named: ColorsHelper.WHITE)

        // variables
        let broadcastsByCategoryModel = dataset[indexPath.row]
        
        // listeners
        cell.buttonCategory.tag = indexPath.row
        cell.buttonCategory.addTarget(self, action: #selector(buttonCategoryClickHandler), for: .touchUpInside)
        
        // update title
        let title = broadcastsByCategoryModel.getName()
        cell.buttonCategory.setText(title, false)
//        let customFont = UIFont.systemFont(ofSize: 17.0)
//        cell.buttonCategory.titleLabel?.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont)
//        cell.buttonCategory.titleLabel?.adjustsFontForContentSizeCategory = true

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
