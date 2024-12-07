//
//  EpisodesPreviewsCollectionViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit
import SDWebImage

class EpisodesPreviewsCollectionViewController: UICollectionViewController {
    
    static var TAG = String(describing: EpisodesPreviewsCollectionViewController.classForCoder())

    private let reuseIdentifier = "EpisodesPreviewsCollectionViewCell"
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

        GeneralUtils.log(EpisodesPreviewsCollectionViewController.TAG, "viewDidLoad")
        self.collectionView.scrollsToTop = true
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTheTop), name: Notification.Name(MyRadioViewController.EVENT_SCROLL_TO_TOP_MYRADIO), object: nil)
    }

    @objc func scrollToTheTop() {
        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
            self?.collectionView.setContentOffset(.zero, animated: false)
        }
    }

    deinit {
        GeneralUtils.log(EpisodesPreviewsCollectionViewController.TAG, "deinit")
    }
    
    // MARK: Custom

    func updateDataset(_ dataset: [GenericPreviewModel]) {
        GeneralUtils.log(EpisodesPreviewsCollectionViewController.TAG, "setupDataset")

        self.dataset = dataset
        
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }
}

// MARK: - UICollectionViewDataSource
extension EpisodesPreviewsCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataset.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! EpisodesPreviewsCollectionViewCell

        // variables
        let genericPreviewModel = dataset[indexPath.row]
        let episodeModel = genericPreviewModel.getEpisodeModel()
        
        // update image
        let imageUrl = episodeModel!.getImageUrl()

        let transformer = SDImageResizingTransformer(
            size: CGSize(
                width: GeneralUtils.dpToPixels(CGFloat(166)),
                height: GeneralUtils.dpToPixels(CGFloat(110))),
            scaleMode: .aspectFill
        )

        cell.imageEpisodePreview.sd_setImage(
            with: URL(string: imageUrl),
            placeholderImage: nil,
            context: [.imageTransformer: transformer]
        )
        
        // update broadcast title
        let broadcastTitle = episodeModel!.getBroadcastName()
        cell.textBroadcastTitle.setText(broadcastTitle)
        
        // update episode title
        let episodeTitle = episodeModel!.getTitle()
        cell.textEpisodeTitle.setText(episodeTitle)
        let customFont = UIFont(name: "FuturaPT-Medium", size: 10.0)
        cell.textBroadcastTitle.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont ?? UIFont.systemFont(ofSize: 17.0))
        cell.textBroadcastTitle.adjustsFontForContentSizeCategory = true
        let customFont1 = UIFont(name: "FuturaPT-Medium", size: 13.0)
        cell.textEpisodeTitle.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont1 ?? UIFont.systemFont(ofSize: 17.0))
        cell.textEpisodeTitle.adjustsFontForContentSizeCategory = true

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
extension EpisodesPreviewsCollectionViewController: UICollectionViewDelegateFlowLayout {

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
