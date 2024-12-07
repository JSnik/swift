//
//  MediaPlaybackStateModel.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 25/08/2022.
//

import UIKit

class MediaPlaybackStateModel: Codable {
    
    let episodeId: String
    private var playedTimeInMilliseconds: Double!

    init(
        _ episodeId: String
    ){
        self.episodeId = episodeId
    }
    
    func getEpisodeId() -> String {
        return episodeId
    }

    func getPlayedTimeInMilliseconds() -> Double {
        if (playedTimeInMilliseconds == nil) {
            playedTimeInMilliseconds = 0
        }
        
        return playedTimeInMilliseconds
    }

    func setPlayedTimeInMilliseconds(_ playedTimeInMilliseconds: Double) {
        self.playedTimeInMilliseconds = playedTimeInMilliseconds
    }
}
