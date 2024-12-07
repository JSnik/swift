//
//  BroadcastEpisodesRequest.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class BroadcastEpisodesRequest {

    static let TAG = String(describing: BroadcastEpisodesRequest.self)
    
    static let REQUEST_PARAM_LIMIT = "limit"
    static let REQUEST_PARAM_SORT_BY_OLDEST = "sort_by_oldest"
    
    static let RESPONSE_PARAM_EPISODES = "episodes"
    static let RESPONSE_PARAM_RESULTS = "results"

    weak var notificationViewController: NotificationViewController?
    
    var task: URLSessionDataTask!
    var successCallback: ((_ receivedData: [String: Any]) -> Void)?
    var errorCallback: (() -> (Void))?
    var restartRequestCallback: (() -> (Void))!
    var errorMessage: String?

    init(_ notificationViewController: NotificationViewController?, _ broadcastId: String, _ urlPathParams: String) {
        self.notificationViewController = notificationViewController
        
        createQuery(broadcastId, urlPathParams)
        
        restartRequestCallback = {
            self.createQuery(broadcastId, urlPathParams)
            self.execute()
        }
    }
    
    func createQuery(_ broadcastId: String, _ urlPathParams: String) {
        notificationViewController?.hideNotificationInstantly()
        
        var url = URL(string: Configuration.API_URL + "/broadcast/" + broadcastId + "/episode" + urlPathParams)!
        
        if (broadcastId == "news") {
            var languageString = "lv"
            if (LanguageManager.getCurrentInterfaceLanguageId() == LanguageManager.LANGUAGE_ID_RU) {
                languageString = "ru"
            }
            url = URL(string: "https://lr-api.pieci.lv/news/?locale=" + languageString)!
        }
        
        GeneralUtils.log(BroadcastEpisodesRequest.TAG, url)
        
        let usersManager = UsersManager.getInstance()
        let accessToken = usersManager.getAccessTokenForRequests()
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(GeneralUtils.getAppVersion(), forHTTPHeaderField: "App-Version-Ios")
        request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")

        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        let session = URLSession.init(configuration: config)

        task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async(execute: {
                // check for network error
                guard let data = data, error == nil else {
                    let message = RequestManager.getMessageFromNetworkError(error)
                    self.notificationViewController?.showNotification(text: message.localized())

                    self.errorMessage = message
                    self.errorCallback?()
                    
                    return
                }

                // process API response
                let responseJson = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJson = responseJson as? [String: Any] {
                    
                    //GeneralUtils.log(BroadcastEpisodesRequest.TAG, String(data: data, encoding: .utf8)!)
                    
                    // check for error
                    let responseError = RequestManager.getErrorFromResponse(responseJson)
                    if (responseError != nil) {
                        self.errorMessage = responseError
                        
                        RequestManager.handleResponseError(responseError!, self.notificationViewController, self.errorCallback, self.restartRequestCallback)
                    } else {   
                        if (broadcastId == "news") {
                            self.successCallback?(responseJson)
                        } else {
                            let data = responseJson[RequestManager.RESPONSE_PARAM_DATA] as! [String: Any]
                            self.successCallback?(data)
                        }
                    }
                } else {
                    let message = RequestManager.getMessageFromNetworkError(error)
                    self.notificationViewController?.showNotification(text: message.localized())

                    self.errorMessage = message
                    self.errorCallback?()
                }
            })
        }
    }

    func execute() {
        task.resume()
    }
}
