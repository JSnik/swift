//
//  UserModel.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class UserModel: Codable {

    /*
     Note to self:
     
     NEVER initialize property with variable here, because, if in new version we add new property X, then user, who installs an update to this app, will be greeted with error:
     
        Swift.DecodingError.keyNotFound(CodingKeys(stringValue: "offlineEpisodes", intValue: nil), Swift.DecodingError.Context(codingPath: [_JSONKey(stringValue: "Index 0", intValue: 0)], debugDescription: "No value associated with key CodingKeys(stringValue: \"offlineEpisodes\", intValue: nil) (\"offlineEpisodes\").", underlyingError: nil))]
     
     That is because users app tried to cast old version of this model to the new version of this model.
     Also, don't initialize NEW properties in constructor - same issue. Set default value of properties in their getters.
     */
    
    static let LAST_KNOWN_SIGN_IN_METHOD_EMAIL = "LAST_KNOWN_SIGN_IN_METHOD_EMAIL"
    static let LAST_KNOWN_SIGN_IN_METHOD_GOOGLE = "LAST_KNOWN_SIGN_IN_METHOD_GOOGLE"
    static let LAST_KNOWN_SIGN_IN_METHOD_FACEBOOK = "LAST_KNOWN_SIGN_IN_METHOD_FACEBOOK"
    static let LAST_KNOWN_SIGN_IN_METHOD_APPLE = "LAST_KNOWN_SIGN_IN_METHOD_APPLE"
    static let LAST_KNOWN_SIGN_IN_METHOD_GUEST = "LAST_KNOWN_SIGN_IN_METHOD_GUEST"

    let id: String
    private var accessToken: String?
    private var refreshToken: String!
    private var registrationType: String!
    private var offlineEpisodes: [EpisodeModel]!
    private var isAutoplayEnabled: Bool!
    private var name: String!
    private var downloadOnlyWithWifi = false
    private var automaticallyDeleteFinishedEpisodesFromMyList = false
    private var imagePath: String?
    private var receivedNotifications = [NotificationModel]()
    private var fcmToken: String?
    private var livestreamsOrder: [String]?
    private var mediaPlaybackStates: [MediaPlaybackStateModel]!

    init(_ id: String){
        self.id = id

        isAutoplayEnabled = true
    }
    
    func getId() -> String {
        return id
    }
    
    func getAccessToken() -> String? {
        return accessToken
    }
    
    func setAccessToken(_ accessToken: String?) {
        self.accessToken = accessToken
    }
    
    func getRefreshToken() -> String {
        return refreshToken
    }
    
    func setRefreshToken(_ refreshToken: String) {
        self.refreshToken = refreshToken
    }
    
    func getRegistrationType() -> String {
        return registrationType
    }
    
    func setRegistrationType(_ registrationType: String) {
        self.registrationType = registrationType
    }
    
    // Keeping this as an example of how getter should look to newly added property,
    // so people with old version objects wouldn't crash.
    func getOfflineEpisodes() -> [EpisodeModel] {
        if (offlineEpisodes == nil) {
            offlineEpisodes = [EpisodeModel]()
        }
        
        return offlineEpisodes
    }

    func setOfflineEpisodes(_ offlineEpisodes: [EpisodeModel]) {
        self.offlineEpisodes = offlineEpisodes
    }
    
    func getIsAutoplayEnabled() -> Bool {
        return isAutoplayEnabled
    }
    
    func setIsAutoplayEnabled(_ isAutoplayEnabled: Bool) {
        self.isAutoplayEnabled = isAutoplayEnabled
    }
    
    func getName() -> String {
        return name
    }
    
    func setName(_ name: String) {
        self.name = name
    }
    
    func getDownloadOnlyWithWifi() -> Bool {
        return downloadOnlyWithWifi
    }
    
    func setDownloadOnlyWithWifi(_ downloadOnlyWithWifi: Bool) {
        self.downloadOnlyWithWifi = downloadOnlyWithWifi
    }
    
    func getAutomaticallyDeleteFinishedEpisodesFromMyList() -> Bool {
        return automaticallyDeleteFinishedEpisodesFromMyList
    }
    
    func setAutomaticallyDeleteFinishedEpisodesFromMyList(_ automaticallyDeleteFinishedEpisodesFromMyList: Bool) {
        self.automaticallyDeleteFinishedEpisodesFromMyList = automaticallyDeleteFinishedEpisodesFromMyList
    }
    
    func getImagePath() -> String? {
        return imagePath
    }
    
    func setImagePath(_ imagePath: String?) {
        self.imagePath = imagePath
    }
    
    func getReceivedNotifications() -> [NotificationModel] {
        return receivedNotifications
    }

    func setReceivedNotifications(_ receivedNotifications: [NotificationModel]) {
        self.receivedNotifications = receivedNotifications
    }
    
    func getFcmToken() -> String? {
        return fcmToken
    }
    
    func setFcmToken(_ fcmToken: String?) {
        self.fcmToken = fcmToken
    }
    
    func getLivestreamsOrder() -> [String]? {
        return livestreamsOrder
    }
    
    func setLivestreamsOrder(_ livestreamsOrder: [String]?) {
        self.livestreamsOrder = livestreamsOrder
    }
    
    func getMediaPlaybackStates() -> [MediaPlaybackStateModel] {
        if (mediaPlaybackStates == nil) {
            mediaPlaybackStates = [MediaPlaybackStateModel]()
        }
        
        return mediaPlaybackStates
    }
    
    func setMediaPlaybackStates(_ mediaPlaybackStates: [MediaPlaybackStateModel]) {
        self.mediaPlaybackStates = mediaPlaybackStates
    }
}
