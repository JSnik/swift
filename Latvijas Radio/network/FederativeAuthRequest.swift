//
//  FederativeAuthRequest.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class FederativeAuthRequest {

    static let TAG = String(describing: FederativeAuthRequest.self)
    
    static let REQUEST_PARAM_FIREBASE_ID = "firebase_id"
    static let REQUEST_PARAM_FIREBASE_AUTH_ID_TOKEN = "firebase_auth_id_token"
    static let REQUEST_PARAM_DEVICE_ID = "device_id"
    
    static let RESPONSE_PARAM_USER_ID = "userId"
    static let RESPONSE_PARAM_ACCESS_TOKEN = "accessToken"
    static let RESPONSE_PARAM_REFRESH_TOKEN = "refreshToken"
    
    static let RESPONSE_ERROR_USER_NOT_FOUND = "user_not_found"
    
    weak var notificationViewController: NotificationViewController?

    var task: URLSessionDataTask!
    var successCallback: ((_ receivedData: [String: Any]) -> Void)? // 1st - params that callback receives, 2nd - callback return type
    var errorCallback: ((_ receivedData: String) -> Void)?

    init(_ notificationViewController: NotificationViewController, _ urlQueryItems: [URLQueryItem]) {
        self.notificationViewController = notificationViewController
        
        self.notificationViewController?.hideNotificationInstantly()
        
        let url = URL(string: Configuration.API_URL + "/federative-auth")!
        
        GeneralUtils.log(FederativeAuthRequest.TAG, url)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = urlQueryItems
        let query = components.url!.query!
        request.httpBody = Data(query.utf8)
        
        request.setValue(GeneralUtils.getAppVersion(), forHTTPHeaderField: "App-Version-Ios")
        
        task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async(execute: {
                // check for network error
                guard let data = data, error == nil else {
                    let message = RequestManager.getMessageFromNetworkError(error)
                    self.notificationViewController?.showNotification(text: message.localized())
                    
                    self.errorCallback?(message)
                    
                    return
                }

                // process API response
                let responseJson = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJson = responseJson as? [String: Any] {
                    
                    GeneralUtils.log(FederativeAuthRequest.TAG, String(data: data, encoding: .utf8)!)
                    
                    // check for error
                    let responseError = RequestManager.getErrorFromResponse(responseJson)
                    if (responseError != nil) {
                        self.errorCallback?(responseError!)
                    } else {
                        let data = responseJson[RequestManager.RESPONSE_PARAM_DATA] as! [String: Any]
                        
                        self.successCallback?(data)
                    }
                } else {
                    let message = RequestManager.getMessageFromNetworkError(error)
                    self.notificationViewController?.showNotification(text: message.localized())
                    
                    self.errorCallback?(message)
                }
            })
        }
    }

    func execute() {
        task.resume()
    }
}
