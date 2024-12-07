//
//  SettingsViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {
    
    var TAG = String(describing: SettingsViewController.classForCoder())

    @IBOutlet weak var buttonBack: UIButtonQuinary!
    @IBOutlet weak var imageUserProfile: UIImageView!
    @IBOutlet weak var textName: UILabelH2!
    @IBOutlet weak var buttonLogOutFromGuest: UIButtonPrimary!
    @IBOutlet weak var buttonLogOut: UIButtonSecondary!
    @IBOutlet weak var buttonDeleteAccount: UIButtonDecary!
    @IBOutlet weak var textUnreadNotificationAmount: UILabelBase!
    @IBOutlet weak var buttonNotifications: UIButtonOctonary!
    @IBOutlet weak var buttonLanguage: UIButtonTertiaryDropdown!
    @IBOutlet weak var dropdownLanguage: Dropdown!
    @IBOutlet weak var checkBoxDownloadOnlyWithWifi: CheckBoxPrimary!
    @IBOutlet weak var checkBoxDeleteCompletedEpisodes: CheckBoxPrimary!
    @IBOutlet weak var checkBoxReceiveNotificationAboutSubscribedBroadcastNewEpisode: CheckBoxPrimary!
    @IBOutlet weak var activityIndicatorReceiveNotificationAboutSubscribedBroadcastNewEpisode: UIActivityIndicatorView!
    @IBOutlet weak var buttonChangeLivestreamsOrderInDashboard: UIButtonOctonary!
    @IBOutlet weak var buttonSupport: UIButtonOctonary!
    @IBOutlet weak var buttonCookies: UIButtonNonary!
    @IBOutlet weak var textVersion: UILabelLabel7!
    @IBOutlet weak var containerNotification: UIView!
    @IBOutlet weak var activityIndicatorDeleteAccount: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var wrapperMenuSettings: UIView!
    @IBOutlet weak var textTitle: UILabelH1!
    @IBOutlet weak var textLanguage: UILabelBase!
    

    weak var notificationViewController: NotificationViewController!
    weak var externalLinksCollectionViewController: ExternalLinksCollectionViewController!

    var fullDataset: [BroadcastsByCategoryModel]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(TAG, "viewDidLoad")
        
        // listeners
        buttonBack.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonLogOutFromGuest.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonLogOut.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonDeleteAccount.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonNotifications.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonLanguage.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonChangeLivestreamsOrderInDashboard.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonSupport.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonCookies.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)

        let customFont4 = UIFont(name: "FuturaPT-Medium", size: 13.0)
        buttonLanguage.titleLabel?.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont4 ?? UIFont.systemFont(ofSize: 13.0))
        buttonLanguage.titleLabel?.adjustsFontForContentSizeCategory = true
        buttonLanguage.adjustsImageSizeForAccessibilityContentSizeCategory = true
        buttonLanguage.titleLabel?.numberOfLines = 0
        buttonLanguage.titleLabel?.adjustsFontSizeToFitWidth = true

//        buttonLanguage.titleLabel?.minimumScaleFactor = 0.5
        buttonLanguage.accessibilityLabel = "Submit Button"
        buttonLanguage.sizeToFit()

        setupDropdownLanguages()
        
        setupCheckBoxDownloadOnlyWithWifi()
        setupCheckBoxDeleteCompletedEpisodes()
        setupCheckBoxReceiveNotificationAboutSubscribedBroadcastNewEpisode()

        // UI
        processUnboundNotifications()
        
        populateViewWithData1()
        
        performRequestSettings()
        let customFont1 = UIFont(name: "FuturaPT-Book", size: 22.0)
        textTitle.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont1 ?? UIFont.systemFont(ofSize: 22.0))
        textTitle.adjustsFontForContentSizeCategory = true
        textName.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont1 ?? UIFont.systemFont(ofSize: 10.0))
        textName.adjustsFontForContentSizeCategory = true
        let customFont2 = UIFont(name: "FuturaPT-Book", size: 12.0)
        textUnreadNotificationAmount.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont2 ?? UIFont.systemFont(ofSize: 12.0))
        textUnreadNotificationAmount.adjustsFontForContentSizeCategory = true
        let customFont3 = UIFont(name: "FuturaPT-Medium", size: 14.0)
        textLanguage.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont3 ?? UIFont.systemFont(ofSize: 14.0))
        textLanguage.adjustsFontForContentSizeCategory = true
        textVersion.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont1 ?? UIFont.systemFont(ofSize: 14.0))
        textVersion.adjustsFontForContentSizeCategory = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkUnreadNotifications()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch(segue.identifier ?? "") {
        case StoryboardsHelper.SEGUE_EMBED_NOTIFICATION:
            self.notificationViewController = (segue.destination as! NotificationViewController)
            self.notificationViewController.setContainerView(containerNotification)
            
            break
        case StoryboardsHelper.SEGUE_EMBED_EXTERNAL_LINKS_COLLECTION:
            self.externalLinksCollectionViewController = (segue.destination as! ExternalLinksCollectionViewController)
            
            break
        default:
            break
        }
    }
    
    deinit {
        GeneralUtils.log(TAG, "deinit")
    }
    
    // MARK: Custom
    
    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonBack) {
            navigationController?.popViewController(animated: true)
        }
        if (sender == buttonLogOutFromGuest) {
            logOut()
        }
        if (sender == buttonLogOut) {
            logOut()
        }
        if (sender == buttonDeleteAccount) {
            let viewControllerAccountDeleteConfirmationPopup = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_ACCOUNT_DELETE_CONFIRMATION_POPUP, bundle: nil)
                                                .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_ACCOUNT_DELETE_CONFIRMATION_POPUP) as! AccountDeleteConfirmationPopupViewController)

            viewControllerAccountDeleteConfirmationPopup.modalTransitionStyle = .crossDissolve
            viewControllerAccountDeleteConfirmationPopup.delegate = self

            navigationController?.present(viewControllerAccountDeleteConfirmationPopup, animated: true, completion: nil)
        }
        if (sender == buttonNotifications) {
            let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_NOTIFICATIONS, bundle: nil)
                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_NOTIFICATIONS) as! NotificationsViewController)

            navigationController?.pushViewController(viewController, animated: true)
        }
        if (sender == buttonLanguage) {
            dropdownLanguage.show()
        }
        if (sender == buttonChangeLivestreamsOrderInDashboard) {
            let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_CHANGE_LIVESTREAMS_ORDER, bundle: nil)
                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_CHANGE_LIVESTREAMS_ORDER) as! ChangeLivestreamsOrderViewController)

            navigationController?.pushViewController(viewController, animated: true)
        }
        if (sender == buttonSupport) {
            let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_SUPPORT, bundle: nil)
                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_SUPPORT) as! SupportViewController)

            navigationController?.pushViewController(viewController, animated: true)
        }
        if (sender == buttonCookies) {
            showContentPopup(ContentPopupViewController.CONTENT_TYPE_PRIVACY_POLICY)
        }
    }

    func showContentPopup(_ contentType: String) {
        let viewControllerContentPopup = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_CONTENT_POPUP, bundle: nil)
                                            .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_CONTENT_POPUP) as! ContentPopupViewController)

        viewControllerContentPopup.modalTransitionStyle = .crossDissolve
        viewControllerContentPopup.contentType = contentType

        navigationController?.present(viewControllerContentPopup, animated: true, completion: nil)
    }
    
    func setupDropdownLanguages() {
        let languages = LanguageManager.getLanguages()
        
        var dataset = [GenericDropdownItemModel]()
        
        for i in (0..<languages.count) {
            let language = languages[i]
            
            let genericDropdownItemModel = GenericDropdownItemModel(language.id, language.displayName, language)
            
            dataset.append(genericDropdownItemModel)
        }
        
        dropdownLanguage.setDropdownData(dataset)
        
        dropdownLanguage.onItemSelectionConfirmed = { [weak self] (position, selectedItem) in
            let id = selectedItem.getId()
            self?.buttonLanguage.accessibilityLabel = id
            self?.buttonLanguage.setText(id)
            
            if (id != LanguageManager.currentInterfaceLanguageId) {
                LanguageManager.setLanguage(id)

                if (self != nil) {
                    if (self!.navigationController != nil) {
                        // Refresh auto interface to show content in correct language.
                        if let carPlaySceneDelegate = CarPlaySceneDelegate.getCarPlaySceneDelegate() {
                            carPlaySceneDelegate.autoContentManager?.loadRootTemplate()
                            
                            carPlaySceneDelegate.autoContentManager?.updateNowPlayingTemplateQueueButtonTitle()
                        }
                        
                        let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_DASHBOARD_CONTAINER, bundle: nil)
                                                .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_DASHBOARD_CONTAINER) as! DashboardContainerViewController)

                        self?.navigationController?.pushViewController(viewController, animated: true)
                        
                        self?.navigationController?.viewControllers.removeSubrange(0..<self!.navigationController!.viewControllers.count - 1)
                        
                        let viewController2 = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_SETTINGS, bundle: nil)
                                                .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_SETTINGS) as! SettingsViewController)

                        self?.navigationController?.pushViewController(viewController2, animated: true)
                    }
                }
            }
        }
    }
    
    func setupCheckBoxDownloadOnlyWithWifi() {
        checkBoxDownloadOnlyWithWifi.addTarget(self, action: #selector(onCheckBoxDownloadOnlyWithWifiClick), for: .touchUpInside)
    }
    
    func setupCheckBoxDeleteCompletedEpisodes() {
        checkBoxDeleteCompletedEpisodes.addTarget(self, action: #selector(onCheckBoxDeleteCompletedEpisodesClick), for: .touchUpInside)
    }
    
    func setupCheckBoxReceiveNotificationAboutSubscribedBroadcastNewEpisode() {
        checkBoxReceiveNotificationAboutSubscribedBroadcastNewEpisode.addTarget(self, action: #selector(onCheckBoxReceiveNotificationAboutSubscribedBroadcastNewEpisodeClick), for: .touchUpInside)
        
        setViewStateReceiveNotificationAboutSubscribedBroadcastNewEpisodeNormal()
    }
    
    @objc func onCheckBoxDownloadOnlyWithWifiClick() {
        let usersManager = UsersManager.getInstance()
        let currentUser = usersManager.getCurrentUser()!
        
        currentUser.setDownloadOnlyWithWifi(checkBoxDownloadOnlyWithWifi.isChecked)
        
        usersManager.saveCurrentUserData()
        
        performRequestUserPost()
    }
    
    @objc func onCheckBoxDeleteCompletedEpisodesClick() {
        let usersManager = UsersManager.getInstance()
        let currentUser = usersManager.getCurrentUser()!
        
        currentUser.setAutomaticallyDeleteFinishedEpisodesFromMyList(checkBoxDeleteCompletedEpisodes.isChecked)
        
        usersManager.saveCurrentUserData()
        
        performRequestUserPost()
    }
    
    @objc func onCheckBoxReceiveNotificationAboutSubscribedBroadcastNewEpisodeClick() {
        setViewStateReceiveNotificationAboutSubscribedBroadcastNewEpisodeLoading()
        
        if (checkBoxReceiveNotificationAboutSubscribedBroadcastNewEpisode.isChecked) {
            // User wants to receive push notifications.

            GeneralUtils.getUserDefaults().set(true, forKey: Configuration.RECEIVE_NOTIFICATION_ABOUT_SUBSCRIBED_BROADCAST_NEW_EPISODE)
            
            Messaging.messaging().deleteToken(completion: { error in
                FirebaseCloudMessagingManager.getCurrentRegistrationToken()
            })
            
            setViewStateReceiveNotificationAboutSubscribedBroadcastNewEpisodeNormal()
        } else {
            // User doesn't want to receive push notifications.

            GeneralUtils.getUserDefaults().removeObject(forKey: FirebaseCloudMessagingManager.FCM_TOKEN_REPRESENTING_THIS_DEVICE)
            GeneralUtils.getUserDefaults().set(false, forKey: Configuration.RECEIVE_NOTIFICATION_ABOUT_SUBSCRIBED_BROADCAST_NEW_EPISODE)
            
            // Update fcm token that represent the device, so any notifications from backend to fcm to this device would fail.
            Messaging.messaging().deleteToken(completion: { [weak self] error in
                self?.setViewStateReceiveNotificationAboutSubscribedBroadcastNewEpisodeNormal()
            })
        }
    }
    
    func performRequestUserPost() {
        // params
        let urlQueryItems = [
            URLQueryItem(name: UserPostRequest.REQUEST_PARAM_DOWNLOAD_ONLY_WITH_WIFI, value: String(checkBoxDownloadOnlyWithWifi.isChecked)),
            URLQueryItem(name: UserPostRequest.REQUEST_PARAM_AUTOMATICALLY_DELETE_FINISHED_EPISODES_FROM_MY_LIST, value: String(checkBoxDeleteCompletedEpisodes.isChecked))
        ]

        let userPostRequest = UserPostRequest(notificationViewController, urlQueryItems)

        userPostRequest.execute()
    }
    
    func processUnboundNotifications() {
        // We check if there are any notifications that have arrived but have not been bound to user.
        // If there are any, we bind them and clear the bucket.
        // This can also be done every time app comes back into foreground if need be.
        
        let usersManager = UsersManager.getInstance()
        if let currentUser = usersManager.getCurrentUser() {
            if let userUnboundNotifications = GeneralUtils.getUserDefaults().array(forKey: Configuration.USER_UNBOUND_NOTIFICATIONS_PREFIX + currentUser.getId()) as? [String] {
                GeneralUtils.log(TAG, "userUnboundNotifications", userUnboundNotifications as Any)
                
                // We might have collected multiple notification batches.
                // Go through each and bind them to current user.
                
                for userUnboundNotification in userUnboundNotifications {
                    let episodesAsJsonString: String = userUnboundNotification
                    
                    if let episodesAsData = episodesAsJsonString.data(using: .utf8) {
                        let episodesJson = try? JSONSerialization.jsonObject(with: episodesAsData, options: [])
                        if let episodesJson = episodesJson as? [[String: Any]] {
                            if (episodesJson.count > 0) {
                                var newReceivedNotifications = [NotificationModel]()
                                
                                for i in (0..<episodesJson.count) {
                                    let episodeJson = episodesJson[i]

                                    let broadcastId = episodeJson[Configuration.NOTIFICATION_PARAM_BROADCAST_ID] as! Int
                                    let broadcastName = episodeJson[Configuration.NOTIFICATION_PARAM_BROADCAST_NAME] as! String
                                    let episodeId = episodeJson[Configuration.NOTIFICATION_PARAM_EPISODE_ID] as! Int
                                    let episodeTitle = episodeJson[Configuration.NOTIFICATION_PARAM_EPISODE_TITLE] as! String

                                    let notificationModel = NotificationModel()
                                    notificationModel.setBroadcastId(String(broadcastId))
                                    notificationModel.setBroadcastName(broadcastName)
                                    notificationModel.setEpisodeId(String(episodeId))
                                    notificationModel.setEpisodeTitle(episodeTitle)

                                    newReceivedNotifications.append(notificationModel)
                                }

                                var receivedNotifications = currentUser.getReceivedNotifications()
                                receivedNotifications.insert(contentsOf: newReceivedNotifications, at: 0)
                                currentUser.setReceivedNotifications(receivedNotifications)

                                usersManager.saveCurrentUserData()
                            }
                        }
                    }
                }
                
                GeneralUtils.getUserDefaults().removeObject(forKey: Configuration.USER_UNBOUND_NOTIFICATIONS_PREFIX + currentUser.getId())
                GeneralUtils.getUserDefaults().synchronize()
            }
        }
    }
    
    func setViewStateNormal() {
        wrapperMenuSettings.isHidden = false
        buttonCookies.isHidden = false
        activityIndicator.isHidden = true
        activityIndicatorDeleteAccount.isHidden = true
    }
    
    func setViewStateLoading() {
        wrapperMenuSettings.isHidden = true
        buttonCookies.isHidden = true
        activityIndicator.isHidden = false
        activityIndicatorDeleteAccount.isHidden = true
    }
    
    func setViewStateDeletingAccount() {
        buttonDeleteAccount.isHidden = true
        activityIndicatorDeleteAccount.isHidden = false
    }
    
    func setViewStateReceiveNotificationAboutSubscribedBroadcastNewEpisodeNormal() {
        checkBoxReceiveNotificationAboutSubscribedBroadcastNewEpisode.isEnabled = true
        checkBoxReceiveNotificationAboutSubscribedBroadcastNewEpisode.alpha = 1
        activityIndicatorReceiveNotificationAboutSubscribedBroadcastNewEpisode.isHidden = true
    }
    
    func setViewStateReceiveNotificationAboutSubscribedBroadcastNewEpisodeLoading() {
        checkBoxReceiveNotificationAboutSubscribedBroadcastNewEpisode.isEnabled = false
        checkBoxReceiveNotificationAboutSubscribedBroadcastNewEpisode.alpha = 0.3
        activityIndicatorReceiveNotificationAboutSubscribedBroadcastNewEpisode.isHidden = false
    }
    
    func performRequestSettings() {
        dismissKeyboard()
        
        setViewStateLoading()

        let settingsRequest = SettingsRequest(notificationViewController)

        settingsRequest.successCallback = { [weak self] (data) -> Void in
            // save received content to appData
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions.prettyPrinted)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    GeneralUtils.getUserDefaults().set(jsonString, forKey: AuthenticationViewController.SETTINGS_FROM_API)
                }

            } catch {
                GeneralUtils.log(AuthenticationViewController.TAG, error.localizedDescription)
            }
            
            self?.populateViewWithData2()
            
            self?.setViewStateNormal()
        }

        settingsRequest.errorCallback = { [weak self] in
            self?.setViewStateNormal()
        }
        
        settingsRequest.execute()
    }
    
    func populateViewWithData1() {
        // Update version
        let appVersion = GeneralUtils.getAppVersion(longVersion: true)
        textVersion.setText("version_colled".localized() + appVersion)
        
        // Update name
        let usersManager = UsersManager.getInstance()
        let currentUser = usersManager.getCurrentUser()!

        if (currentUser.getRegistrationType() == UserGetRequest.REGISTRATION_TYPE_GUEST) {
            textName.setText("guest".localized())
        } else {
            textName.setText(currentUser.getName())
        }
        
        // Update image
        imageUserProfile.layer.cornerRadius = 42.5
        imageUserProfile.layer.borderColor = UIColor(named: ColorsHelper.BLACK)!.cgColor
        imageUserProfile.layer.borderWidth = 1
        imageUserProfile.layer.masksToBounds = true

        if let imagePath = currentUser.getImagePath() {
            imageUserProfile.sd_setImage(with: URL(string: imagePath)!, completed: nil)
        }
        
        // Update change livestreams order button visibility
        if (currentUser.getRegistrationType() == UserGetRequest.REGISTRATION_TYPE_GUEST) {
            buttonChangeLivestreamsOrderInDashboard.setVisibility(UIView.VISIBILITY_GONE)
        } else {
            buttonChangeLivestreamsOrderInDashboard.setVisibility(UIView.VISIBILITY_VISIBLE)
        }
        
        // Update log out button visibility
        if (currentUser.getRegistrationType() == UserGetRequest.REGISTRATION_TYPE_GUEST) {
            buttonLogOutFromGuest.isHidden = false
            buttonLogOut.isHidden = true
        } else {
            buttonLogOutFromGuest.isHidden = true
            buttonLogOut.isHidden = false
        }
    }
    
    func populateViewWithData2() {
        let usersManager = UsersManager.getInstance()
        if let currentUser = usersManager.getCurrentUser() {
            // update settings
            checkBoxDownloadOnlyWithWifi.isChecked = currentUser.getDownloadOnlyWithWifi()
            checkBoxDeleteCompletedEpisodes.isChecked = currentUser.getAutomaticallyDeleteFinishedEpisodesFromMyList()
            
            // update notification flag
            var receiveNotificationAboutSubscribedBroadcastNewEpisode = GeneralUtils.getUserDefaults().object(forKey: Configuration.RECEIVE_NOTIFICATION_ABOUT_SUBSCRIBED_BROADCAST_NEW_EPISODE) as? Bool
            
            if (receiveNotificationAboutSubscribedBroadcastNewEpisode == nil) {
                receiveNotificationAboutSubscribedBroadcastNewEpisode = true
            }

            checkBoxReceiveNotificationAboutSubscribedBroadcastNewEpisode.isChecked = receiveNotificationAboutSubscribedBroadcastNewEpisode!
            
            if let settingsFromApi = GeneralUtils.getUserDefaults().object(forKey: AuthenticationViewController.SETTINGS_FROM_API) as? String {
                if let settingsFromApiAsData = settingsFromApi.data(using: .utf8) {
                    let settingsFromApiJson = try? JSONSerialization.jsonObject(with: settingsFromApiAsData, options: [])
                    if let settingsFromApiJson = settingsFromApiJson as? [String: Any] {
                        // update external links
                        let externalLinks = settingsFromApiJson[SettingsRequest.RESPONSE_PARAM_EXTERNAL_LINKS] as! [[String: Any]]
                        
                        var dataset = [ExternalLinkModel]()
                        
                        for i in (0..<externalLinks.count) {
                            let externalLink = externalLinks[i]
                            let name = externalLink[SettingsRequest.RESPONSE_PARAM_NAME] as! String
                            let link = externalLink[SettingsRequest.RESPONSE_PARAM_LINK] as! String
                            
                            let externalLinkModel = ExternalLinkModel(name, link)
                            
                            dataset.append(externalLinkModel)
                        }
                        
                        externalLinksCollectionViewController.updateDataset(dataset)
                    }
                }
            }
            
            // udpate language
            dropdownLanguage.selectItemById(LanguageManager.currentInterfaceLanguageId!)
            
            buttonLanguage.setText(LanguageManager.currentInterfaceLanguageId!)
            buttonLanguage.accessibilityLabel = LanguageManager.currentInterfaceLanguageId!
        }
    }
    
    func checkUnreadNotifications() {
        var unreadNotificationAmount = 0
        
        let usersManager = UsersManager.getInstance()
        let currentUser = usersManager.getCurrentUser()!
        
        let dataset = currentUser.getReceivedNotifications()
        
        for i in (0..<dataset.count) {
            let notificationModel = dataset[i]
            
            if (!notificationModel.getIsRead()) {
                unreadNotificationAmount += 1
            }
        }
        
        if (unreadNotificationAmount > 0) {
            textUnreadNotificationAmount.setVisibility(UIView.VISIBILITY_VISIBLE)
            
            textUnreadNotificationAmount.setText(String(unreadNotificationAmount))
        } else {
            textUnreadNotificationAmount.setVisibility(UIView.VISIBILITY_GONE)
        }
    }
    
    func logOut() {
        UsersManager.logOutCurrentUser()
        
        // Update fcm token that represent the device, so any notifications from backend to fcm to this device would fail.
        Messaging.messaging().deleteToken(completion: { error in
            FirebaseCloudMessagingManager.getCurrentRegistrationToken()
        })
        
        // Notify CarPlay to reload root item.
        if let carPlaySceneDelegate = CarPlaySceneDelegate.getCarPlaySceneDelegate() {
            carPlaySceneDelegate.autoContentManager?.loadRootTemplate()
        }
        
        let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_AUTHENTICATION, bundle: nil)
                                .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_AUTHENTICATION) as! AuthenticationViewController)

        navigationController?.pushViewController(viewController, animated: true)
        
        navigationController?.viewControllers.removeSubrange(0..<navigationController!.viewControllers.count - 1)
    }
}

extension SettingsViewController: AccountDeleteConfirmationPopupDelegate {
    
    func onAccountDeleteConfirmed() {
        setViewStateDeletingAccount()
        
        performRequestUserDelete()
    }
    
    func performRequestUserDelete() {
        let userDeleteRequest = UserDeleteRequest(notificationViewController)

        userDeleteRequest.successCallback = { [weak self] (data) -> Void in
            self?.logOut()
        }

        userDeleteRequest.errorCallback = { [weak self] in
            self?.setViewStateNormal()
        }
        
        userDeleteRequest.execute()
    }
}
