//
//  RefreshTokenRequest.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class RefreshTokenRequest {

    static let TAG = String(describing: RefreshTokenRequest.self)
    
    static let REQUEST_PARAM_REFRESH_TOKEN = "refresh_token"
    
    static let RESPONSE_PARAM_ACCESS_TOKEN = "accessToken"
    static let RESPONSE_PARAM_REFRESH_TOKEN = "refreshToken"

    var task: URLSessionDataTask!
    var successCallback: ((_ receivedData: [String: Any]) -> Void)? // 1st - params that callback receives, 2nd - callback return type
    var errorCallback: ((_ receivedData: String) -> Void)?

    init(_ notificationViewController: NotificationViewController?, _ urlQueryItems: [URLQueryItem]) {
        notificationViewController?.hideNotificationInstantly()
        
        let url = URL(string: Configuration.API_URL + "/refresh-token")!
        
        GeneralUtils.log(RefreshTokenRequest.TAG, url)
        GeneralUtils.log(RefreshTokenRequest.TAG, urlQueryItems)
        
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
                    notificationViewController?.showNotification(text: message.localized())
                    
                    self.errorCallback?(message)
                    
                    return
                }

                // process API response
                let responseJson = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJson = responseJson as? [String: Any] {
                    
                    GeneralUtils.log(RefreshTokenRequest.TAG, String(data: data, encoding: .utf8)!)
                    
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
                    notificationViewController?.showNotification(text: message.localized())
                    
                    self.errorCallback?(message)
                }
            })
        }
    }

    func execute() {
        task.resume()
    }
}
