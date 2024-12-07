//
//  AppDelegate.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKCoreKit
import FacebookCore
import FirebaseAnalytics

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static var TAG = String(describing: AppDelegate.classForCoder())
    
    weak var dashboardContainerViewController: DashboardContainerViewController?
    
    var firebaseCloudMessagingManager: FirebaseCloudMessagingManager!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")

        var appInstanceId = GeneralUtils.getUserDefaults().string(forKey: Configuration.APP_INSTANCE_ID)
        if (appInstanceId == nil) {
            appInstanceId = "ios-" + UUID().uuidString.lowercased()
            GeneralUtils.getUserDefaults().set(appInstanceId, forKey: Configuration.APP_INSTANCE_ID)
        }
        
        GeneralUtils.getUserDefaults().set(false, forKey: Configuration.IS_BIG_IMAGE_POPUP_SHOW)

        GeneralUtils.log(AppDelegate.TAG, "appInstanceId:", "\(appInstanceId ?? "")")
        
        // We have to register to remove notifications BEFORE we perform firebase setup.
        // Otherwise, push notifications are not working on first-time launched apps.
        application.registerForRemoteNotifications()
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        firebaseCloudMessagingManager = FirebaseCloudMessagingManager()
        firebaseCloudMessagingManager.setup(application)
        
        // For Firebase Analytics
        Analytics.setAnalyticsCollectionEnabled(true)
        
        // For Facebook Analytics
        // The setAdvertiserTrackingEnabled flag is not used for FBSDK v17+ on iOS 17+ as the FBSDK v17+ now relies on ATTrackingManager.trackingAuthorizationStatus
        // Settings.shared.isAdvertiserTrackingEnabled = true
        
        // For facebook login.
        // Allows the SDK handle logins and sharing from the native Facebook app when you perform a Login or Share action.
        // Otherwise, the user must be logged into Facebook to use the in-app browser to login.
        
        // TODO: causes 23 memory leaks. Problem in "facebook-ios-sdk -> Facebook Login"
        // https://github.com/facebook/facebook-ios-sdk/issues/1984
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
