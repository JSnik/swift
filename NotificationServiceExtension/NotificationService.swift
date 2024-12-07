//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by Aigars Sukurs on 23/07/2024.
//  Copyright © 2024 Latvijas Radio. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    
    let TAG = String(describing: NotificationService.self)
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        GeneralUtils.log(TAG, "didReceive")
        
        guard let bestAttemptContent = bestAttemptContent else {
            completeNotification()
            return
        }
        
        GeneralUtils.log(TAG, "bestAttempt")
        
        bestAttemptContent.sound = .default
        bestAttemptContent.badge = 1
        
        guard let actionId = bestAttemptContent.userInfo[Configuration.NOTIFICATION_PARAM_ACTION] as? String,
              actionId == Configuration.ACTION_ID_NEW_EPISODE_AVAILABLE_FROM_SUBSCRIBED_BROADCAST else {
            completeNotification()
            return
        }
        
        GeneralUtils.log(TAG, "actionId:", actionId)
        
        guard let currentlySignedInUserId = GeneralUtils.getUserDefaults().string(forKey: Configuration.CURRENTLY_SIGNED_IN_USER_ID) else {
            completeNotification()
            return
        }
        
        GeneralUtils.log(TAG, "currentlySignedInUserId:", currentlySignedInUserId)
        
        var userUnboundNotifications = GeneralUtils.getUserDefaults().array(forKey: Configuration.USER_UNBOUND_NOTIFICATIONS_PREFIX + currentlySignedInUserId) as? [String] ?? [String]()
        GeneralUtils.log(TAG, "userUnboundNotifications: ", userUnboundNotifications)
        
        guard let episodesAsJsonString = bestAttemptContent.userInfo[Configuration.NOTIFICATION_PARAM_EPISODES] as? String else {
            completeNotification()
            return
        }
        
        userUnboundNotifications.append(episodesAsJsonString)
        GeneralUtils.getUserDefaults().set(userUnboundNotifications, forKey: Configuration.USER_UNBOUND_NOTIFICATIONS_PREFIX + currentlySignedInUserId)
        GeneralUtils.getUserDefaults().synchronize()
        
        updateNotificationContent(with: episodesAsJsonString)
    }
    
    override func serviceExtensionTimeWillExpire() {
        GeneralUtils.log(TAG, "serviceExtensionTimeWillExpire")
        completeNotification()
    }
    
    private func completeNotification() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    private func updateNotificationContent(with episodesAsJsonString: String) {
        if let episodesAsData = episodesAsJsonString.data(using: .utf8),
           let episodesJson = try? JSONSerialization.jsonObject(with: episodesAsData, options: []) as? [[String: Any]],
           let firstEpisodeJson = episodesJson.first,
           let broadcastName = firstEpisodeJson[Configuration.NOTIFICATION_PARAM_BROADCAST_NAME] as? String,
           let episodeTitle = firstEpisodeJson[Configuration.NOTIFICATION_PARAM_EPISODE_TITLE] as? String {
            
            bestAttemptContent?.title = "new_episode_for_broadcast".localized() + " " + broadcastName
            bestAttemptContent?.body = episodeTitle
            completeNotification()
        } else {
            completeNotification()
        }
    }
}
