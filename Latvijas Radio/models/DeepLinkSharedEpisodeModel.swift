//
//  DeepLinkSharedEpisodeModel.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class DeepLinkSharedEpisodeModel: Codable {
    
    static let TAG = String(describing: DeepLinkSharedEpisodeModel.self)

    static let DEEP_LINK_QUERY_PARAM_EPISODE_ID = "e"
    static let DEEP_LINK_QUERY_PARAM_EPISODE_URL = "url"
    
    private let episodeId: String
    
    init(_ episodeId: String){
        self.episodeId = episodeId
    }
    
    func getEpisodeId() -> String {
        return episodeId
    }
}
