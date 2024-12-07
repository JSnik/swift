//
//  BroadcastsByCategoriesCollectionViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class BroadcastsByCategoriesCollectionViewController: UICollectionViewController {
    
    static var TAG = String(describing: BroadcastsByCategoriesCollectionViewController.classForCoder())

    weak var scrollDelegate: UIScrollViewDelegate?
    
    private let reuseIdentifier = "BroadcastsByCategoriesCollectionViewCell"
    public var dataset: [BroadcastsByCategoryModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(BroadcastsByCategoriesCollectionViewController.TAG, "viewDidLoad")
        self.collectionView.scrollsToTop = true
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTheTop), name: Notification.Name(BroadcastsViewController.EVENT_SCROLL_TO_TOP_BROADCASTS), object: nil)
    }

    @objc func scrollToTheTop() {
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            self?.collectionView.setContentOffset(.zero, animated: false)
        }
    }

    deinit {
        GeneralUtils.log(BroadcastsByCategoriesCollectionViewController.TAG, "deinit")
    }
    
    // MARK: UIScrollViewDelegate

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.scrollViewDidScroll?(scrollView)
    }
    
    // MARK: Custom

    func updateDataset(_ dataset: [BroadcastsByCategoryModel]) {
        GeneralUtils.log(BroadcastsByCategoriesCollectionViewController.TAG, "setupDataset")
        
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        config.backgroundColor = UIColor.clear
        
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        
        collectionView.collectionViewLayout = layout

        self.dataset = dataset

        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }
    
    func loadItemViewController(_ cell: BroadcastsByCategoriesCollectionViewCell, _ position: Int) {
        
        let broadcastsByCategoryModel = dataset[position]

        let viewController = UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_BROADCASTS_BY_CATEGORIES_ITEM, bundle: nil)
            .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_BROADCASTS_BY_CATEGORIES_ITEM) as! BroadcastsByCategoriesItemViewController
        
        viewController.broadcastsByCategoryModel = broadcastsByCategoryModel

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
    }
}

// MARK: - UICollectionViewDataSource
extension BroadcastsByCategoriesCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataset.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BroadcastsByCategoriesCollectionViewCell

        loadItemViewController(cell, indexPath.row)
        
        return cell
    }
}
