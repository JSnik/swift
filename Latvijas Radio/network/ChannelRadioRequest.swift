//
//  ChannelRadioRequest.swift
//  Latvijas Radio
//
//  Created by andriy kruglyanko on 05.11.2024.
//  Copyright © 2024 Latvijas Radio. All rights reserved.
//

import Foundation

class ChannelRadioRequest {
    static let TAG = String(describing: ChannelRadioRequest.self)

    static let RESPONSE_PARAM_RADIO = "stations"
    static let RESPONSE_PARAM_RESULTS = "results"

    weak var notificationViewController: NotificationViewController?

    var task: URLSessionDataTask!
    var successCallback: ((_ receivedData: [String: Any], _ data1: Data) -> Void)?
    var errorCallback: (() -> (Void))?
    var restartRequestCallback: (() -> (Void))!

    init(_ notificationViewController: NotificationViewController, _ channelId: String) {
        self.notificationViewController = notificationViewController
        if channelId == "" {
            createQueryList()
            restartRequestCallback = {
                self.createQueryList()
                self.execute()
            }
        } else {
            createQuery(channelId)
            restartRequestCallback = {
                self.createQuery(channelId)
                self.execute()
            }
        }
        //createQuery(channelId)


//        restartRequestCallback = {
//            if channelId == "" {
//                self.createQueryList()
//            } else {
//                self.createQuery(channelId)
//            }
////            self.createQuery(channelId)
////            self.createQueryList()
//            self.execute()
//        }
    }

    func createQueryList() {
        notificationViewController?.hideNotificationInstantly()

        let url = URL(string: "https://lr-api.pieci.lv/stations/?populate=mobile")!
//        URL(string: Configuration.API_URL + "/stations/populate=mobile")!

        GeneralUtils.log(ChannelBroadcastsRequest.TAG, url)

        let usersManager = UsersManager.getInstance()
        let accessToken = usersManager.getAccessTokenForRequests()

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(GeneralUtils.getAppVersion(), forHTTPHeaderField: "App-Version-Ios")
        request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        let session = URLSession.init(configuration: config)

        task = session.dataTask(with: request) { data, response, error in
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

                    //GeneralUtils.log(ChannelBroadcastsRequest.TAG, String(data: data, encoding: .utf8)!)

                    // check for error
                    let responseError = RequestManager.getErrorFromResponse(responseJson)
                    if (responseError != nil) {
                        RequestManager.handleResponseError(responseError!, self.notificationViewController, self.errorCallback, self.restartRequestCallback)
                    } else {
//                        let data = responseJson[RequestManager.RESPONSE_PARAM_DATA] as! [String: Any]

                        self.successCallback?(responseJson, data)
                    }
                } else {
                    let message = RequestManager.getMessageFromNetworkError(error)
                    self.notificationViewController?.showNotification(text: message.localized())

                    self.errorCallback?()
                }
            })
        }
    }


    func createQuery(_ channelId: String) {
        notificationViewController?.hideNotificationInstantly()

        let url = URL(string: Configuration.API_URL + "/stations/" + channelId + "/populate=mobile")!

        GeneralUtils.log(ChannelBroadcastsRequest.TAG, url)

        let usersManager = UsersManager.getInstance()
        let accessToken = usersManager.getAccessTokenForRequests()

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(GeneralUtils.getAppVersion(), forHTTPHeaderField: "App-Version-Ios")
        request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        let session = URLSession.init(configuration: config)

        task = session.dataTask(with: request) { data, response, error in
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

                    //GeneralUtils.log(ChannelBroadcastsRequest.TAG, String(data: data, encoding: .utf8)!)

                    // check for error
                    let responseError = RequestManager.getErrorFromResponse(responseJson)
                    if (responseError != nil) {
                        RequestManager.handleResponseError(responseError!, self.notificationViewController, self.errorCallback, self.restartRequestCallback)
                    } else {
                        //let data = responseJson[RequestManager.RESPONSE_PARAM_DATA] as! [String: Any]

                        self.successCallback?(responseJson, data)
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
