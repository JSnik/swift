//
//  UserSubscribedEpisodesOrderRequest.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class UserSubscribedEpisodesOrderRequest {

    static let TAG = String(describing: UserSubscribedEpisodesOrderRequest.self)
    
    static let REQUEST_PARAM_IDS = "ids"

    var task: URLSessionDataTask!
    var successCallback: ((_ receivedData: [String: Any]) -> Void)?
    var errorCallback: (() -> (Void))?
    var restartRequestCallback: (() -> (Void))!
    
    init(_ urlQueryItems: [URLQueryItem]) {
        createQuery(urlQueryItems)
        
        // network callbacks must not contain weak self
        restartRequestCallback = {
            self.createQuery(urlQueryItems)
            self.execute()
        }
    }
    
    func createQuery(_ urlQueryItems: [URLQueryItem]) {
        let url = URL(string: Configuration.API_URL + "/user/subscribed-episodes-order")!
        
        GeneralUtils.log(UserSubscribedEpisodesOrderRequest.TAG, url)
        
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
                    self.errorCallback?()
                    
                    return
                }

                // process API response
                let responseJson = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJson = responseJson as? [String: Any] {
                    
                    GeneralUtils.log(UserSubscribedEpisodesOrderRequest.TAG, String(data: data, encoding: .utf8)!)
                    
                    // check for error
                    let responseError = RequestManager.getErrorFromResponse(responseJson)
                    if (responseError != nil) {
                        RequestManager.handleResponseError(responseError!, nil, self.errorCallback, self.restartRequestCallback)
                    } else {
                        let data = responseJson[RequestManager.RESPONSE_PARAM_DATA] as! [String: Any]
                        
                        self.successCallback?(data)
                    }
                } else {
                    self.errorCallback?()
                }
            })
        }
    }

    func execute() {
        task.resume()
    }
}
