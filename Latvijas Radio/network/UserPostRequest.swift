//
//  UserPostRequest.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class UserPostRequest {

    static let TAG = String(describing: UserPostRequest.self)
    
    static let REQUEST_PARAM_DOWNLOAD_ONLY_WITH_WIFI = "download_only_with_wifi"
    static let REQUEST_PARAM_AUTOMATICALLY_DELETE_FINISHED_EPISODES_FROM_MY_LIST = "automatically_delete_finished_episodes_from_my_list"
    static let REQUEST_PARAM_FCM_TOKEN = "fcm_token"
    static let REQUEST_PARAM_DEVICE_ID = "device_id"

    weak var notificationViewController: NotificationViewController?
    
    var task: URLSessionDataTask!
    var successCallback: ((_ receivedData: [String: Any]) -> Void)?
    var errorCallback: (() -> (Void))?
    var restartRequestCallback: (() -> (Void))!
    
    init(_ notificationViewController: NotificationViewController?, _ urlQueryItems: [URLQueryItem]) {
        self.notificationViewController = notificationViewController
        
        createQuery(urlQueryItems)
        
        // network callbacks must not contain weak self
        restartRequestCallback = {
            self.createQuery(urlQueryItems)
            self.execute()
        }
    }
    
    func createQuery(_ urlQueryItems: [URLQueryItem]) {
        notificationViewController?.hideNotificationInstantly()
        
        let url = URL(string: Configuration.API_URL + "/user")!
        
        GeneralUtils.log(UserPostRequest.TAG, url)
        GeneralUtils.log(UserPostRequest.TAG, urlQueryItems)
        
        let usersManager = UsersManager.getInstance()
        let accessToken = usersManager.getAccessTokenForRequests()
                
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = urlQueryItems
        let query = components.url!.query!
        request.httpBody = Data(query.utf8)
        
        request.setValue(GeneralUtils.getAppVersion(), forHTTPHeaderField: "App-Version-Ios")
        request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")

        task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async(execute: {
                // check for network error
                guard let data = data, error == nil else {
                    let message = RequestManager.getMessageFromNetworkError(error)
                    self.notificationViewController?.showNotification(text: message.localized())

                    self.errorCallback?()
                    
                    return
                }

                // process API response
                let responseJson = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJson = responseJson as? [String: Any] {
                    
                    GeneralUtils.log(UserPostRequest.TAG, String(data: data, encoding: .utf8)!)
                    
                    // check for error
                    let responseError = RequestManager.getErrorFromResponse(responseJson)
                    if (responseError != nil) {
                        RequestManager.handleResponseError(responseError!, self.notificationViewController, self.errorCallback, self.restartRequestCallback)
                    } else {
                        let data = responseJson[RequestManager.RESPONSE_PARAM_DATA] as! [String: Any]

                        self.successCallback?(data)
                    }
                } else {
                    let message = RequestManager.getMessageFromNetworkError(error)
                    self.notificationViewController?.showNotification(text: message.localized())

                    self.errorCallback?()
                }
            })
        }
    }

    func execute() {
        task.resume()
    }
}
