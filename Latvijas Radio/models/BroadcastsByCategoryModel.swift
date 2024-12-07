//
//  BroadcastsByCategoryModel.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class BroadcastsByCategoryModel: Codable {
    
    static let TAG = String(describing: BroadcastsByCategoryModel.self)

    private let id: String
    private var name: String!
    private var broadcasts: [String]! // to conform to "Encodable", we keep json structures as strings, decoding them when needed
    
    init(_ id: String, _ name: String){
        self.id = id
        self.name = name
        
        broadcasts = [String]()
    }
    
    func getId() -> String {
        return id
    }
    
    func getName() -> String {
        return name
    }

    func getBroadcasts() -> [[String: Any]] {
        var result = [[String: Any]]()
        
        for hostJsonString in broadcasts {
            if let data = hostJsonString.data(using: String.Encoding.utf8) {
                let hostJson = try? JSONSerialization.jsonObject(with: data, options: [])
                if let hostJson = hostJson as? [String: Any] {
                    result.append(hostJson)
                }
            }
        }

        return result
    }

    func setBroadcasts(_ broadcastsJson: [NSDictionary]) {
        var result = [String]()

        do {
            for broadcastJson in broadcastsJson {
                // one liner: let hostsAsJsonString = try? hosts.toString()
                let broadcastAsJsonString: String? = try broadcastJson.toString()
                if (broadcastAsJsonString != nil) {
                    result.append(broadcastAsJsonString!)
                }
            }

        } catch(let error){
            GeneralUtils.log(BroadcastByCategoryRequest.TAG, error.localizedDescription)
        }
        
        self.broadcasts = result
    }
}
