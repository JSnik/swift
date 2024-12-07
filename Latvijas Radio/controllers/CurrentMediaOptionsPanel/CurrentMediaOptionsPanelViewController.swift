//
//  CurrentMediaOptionsPanelViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class CurrentMediaOptionsPanelViewController: UIViewController {
    
    static var TAG = String(describing: CurrentMediaOptionsPanelViewController.classForCoder())

    @IBOutlet weak var imageMedia: UIImageView!
    @IBOutlet weak var textBroadcastName: UILabelLabel5!
    @IBOutlet weak var textMediaTitle: UILabelLabel2!
    @IBOutlet weak var buttonClose: UIButtonGenericWithCustomBackground!
    @IBOutlet weak var buttonSpeed: UIButtonSeptenary!
    @IBOutlet weak var textPlaybackSpeedValue: UILabelLabel7!
    @IBOutlet weak var buttonAutoplay: UIButtonSeptenary!
    @IBOutlet weak var buttonPlaybackTimeout: UIButtonSeptenary!
    @IBOutlet weak var textPlaybackTimeoutValue: UILabelLabel7!
    @IBOutlet weak var dropdownPlaybackTimeout: Dropdown!

    var containerCurrentMediaOptionsPanel: UIView!
    var containerCurrentMediaOptionsPanelBottomConstraint: NSLayoutConstraint!
    var isOpened = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(CurrentMediaOptionsPanelViewController.TAG, "viewDidLoad")

        // Listeners
        buttonClose.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonSpeed.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonAutoplay.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonPlaybackTimeout.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        
        setupMediaPlayerTimeoutManagerListener()
        
        setupDropdownPlaybackTimeout()
        
        // Other
        view.translatesAutoresizingMaskIntoConstraints = false

        self.containerCurrentMediaOptionsPanelBottomConstraint.constant = -self.view.frame.height
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        MediaPlayerManager.getInstance().performActionGetTimeout()
    }

    deinit {
        GeneralUtils.log(CurrentMediaOptionsPanelViewController.TAG, "deinit")
    }

    // MARK: Custom
    
    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonClose) {
            closePanel()
        }
        if (sender == buttonSpeed) {
            MediaPlayerManager.getInstance().performActionCyclePlaybackSpeed(true)
        }
        if (sender == buttonAutoplay) {
            let usersManager = UsersManager.getInstance()
            let currentUser = usersManager.getCurrentUser()!
            
            if (currentUser.getIsAutoplayEnabled()) {
                buttonAutoplay.customTintColor = UIColor(named: ColorsHelper.GRAY_3)
                
                currentUser.setIsAutoplayEnabled(false)
            } else {
                buttonAutoplay.customTintColor = UIColor(named: ColorsHelper.GREEN)
                
                currentUser.setIsAutoplayEnabled(true)
            }
            
            usersManager.saveCurrentUserData()
        }
        if (sender == buttonPlaybackTimeout) {
            dropdownPlaybackTimeout.show()
        }
    }
    
    func setContainerView(_ containerCurrentMediaOptionsPanel: UIView) {
        self.containerCurrentMediaOptionsPanel = containerCurrentMediaOptionsPanel
    }
    
    func setContainerBottomConstraintReference(_ containerCurrentMediaOptionsPanelBottomConstraint: NSLayoutConstraint) {
        self.containerCurrentMediaOptionsPanelBottomConstraint = containerCurrentMediaOptionsPanelBottomConstraint
    }

    func openPanel() {
        isOpened = true

        DispatchQueue.main.async { [weak self] in
            if (self != nil) {
                self!.containerCurrentMediaOptionsPanelBottomConstraint.constant = -self!.view.frame.height
                self!.containerCurrentMediaOptionsPanel.superview!.layoutIfNeeded()

                UIView.animate(withDuration: 0.3, animations: {
                    self!.containerCurrentMediaOptionsPanelBottomConstraint.constant = 0
                    self!.containerCurrentMediaOptionsPanel.superview!.layoutIfNeeded()
                })
            }
        }
    }
    
    func closePanel() {
        isOpened = false

        UIView.animate(withDuration: 0.3, animations: {
            self.containerCurrentMediaOptionsPanelBottomConstraint.constant = -self.view.frame.height
            self.containerCurrentMediaOptionsPanel.superview!.layoutIfNeeded()
        })
    }

    func togglePanel() {
        if (isOpened) {
            closePanel()
        } else {
            openPanel()
        }
    }
    
    func setupMediaPlayerTimeoutManagerListener() {
        NotificationCenter.default.addObserver(forName: Notification.Name(MediaPlayerManagerTimeoutManager.EVENT_ON_BROADCAST_CURRENT_PLAYBACK_TIMEOUT_MODEL), object: nil, queue: .main) { [weak self] notification in
            GeneralUtils.log(PlayerMiniViewController.TAG, "EVENT_ON_BROADCAST_CURRENT_PLAYBACK_TIMEOUT_MODEL")

            if (self != nil) {
                if let data = notification.userInfo as NSDictionary? {
                    if let playbackTimeoutModel = data[MediaPlayerManager.NOTIFICATION_PARAMS_DEFAULT_KEY] as? PlaybackTimeoutModel {
                        self?.updatePlaybackTimeoutSelectionRepresentation(playbackTimeoutModel)
                    }
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name(MediaPlayerManager.EVENT_ON_PLAYBACK_SPEED_CHANGED), object: nil, queue: .main) { [weak self] notification in
            GeneralUtils.log(PlayerMiniViewController.TAG, "EVENT_ON_PLAYBACK_SPEED_CHANGED")

            if (self != nil) {
                if let data = notification.userInfo as NSDictionary? {
                    if let playbackSpeed = data[MediaPlayerManager.NOTIFICATION_PARAMS_DEFAULT_KEY] as? Float {
                        self?.updatePlaybackSpeedRepresentation(playbackSpeed)
                    }
                }
            }
        }
    }
    
    func setupDropdownPlaybackTimeout() {
        let timeoutOptions = MediaPlayerManagerTimeoutManager.getOptions()
        
        var dataset = [GenericDropdownItemModel]()
        
        for playbackTimeoutModel in timeoutOptions {
            let genericDropdownItemModel = GenericDropdownItemModel(playbackTimeoutModel.getId(), playbackTimeoutModel.getTitleResourceId().localized(), playbackTimeoutModel)
            
            dataset.append(genericDropdownItemModel)
        }

        dropdownPlaybackTimeout.setDropdownData(dataset)
        
        dropdownPlaybackTimeout.onItemSelectionConfirmed = { [weak self] (position, selectedItem) in
            let playbackTimeoutModel = selectedItem.getObject() as! PlaybackTimeoutModel
            
            self?.updatePlaybackTimeoutSelectionRepresentation(playbackTimeoutModel)
            
            // Update selection in player manager.
            MediaPlayerManager.getInstance().performActionSetTimeout(playbackTimeoutModel)
        }
    }
    
    func updateCurrentMediaOptionsPanel() {
        let playbackTimeoutModel: PlaybackTimeoutModel = MediaPlayerManager.getInstance().mediaPlayerManagerTimeoutManager.currentPlaybackTimeoutModel
        updatePlaybackTimeoutSelectionRepresentation(playbackTimeoutModel)
        
        let playbackSpeed = MediaPlayerManager.getInstance().playbackSpeed
        updatePlaybackSpeedRepresentation(playbackSpeed)
        
        if let currentEpisode = MediaPlayerManager.getInstance().currentEpisode {
            // update title
            let title = currentEpisode.getTitle()
            textMediaTitle.setText(title)
            textMediaTitle.setVisibility(UIView.VISIBILITY_VISIBLE)

            // update category name
            let categoryName = currentEpisode.getCategoryName()
            textBroadcastName.setText(categoryName)

            // update image
            let imageUrl = currentEpisode.getImageUrl()
            imageMedia.sd_setImage(with: URL(string: imageUrl), completed: nil)
            
            // update playback speed
            buttonSpeed.setVisibility(UIView.VISIBILITY_VISIBLE)
            textPlaybackSpeedValue.setVisibility(UIView.VISIBILITY_VISIBLE)
            
            // update button autoplay
            buttonAutoplay.setVisibility(UIView.VISIBILITY_VISIBLE)
            
            // update autoplay state
            let usersManager = UsersManager.getInstance()
            if let currentUser = usersManager.getCurrentUser() {
                if (currentUser.getIsAutoplayEnabled()) {
                    buttonAutoplay.customTintColor = UIColor(named: ColorsHelper.GREEN)
                } else {
                    buttonAutoplay.customTintColor = UIColor(named: ColorsHelper.GRAY_3)
                }
            }
        }
        
        if let currentLivestream = MediaPlayerManager.getInstance().currentLivestream {
            // update title
            textMediaTitle.setVisibility(UIView.VISIBILITY_GONE)

            // update category name
            let categoryName = currentLivestream.name //getName()
            textBroadcastName.setText(categoryName)

            // update image
//            let imageResourceId = currentLivestream.getImageResourceId()
//            imageMedia.image = UIImage(named: imageResourceId)
            if (currentLivestream.image != nil) {
                imageMedia.sd_setImage(with: URL(string: currentLivestream.image ?? ""))
            } else {
                imageMedia.image = nil
            }

            // update playback speed
            buttonSpeed.setVisibility(UIView.VISIBILITY_GONE)
            textPlaybackSpeedValue.setVisibility(UIView.VISIBILITY_GONE)
            
            // update button autoplay
            buttonAutoplay.setVisibility(UIView.VISIBILITY_GONE)
        }
    }

    func updatePlaybackTimeoutSelectionRepresentation(_ playbackTimeoutModel: PlaybackTimeoutModel) {
        let id = playbackTimeoutModel.getId()
        let localizedTitle = playbackTimeoutModel.getTitleResourceId().localized()
        
        if (id == PlaybackTimeoutModel.ID_TURN_OFF) {
            textPlaybackTimeoutValue.isHidden = true
        } else {
            textPlaybackTimeoutValue.setText(localizedTitle)
            
            textPlaybackTimeoutValue.isHidden = false
        }
    }
    
    func updatePlaybackSpeedRepresentation(_ playbackSpeed: Float) {
        textPlaybackSpeedValue.setText("x " + String(format:"%.2f", playbackSpeed))
    }
}

