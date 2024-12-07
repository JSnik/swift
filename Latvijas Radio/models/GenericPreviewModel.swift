//
//  GenericPreviewModel.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class GenericPreviewModel: Codable {
    
    static let TAG = String(describing: GenericPreviewModel.self)
    
    static let TYPE_BROADCAST = "TYPE_BROADCAST"
    static let TYPE_EPISODE = "TYPE_EPISODE"

    private let type: String
    private var broadcastModel: BroadcastModel?
    private var episodeModel: EpisodeModel?

    init(_ type: String, _ broadcastModel: BroadcastModel?, _ episodeModel: EpisodeModel?){
        self.type = type
        self.broadcastModel = broadcastModel
        self.episodeModel = episodeModel
    }
    
    func getType() -> String {
        return type
    }
    
    func getBroadcastModel() -> BroadcastModel? {
        return broadcastModel
    }
    
    func getEpisodeModel() -> EpisodeModel? {
        return episodeModel
    }
}
