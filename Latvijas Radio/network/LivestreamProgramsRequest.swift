//
//  LivestreamProgramsRequest.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class LivestreamProgramsRequest {

    static let TAG = String(describing: LivestreamProgramsRequest.self)
    
    static let RESPONSE_PARAM_LIVESTREAM_PROGRAMS = "livestreamPrograms"
    static let RESPONSE_PARAM_CHANNEL_ID = "channel_id"
    static let RESPONSE_PARAM_TITLE = "title"
    
    var task: URLSessionDataTask!
    var successCallback: ((_ receivedData: [String: Any]) -> Void)?
    var errorCallback: (() -> (Void))?
    var restartRequestCallback: (() -> (Void))!

    init() {
        createQuery()
        
        restartRequestCallback = {
            self.createQuery()
            self.execute()
        }
    }
    
    func createQuery() {
        let url = URL(string: Configuration.API_URL + "/livestream-programs")!
        
        GeneralUtils.log(LivestreamProgramsRequest.TAG, url)
        
        let usersManager = UsersManager.getInstance()
        let accessToken = usersManager.getAccessTokenForRequests()
        
        //GeneralUtils.log(LivestreamProgramsRequest.TAG, "accessToken: " + accessToken)
        
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
                    self.errorCallback?()
                    
                    return
                }

                // process API response
                let responseJson = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJson = responseJson as? [String: Any] {
                    
                    //GeneralUtils.log(LivestreamProgramsRequest.TAG, String(data: data, encoding: .utf8)!)
                    
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
