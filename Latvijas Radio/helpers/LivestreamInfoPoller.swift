//
//  BroadcastInfoPoller.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class LivestreamInfoPoller: NSObject {
    
    let TAG = String(describing: LivestreamInfoPoller.self)
    
    static let EVENT_ON_LIVESTREAM_PROGRAMS_UDPATED = "EVENT_ON_LIVESTREAM_PROGRAMS_UDPATED"
    
    static var lastKnownReceivedPayload: [String: Any]?

    var timer = Timer()

    func startPollingProcedure() {
        performRequestLivestream()
        
        timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true, block: { [weak self] _ in
            self?.performRequestLivestream()
        })
    }
    
    func stopPollingProcedure() {
        timer.invalidate()
    }
    
    func performRequestLivestream() {
        let livestreamProgramsRequest = LivestreamProgramsRequest()

        livestreamProgramsRequest.successCallback = { [weak self] (data) -> Void in
            LivestreamInfoPoller.lastKnownReceivedPayload = data
            
            self?.notifyOnLivestreamProgramsUpdated()
        }
        
        livestreamProgramsRequest.errorCallback = { [weak self] in
            LivestreamInfoPoller.lastKnownReceivedPayload = nil
            
            self?.notifyOnLivestreamProgramsUpdated()
        }
        
        livestreamProgramsRequest.execute()
    }
    
    func notifyOnLivestreamProgramsUpdated() {
        NotificationCenter.default.post(
            name: Notification.Name(LivestreamInfoPoller.EVENT_ON_LIVESTREAM_PROGRAMS_UDPATED),
            object: nil,
            userInfo: nil
        )
    }

    static func getLivestreamBroadcastTitleWithLivestreamId(_ livestreamId: String) -> String? {
        var result: String?
        
        let payload = LivestreamInfoPoller.lastKnownReceivedPayload
        
        if (payload != nil) {
            if let livestreamPrograms = payload![LivestreamProgramsRequest.RESPONSE_PARAM_LIVESTREAM_PROGRAMS] as? [[String: Any]] {
                for i in (0..<livestreamPrograms.count) {
                    let livestreamProgram = livestreamPrograms[i]
                    let channelId = livestreamProgram[LivestreamProgramsRequest.RESPONSE_PARAM_CHANNEL_ID] as! String
                    
                    if (channelId == livestreamId) {
                        result = livestreamProgram[LivestreamProgramsRequest.RESPONSE_PARAM_TITLE] as? String
                        
                        break
                    }
                }
            }
        }
        
        return result
    }
}
