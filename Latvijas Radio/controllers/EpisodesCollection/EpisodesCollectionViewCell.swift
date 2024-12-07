//
//  EpisodesCollectionViewCell.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

protocol EpisodesCollectionViewCellDelegate: AnyObject {
    func episodesCollectionViewCell(_ cell: EpisodesCollectionViewCell, downloadStateDidChange newState: Asset.DownloadState)
}

class EpisodesCollectionViewCell: UICollectionViewCell {
    
    static var TAG = String(describing: EpisodesCollectionViewCell.classForCoder())

    @IBOutlet weak var wrapperItem: UIView!
    @IBOutlet weak var imageEpisode: UIImageView!
    /// <#Description#>
    @IBOutlet weak var textBroadcastName: UILabelLabel5!
    @IBOutlet weak var textDate: UILabelLabel6!
    @IBOutlet weak var textTitle: UILabelLabel2!
    @IBOutlet weak var wrapperButtonDownload: UIView!
    @IBOutlet weak var buttonDownload: UIButtonGenericWithImage!
    @IBOutlet weak var downloadProgress: CustomProgressView!
    @IBOutlet weak var buttonTogglePlayback: UIButtonGenericWithImage!
    @IBOutlet weak var sliderTimeline: UISliderBase!
    @IBOutlet weak var textElapsedDuration: UILabelLabel6!
    @IBOutlet weak var textTotalDuration: UILabelLabel6!
    @IBOutlet weak var buttonAdd: UIButtonGenericWithCustomBackground!
    @IBOutlet weak var buttonRemove: UIButtonGenericWithCustomBackground!
    @IBOutlet weak var wrapperItemLoadMore: UIView!
    @IBOutlet weak var buttonLoadMore: UIButtonPrimary!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    weak var delegate: EpisodesCollectionViewCellDelegate?
    
    var asset: Asset? {
        didSet {
            if asset != nil {
                let notificationCenter = NotificationCenter.default
                notificationCenter.addObserver(self,
                                               selector: #selector(handleAssetDownloadStateChanged(_:)),
                                               name: .AssetDownloadStateChanged, object: nil)
                notificationCenter.addObserver(self, selector: #selector(handleAssetDownloadProgress(_:)),
                                               name: .AssetDownloadProgress, object: nil)
            }
        }
    }
    
    // MARK: Notification handling

    @objc
    func handleAssetDownloadStateChanged(_ notification: Notification) {
        guard let assetEpisodeId = notification.userInfo![Asset.Keys.assetEpisodeId] as? String,
            let downloadStateRawValue = notification.userInfo![Asset.Keys.downloadState] as? String,
            let downloadState = Asset.DownloadState(rawValue: downloadStateRawValue),
              let asset = asset, asset.episodeModel.getId() == assetEpisodeId else { return }

        DispatchQueue.main.async {
            self.delegate?.episodesCollectionViewCell(self, downloadStateDidChange: downloadState)
        }
    }

    @objc func handleAssetDownloadProgress(_ notification: NSNotification) {
        guard let assetEpisodeId = notification.userInfo![Asset.Keys.assetEpisodeId] as? String,
              let asset = asset, asset.episodeModel.getId() == assetEpisodeId else { return }
        guard let progress = notification.userInfo![Asset.Keys.percentDownloaded] as? Double else { return }

        GeneralUtils.log(EpisodesCollectionViewCell.TAG, "Download progress:", progress)
        
        downloadProgress.progress = Float(progress)
    }
}
