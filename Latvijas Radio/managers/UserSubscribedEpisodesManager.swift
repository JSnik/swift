//
//  UserSubscribedEpisodesManager.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 14/10/2022.
//

import UIKit

class UserSubscribedEpisodesManager {
    
    static let TAG = String(describing: UserSubscribedEpisodesManager.self)
    
    private static var instance: UserSubscribedEpisodesManager!
    
    // This flag helps us refresh "SubscribedEpisodes" list.
    var episodeItemHasCompletedWithAutoRemoveEnabled = false
    
    /*
        We keep subscribed episodes list here, so episode lists in app can check whether or not user has subscribed to episode.
        For that check we require only episode ids, nothing more.
        We acquire this list when:
        - user transitions from AuthenticationVC to DashboardVC
        - user performs subscribe/unsubscribe to an episode
        - "auto remove finishes episodes" feature performs unsubscribe to an episode
        - we reload "SubscribedEpisodes" vc
     */
    private var userSubscribedEpisodesIds = [String]()
    
    private init() {

    }
    
    @discardableResult static func getInstance() -> UserSubscribedEpisodesManager {
        if (instance == nil) {
            instance = UserSubscribedEpisodesManager()
        }
        
        return instance
    }
    
    func getUserSubscribedEpisodesIds(_ callback: @escaping (() -> Void) ) {
        performRequestUserSubscribedEpisodes(callback)
    }
    
    func performRequestUserSubscribedEpisodes(_ callback: @escaping (() -> Void) ) {
        let userSubscribedEpisodesRequest = UserSubscribedEpisodesRequest(nil)

        userSubscribedEpisodesRequest.successCallback = { [weak self] (data) -> Void in
            let userSubscribedEpisodesJsonArray = data[UserSubscribedEpisodesRequest.RESPONSE_PARAM_EPISODES] as! [[String: Any]]
            
            var episodeIds = [String]()

            let userSubscribedEpisodes = EpisodesHelper.getEpisodesListFromJsonArray(userSubscribedEpisodesJsonArray)
            
            for episodeModel in userSubscribedEpisodes {
                episodeIds.append(episodeModel.getId())
            }
            
            self?.userSubscribedEpisodesIds = episodeIds
            
            callback()
        }
        
        userSubscribedEpisodesRequest.errorCallback = callback

        userSubscribedEpisodesRequest.execute()
    }
    
    func performRequestSetEpisodeSubscriptionStatus(_ episodeModel: EpisodeModel, _ subscribed: Bool, _ callback: @escaping (() -> Void) ) {
        /*
            If we are removing an episode, remove it from in-memory subscribed episodes list.
            By doing that:
            - when an episode gets completed, episodesAdapter will show a unsubscribed state immediately;
            - subscribe buttons in episodesAdapter lists get updated immediately ON RESUME.
         */
        if (!subscribed) {
            removeEpisode(episodeModel)
        }
        
        let episodeId = episodeModel.getId()

        let urlQueryItems = [
            URLQueryItem(name: EpisodeSubscriptionStatusPostRequest.REQUEST_PARAM_SUBSCRIBED, value: String(subscribed))
        ]

        let episodeSubscriptionStatusSetRequest = EpisodeSubscriptionStatusPostRequest(nil, episodeId, urlQueryItems)

        episodeSubscriptionStatusSetRequest.successCallback = { [weak self] (data) -> Void in
            // After successful request, we could manually modify existing userSubscribedEpisodes list to add/remove episode from it.
            // But if user has made changed on another device for the same account, then subscribed episodes would not be in sync on current device.
            // So we ask for the actual subscribed episodes list from API.
            
            self?.performRequestUserSubscribedEpisodes(callback)
        }

        episodeSubscriptionStatusSetRequest.execute()
    }
    
    func isUserSubscribedToEpisode(_ episodeModel: EpisodeModel) -> Bool {
        var result = false

        if (userSubscribedEpisodesIds.contains(episodeModel.getId())) {
            result = true
        }
        
        return result
    }
    
    func removeEpisode(_ episodeModel: EpisodeModel) {
        var indexToRemove = -1
        
        for i in (0..<userSubscribedEpisodesIds.count) {
            let episodeId = userSubscribedEpisodesIds[i]
            
            if (episodeId == episodeModel.getId()) {
                indexToRemove = i
                
                break
            }
        }
        
        if (indexToRemove != -1) {
            userSubscribedEpisodesIds.remove(at: indexToRemove)
        }
    }
}
