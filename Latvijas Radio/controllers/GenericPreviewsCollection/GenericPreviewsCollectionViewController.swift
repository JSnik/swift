//
//  GenericPreviewsCollectionViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit
import SDWebImage

class GenericPreviewsCollectionViewController: UICollectionViewController {
    
    static var TAG = String(describing: GenericPreviewsCollectionViewController.classForCoder())

    private let reuseIdentifier = "GenericPreviewCollectionViewCell"
    private let sectionInsets = UIEdgeInsets(
        top: 0.0,
        left: 16.0,
        bottom: 0.0,
        right: 16.0
    )
    let spacingBetweenCells:CGFloat = 10
    
    private var dataset: [GenericPreviewModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(GenericPreviewsCollectionViewController.TAG, "viewDidLoad")
        self.collectionView.scrollsToTop = true
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTheTop), name: Notification.Name(MyRadioViewController.EVENT_SCROLL_TO_TOP_MYRADIO), object: nil)
    }

    @objc func scrollToTheTop() {
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            self?.collectionView.setContentOffset(.zero, animated: false)
        }
    }

    deinit {
        GeneralUtils.log(GenericPreviewsCollectionViewController.TAG, "deinit")
    }
    
    // MARK: Custom

    func updateDataset(_ dataset: [GenericPreviewModel]) {
        GeneralUtils.log(GenericPreviewsCollectionViewController.TAG, "setupDataset")

        self.dataset = dataset
        
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }
}

// MARK: - UICollectionViewDataSource
extension GenericPreviewsCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataset.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GenericPreviewsCollectionViewCell
        let customFont1 = UIFont(name: "FuturaPT-Demi", size: 12.0)
        cell.textGenericPreview.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont1 ?? UIFont.systemFont(ofSize: 12.0))
        cell.textGenericPreview.adjustsFontForContentSizeCategory = true
        // variables
        let genericPreviewModel = dataset[indexPath.row]
        
        let imageUrl: String!
        let title: String!
        
        if (genericPreviewModel.getType() == GenericPreviewModel.TYPE_BROADCAST) {
            let broadcastModel = genericPreviewModel.getBroadcastModel()
            
            imageUrl = broadcastModel!.getImageUrl()
            title = broadcastModel!.getTitle()
        } else {
            let episodeModel = genericPreviewModel.getEpisodeModel()
            
            imageUrl = episodeModel!.getImageUrl()
            title = episodeModel!.getTitle()
        }
        
        // listeners
        
        
        // update image
        if (imageUrl != nil) {
            let transformer = SDImageResizingTransformer(
                size: CGSize(
                    width: GeneralUtils.dpToPixels(CGFloat(166)),
                    height: GeneralUtils.dpToPixels(CGFloat(166))),
                scaleMode: .aspectFill
            )

            cell.imageGenericPreview.sd_setImage(
                with: URL(string: imageUrl),
                placeholderImage: nil,
                context: [.imageTransformer: transformer]
            )
        }
        
        // update title
        cell.textGenericPreview.setText(title)

        return cell
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
extension GenericPreviewsCollectionViewController: UICollectionViewDelegateFlowLayout {

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
