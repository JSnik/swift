//
//  ExternalLinksCollectionViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class ExternalLinksCollectionViewController: UICollectionViewController {
    
    static var TAG = String(describing: ExternalLinksCollectionViewController.classForCoder())

    private let reuseIdentifier = "ExternalLinksCollectionViewCell"
    private var dataset: [ExternalLinkModel] = []
    private var collectionContentSizeObserver: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(ExternalLinksCollectionViewController.TAG, "viewDidLoad")
        
        view.translatesAutoresizingMaskIntoConstraints = false

        collectionContentSizeObserver = collectionView.observe(\.contentSize, options: .new) { (collView, change) in
            if let containerView = self.view.superview {
                ContainedCollectionViewHeightHelper.updateCollectionContainerHeightConstraint(view: containerView, collectionView: self.collectionView)
            }
        }
        self.collectionView.scrollsToTop = true
    }

    deinit {
        GeneralUtils.log(ExternalLinksCollectionViewController.TAG, "deinit")
    }
    
    // MARK: Custom

    func updateDataset(_ dataset: [ExternalLinkModel]) {
        GeneralUtils.log(ExternalLinksCollectionViewController.TAG, "setupDataset")

        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = false
        config.backgroundColor = UIColor.clear
        
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        
        collectionView.collectionViewLayout = layout

        self.dataset = dataset

        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }
    
    @objc func buttonExternalLinkClickHandler(_ sender: UIView) {
        let externalLinkModel = dataset[sender.tag]
        
        let link = externalLinkModel.getLink()
        
        UIApplication.shared.open(URL(string: link)!, options: [:], completionHandler: nil)
    }
}

// MARK: - UICollectionViewDataSource
extension ExternalLinksCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataset.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ExternalLinksCollectionViewCell

        // variables
        let externalLinkModel = dataset[indexPath.row]
        
        // listeners
        cell.buttonExternalLink.tag = indexPath.row
        cell.buttonExternalLink.addTarget(self, action: #selector(buttonExternalLinkClickHandler), for: .touchUpInside)
        
        // update title
        let name = externalLinkModel.getName()
        cell.buttonExternalLink.setText(name, false)
        
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
