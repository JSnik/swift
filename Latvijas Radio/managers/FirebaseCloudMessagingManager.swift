//
//  FirebaseCloudMessagingManager.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit
import Firebase

class FirebaseCloudMessagingManager: NSObject {
    
    static let TAG = String(describing: FirebaseCloudMessagingManager.self)
    
    static let FCM_TOKEN_REPRESENTING_THIS_DEVICE = "FCM_TOKEN_REPRESENTING_THIS_DEVICE"

    func setup(_ application: UIApplication) {
        // Register for remote notifications
        
        // For iOS 10 display notification (sent via APNS)
        UNUserNotificationCenter.current().delegate = self

        // shows ".. would like to send you notifications" popup
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in })

        // remove old badges from desktop when launching app
        UIApplication.shared.applicationIconBadgeNumber = 0

        // Listen for tokens
        Messaging.messaging().delegate = self
    }

    static func getCurrentRegistrationToken() {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
            }
        }
    }

    static func updateFcmTokenInServer(_ fcmToken: String) {
        var receiveNotificationAboutSubscribedBroadcastNewEpisode = GeneralUtils.getUserDefaults().object(forKey: Configuration.RECEIVE_NOTIFICATION_ABOUT_SUBSCRIBED_BROADCAST_NEW_EPISODE) as? Bool

        if (receiveNotificationAboutSubscribedBroadcastNewEpisode == nil) {
            receiveNotificationAboutSubscribedBroadcastNewEpisode = true
        }

        if (receiveNotificationAboutSubscribedBroadcastNewEpisode!) {
            // params
            let appInstanceId = GeneralUtils.getUserDefaults().string(forKey: Configuration.APP_INSTANCE_ID)
            
            let urlQueryItems = [
                URLQueryItem(name: UserPostRequest.REQUEST_PARAM_FCM_TOKEN, value: fcmToken),
                URLQueryItem(name: UserPostRequest.REQUEST_PARAM_DEVICE_ID, value: appInstanceId)
            ]

            let userPostRequest = UserPostRequest(nil, urlQueryItems)
            
            userPostRequest.successCallback = { _ in
                // save the new token in our user object
                let usersManager = UsersManager.getInstance()
                if let currentUser = usersManager.getCurrentUser() {
                    currentUser.setFcmToken(fcmToken)
                    
                    usersManager.saveCurrentUserData()
                }
            }

            userPostRequest.execute()
        }
    }
}

extension FirebaseCloudMessagingManager: UNUserNotificationCenterDelegate {
    
    // Notifications (local or remote) won't show up if app is in foreground.
    // Implementing "willPresent" allows it to be shown.
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        //Messaging.messaging().appDidReceiveMessage(userInfo)

        GeneralUtils.log(FirebaseCloudMessagingManager.TAG, "willPresent: ", userInfo)

        // For notifications in foreground:

        // - banner: slides notification down from top. Shows only if set in completionHandler.
        // - list: saves notification in notification list (when user drags down from top to bottom of the screen). Shows only if set in completionHandler.
        // - sound: (default value: false) sound will only play in foreground notification, if is passed in completionHandler here AND it "exists" in payload (doesn't matter if true|false) AND ".list" or ".banner" is set in completionHandler
        // - badge: (default value: 0) badge number will show in foreground notification, if is passed in completionHandler here AND it is in payload as non-zero value

        completionHandler([.banner, .list, .sound, .badge])
    }

    // "didReceive" gets called whenever user taps a notification.
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        //Messaging.messaging().appDidReceiveMessage(userInfo)

        GeneralUtils.log(FirebaseCloudMessagingManager.TAG, "didTapOnNotification: ", userInfo)
        
        // Remove badges from desktop when user clicks a notification
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        if let actionId = userInfo[Configuration.NOTIFICATION_PARAM_ACTION] as? String {
            if (actionId == Configuration.ACTION_ID_NEW_EPISODE_AVAILABLE_FROM_SUBSCRIBED_BROADCAST) {
                // Redirect app to open specified episode.
                // Do it by imitating deep link action.
                
                let episodesAsJsonString = userInfo[Configuration.NOTIFICATION_PARAM_EPISODES] as! String

                if let episodesAsData = episodesAsJsonString.data(using: .utf8) {
                    let episodesJson = try? JSONSerialization.jsonObject(with: episodesAsData, options: [])
                    if let episodesJson = episodesJson as? [[String: Any]] {
                        if (episodesJson.count > 0) {
                            let firstEpisodeJson = episodesJson[0]
                            
                            let episodeId = firstEpisodeJson[Configuration.NOTIFICATION_PARAM_EPISODE_ID] as! Int
                            let urlString = Configuration.HOST + "/" + DeepLinkManager.DEEP_LINK_ID_SHARED_EPISODE + "/?" + DeepLinkSharedEpisodeModel.DEEP_LINK_QUERY_PARAM_EPISODE_ID + "=" + String(episodeId)

                            let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
                            userActivity.webpageURL = URL(string: urlString)
                            
                            DeepLinkManager.validateAndExtractDataFromDeepLink(userActivity)
                            
                            completionHandler()
                        }
                    }
                }
            }
            
            if (actionId == Configuration.ACTION_ID_EPISODE_DOWNLOADED) {
                // Redirect app to open specified episode.
                // Do it by imitating deep link action.
                
                let episodeId = userInfo[Configuration.NOTIFICATION_PARAM_EPISODE_ID] as! Int
                let urlString = Configuration.HOST + "/" + DeepLinkManager.DEEP_LINK_ID_SHARED_EPISODE + "/?" + DeepLinkSharedEpisodeModel.DEEP_LINK_QUERY_PARAM_EPISODE_ID + "=" + String(episodeId)

                let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
                userActivity.webpageURL = URL(string: urlString)
                
                DeepLinkManager.validateAndExtractDataFromDeepLink(userActivity)
                
                completionHandler()
            }
        }
    }
    
    // if we disable swizzling, implement this
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        Messaging.messaging().apnsToken = deviceToken
//
//        // APNS device token not set before retrieving FCM Token for Sender ID 'xxx'.
//        // Notifications to this FCM Token will not be delivered over APNS. Be sure to re-retrieve the FCM token once the APNS device token is set.
//
//        // ...
//    }
}

extension FirebaseCloudMessagingManager: MessagingDelegate {
    
    // This callback is fired at each app startup and whenever a new token is generated.
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        GeneralUtils.log(FirebaseCloudMessagingManager.TAG, "didReceiveRegistrationToken: ", fcmToken as Any)

        let dataDict: [String: String] = ["token": fcmToken ?? ""]

        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        
        // Difference between Android and iOS is that in iOS this function gets called everytime user start app, even though token has not changed.

        if (fcmToken != nil && fcmToken != "") {
            GeneralUtils.getUserDefaults().set(fcmToken!, forKey: FirebaseCloudMessagingManager.FCM_TOKEN_REPRESENTING_THIS_DEVICE)

            let usersManager = UsersManager.getInstance()
            
            if let currentUser = usersManager.getCurrentUser() {
                if (fcmToken != currentUser.getFcmToken()) {
                    FirebaseCloudMessagingManager.updateFcmTokenInServer(fcmToken!)
                }
            }
        }
    }
}
