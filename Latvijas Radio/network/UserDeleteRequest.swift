//
//  UserDeleteRequest.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 12/08/2022.
//

import UIKit

class UserDeleteRequest {

    static let TAG = String(describing: UserDeleteRequest.self)
    
    weak var notificationViewController: NotificationViewController?
    
    var task: URLSessionDataTask!
    var successCallback: ((_ receivedData: [String: Any]) -> Void)?
    var errorCallback: (() -> (Void))?
    var restartRequestCallback: (() -> (Void))!
    
    init(_ notificationViewController: NotificationViewController) {
        self.notificationViewController = notificationViewController
        
        createQuery()
        
        // network callbacks must not contain weak self
        restartRequestCallback = {
            self.createQuery()
            self.execute()
        }
    }
    
    func createQuery() {
        notificationViewController?.hideNotificationInstantly()
        
        let url = URL(string: Configuration.API_URL + "/user")!
        
        GeneralUtils.log(UserPostRequest.TAG, url)
        
        let usersManager = UsersManager.getInstance()
        let accessToken = usersManager.getAccessTokenForRequests()
                
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
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
