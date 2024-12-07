//
//  Configuration.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

class Configuration {

    //static let HOST = "http://192.168.0.117" // local
   // static let HOST = "https://latvijas-radio.tst.lv" // test
//     static let HOST = "https://lr-api.pieci.lv" // test
    static let HOST = "https://mapp.latvijasradio.lv" // production
    static let API_URL = HOST + "/api"
    static let PASSWORD_MIN_LENGTH = 8
    static let FORM_DISABLED_STATE_OPACITY = 0.4
    static let SEARCHURL = "https://search.latvijasradio.lv/collections/devlrapp/documents/search"
    static let X_TYPESENSE_API_KEY = "5JsQS8C56v1DMh22nbX79K2lmRPekRR9" // x-typesense-api-key
    static let API_KEY = "634802d7c5d5e3664a7134129832ab8c96b6fead" 

    // Get this in one of the following ways:
    // - "Firebase -> Authentication -> Sign-in method -> Google -> Web SDK configuration -> Web client ID"
    // - "Google API Console -> Credentials -> OAuth 2.0 Client IDs - >Web client (auto created by Google Service)"
    // "Web client" id is used because we are going to use googleClients' user's ID token for authorization with our own server.
    static let OAUTH2_WEB_CLIENT_ID = "376511770276-v0rmvo85dln4oa0io8mcqdgqnee1o38v.apps.googleusercontent.com"
    
    static let APP_INSTANCE_ID = "APP_INSTANCE_ID"
    static let RECEIVE_NOTIFICATION_ABOUT_SUBSCRIBED_BROADCAST_NEW_EPISODE = "RECEIVE_NOTIFICATION_ABOUT_SUBSCRIBED_BROADCAST_NEW_EPISODE"
    
    // This only needs to be "group.SOMETHING".
    // Simply adding team id and bundle id to try to get rid of "Couldn't read values in CFPrefsPlistSource" debug error (still doesn't work though)
    static let SHARED_USER_DEFAULTS_GROUP_ID = "group.FSUTAYAPUF.lv.latvijasradio.shared-user-defaults"
    
    static let CURRENTLY_SIGNED_IN_USER_ID = "CURRENTLY_SIGNED_IN_USER_ID"
    static let USER_UNBOUND_NOTIFICATIONS_PREFIX = "USER_UNBOUND_NOTIFICATIONS_PREFIX_"
    static let NOTIFICATION_PARAM_ACTION = "action"
    static let NOTIFICATION_PARAM_EPISODES = "episodes"
    static let NOTIFICATION_PARAM_BROADCAST_ID = "broadcastId"
    static let NOTIFICATION_PARAM_BROADCAST_NAME = "broadcastName"
    static let NOTIFICATION_PARAM_EPISODE_ID = "episodeId"
    static let NOTIFICATION_PARAM_EPISODE_TITLE = "episodeTitle"
    static let ACTION_ID_NEW_EPISODE_AVAILABLE_FROM_SUBSCRIBED_BROADCAST = "new_episode_available_from_subscribed_broadcast"
    static let ACTION_ID_EPISODE_DOWNLOADED = "episode_downloaded"
    
    static let IS_BIG_IMAGE_POPUP_SHOW = "IS_BIG_IMAGE_POPUP_SHOW"
}
