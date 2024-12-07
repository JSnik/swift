//
//  OfflinePlaybackViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

// https://developer.apple.com/documentation/avfoundation/media_playback_and_selection/using_avfoundation_to_play_and_persist_http_live_streams#//apple_ref/doc/uid/TP40017320-RevisionHistory-DontLinkElementID_1

class OfflinePlaybackViewController: UIViewController {
    
    static var TAG = String(describing: OfflinePlaybackViewController.classForCoder())

    @IBOutlet weak var buttonBack: UIButtonQuinary!
    @IBOutlet weak var containerDownloadsCollection: UIView!
    @IBOutlet weak var containerPlayerMini: UIView!
    @IBOutlet weak var containerPlayerMiniBottomConstraint: NSLayoutConstraint!
    
    weak var episodesCollectionViewController: EpisodesCollectionViewController!
    weak var playerMiniViewController: PlayerMiniViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(OfflinePlaybackViewController.TAG, "viewDidLoad")

        // listeners
        buttonBack.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        
        // UI
        populateListEpisodes()

        MediaPlayerManager.getInstance().triggerAllPlayersUiSetupOrUpdate()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch(segue.identifier ?? "") {
        case StoryboardsHelper.SEGUE_EMBED_EPISODES_COLLECTION:
            episodesCollectionViewController = (segue.destination as! EpisodesCollectionViewController)
            episodesCollectionViewController.isOfflineList = true
            episodesCollectionViewController.openItemInExpandedViewEnabled = false
            self.episodesCollectionViewController.collectionView.scrollsToTop = true

            break
        case StoryboardsHelper.SEGUE_EMBED_PLAYER_MINI:
            self.playerMiniViewController = (segue.destination as! PlayerMiniViewController)
            self.playerMiniViewController.setContainerView(containerPlayerMini)
            self.playerMiniViewController.setContainerBottomConstraintReference(containerPlayerMiniBottomConstraint)

            break
        default:
            break
        }
    }
    
    deinit {
        GeneralUtils.log(OfflinePlaybackViewController.TAG, "deinit")
    }
    
    // MARK: Custom

    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonBack) {
            navigationController?.popViewController(animated: true)
        }
    }

    func populateListEpisodes() {
        let usersManager = UsersManager.getInstance()
        let currentUser = usersManager.getCurrentUser()!

        let dataset = currentUser.getOfflineEpisodes()
        
        episodesCollectionViewController.dataset.removeAll()
        episodesCollectionViewController.updateDataset(dataset)
    }
}

