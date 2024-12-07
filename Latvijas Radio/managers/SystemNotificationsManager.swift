//
//  SystemNotificationsManager.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class SystemNotificationsManager {
    
    static let TAG = String(describing: SystemNotificationsManager.self)
    
    static func showEpisodeDownloadedNotification(_ episodeId: String, _ body: String) {
        let content = UNMutableNotificationContent()
        content.title = "episode_downloaded_successfully".localized()
        content.body = body
        content.sound = UNNotificationSound.default
        content.userInfo = [
            Configuration.NOTIFICATION_PARAM_ACTION: Configuration.ACTION_ID_EPISODE_DOWNLOADED,
            Configuration.NOTIFICATION_PARAM_EPISODE_ID: Int(episodeId)!
        ]
        
        let notificationId = UUID().uuidString.lowercased()

        let request = UNNotificationRequest.init(identifier: "LatvijasRadioEpisodeDownloadedNotification_" + notificationId, content: content, trigger: nil)

        UNUserNotificationCenter.current().add(request)
    }
}

