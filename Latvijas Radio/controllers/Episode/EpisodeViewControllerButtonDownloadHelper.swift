//
//  EpisodeViewControllerButtonDownloadHelper.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit
import AVFoundation

class EpisodeViewControllerButtonDownloadHelper {
    
    static var TAG = String(describing: EpisodeViewControllerButtonDownloadHelper.self)

    weak var viewController: EpisodeViewController?
    
    var asset: Asset!
    
    deinit {
        GeneralUtils.log(EpisodeViewControllerButtonDownloadHelper.TAG, "deinit")
    }
    
    func setupEpisodeDownloadButton(_ episodeModel: EpisodeModel) {
        let urlAsset = AVURLAsset(url: URL(string: episodeModel.getMediaStreamUrl())!)
        asset = Asset(episodeModel: episodeModel, urlAsset: urlAsset)
        
        updateEpisodeDownloadButtonState()
        
        // listeners
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(handleAssetDownloadStateChanged(_:)),
                                       name: .AssetDownloadStateChanged, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleAssetDownloadProgress(_:)),
                                       name: .AssetDownloadProgress, object: nil)
    }

    // MARK: Notification handling

    @objc
    func handleAssetDownloadStateChanged(_ notification: Notification) {
        guard let assetEpisodeId = notification.userInfo![Asset.Keys.assetEpisodeId] as? String,
              let asset = asset, asset.episodeModel.getId() == assetEpisodeId else { return }

        DispatchQueue.main.async {
            self.updateEpisodeDownloadButtonState()
        }
    }

    @objc func handleAssetDownloadProgress(_ notification: NSNotification) {
        guard let assetEpisodeId = notification.userInfo![Asset.Keys.assetEpisodeId] as? String,
              let asset = asset, asset.episodeModel.getId() == assetEpisodeId else { return }
        guard let progress = notification.userInfo![Asset.Keys.percentDownloaded] as? Double else { return }

        GeneralUtils.log(EpisodeViewControllerButtonDownloadHelper.TAG, "Download progress:", progress)

        guard (viewController != nil) else { return }
        
        viewController!.downloadProgress.progress = Float(progress)
    }

    func initDownloadOfEpisodeMediaFile() {
        guard (viewController != nil) else { return }
        
        let usersManager = UsersManager.getInstance()
        let currentUser =  usersManager.getCurrentUser()!

        if (currentUser.getDownloadOnlyWithWifi() && !Reachability.isConnectedToNetwork()) {
            Toast.show(message: "no_connection_to_wifi".localized(), controller: viewController!)

            return
        }

        AssetPersistenceManager.sharedManager.downloadStream(for: asset)
    }

    func updateEpisodeDownloadButtonState() {
        guard (viewController != nil) else { return }

        if (!EpisodesHelper.isEpisodeAllowedToBeDownloaded(asset.episodeModel)) {
            viewController!.buttonDownload.setVisibility(UIView.VISIBILITY_GONE)
            viewController!.downloadProgress.setVisibility(UIView.VISIBILITY_GONE)
        } else {
            // update download button state
            let usersManager = UsersManager.getInstance()

            if (usersManager.getOfflineEpisodeById(asset.episodeModel.getId()) != nil) {
                // already downloaded and bound
                viewController!.buttonDownload.setImage(UIImage(named: ImagesHelper.IC_CHECKMARK_IN_CIRCLE), for: .normal)

                viewController!.buttonDownload.isUserInteractionEnabled = false

                viewController!.downloadProgress.setVisibility(UIView.VISIBILITY_GONE)
            } else {
                // not downloaded, check state
                if AssetPersistenceManager.sharedManager.localAssetForEpisodeModel(withEpisodeModel: asset.episodeModel) != nil {
                    // shouldn't happen, means binding hasn't happened after download

                    viewController!.downloadProgress.setVisibility(UIView.VISIBILITY_GONE)
                } else {
                    if AssetPersistenceManager.sharedManager.assetForEpisodeModel(withId: asset.episodeModel.getId()) != nil {
                        // currently being downloaded
                        viewController!.buttonDownload.setImage(UIImage(named: ImagesHelper.IC_DOWNLOAD), for: .normal)

                        viewController!.buttonDownload.isUserInteractionEnabled = false

                        viewController!.downloadProgress.setVisibility(UIView.VISIBILITY_VISIBLE)
                    } else {
                        // currently not downloaded
                        viewController!.buttonDownload.setImage(UIImage(named: ImagesHelper.IC_DOWNLOAD), for: .normal)

                        viewController!.buttonDownload.isUserInteractionEnabled = true
                        
                        viewController!.downloadProgress.setVisibility(UIView.VISIBILITY_GONE)
                    }
                }
            }
        }
    }
}
