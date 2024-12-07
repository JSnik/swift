//
//  DeepLinkSharedBroadcastModel.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class DeepLinkSharedBroadcastModel: Codable {
    
    static let TAG = String(describing: DeepLinkSharedBroadcastModel.self)

    static let DEEP_LINK_QUERY_PARAM_BROADCAST_ID = "b"
    static let DEEP_LINK_QUERY_PARAM_BROADCAST_URL = "url"
    
    private let broadcastId: String
    
    init(_ broadcastId: String){
        self.broadcastId = broadcastId
    }
    
    func getBroadcastId() -> String {
        return broadcastId
    }
}
