//
//  EpisodeModel.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class EpisodeModel: Codable {
    
    static let TAG = String(describing: EpisodeModel.self)

    private let id: String
    private var imageUrl: String!
    private var title: String!
    private var description: String?
    private var categoryName: String!
    private var categoryId: String!
    private var channelId: String?
    private var hosts: [String]! // to conform to "Encodable", we keep json structures as strings, decoding them when needed
    private var broadcastName: String!
    private var broadcastEmail: String!
    private var dateInMillis: Double!
    private var mediaDurationInSeconds: Int!
    private var mediaStreamUrl: String!
    private var mediaDownloadUrl: String?
    private var downloadedMediaPath: String? // only available to episodes that have been saved for offline playback
    private var lsmTags: [String]! // to conform to "Encodable", we keep json structures as strings, decoding them when needed
    private var newsBlocks: [String]! // to conform to "Encodable", we keep json structures as strings, decoding them when needed
    private var containsCopyrightedMusic = false
    private var url: String?
    private var color: String?

    init(_ id: String){
        self.id = id
        
        hosts = [String]()
        lsmTags = [String]()
    }
    
    func getId() -> String {
        return id
    }
    
    func getImageUrl() -> String {
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

    func getCategoryId() -> String {
        return categoryId
    }

    func setCategoryId(_ categoryId: String) {
        self.categoryId = categoryId
    }

    func getChannelId() -> String? {
        return channelId
    }

    func setChannelId(_ channelId: String?) {
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

    func getBroadcastName() -> String {
        return broadcastName
    }

    func setBroadcastName(_ broadcastName: String) {
        self.broadcastName = broadcastName
    }

    func getBroadcastEmail() -> String {
        return broadcastEmail
    }

    func setBroadcastEmail(_ broadcastEmail: String) {
        self.broadcastEmail = broadcastEmail
    }

    func getDateInMillis() -> Double {
        return dateInMillis
    }

    func setDateInMillis(_ dateInMillis: Double) {
        self.dateInMillis = dateInMillis
    }

    func getMediaDurationInSeconds() -> Int {
        return mediaDurationInSeconds
    }

    func setMediaDurationInSeconds(_ mediaDurationInSeconds: Int) {
        self.mediaDurationInSeconds = mediaDurationInSeconds
    }

    func getMediaStreamUrl() -> String {
        return mediaStreamUrl
    }

    func setMediaStreamUrl(_ mediaStreamUrl: String) {
        self.mediaStreamUrl = mediaStreamUrl
    }

    func getMediaDownloadUrl() -> String? {
        return mediaDownloadUrl
    }

    func setMediaDownloadUrl(_ mediaDownloadUrl: String?) {
        self.mediaDownloadUrl = mediaDownloadUrl
    }

    func getDownloadedMediaPath() -> String? {
        return downloadedMediaPath
    }

    func setDownloadedMediaPath(_ downloadedMediaPath: String) {
        self.downloadedMediaPath = downloadedMediaPath
    }

    func getLsmTags() -> [[String: Any]] {
        var result = [[String: Any]]()
        
        for lsmTagJsonString in lsmTags {
            if let data = lsmTagJsonString.data(using: String.Encoding.utf8) {
                let lsmTagJson = try? JSONSerialization.jsonObject(with: data, options: [])
                if let lsmTagJson = lsmTagJson as? [String: Any] {
                    result.append(lsmTagJson)
                }
            }
        }

        return result
    }

    func setLsmTags(_ lsmTagsJson: [NSDictionary]) {
        var result = [String]()

        do {
            for lsmTagJson in lsmTagsJson {
                let lsmTagAsJsonString: String? = try lsmTagJson.toString()
                if (lsmTagAsJsonString != nil) {
                    result.append(lsmTagAsJsonString!)
                }
            }

        } catch(let error){
            GeneralUtils.log(EpisodeModel.TAG, error.localizedDescription)
        }
        
        self.lsmTags = result
    }
    
    func getNewsBlocks() -> [[String: Any]] {
        var result = [[String: Any]]()
        if let els: [String] = newsBlocks {
            for newsBlockJsonString in els {
                if let data = newsBlockJsonString.data(using: String.Encoding.utf8) {
                    let newsBlockJson = try? JSONSerialization.jsonObject(with: data, options: [])
                    if let newsBlockJson = newsBlockJson as? [String: Any] {
                        result.append(newsBlockJson)
                    }
                }
            }
        }

        return result
    }

    func setNewsBlocks(_ newsBlocksJson: [NSDictionary]) {
        var result = [String]()

        do {
            for newsBlockJson in newsBlocksJson {
                let newsBlockAsJsonString: String? = try newsBlockJson.toString()
                if (newsBlockAsJsonString != nil) {
                    result.append(newsBlockAsJsonString!)
                }
            }

        } catch(let error){
            GeneralUtils.log(EpisodeModel.TAG, error.localizedDescription)
        }
        
        self.newsBlocks = result
    }
    
    func getContainsCopyrightedMusic() -> Bool {
        return containsCopyrightedMusic
    }

    func setContainsCopyrightedMusic(_ containsCopyrightedMusic: Bool) {
        self.containsCopyrightedMusic = containsCopyrightedMusic
    }
    
    func getUrl() -> String? {
        return url
    }

    func setUrl(_ url: String?) {
        self.url = url
    }
    
    func getColor() -> String? {
        return color
    }

    func setColor(_ color: String?) {
        self.color = color
    }
}
