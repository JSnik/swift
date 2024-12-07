//
//  DeepLinkSharedLivestreamModel.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class DeepLinkSharedLivestreamModel: Codable {
    
    static let TAG = String(describing: DeepLinkSharedLivestreamModel.self)

    static let DEEP_LINK_QUERY_PARAM_LIVESTREAM_ID = "id"
    
    private let livestreamId: String
    
    init(_ livestreamId: String){
        self.livestreamId = livestreamId
    }
    
    func getLivestreamId() -> String {
        return livestreamId
    }
}
