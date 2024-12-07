//
//  RegistrationStep2Request.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class RegistrationStep2Request {

    static let TAG = String(describing: RegistrationStep2Request.self)
    
    static let REQUEST_PARAM_REGISTRATION_TYPE = "registration_type"
    static let REQUEST_PARAM_PASSWORD = "password"
    static let REQUEST_PARAM_DEVICE_ID = "device_id"
    static let REQUEST_PARAM_REGISTRATION_EMAIL_VERIFICATION_TOKEN = "registration_email_verification_token"
    static let REQUEST_PARAM_FIREBASE_ID = "firebase_id"
    static let REQUEST_PARAM_FIREBASE_AUTH_ID_TOKEN = "firebase_auth_id_token"
    static let REQUEST_PARAM_EMAIL = "email"
    static let REQUEST_PARAM_NAME = "name"
    
    static let REGISTRATION_TYPE_EMAIL = "email"
    static let REGISTRATION_TYPE_APPLE = "apple"
    static let REGISTRATION_TYPE_FACEBOOK = "facebook"
    static let REGISTRATION_TYPE_GOOGLE = "google"
    
    static let RESPONSE_PARAM_USER_ID = "userId"
    static let RESPONSE_PARAM_ACCESS_TOKEN = "accessToken"
    static let RESPONSE_PARAM_REFRESH_TOKEN = "refreshToken"
    
    weak var notificationViewController: NotificationViewController?

    var task: URLSessionDataTask!
    var successCallback: ((_ receivedData: [String: Any]) -> Void)? // 1st - params that callback receives, 2nd - callback return type
    var errorCallback: ((_ receivedData: String) -> Void)?

    init(_ notificationViewController: NotificationViewController, _ urlQueryItems: [URLQueryItem]) {
        self.notificationViewController = notificationViewController
        
        self.notificationViewController?.hideNotificationInstantly()
        
        let url = URL(string: Configuration.API_URL + "/registration-step-2")!
        
        GeneralUtils.log(RegistrationStep2Request.TAG, url)
        
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
                    
                    GeneralUtils.log(RegistrationStep2Request.TAG, String(data: data, encoding: .utf8)!)
                    
                    // check for error
                    let responseError = RequestManager.getErrorFromResponse(responseJson)
                    if (responseError != nil) {
                        self.notificationViewController?.showNotification(text: responseError!.localized())
                        
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
