//
//  ContentSectionRequest.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class ContentSectionRequest {

    static let TAG = String(describing: ContentSectionRequest.self)
    
    static let SECTION_ID_DASHBOARD = "1"
    static let SECTION_ID_BROADCASTS = "2"
    static let SECTION_ID_AUTO_CONTENT = "3"
    
    static let RESPONSE_PARAM_BLOCKS = "blocks"
    static let RESPONSE_PARAM_NAME = "name"
    static let RESPONSE_PARAM_PRESENTATION_TYPE_ID = "presentationTypeId"
    static let RESPONSE_PARAM_CONTENT_TYPE = "contentType"
    static let RESPONSE_PARAM_ITEMS = "items"
    static let RESPONSE_PARAM_SHOW_IN_AUTO_APPS  = "showInAutoApps"
    
    static let CONTENT_TYPE_BROADCASTS = "broadcasts"
    static let CONTENT_TYPE_EPISODES = "episodes"
    
    weak var notificationViewController: NotificationViewController?

    var task: URLSessionDataTask!
    var successCallback: ((_ receivedData: [String: Any]) -> Void)?
    var errorCallback: (() -> (Void))?
    var restartRequestCallback: (() -> (Void))!
    var errorMessage: String?

    init(_ notificationViewController: NotificationViewController?, _ sectionId: String) {
        self.notificationViewController = notificationViewController
        
        createQuery(sectionId)
        
        restartRequestCallback = {
            self.createQuery(sectionId)
            self.execute()
        }
    }
    
    func createQuery(_ sectionId: String) {
        notificationViewController?.hideNotificationInstantly()
        
        let url = URL(string: Configuration.API_URL + "/content-section/" + sectionId)!
        
        GeneralUtils.log(ContentSectionRequest.TAG, url)
        
        let usersManager = UsersManager.getInstance()
        let accessToken = usersManager.getAccessTokenForRequests()
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(GeneralUtils.getAppVersion(), forHTTPHeaderField: "App-Version-Ios")
        request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        request.setValue(LanguageManager.getCurrentInterfaceLanguageId(), forHTTPHeaderField: "Accept-Language")
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
                    
                    //GeneralUtils.log(ContentSectionRequest.TAG, String(data: data, encoding: .utf8)!)
                    
                    // check for error
                    let responseError = RequestManager.getErrorFromResponse(responseJson)
                    if (responseError != nil) {
                        self.errorMessage = responseError
                        
                        RequestManager.handleResponseError(responseError!, self.notificationViewController, self.errorCallback, self.restartRequestCallback)
                    } else {
                        let data = responseJson[RequestManager.RESPONSE_PARAM_DATA] as! [String: Any]

                        self.successCallback?(data)
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
