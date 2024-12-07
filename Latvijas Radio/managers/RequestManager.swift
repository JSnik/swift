//
//  RequestManager.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class RequestManager {
    
    static let TAG = String(describing: RequestManager.self)
    
    static let RESPONSE_PARAM_DATA = "data"
    static let RESPONSE_PARAM_RESULTS = "results"
    static let RESPONSE_PARAM_ERROR = "error"
    static let RESPONSE_PARAM_ERRORS = "errors"
    static let RESPONSE_PARAM_MESSAGE = "message"
    
    static let ERROR_NETWORK_ERROR_GENERIC = "network_error_generic"
    static let ERROR_NETWORK_ERROR_NO_CONNECTION = "network_error_no_connection"
    static let ERROR_JWT_TOKEN_EXPIRED = "jwt_token_expired"
    static let ERROR_JWT_TOKEN_NOT_FOUND = "refresh_token_not_found"
    
    static var isRefreshingTokenInProgress = false
    static var requestsToReDoOnTokenRefreshed = [(() -> Void)]()

    static func getMessageFromNetworkError(_ error: Error?) -> String {
        var message = RequestManager.ERROR_NETWORK_ERROR_GENERIC
        
        if (error != nil) {
            switch(error!._code) {
            case -1009, -1005, -1001:
                GeneralUtils.log(TAG, "ERROR: TimeoutError | NoConnectionError")
                
                message = RequestManager.ERROR_NETWORK_ERROR_NO_CONNECTION
                
                break
            default:
                GeneralUtils.log(TAG, "ERROR: GenericError")
                
                break
            }
        }
        
        return message
    }
    
    static func handleResponseError(
        _ responseError: String,
        _ notificationViewController: NotificationViewController?,
        _ errorCallback: (() -> (Void))?,
        _ restartRequestCallback: (() -> (Void))?) {
            
        GeneralUtils.log(TAG, "handleResponseError:", responseError)
        
        if (responseError == ERROR_JWT_TOKEN_EXPIRED) {
            // We might open view where multiple requests get fired with expired accessToken, which will trigger multiple "/refresh-token" endpoint calls.
            // When first call consumes the request token, subsequent calls will get error "refresh_token_not_found".
            // That's why we keep track of "isRefreshingTokenInProgress" so no subsequent requests are made.
            // But, we still need to re-do those subsequent requests on successful "/refresh-token" response, so track them in an array.
            if (!RequestManager.isRefreshingTokenInProgress)
            {
                RequestManager.isRefreshingTokenInProgress = true

                requestsToReDoOnTokenRefreshed.insert(restartRequestCallback!, at: 0)
                
                // refresh token
                let usersManager = UsersManager.getInstance()
                let currentUser = usersManager.getCurrentUser()
                
                // params
                let refreshToken = currentUser!.getRefreshToken()

                let urlQueryItems = [
                    URLQueryItem(name: RefreshTokenRequest.REQUEST_PARAM_REFRESH_TOKEN, value: refreshToken)
                ]
                
                let refreshTokenRequest = RefreshTokenRequest(notificationViewController, urlQueryItems)

                refreshTokenRequest.successCallback = { (data) -> Void in
                    let accessToken = data[RefreshTokenRequest.RESPONSE_PARAM_ACCESS_TOKEN] as! String
                    let refreshToken = data[RefreshTokenRequest.RESPONSE_PARAM_REFRESH_TOKEN] as! String
                    
                    currentUser!.setAccessToken(accessToken)
                    currentUser!.setRefreshToken(refreshToken)
                    
                    usersManager.saveCurrentUserData()
                    
                    isRefreshingTokenInProgress = false
                    
                    // re-do failed requests
                    for failedRequestRestartCallback in requestsToReDoOnTokenRefreshed {
                        failedRequestRestartCallback()
                    }
                    
                    requestsToReDoOnTokenRefreshed.removeAll()
                }

                refreshTokenRequest.errorCallback = { (data) -> Void in
                    isRefreshingTokenInProgress = false
                    
                    let refreshTokenError = data
                    
                    RequestManager.handleResponseError(refreshTokenError, notificationViewController, errorCallback, restartRequestCallback)
                }
                
                refreshTokenRequest.execute()
            } else {
                requestsToReDoOnTokenRefreshed.insert(restartRequestCallback!, at: 0)
            }
        } else {
            if let notificationViewController = notificationViewController {
                if (responseError == ERROR_JWT_TOKEN_NOT_FOUND) {
                    // We have tried refreshing the token, but it somehow failed on server side (ex. refresh expires after 3 months).
                    // Navigate user to authentication view.
                    
                    if let sceneDelegate = SceneDelegate.getSceneDelegate() {
                        if let navigationController = sceneDelegate.window?.rootViewController as? UINavigationController {
                            // If we are refreshing token from authentication view itself, we shouldn't process this.
                            if (!(navigationController.topViewController is AuthenticationViewController)) {
                                // In order for this error message to be called only once, we have to clear the current user object.
                                UsersManager.logOutCurrentUser()
                                
                                // Redirect user to authentication view controller.
                                let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_AUTHENTICATION, bundle: nil)
                                                        .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_AUTHENTICATION) as! AuthenticationViewController)
                                
                                viewController.initialNotificationMessage = responseError.localized()
                                
                                navigationController.setViewControllers([viewController], animated: true)
                                
                                return
                            }
                        }
                    }
                }
                
                // for silent requests, we won't have notificationViewController, so report error as toast or don't report at all
                notificationViewController.showNotification(text: responseError.localized())
            }
            
            errorCallback?()
        }
    }
    
    static func getErrorFromResponse(_ responseJson: [String: Any]) -> String? {
        var result: String?
        
        // This api will give us errors in 2 forms:
        // First form example:
//                                {
//                                    "error": {
//                                        "code": "user_is_already_registered"
//                                    }
//                                }

        // Second form example:
//                                {
//                                    "apiVersion": "$API_VERSION",
//                                    "errors": [
//                                        [
//                                            {
//                                                "fieldName": "forLifeId",
//                                                "message": "this_value_should_not_be_blank"
//                                            }
//                                        ]
//                                    ]
//                                }

        let error = responseJson[RequestManager.RESPONSE_PARAM_ERROR] as? [String: Any]
        if (error != nil) {
            result = error?[RequestManager.RESPONSE_PARAM_MESSAGE] as? String
        }
        
        let errors = responseJson[RequestManager.RESPONSE_PARAM_ERRORS] as? [[String: Any]]
        if (errors != nil) {
            let errorsJson = errors![0] as [String: Any]
            result = errorsJson[RequestManager.RESPONSE_PARAM_MESSAGE] as? String
        }

        return result
    }
}
