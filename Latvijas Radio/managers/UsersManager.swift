//
//  UsersManager.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit
import Firebase

class UsersManager {
    
    static let TAG = String(describing: UsersManager.self)
    
    static let USERS = "USERS"
    
    private static var instance: UsersManager!
    
    private var users = [UserModel]()
    private var currentUser: UserModel?
    
    private init() {
        do {
            let savedUsers = try GeneralUtils.getUserDefaults().getCustomObject(forKey: UsersManager.USERS, as: [UserModel].self)
            if (savedUsers != nil) {
                users = savedUsers!
            }
            
        } catch {
            GeneralUtils.log(UsersManager.TAG, "Error loading users: ", error)
        }
    }
    
    @discardableResult static func getInstance() -> UsersManager {
        if (instance == nil) {
            instance = UsersManager()
        }
        
        return instance
    }
    
    func getCurrentUser() -> UserModel? {
        if (currentUser == nil) {
            let currentlySignedInUser = getCurrentlySignedInUser()
            if (currentlySignedInUser != nil) {
                setCurrentUser(currentlySignedInUser!)
            }
        }
        
        return currentUser
    }
    
    func setCurrentUser(_ currentUser: UserModel?) {
        self.currentUser = currentUser
    }
    
    func getUserById(_ userId: String) -> UserModel? {
        var result: UserModel?
        
        for user in users {
            if (user.getId() == userId) {
                result = user
                
                break
            }
        }
        
        return result
    }
    
    // When app starts, we need to know which users token to check for auto-login.
    // Basically, this keeps track of last signed in user.
    func getCurrentlySignedInUser() -> UserModel? {
        var result: UserModel?

        let currentlySignedInUserId = GeneralUtils.getUserDefaults().string(forKey: Configuration.CURRENTLY_SIGNED_IN_USER_ID)
        if (currentlySignedInUserId != nil) {
            result = getUserById(currentlySignedInUserId!)
        }
        
        return result
    }
    
    func setCurrentlySignedInUser(_ user: UserModel?) {
        if let user = user {
            GeneralUtils.getUserDefaults().set(user.getId(), forKey: Configuration.CURRENTLY_SIGNED_IN_USER_ID)
        } else {
            GeneralUtils.getUserDefaults().removeObject(forKey: Configuration.CURRENTLY_SIGNED_IN_USER_ID)
        }
        
        GeneralUtils.getUserDefaults().synchronize()
    }
    
    func createUser(_ userId: String) -> UserModel {
        let newUser = UserModel(userId)
        
        users.append(newUser)
        
        return newUser
    }
    
    func saveCurrentUserData() {
        for i in (0..<users.count) {
            let user = users[i]
            
            if (user.getId() == currentUser!.getId()) {
                users[i] = currentUser!
                
                break
            }
        }
        
        do {
            try GeneralUtils.getUserDefaults().setCustomObject(users, forKey: UsersManager.USERS)
            
        } catch {
            GeneralUtils.log(UsersManager.TAG, error.localizedDescription)
        }
    }
        
    func performUserCreationOrUpdate(_ lastKnownSignInMethod: String, _ firebaseUser: User?, _ userId: String, _ accessToken: String, _ refreshToken: String) {
        // check if user with this id already exists in our local user list
        var currentUser = getUserById(userId)
        if (currentUser == nil) {
            // user in appData does not exist, create it
            currentUser = createUser(userId)
        }
        
        currentUser!.setAccessToken(accessToken)
        currentUser!.setRefreshToken(refreshToken)
        
        switch(lastKnownSignInMethod) {
        case UserModel.LAST_KNOWN_SIGN_IN_METHOD_GOOGLE:
            if let photoUrl = firebaseUser?.photoURL {
                currentUser?.setImagePath(photoUrl.absoluteString)
            }
            
            break
        case UserModel.LAST_KNOWN_SIGN_IN_METHOD_FACEBOOK:
            if let photoUrl = firebaseUser?.photoURL {
                // acquired image from facebook by default will be 50x50 px, resize it (return closest to our provided size)
                let modifiedPhotoUrl = photoUrl.absoluteString + "?width=340&height=340"
                
                currentUser?.setImagePath(modifiedPhotoUrl)
            }
            
            break
        default:
            break
        }
        
        // -------------------------------------------------------
        
        // set processed user object as a current user
        setCurrentUser(currentUser!)
        
        // set current user as currently signed in user
        setCurrentlySignedInUser(currentUser!)
        
        // save current user data (we might have created a new user or an existing user might have its data udpated)
        saveCurrentUserData()
    }
    
    // Apply user data from API to local user object
    func updateLocalUserData(_ data: [String: Any]) {
        let user = data[UserGetRequest.RESPONSE_PARAM_USER] as! [String: Any]
        let registrationType = user[UserGetRequest.RESPONSE_PARAM_REGISTRATION_TYPE] as! String
        let name = user[UserGetRequest.RESPONSE_PARAM_NAME] as! String
        let downloadOnlyWithWifi = user[UserGetRequest.RESPONSE_PARAM_DOWNLOAD_ONLY_WITH_WIFI] as! Bool
        let automaticallyDeleteFinishedEpisodesFromMyList = user[UserGetRequest.RESPONSE_PARAM_AUTOMATICALLY_DELETE_FINISHED_EPISODES_FROM_MY_LIST] as! Bool
        
        // We receive all fcm tokens and their appInstaceIds for this API account.
        // Get only this appInstanceId fcmToken.
        
        var fcmToken: String?
        
        if let fcmTokensJson = user[UserGetRequest.RESPONSE_PARAM_FCM_TOKENS] as? [String: Any] {
            let appInstanceId = GeneralUtils.getUserDefaults().string(forKey: Configuration.APP_INSTANCE_ID)!
            
            fcmToken = fcmTokensJson[appInstanceId] as? String
        }

        let currentUser = getCurrentUser()!
        
        currentUser.setRegistrationType(registrationType)
        currentUser.setName(name)
        currentUser.setDownloadOnlyWithWifi(downloadOnlyWithWifi)
        currentUser.setAutomaticallyDeleteFinishedEpisodesFromMyList(automaticallyDeleteFinishedEpisodesFromMyList)
        currentUser.setFcmToken(fcmToken)
        
        saveCurrentUserData()
    }
    
    /*
     Sending requests to API must contain a non-null access token.
     Also, if user logs out (current user is destroyed) then all other requests that are currently being
     constructed will properly be guarded against no current user.
     */
    func getAccessTokenForRequests() -> String {
        var accessToken = ""
        if let currentUser = currentUser {
            if let token = currentUser.getAccessToken() {
                accessToken = token
            }
        }

        return accessToken
    }
    
    func getOfflineEpisodeById(_ lookUpEpisodeId: String) -> EpisodeModel? {
        var result: EpisodeModel? = nil

        if let currentUser = currentUser {
            let offlineEpisodes = currentUser.getOfflineEpisodes()
            
            for offlineEpisode in offlineEpisodes {
                if (offlineEpisode.getId() == lookUpEpisodeId) {
                    result = offlineEpisode
                    
                    break
                }
            }
        }
        
        return result
    }
    
    static func logOutCurrentUser() {
        // stop current playback
        MediaPlayerManager.getInstance().performActionStopMediaPlayer()
        
        let usersManager = UsersManager.getInstance()
        if let currentUser = usersManager.getCurrentUser() {
            // Clear access token, just in case.
            currentUser.setAccessToken(nil)
            
            // Clear bound fcm token to user object, so if we logout with user and log back in with it,
            // then it would send the new token to API.
            currentUser.setFcmToken(nil)
            
            usersManager.saveCurrentUserData()
        }
        
        // Clear currentUser and currently signed in user, so on next "AuthenticationVC" launch there
        // would be no auto-login procedure, and on token update it wouldn't perform a request with "null" accessToken.
        usersManager.setCurrentUser(nil)
        usersManager.setCurrentlySignedInUser(nil)
    }
}
