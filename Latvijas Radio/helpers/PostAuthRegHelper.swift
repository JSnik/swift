//
//  PostAuthRegHelper.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class PostAuthRegHelper {
    
    static let TAG = String(describing: PostAuthRegHelper.self)

    static func performPostProcedure(_ callback: (() -> Void)) {
        // A device is represented by a single fcmToken, saved in "FCM_TOKEN_REPRESENTING_THIS_DEVICE" variable.
        // Now that we have logged in - check current users fcmToken from API with the "device-representing" token.
        // If they differ - update the new one to API.

        if let fcmTokenRepresentingThisDevice = GeneralUtils.getUserDefaults().object(forKey: FirebaseCloudMessagingManager.FCM_TOKEN_REPRESENTING_THIS_DEVICE) as? String {
            let usersManager = UsersManager.getInstance()
            let currentUser = usersManager.getCurrentUser()!
            
            if (fcmTokenRepresentingThisDevice != currentUser.getFcmToken()) {
                FirebaseCloudMessagingManager.updateFcmTokenInServer(fcmTokenRepresentingThisDevice)
            }
        }
        
        // Registration might have caused our app to go into background, enabling following params.
        // We reset them, so view controllers don't get loaded twice.
        DashboardViewController.needsUpdate = false
        BroadcastsViewController.needsUpdate = false
        
        callback()
    }
}
