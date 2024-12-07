//
//  PlaybackTimeoutModel.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 22/08/2022.
//

import UIKit

class PlaybackTimeoutModel: Codable {
    
    static let ID_TURN_OFF = "ID_TURN_OFF"
    static let ID_AFTER_30M = "ID_AFTER_30M"
    static let ID_AFTER_1H = "ID_AFTER_1H"
    static let ID_AFTER_1H30M = "ID_AFTER_1H30M"
    
    let id: String
    let titleResourceId: String
    let timeoutInMilliseconds: Int

    init(
        _ id: String,
        _ titleResourceId: String,
        _ timeoutInMilliseconds: Int
    ){
        self.id = id
        self.titleResourceId = titleResourceId
        self.timeoutInMilliseconds = timeoutInMilliseconds
    }
    
    func getId() -> String {
        return id
    }

    func getTitleResourceId() -> String {
        return titleResourceId
    }
    
    func getTimeoutInMilliseconds() -> Int {
        return timeoutInMilliseconds
    }
}
