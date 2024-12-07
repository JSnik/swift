//
//  BroadcastsBySearchCompactCollectionViewController.swift
//  Latvijas Radio
//
//  Created by andriy kruglyanko on 16.10.2024.
//  Copyright © 2024 Latvijas Radio. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class BroadcastsBySearchCompactCollectionViewController: UICollectionViewController {

    static var TAG = String(describing: BroadcastsBySearchCompactCollectionViewController.classForCoder())


    private let reuseIdentifier = "SearchCompactCollectionViewCell"
    private var dataset: [Hit] = []
    private var collectionContentSizeObserver: NSKeyValueObservation?

    var originalDataset: [Hit]!

    override func viewDidLoad() {
        super.viewDidLoad()
        GeneralUtils.log(BroadcastsBySearchCompactCollectionViewController.TAG, "viewDidLoad")
        view.translatesAutoresizingMaskIntoConstraints = false
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        collectionContentSizeObserver = collectionView.observe(\.contentSize, options: .new) { (collView, change) in
            if let containerView = self.view.superview {
                ContainedCollectionViewHeightHelper.updateCollectionContainerHeightConstraint(view: containerView, collectionView: self.collectionView)
            }
        }
        // Do any additional setup after loading the view.
        self.collectionView.scrollsToTop = true
    }

    deinit {
        GeneralUtils.log(BroadcastsBySearchCompactCollectionViewController.TAG, "deinit")
    }

    // MARK: Custom

    func updateDataset(_ dataset: [Hit]) {
        GeneralUtils.log(BroadcastsBySearchCompactCollectionViewController.TAG, "setupDataset")

        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        config.backgroundColor = UIColor.clear

        let layout = UICollectionViewCompositionalLayout.list(using: config)

        collectionView.collectionViewLayout = layout

        self.dataset = dataset

        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }

    @objc func buttonSearchClickHandler(_ sender: UIView) {
        let broadcastsByCategoryModel = dataset[sender.tag] as? Hit

        if let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_SEARCH_FILTERED, bundle: nil)
            .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_SEARCH_FILTERED) as? SearchItemViewController) {

            viewController.searchItemModel = broadcastsByCategoryModel

            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

// MARK: - UICollectionViewDataSource
extension BroadcastsBySearchCompactCollectionViewController {
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return dataset.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SearchCompactCollectionViewCell
        // Configure the cell

        // variables
        let broadcastModel = dataset[indexPath.row]
        // listeners
        cell.buttonChannel.tag = indexPath.row
        cell.buttonChannel.addTarget(self, action: #selector(buttonSearchClickHandler), for: .touchUpInside)

        // listeners
        cell.buttonChannel.tag = indexPath.row
        cell.buttonChannel.addTarget(self, action: #selector(buttonSearchClickHandler), for: .touchUpInside)

        // update image
        if (broadcastModel.document?.image != nil) {
            cell.imageGenericPreview.sd_setImage(with: URL(string: broadcastModel.document?.image ?? ""))
        } else {
            cell.imageGenericPreview.image = nil
        }

        // update title
        let title = broadcastModel.document?.showName //.show_name
        cell.textGenericPreview.setText(title)
        let customFont = UIFont.systemFont(ofSize: 17.0)
        cell.textGenericPreview.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont ?? UIFont.systemFont(ofSize: 17.0))
        cell.textGenericPreview.adjustsFontForContentSizeCategory = true
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

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let broadcastModel = dataset[indexPath.row]

        let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_SEARCHITEM, bundle: nil)
                                .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_SEARCHITEM) as! SearchItemViewController)

//        viewController.broadcastModel = broadcastModel
//        viewController.channelModel = channelModel
        viewController.searchItemModel = broadcastModel

        navigationController?.pushViewController(viewController, animated: true)
    }

    // MARK: UICollectionViewDelegate


    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }



    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }



    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }


}

// MARK: - Collection View Flow Layout Delegate

private let sectionInsets = UIEdgeInsets(
    top: 0.0,
    left: 16.0,
    bottom: 0.0,
    right: 16.0
)
//let spacingBetweenCells: CGFloat = 0

extension BroadcastsBySearchCompactCollectionViewController: UICollectionViewDelegateFlowLayout {

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


