//
//  EpisodesHelper.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit
import AVFoundation

class EpisodesHelper {

    static func getEpisodesListFromJsonArray(_ episodes: [[String: Any]]) -> [EpisodeModel] {
        var dataset = [EpisodeModel]()
        
        for episodeJson in episodes {
            let episodeModel = getEpisodeFromJsonObject(episodeJson)
            if (episodeModel != nil) {
                dataset.append(episodeModel!)
            }
        }

        return dataset
    }
    
    static func getEpisodeFromJsonObject(_ episodeJson: [String: Any]) -> EpisodeModel? {
        var episodeModel: EpisodeModel? = nil
        
        // Since many endpoints return EpisodeJsonObjectModel,
        // we keep the field names here.

        // Some episodes from client API might not have any audio (comes as empty array), skip them.
        let media = episodeJson["media"] as? [String: Any]
        if (media != nil) {
            let id = episodeJson["id"] as! Int
            let imageUrl = episodeJson["imageUrl"] as! String
            let title = episodeJson["title"] as! String
            let description = episodeJson["description"] as? String
            
            var categoryName = title
            
            let broadcastCategories = episodeJson["broadcastCategories"] as? [[String: Any]]
            if (broadcastCategories != nil) {

                if (broadcastCategories!.count > 0) {
                    categoryName = ""

                    for i in 0...broadcastCategories!.count - 1 {
                        let broadcastCategory = broadcastCategories![i]
                        var categoryTitle = broadcastCategory["title"] as? String
                        if (categoryTitle == nil) {
                            categoryTitle = "null"
                        }

                        categoryName = categoryName + categoryTitle!

                        if (i < broadcastCategories!.count - 1) {
                            categoryName = categoryName + ", "
                        }
                    }
                }
            }

            let categoryId = episodeJson["categoryId"] as! Int
            let channelId = episodeJson["channelId"] as? String
            
            let hosts = episodeJson["hosts"] as! [NSDictionary]
            
            let broadcastName = episodeJson["broadcastName"] as! String
            let broadcastEmail = episodeJson["broadcastEmail"] as! String
            let date = episodeJson["date"] as! Double
            
            let audio = media!["audio"] as! [[String: Any]]
            let audioItem = audio[0]
            let mediaDuration = audioItem["duration"] as! Int
            
            let audioData = audioItem["data"] as! [String: Any]
            let links = audioData["links"] as! [String: Any]
            let mp3 = links["mp3"] as! [String: Any]
            
            let mediaDownloadUrl = mp3["download"] as? String
            
            let mediaStreamUrl = mp3["html5"] as! String
            
            let lsmTags = episodeJson["lsmTags"] as! [NSDictionary]
            let newsBlocks = episodeJson["newsBlocks"] as! [NSDictionary]
            let containsCopyrightedMusic = episodeJson["containsCopyrightedMusic"] as! Bool
            let url = episodeJson["url"] as? String
            
            
            episodeModel = EpisodeModel(String(id))
            
            episodeModel?.setImageUrl(imageUrl)
            episodeModel?.setTitle(title)
            episodeModel?.setDescription(description)
            episodeModel?.setCategoryName(categoryName)
            episodeModel?.setCategoryId(String(categoryId))
            episodeModel?.setChannelId(channelId)
            episodeModel?.setHosts(hosts)
            episodeModel?.setBroadcastName(broadcastName)
            episodeModel?.setBroadcastEmail(broadcastEmail)
            episodeModel?.setDateInMillis(date)
            episodeModel?.setMediaDurationInSeconds(mediaDuration)
            episodeModel?.setMediaDownloadUrl(mediaDownloadUrl)
            episodeModel?.setMediaStreamUrl(mediaStreamUrl)
            episodeModel?.setLsmTags(lsmTags)
            episodeModel?.setNewsBlocks(newsBlocks)
            episodeModel?.setContainsCopyrightedMusic(containsCopyrightedMusic)
            episodeModel?.setUrl(url)
        } else {
            let media = episodeJson["url"] as? String
            if (media != nil) {
                let id = episodeJson["id"] as? Int
                let imageUrl: String? = episodeJson["image"] as? String
                let title = episodeJson["name"] as? String
                let isActive = episodeJson["is_active"] as? String
                let updatedAt = episodeJson["updated_at"] as? String
                let mediaUrl = episodeJson["url"] as? String
                let contentType = episodeJson["content_type"] as? String
                let color = episodeJson["color"] as? String

                let dateFormatter = DateFormatter()
//                RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
//                RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
//                RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXX"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

                /* 39 minutes and 57 seconds after the 16th hour of December 19th, 1996 with an offset of -08:00 from UTC (Pacific Standard Time) */
                let string = updatedAt ?? "1996-12-19T16:39:57-08:00"
                let date = dateFormatter.date(from: string)?.timeIntervalSinceReferenceDate as? Double ?? 1093920923

                episodeModel = EpisodeModel(String(id ?? 0))
                episodeModel?.setImageUrl(imageUrl ?? "")
                episodeModel?.setTitle(title ?? "")
                episodeModel?.setDescription("")
                episodeModel?.setCategoryName("")
                episodeModel?.setCategoryId(String(id ?? 0))
                episodeModel?.setChannelId("")
                episodeModel?.setBroadcastName(title ?? "")
                episodeModel?.setDateInMillis(date)
                let audioAsset = AVURLAsset.init(url: URL(string: media!)!, options: nil)
                let duration = audioAsset.duration
                let durationInSeconds = CMTimeGetSeconds(duration)
                episodeModel?.setMediaDurationInSeconds(Int(durationInSeconds))
                episodeModel?.setMediaDownloadUrl(mediaUrl)
                episodeModel?.setMediaStreamUrl(mediaUrl ?? "")
                episodeModel?.setUrl(mediaUrl ?? "")
                episodeModel?.setColor(color ?? "")
            }
        }
        
        return episodeModel
    }
    
    static func isEpisodeAllowedToBeDownloaded(_ episodeModel: EpisodeModel?) -> Bool {
        var result = false
        
        if let episodeModel = episodeModel {
            if (episodeModel.getMediaDownloadUrl() != nil && !episodeModel.getContainsCopyrightedMusic()) {
                result = true
            }
        }
 
        return result
    }

    static func getEpisodesSearchListFromJsonArray(_ episodes: [[String: Any]]) -> [EpisodeModel] {
        var dataset = [EpisodeModel]()

        for episodeJson in episodes {
            let episodeModel = getEpisodeSearchFromJsonObject(episodeJson)
            if (episodeModel != nil) {
                dataset.append(episodeModel!)
            }
        }

        return dataset
    }

    static func getEpisodeSearchFromJsonObject(_ episodeJson: [String: Any]) -> EpisodeModel? {
        var episodeModel: EpisodeModel? = nil

        // Since many endpoints return EpisodeJsonObjectModel,
        // we keep the field names here.

        // Some episodes from client API might not have any audio (comes as empty array), skip them.
        let media = episodeJson["media"] as? [String: Any]
        if (media != nil) {
            let id = episodeJson["id"] as! Int
            episodeModel = EpisodeModel(String(id))
            var imageUrl = ""
            if let images = episodeJson["images"] as? Dictionary<String,String> ,
            let imLarge = images["large"] {
                imageUrl = imLarge
            } else {
                imageUrl = episodeJson["imageUrl"] as! String
            }

            //let imageUrl = episodeJson["imageUrl"] as! String
            let title = episodeJson["title"] as! String
            if let description = episodeJson["description"] as? String {
                episodeModel?.setDescription(description)
            } else {
                if let leadHtml = episodeJson["lead"] {
                   let strHtml = (leadHtml as AnyObject).debugDescription.replacingOccurrences(of: "<[^>]+>", with: "")
                    episodeModel?.setDescription(strHtml)
                }
            }

            var categoryName = title

            let broadcastCategories = episodeJson["broadcastCategories"] as? [[String: Any]]
            if (broadcastCategories != nil) {

                if (broadcastCategories!.count > 0) {
                    categoryName = ""

                    for i in 0...broadcastCategories!.count - 1 {
                        let broadcastCategory = broadcastCategories![i]
                        var categoryTitle = broadcastCategory["title"] as? String
                        if (categoryTitle == nil) {
                            categoryTitle = "null"
                        }

                        categoryName = categoryName + categoryTitle!

                        if (i < broadcastCategories!.count - 1) {
                            categoryName = categoryName + ", "
                        }
                    }
                }
            }
            var  categoryId = 0 //episodeJson["categoryId"] as! Int
            if let category = episodeJson["category"] as? Dictionary<String,Any>,
               let ktit = category["id"] as? Int64 {
                categoryId = Int(ktit)
            } else {
                categoryId = episodeJson["categoryId"] as! Int
            }
            //let categoryId = episodeJson["categoryId"] as! Int
            if let channelId = episodeJson["channelId"] as? String {
                episodeModel?.setChannelId(channelId)
            } else {
                if let channelId = episodeJson["channel"] as? Int {
                    episodeModel?.setChannelId("\(channelId)")
                }
            }

            if let hosts = episodeJson["hosts"] as? [NSDictionary] {
                episodeModel?.setHosts(hosts)
            }

            if let broadcastName = episodeJson["broadcastName"] as? String {
                episodeModel?.setBroadcastName(broadcastName)
            } else {
                if let broadcastName = episodeJson["title"] as? String {
                    episodeModel?.setBroadcastName(broadcastName)
                }
            }
            if let broadcastEmail = episodeJson["broadcastEmail"] as? String {
                episodeModel?.setBroadcastEmail(broadcastEmail)
            }
            if let date = episodeJson["date"] as? Double {
                episodeModel?.setDateInMillis(date)
            } else {
                let aired: Int64 = episodeJson["aired"] as! Int64
                let published: Int64 = episodeJson["published"] as! Int64
                var dateInMillis = aired > 0 ? aired * 1000 : published * 1000
                episodeModel?.setDateInMillis(Double(aired))
            }

            let audio = media!["audio"] as! [[String: Any]]
            let audioItem = audio[0]
            let mediaDuration = audioItem["duration"] as! Int

            let audioData = audioItem["data"] as! [String: Any]
            let links = audioData["links"] as! [String: Any]
            let mp3 = links["mp3"] as! [String: Any]

            let mediaDownloadUrl = mp3["download"] as? String

            let mediaStreamUrl = mp3["html5"] as! String

            if let lsmTags = episodeJson["lsmTags"] as? [NSDictionary] {
                episodeModel?.setLsmTags(lsmTags)
            }
            if let newsBlocks = episodeJson["newsBlocks"] as? [NSDictionary] {
                episodeModel?.setNewsBlocks(newsBlocks)
            }
            if let containsCopyrightedMusic = episodeJson["containsCopyrightedMusic"] as? Bool {
                episodeModel?.setContainsCopyrightedMusic(containsCopyrightedMusic)
            }
            let url = episodeJson["url"] as? String


//            episodeModel = EpisodeModel(String(id))

            episodeModel?.setImageUrl(imageUrl)
            episodeModel?.setTitle(title)
//            episodeModel?.setDescription(description)
            episodeModel?.setCategoryName(categoryName)
            episodeModel?.setCategoryId(String(categoryId))
//            episodeModel?.setChannelId(channelId)
            //episodeModel?.setHosts(hosts)
//            episodeModel?.setBroadcastName(broadcastName)
//            episodeModel?.setBroadcastEmail(broadcastEmail)
//            episodeModel?.setDateInMillis(date)
            episodeModel?.setMediaDurationInSeconds(mediaDuration)
            episodeModel?.setMediaDownloadUrl(mediaDownloadUrl)
            episodeModel?.setMediaStreamUrl(mediaStreamUrl)
//            episodeModel?.setLsmTags(lsmTags)
//            episodeModel?.setNewsBlocks(newsBlocks)
//            episodeModel?.setContainsCopyrightedMusic(containsCopyrightedMusic)
            episodeModel?.setUrl(url)
        } else {
            let media = episodeJson["url"] as? String
            if (media != nil) {
                let id = episodeJson["id"] as? Int
                let imageUrl: String? = episodeJson["image"] as? String
                let title = episodeJson["name"] as? String
                let isActive = episodeJson["is_active"] as? String
                let updatedAt = episodeJson["updated_at"] as? String
                let mediaUrl = episodeJson["url"] as? String
                let contentType = episodeJson["content_type"] as? String
                let color = episodeJson["color"] as? String

                let dateFormatter = DateFormatter()
//                RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
//                RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
//                RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXX"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

                /* 39 minutes and 57 seconds after the 16th hour of December 19th, 1996 with an offset of -08:00 from UTC (Pacific Standard Time) */
                let string = updatedAt ?? "1996-12-19T16:39:57-08:00"
                let date = dateFormatter.date(from: string)?.timeIntervalSinceReferenceDate as? Double ?? 1093920923

                episodeModel = EpisodeModel(String(id ?? 0))
                episodeModel?.setImageUrl(imageUrl ?? "")
                episodeModel?.setTitle(title ?? "")
                episodeModel?.setDescription("")
                episodeModel?.setCategoryName("")
                episodeModel?.setCategoryId(String(id ?? 0))
                episodeModel?.setChannelId("")
                episodeModel?.setBroadcastName(title ?? "")
                episodeModel?.setDateInMillis(date)
                let audioAsset = AVURLAsset.init(url: URL(string: media!)!, options: nil)
                let duration = audioAsset.duration
                let durationInSeconds = CMTimeGetSeconds(duration)
                episodeModel?.setMediaDurationInSeconds(Int(durationInSeconds))
                episodeModel?.setMediaDownloadUrl(mediaUrl)
                episodeModel?.setMediaStreamUrl(mediaUrl ?? "")
                episodeModel?.setUrl(mediaUrl ?? "")
                episodeModel?.setColor(color ?? "")
            }
        }

        return episodeModel
    }


}
