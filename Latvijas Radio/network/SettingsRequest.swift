//
//  SettingsRequest.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class SettingsRequest {

    static let TAG = String(describing: SettingsRequest.self)

    static let RESPONSE_PARAM_PRIVACY_POLICY_AND_TERMS_OF_SERVICE_CONTENT = "privacyPolicyAndTermsOfServiceContent"
    static let RESPONSE_PARAM_COOKIES_CONTENT = "cookiesContent"
    static let RESPONSE_PARAM_LIVESTREAMS_CONTACT_INFO = "livestreamsContactInfo"
    static let RESPONSE_PARAM_PHONE_NUMBER = "phoneNumber"
    static let RESPONSE_PARAM_EXTERNAL_LINKS = "externalLinks"
    static let RESPONSE_PARAM_NAME = "name"
    static let RESPONSE_PARAM_LINK = "link"
    
    weak var notificationViewController: NotificationViewController?
    
    var task: URLSessionDataTask!
    var successCallback: ((_ receivedData: [String: Any]) -> Void)?
    var errorCallback: (() -> (Void))?

    init(_ notificationViewController: NotificationViewController) {
        self.notificationViewController = notificationViewController
        
        self.notificationViewController?.hideNotificationInstantly()
        
        let url = URL(string: Configuration.API_URL + "/settings")!
        
        GeneralUtils.log(SettingsRequest.TAG, url)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(GeneralUtils.getAppVersion(), forHTTPHeaderField: "App-Version-Ios")
        request.setValue(LanguageManager.getCurrentInterfaceLanguageId(), forHTTPHeaderField: "Accept-Language")
        
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
                    
                    //GeneralUtils.log(SettingsRequest.TAG, String(data: data, encoding: .utf8)!)
                    
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
