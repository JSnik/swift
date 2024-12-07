//
//  DeepLinkManager.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class DeepLinkManager {
    
    static let TAG = String(describing: DeepLinkManager.self)
    
    static let DEEP_LINK_ID_REGISTRATION_EMAIL_TOKEN_VERIFICATION = "registration-email-token-verification"
    static let DEEP_LINK_ID_PASSWORD_RESET_EMAIL_TOKEN_VERIFICATION = "password-reset-email-token-verification"
    static let DEEP_LINK_ID_SHARED_EPISODE = "shared-episode"
    static let DEEP_LINK_ID_SHARED_LIVESTREAM = "shared-livestream"
    static let DEEP_LINK_ID_SHARED_BROADCAST = "shared-broadcast"
    
    static let DEEP_LINK_DATA_SHARED_EPISODE = "DEEP_LINK_DATA_SHARED_EPISODE"
    static let DEEP_LINK_DATA_SHARED_LIVESTREAM = "DEEP_LINK_DATA_SHARED_LIVESTREAM"
    static let DEEP_LINK_DATA_SHARED_BROADCAST = "DEEP_LINK_DATA_SHARED_BROADCAST"
    
    static let DEEP_LINK_QUERY_PARAM_EMAIL = "email"

    static func validateAndExtractDataFromDeepLink(_ userActivity: NSUserActivity) {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            let url = userActivity.webpageURL!
            
            if let sceneDelegate = SceneDelegate.getSceneDelegate() {
                GeneralUtils.log(SceneDelegate.TAG, "validateAndExtractDataFromDeepLink: ", url)

                let deepLinkType = url.pathComponents[1]
                
                // check if specific deep link has its necessary params
                switch (deepLinkType) {
                case DeepLinkManager.DEEP_LINK_ID_REGISTRATION_EMAIL_TOKEN_VERIFICATION:
                    let token = url.lastPathComponent
                    
                    let registrationFinalizeViewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_REGISTRATION_FINALIZE, bundle: nil)
                                            .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_REGISTRATION_FINALIZE) as! RegistrationFinalizeViewController)

                    registrationFinalizeViewController.registrationEmailVerificationToken = token
                    
                    let navigationController = sceneDelegate.window?.rootViewController as? UINavigationController
                    navigationController?.pushViewController(registrationFinalizeViewController, animated: true)
                    
                    break
                case DeepLinkManager.DEEP_LINK_ID_PASSWORD_RESET_EMAIL_TOKEN_VERIFICATION:
                    let token = url.lastPathComponent
                    let email = url.queryParameters?[DeepLinkManager.DEEP_LINK_QUERY_PARAM_EMAIL]
                    
                    if (email != nil) {
                        let forgotPasswordFinalizeViewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_FORGOT_PASSWORD_FINALIZE, bundle: nil)
                                                .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_FORGOT_PASSWORD_FINALIZE) as! ForgotPasswordFinalizeViewController)

                        forgotPasswordFinalizeViewController.passwordResetEmailVerificationToken = token
                        forgotPasswordFinalizeViewController.email = email
                        
                        let navigationController = sceneDelegate.window?.rootViewController as? UINavigationController
                        navigationController?.pushViewController(forgotPasswordFinalizeViewController, animated: true)
                    }

                    break
                case DeepLinkManager.DEEP_LINK_ID_SHARED_EPISODE:
                    let episodeId = url.queryParameters?[DeepLinkSharedEpisodeModel.DEEP_LINK_QUERY_PARAM_EPISODE_ID]
                    
                    if let episodeId = episodeId {
                        let deepLinkSharedEpisodeModel = DeepLinkSharedEpisodeModel(episodeId)
                        
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        if (appDelegate.dashboardContainerViewController != nil) {
                            // app is already running
                            let episodeViewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_EPISODE, bundle: nil)
                                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_EPISODE) as! EpisodeViewController)

                            episodeViewController.deepLinkSharedEpisodeModel = deepLinkSharedEpisodeModel

                            let navigationController = sceneDelegate.window?.rootViewController as? UINavigationController
                            navigationController?.pushViewController(episodeViewController, animated: true)
                        } else {
                            // app is not running
                            do {
                                try GeneralUtils.getUserDefaults().setCustomObject(deepLinkSharedEpisodeModel, forKey: DeepLinkManager.DEEP_LINK_DATA_SHARED_EPISODE)
                                
                            } catch {
                                GeneralUtils.log(UsersManager.TAG, error.localizedDescription)
                            }
                        }
                    }

                    break
                case DeepLinkManager.DEEP_LINK_ID_SHARED_LIVESTREAM:
                    let livestreamId = url.queryParameters?[DeepLinkSharedLivestreamModel.DEEP_LINK_QUERY_PARAM_LIVESTREAM_ID]
                    
                    if var livestreamId = livestreamId {
                        livestreamId = livestreamId.uppercased()
                        
                        let deepLinkSharedLivestreamModel = DeepLinkSharedLivestreamModel(livestreamId)
                        
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        if (appDelegate.dashboardContainerViewController != nil) {
                            // app is already running
                            let livestreamId = deepLinkSharedLivestreamModel.getLivestreamId()

                            if let livestreamModel = LivestreamsManager.getLivestreamByIdFromAllChannels(livestreamId) {
                                MediaPlayerManager.getInstance().performActionLoadAndPlayLivestream(MediaPlayerManager.PLAYBACK_TYPE_STREAM, livestreamModel, nil)
                                
                                // switch to livestreams tab
                                appDelegate.dashboardContainerViewController!.navigateToPage(NavigationViewController.NAVIGATION_ITEM_INDEX_LIVESTREAMS)
                            }
                        } else {
                            // app is not running
                            do {
                                try GeneralUtils.getUserDefaults().setCustomObject(deepLinkSharedLivestreamModel, forKey: DeepLinkManager.DEEP_LINK_DATA_SHARED_LIVESTREAM)
                                
                            } catch {
                                GeneralUtils.log(UsersManager.TAG, error.localizedDescription)
                            }
                        }
                    }

                    break
                case DeepLinkManager.DEEP_LINK_ID_SHARED_BROADCAST:
                    let broadcastId = url.queryParameters?[DeepLinkSharedBroadcastModel.DEEP_LINK_QUERY_PARAM_BROADCAST_ID]
                    
                    if let broadcastId = broadcastId {
                        let deepLinkSharedBroadcastModel = DeepLinkSharedBroadcastModel(broadcastId)
                        
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        if (appDelegate.dashboardContainerViewController != nil) {
                            // app is already running
                            let broadcastViewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_BROADCAST, bundle: nil)
                                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_BROADCAST) as! BroadcastViewController)

                            broadcastViewController.broadcastIdToQuery = broadcastId

                            let navigationController = sceneDelegate.window?.rootViewController as? UINavigationController
                            navigationController?.pushViewController(broadcastViewController, animated: true)
                        } else {
                            // app is not running
                            do {
                                try GeneralUtils.getUserDefaults().setCustomObject(deepLinkSharedBroadcastModel, forKey: DeepLinkManager.DEEP_LINK_DATA_SHARED_BROADCAST)
                                
                            } catch {
                                GeneralUtils.log(UsersManager.TAG, error.localizedDescription)
                            }
                        }
                    }

                    break
                default:
                    break
                }
            }
        }
    }
}

