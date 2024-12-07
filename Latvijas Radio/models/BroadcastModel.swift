//
//  BroadcastModel.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class BroadcastModel: Codable {
    
    static let TAG = String(describing: BroadcastModel.self)

    private let id: String
    private var imageUrl: String?
    private var title: String!
    private var description: String?
    private var categoryName: String!
    private var channelId: String!
    private var hosts: [String]! // to conform to "Encodable", we keep json structures as strings, decoding them when needed
    private var url: String?
    
    init(_ id: String){
        self.id = id
        
        hosts = [String]()
    }
    
    func getId() -> String {
        return id
    }
    
    func getImageUrl() -> String? {
        return imageUrl
    }
    
    func setImageUrl(_ imageUrl: String) {
        self.imageUrl = imageUrl
    }
    
    func getTitle() -> String {
        return title
    }

    func setTitle(_ title: String) {
        self.title = title
    }

    func getDescription() -> String? {
        return description
    }

    func setDescription(_ description: String?) {
        self.description = description
    }

    func getCategoryName() -> String {
        return categoryName
    }

    func setCategoryName(_ categoryName: String) {
        self.categoryName = categoryName
    }

    func getChannelId() -> String {
        return channelId
    }

    func setChannelId(_ channelId: String) {
        self.channelId = channelId
    }

    func getHosts() -> [[String: Any]] {
        var result = [[String: Any]]()
        
        for hostJsonString in hosts {
            if let data = hostJsonString.data(using: String.Encoding.utf8) {
                let hostJson = try? JSONSerialization.jsonObject(with: data, options: [])
                if let hostJson = hostJson as? [String: Any] {
                    result.append(hostJson)
                }
            }
        }

        return result
    }

    func setHosts(_ hostsJson: [NSDictionary]) {
        var result = [String]()

        do {
            for hostJson in hostsJson {
                // one liner: let hostsAsJsonString = try? hosts.toString()
                let hostAsJsonString: String? = try hostJson.toString()
                if (hostAsJsonString != nil) {
                    result.append(hostAsJsonString!)
                }
            }

        } catch(let error){
            GeneralUtils.log(EpisodeModel.TAG, error.localizedDescription)
        }
        
        self.hosts = result
    }
    
    func getUrl() -> String? {
        return url
    }

    func setUrl(_ url: String?) {
        self.url = url
    }
}
