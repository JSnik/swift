//
//  LivestreamsCollectionViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class LivestreamsCompactCollectionViewController: UICollectionViewController {
    
    static var TAG = String(describing: LivestreamsCompactCollectionViewController.classForCoder())

//    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    private let reuseIdentifier = "LivestreamsCompactCollectionViewCell"
    private let sectionInsets = UIEdgeInsets(
        top: 0.0,
        left: 16.0,
        bottom: 0.0,
        right: 16.0
    )
    let spacingBetweenCells:CGFloat = 10
    
    private var dataset: [/*LivestreamModel*/RadioChannel] = []
    var fullRadioChannelDataset: [RadioChannel]!
    private var dataset1: [RadioChannel] = []

    deinit {
        GeneralUtils.log(LivestreamsCompactCollectionViewController.TAG, "deinit")
    }
    
    // MARK: Custom

    func updateDataset(_ dataset: [/*LivestreamModel*/RadioChannel]) {
        GeneralUtils.log(LivestreamsCompactCollectionViewController.TAG, "setupDataset")
        var dataset1 = [RadioChannel]()
        for el in dataset {
            dataset1.append(el)
            if el.name?.contains("Naba") == true {
                var rEl = el
                rEl.name = "Radioteātris"
                rEl.display_name = "Iestudējumi bērniem un pieaugušajiem"
                rEl.id = Int(LivestreamsManager.ID_LATVIJAS_RADIO_RADIOTEATRIS)
                rEl.image =  ImagesHelper.LOGO_WIDE_LATVIJAS_RADIO_RADIOTEATRIS
                rEl.mobile?.square_image =  ImagesHelper.LOGO_LATVIJAS_RADIO_RADIOTEATRIS
                dataset1.append(rEl)
            }
        }
        self.dataset = dataset1
        self.fullRadioChannelDataset = dataset1

        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }

}

// MARK: - UICollectionViewDataSource
extension LivestreamsCompactCollectionViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataset.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LivestreamsCompactCollectionViewCell

        let livestreamModel = dataset[indexPath.row]
        
        //cell.imageLivestream.image = UIImage(named: livestreamModel.getImageResourceId())

        if livestreamModel.name == "Radioteātris" {
            cell.imageLivestream.image = UIImage(named: "logo_latvijas_radio_radioteatris")
        } else {
            if (livestreamModel.image != nil) {
                cell.imageLivestream.sd_setImage(with: URL(string: livestreamModel.image ?? ""))
            } else {
                cell.imageLivestream.image = nil
            }
        }

        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let livestreamModel = dataset[indexPath.row]

//        if (!livestreamModel.getFakeLivestream()) {
        if (livestreamModel.name?.contains("Radioteātris") == false) {
            let playableLivestreams = LivestreamsManager.getOnlyPlayableLivestreams(dataset)
            
            MediaPlayerManager.getInstance().contentLoadedFromSource = MediaPlayerManager.CONTENT_SOURCE_NAME_APP_DASHBOARD_HORIZONTAL_SLIDER
            
            MediaPlayerManager.getInstance().performActionLoadAndPlayLivestream(MediaPlayerManager.PLAYBACK_TYPE_STREAM, livestreamModel, playableLivestreams)
        } else {
            if (livestreamModel.id /*getId()*/ == Int(LivestreamsManager.ID_LATVIJAS_RADIO_RADIOTEATRIS)) {
                let channelModel = ChannelsManager.getChannelById(ChannelsManager.ID_LATVIJAS_RADIO_RADIOTEATRIS)
                
                let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_BROADCASTS_FILTERED, bundle: nil)
                                        .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_BROADCASTS_FILTERED) as! BroadcastsFilteredViewController)
                
                viewController.channelModel = channelModel
                
                navigationController?.pushViewController(viewController, animated: true)
            }
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
extension LivestreamsCompactCollectionViewController: UICollectionViewDelegateFlowLayout {

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

// leaving for reference: setting item widths programmatically
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
////        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
////        let availableWidth = view.frame.width - paddingSpace
////        let widthPerItem = availableWidth / itemsPerRow
////
////        return CGSize(width: widthPerItem, height: widthPerItem)
//
//        // -----------------------------------
//
//
//        let numberOfItemsPerRow:CGFloat = CGFloat(dataset.count)
//
//
//        let totalSpacing = (2 * self.spacing) + ((numberOfItemsPerRow - 1) * spacingBetweenCells) //Amount of total spacing in a row
//
//        let width = (self.collectionView.bounds.width - totalSpacing)/numberOfItemsPerRow
//
//        print(width)
//
//        return CGSize(width: width, height: width)
//    }
