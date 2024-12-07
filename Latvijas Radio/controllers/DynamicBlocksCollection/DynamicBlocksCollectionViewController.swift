//
//  DynamicBlocksCollectionViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class DynamicBlocksCollectionViewController: UICollectionViewController {
    
    static var TAG = String(describing: DynamicBlocksCollectionViewController.classForCoder())

    private let reuseIdentifier = "DynamicBlocksCollectionViewCell"
    private var dataset: [DynamicBlockModel] = []
    private var collectionContentSizeObserver: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(DynamicBlocksCollectionViewController.TAG, "viewDidLoad")
        
        view.translatesAutoresizingMaskIntoConstraints = false

        collectionContentSizeObserver = collectionView.observe(\.contentSize, options: .new) { (collView, change) in
            if let containerView = self.view.superview {
                ContainedCollectionViewHeightHelper.updateCollectionContainerHeightConstraint(view: containerView, collectionView: self.collectionView)
            }
        }
        self.collectionView.scrollsToTop = true
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTheTop), name: Notification.Name(BroadcastsViewController.EVENT_SCROLL_TO_TOP_BROADCASTS), object: nil)
    }

    @objc func scrollToTheTop() {
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            self?.collectionView.setContentOffset(.zero, animated: false)
        }
    }

    deinit {
        GeneralUtils.log(DynamicBlocksCollectionViewController.TAG, "deinit")
    }
    
    // MARK: Custom

    func updateDataset(_ dataset: [DynamicBlockModel]) {
        GeneralUtils.log(DynamicBlocksCollectionViewController.TAG, "setupDataset")
        
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        config.backgroundColor = UIColor.clear
        
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        
        collectionView.collectionViewLayout = layout

        self.dataset = dataset

        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }
    
    func loadDynamicBlock(_ cell: DynamicBlocksCollectionViewCell, _ position: Int) {
        
        let dynamicBlockModel = dataset[position]

        let presentationTypeId = dynamicBlockModel.getPresentationTypeId()

        var viewController: UIViewController!
        
        switch (presentationTypeId) {
        case "1":
            viewController = UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_DYNAMIC_BLOCK_PRESENTATION_TYPE_1, bundle: nil)
                                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_DYNAMIC_BLOCK_PRESENTATION_TYPE_1) as! DynamicBlockPresentationType1ViewController
            (viewController as! DynamicBlockPresentationType1ViewController).dynamicBlockModel = dynamicBlockModel
            
            break
        case "2":
            viewController = UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_DYNAMIC_BLOCK_PRESENTATION_TYPE_2, bundle: nil)
                                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_DYNAMIC_BLOCK_PRESENTATION_TYPE_2) as! DynamicBlockPresentationType2ViewController
            (viewController as! DynamicBlockPresentationType2ViewController).dynamicBlockModel = dynamicBlockModel
            
            break
        case "3":
            viewController = UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_DYNAMIC_BLOCK_PRESENTATION_TYPE_3, bundle: nil)
                                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_DYNAMIC_BLOCK_PRESENTATION_TYPE_3) as! DynamicBlockPresentationType3ViewController
            (viewController as! DynamicBlockPresentationType3ViewController).dynamicBlockModel = dynamicBlockModel
            
            break
        default:
            break
        }
        
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
extension DynamicBlocksCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataset.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DynamicBlocksCollectionViewCell

        loadDynamicBlock(cell, indexPath.row)
        
        return cell
    }
}
