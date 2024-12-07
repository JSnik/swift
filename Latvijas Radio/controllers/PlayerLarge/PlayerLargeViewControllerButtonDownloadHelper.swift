//
//  PlayerLargeViewControllerButtonDownloadHelper.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit
import AVFoundation

class PlayerLargeViewControllerButtonDownloadHelper {
    
    static var TAG = String(describing: PlayerLargeViewControllerButtonDownloadHelper.self)

    weak var viewController: PlayerLargeViewController?
    
    var asset: Asset?
    
    deinit {
        GeneralUtils.log(PlayerLargeViewControllerButtonDownloadHelper.TAG, "deinit")
    }
    
    func setupEpisodeDownloadButton(_ episodeModel: EpisodeModel?) {
        if let episodeModel = episodeModel {
            viewController!.wrapperButtonDownload.isHidden = false
            
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
        } else {
            asset = nil
            
            viewController!.wrapperButtonDownload.isHidden = true
        }
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

        GeneralUtils.log(PlayerLargeViewControllerButtonDownloadHelper.TAG, "Download progress:", progress)

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

        if let asset = asset {
            AssetPersistenceManager.sharedManager.downloadStream(for: asset)
        }
    }

    func updateEpisodeDownloadButtonState() {
        guard (viewController != nil) else { return }

        if let asset = asset {
            if (!EpisodesHelper.isEpisodeAllowedToBeDownloaded(asset.episodeModel)) {
                viewController!.buttonDownload.isHidden = true
                viewController!.downloadProgress.setVisibility(UIView.VISIBILITY_GONE)
            } else {
                // update download button state
                let usersManager = UsersManager.getInstance()
                
                viewController!.buttonDownload.tintColor = UIColor(named: ColorsHelper.BLACK)
                
                if (usersManager.getOfflineEpisodeById(asset.episodeModel.getId()) != nil) {
                    // already downloaded and bound
                    viewController!.buttonDownload.setImage(UIImage(named: ImagesHelper.IC_CHECKMARK), for: .normal)
                    viewController!.buttonDownload.tintColor = UIColor(named: ColorsHelper.RED)
                    
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
                            viewController!.buttonDownload.setImage(UIImage(named: ImagesHelper.IC_DOWNLOAD_DEFAULT), for: .normal)
                            viewController!.buttonDownload.tintColor = UIColor(named: ColorsHelper.GRAY_4)
                            
                            viewController!.buttonDownload.isUserInteractionEnabled = false
                            
                            viewController!.downloadProgress.setVisibility(UIView.VISIBILITY_VISIBLE)
                        } else {
                            // currently not downloaded
                            viewController!.buttonDownload.setImage(UIImage(named: ImagesHelper.IC_DOWNLOAD_DEFAULT), for: .normal)
                            
                            viewController!.buttonDownload.isUserInteractionEnabled = true
                            
                            viewController!.downloadProgress.setVisibility(UIView.VISIBILITY_GONE)
                        }
                    }
                }
            }
        }
    }
}
