//
//  RegistrationGuestRequest.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class RegistrationGuestRequest {

    static let TAG = String(describing: RegistrationGuestRequest.self)
    
    static let REQUEST_PARAM_EMAIL = "email"
    static let REQUEST_PARAM_PASSWORD = "password"
    static let REQUEST_PARAM_DEVICE_ID = "device_id"
    
    static let RESPONSE_PARAM_USER_ID = "userId"
    static let RESPONSE_PARAM_ACCESS_TOKEN = "accessToken"
    static let RESPONSE_PARAM_REFRESH_TOKEN = "refreshToken"
    
    weak var notificationViewController: NotificationViewController?

    var task: URLSessionDataTask!
    var successCallback: ((_ receivedData: [String: Any]) -> Void)?
    var errorCallback: (() -> Void)?

    init(_ notificationViewController: NotificationViewController, _ urlQueryItems: [URLQueryItem]) {
        self.notificationViewController = notificationViewController
        
        self.notificationViewController?.hideNotificationInstantly()
        
        let url = URL(string: Configuration.API_URL + "/registration-guest")!
        
        GeneralUtils.log(RegistrationGuestRequest.TAG, url)
        
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

                    self.errorCallback?()
                    
                    return
                }

                // process API response
                let responseJson = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJson = responseJson as? [String: Any] {
                    
                    GeneralUtils.log(RegistrationGuestRequest.TAG, String(data: data, encoding: .utf8)!)
                    
                    // check for error
                    let responseError = RequestManager.getErrorFromResponse(responseJson)
                    if (responseError != nil) {
                        RequestManager.handleResponseError(responseError!, self.notificationViewController, self.errorCallback, nil)
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
