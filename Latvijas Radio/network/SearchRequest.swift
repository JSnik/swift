//
//  SearchRequest.swift
//  Latvijas Radio
//
//  Created by andriy kruglyanko on 19.10.2024.
//  Copyright © 2024 Latvijas Radio. All rights reserved.
//

import UIKit

class SearchRequest {

    static let TAG = String(describing: SearchRequest.self)

    static let RESPONSE_PARAM_HITS = "hits"
    static let RESPONSE_PARAM_ID = "id"
    static let RESPONSE_PARAM_TITLE = "title"
    static let RESPONSE_PARAM_BROADCASTS = "broadcasts"

    weak var notificationViewController: NotificationViewController?

    var task: URLSessionDataTask!
    var successCallback: ((_ receivedData: [String: Any], _ data1: Data) -> Void)?
    var errorCallback: (() -> (Void))?
    var restartRequestCallback: (() -> (Void))!
    var errorMessage: String?

    init( _ urlQueryItems: [URLQueryItem]) {

        createQuery(urlQueryItems)

        restartRequestCallback = {
            self.createQuery(urlQueryItems)
            self.execute()
        }
    }

    func createQuery( _ urlQueryItems: [URLQueryItem]) {

//        let url = URL(string: Configuration.SEARCHURL)!



        let usersManager = UsersManager.getInstance()
        let accessToken = usersManager.getAccessTokenForRequests()



        var components = URLComponents() //url: url, resolvingAgainstBaseURL: false)!
//        components.scheme = "https"
//        components.host = "search.latvijasradio.lv"
//        components.path = "/collections/devlrapp/documents/search"
        components.scheme = "http"
        components.host = "www.latvijasradio.lsm.lv"
        components.path = "/api/"
        components.queryItems = urlQueryItems
//        let query = components.url!.query!
//        request.httpBody = Data(query.utf8)


        if let url = URL(string: components.string ?? Configuration.SEARCHURL) {
            GeneralUtils.log(SearchRequest.TAG, url)
            GeneralUtils.log(SearchRequest.TAG, urlQueryItems)
            var request = URLRequest(url: (url))
//            var request = URLRequest(url: components.url)
            request.httpMethod = "GET"

//            request.setValue(GeneralUtils.getAppVersion(), forHTTPHeaderField: "App-Version-Ios")
//            request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
//            request.setValue(LanguageManager.getCurrentInterfaceLanguageId(), forHTTPHeaderField: "Accept-Language")
            let config = URLSessionConfiguration.default
            config.requestCachePolicy = .reloadIgnoringLocalCacheData //.returnCacheDataElseLoad //.reloadIgnoringLocalCacheData
//            config.urlCache = nil

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
//                    let searchSuccess = try? JSONDecoder().decode(SearchSuccess.self, from: data)
//                    print("searchSuccess = \(searchSuccess)")
//                    print("responseJson = \(responseJson)")
                    if let responseJson = responseJson as? [String: Any] {

                        //GeneralUtils.log(BroadcastByCategoryRequest.TAG, String(data: data, encoding: .utf8)!)

                        // check for error
                        let responseError = RequestManager.getErrorFromResponse(responseJson)
                        if (responseError != nil) {
                            self.errorMessage = responseError

                            RequestManager.handleResponseError(responseError!, self.notificationViewController, self.errorCallback, self.restartRequestCallback)
                        } else {
//                            let data = responseJson

                            self.successCallback?(responseJson, data)
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
    }

    func execute() {
        task.resume()
    }

}

