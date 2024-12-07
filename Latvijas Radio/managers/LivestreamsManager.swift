//
//  LivestreamsManager.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class LivestreamsManager {
    
    static let TAG = String(describing: LivestreamsManager.self)
    
    static let TYPE_CLASSIC = "TYPE_CLASSIC"
    static let TYPE_INTERNET_CHANNEL = "TYPE_INTERNET_CHANNEL"
    
    // The numbers in ids represent the station ids in lr5 api, to get currently airing broadcast name.
    // Do not change existing ones, because if they are set in users custom list,
    // that list will see that channel as null because ids will differ.
    
    // classic
    static let ID_LATVIJAS_RADIO_1 = "1"
    static let ID_LATVIJAS_RADIO_2 = "2"
    static let ID_LATVIJAS_RADIO_3 = "3"
    static let ID_LATVIJAS_RADIO_4 = "4"
    static let ID_LATVIJAS_RADIO_5 = "5"
    static let ID_LATVIJAS_RADIO_6 = "6"
    static let ID_LATVIJAS_RADIO_RADIOTEATRIS = "999"
    
    // internet channels
    static let ID_PIECI_ZIEMASSVETKI = ""
    static let ID_PIECI_HITI = "ID_PIECI_HITI"
    static let ID_PIECI_LATVIESI = "ID_PIECI_LATVIESI"
    static let ID_PIECI_LATGALIESI = "ID_PIECI_LATGALIESI"
    static let ID_UKRAINAS_MUZIKA = "ID_UKRAINAS_MUZIKA"
    static let ID_PIECI_ATKLAJUMI = "ID_PIECI_ATKLAJUMI"
    static let ID_RITA_RADIO = "ID_RITA_RADIO"
    static let ID_LR2_VP = "ID_VECAS_PLATES"
    static let ID_LR_POP_UP = "ID_LR_POP_UP"

    private static var dataset = [RadioChannel]()
    private static var livestreamsClassic: [RadioChannel]! /*[LivestreamModel]!*/
    private static var livestreamsInternetChannels: [LivestreamModel]!

//    static func getLivestreamsClassic() -> /*[RadioChannel]*/ [LivestreamModel] {
//        if (LivestreamsManager.livestreamsClassic == nil) {
//            LivestreamsManager.livestreamsClassic = [LivestreamModel]()
//            
//            // Latvijas Radio 1
//            var id = LivestreamsManager.ID_LATVIJAS_RADIO_1
//            var name = "Latvijas Radio 1"
//            var title = "Latvijas radio 1 - vienmēr pirmais!"
//            var imageResourceId = ChannelsHelper.getImageDrawableIdFromChannelId(id)!
//            var wideImageResourceId = ImagesHelper.LOGO_WIDE_LATVIJAS_RADIO_1
//            var largeArtworkImageResourceId: String? = nil
//            var stationIdInMqttService: String? = nil
//            var streamUrl = "http://lr1mp1.latvijasradio.lv:8012"
//            
//            var livestreamModel = LivestreamModel(id, LivestreamsManager.TYPE_CLASSIC, name, title, imageResourceId, wideImageResourceId, largeArtworkImageResourceId, stationIdInMqttService, streamUrl, false)
//            LivestreamsManager.livestreamsClassic.append(livestreamModel)
//            
//            // Latvijas Radio 2
//            id = LivestreamsManager.ID_LATVIJAS_RADIO_2
//            name = "Latvijas Radio 2"
//            title = "Dziesmas dzimtajā valodā"
//            imageResourceId = ChannelsHelper.getImageDrawableIdFromChannelId(id)!
//            wideImageResourceId = ImagesHelper.LOGO_WIDE_LATVIJAS_RADIO_2
//            largeArtworkImageResourceId = nil
//            stationIdInMqttService = nil
//            streamUrl = "http://lr2mp1.latvijasradio.lv:8002"
//            
//            livestreamModel = LivestreamModel(id, LivestreamsManager.TYPE_CLASSIC, name, title, imageResourceId, wideImageResourceId, largeArtworkImageResourceId, stationIdInMqttService, streamUrl, false)
//            LivestreamsManager.livestreamsClassic.append(livestreamModel)
//            
//            // Latvijas Radio 3
//            id = LivestreamsManager.ID_LATVIJAS_RADIO_3
//            name = "Latvijas Radio 3 - Klasika"
//            title = "Mode mainās, klasika paliek!"
//            imageResourceId = ChannelsHelper.getImageDrawableIdFromChannelId(id)!
//            wideImageResourceId = ImagesHelper.LOGO_WIDE_LATVIJAS_RADIO_3
//            largeArtworkImageResourceId = nil
//            stationIdInMqttService = nil
//            streamUrl = "http://lr3mp0.latvijasradio.lv:8004"
//            
//            livestreamModel = LivestreamModel(id, LivestreamsManager.TYPE_CLASSIC, name, title, imageResourceId, wideImageResourceId, largeArtworkImageResourceId, stationIdInMqttService, streamUrl, false)
//            LivestreamsManager.livestreamsClassic.append(livestreamModel)
//            
//            // Latvijas Radio 4
//            id = LivestreamsManager.ID_LATVIJAS_RADIO_4
//            name = "Latvijas Radio 4 - DOMA LAUKUMS"
//            title = "Ваше пространство и Ваше время"
//            imageResourceId = ChannelsHelper.getImageDrawableIdFromChannelId(id)!
//            wideImageResourceId = ImagesHelper.LOGO_WIDE_LATVIJAS_RADIO_4
//            largeArtworkImageResourceId = nil
//            stationIdInMqttService = nil
//            streamUrl = "http://lr4mp1.latvijasradio.lv:8020"
//            
//            livestreamModel = LivestreamModel(id, LivestreamsManager.TYPE_CLASSIC, name, title, imageResourceId, wideImageResourceId, largeArtworkImageResourceId, stationIdInMqttService, streamUrl, false)
//            LivestreamsManager.livestreamsClassic.append(livestreamModel)
//            
//            // Latvijas Radio 5
//            id = LivestreamsManager.ID_LATVIJAS_RADIO_5
//            name = "Latvijas Radio 5"
//            title = "Radio, kas klausās"
//            imageResourceId = ChannelsHelper.getImageDrawableIdFromChannelId(id)!
//            wideImageResourceId = ImagesHelper.LOGO_WIDE_LATVIJAS_RADIO_5
//            largeArtworkImageResourceId = nil
//            stationIdInMqttService = "5"
//            //streamUrl = "https://live.pieci.lv/live19-hq.mp3" // alternative stream, has problems on some android devices (stops on 22nd minute mark)
//            streamUrl = "https://5a44e5b800a41.streamlock.net/pieci/mp4:k2/playlist.m3u8"
//            
//            livestreamModel = LivestreamModel(id, LivestreamsManager.TYPE_CLASSIC, name, title, imageResourceId, wideImageResourceId, largeArtworkImageResourceId, stationIdInMqttService, streamUrl, false)
//            LivestreamsManager.livestreamsClassic.append(livestreamModel)
//            
//            // Latvijas Radio 6
//            id = LivestreamsManager.ID_LATVIJAS_RADIO_6
//            name = "Radio Naba"
//            title = "Pagriez pasauli"
//            imageResourceId = ChannelsHelper.getImageDrawableIdFromChannelId(id)!
//            wideImageResourceId = ImagesHelper.LOGO_WIDE_LATVIJAS_RADIO_6
//            largeArtworkImageResourceId = nil
//            stationIdInMqttService = "6"
//            streamUrl = "https://5a44e5b800a41.streamlock.net/shoutcast/naba.stream/playlist.m3u8"
//            
//            livestreamModel = LivestreamModel(id, LivestreamsManager.TYPE_CLASSIC, name, title, imageResourceId, wideImageResourceId, largeArtworkImageResourceId, stationIdInMqttService, streamUrl, false)
//            LivestreamsManager.livestreamsClassic.append(livestreamModel)
//            
//            // Fake livestream - Radioteātris
//            id = LivestreamsManager.ID_LATVIJAS_RADIO_RADIOTEATRIS
//            name = "Radioteātris"
//            title = "Iestudējumi bērniem un pieaugušajiem"
//            imageResourceId = ChannelsHelper.getImageDrawableIdFromChannelId(id)!
//            wideImageResourceId = ImagesHelper.LOGO_WIDE_LATVIJAS_RADIO_RADIOTEATRIS
//            largeArtworkImageResourceId = nil
//            stationIdInMqttService = nil
//            streamUrl = ""
//            
//            livestreamModel = LivestreamModel(id, LivestreamsManager.TYPE_CLASSIC, name, title, imageResourceId, wideImageResourceId, largeArtworkImageResourceId, stationIdInMqttService, streamUrl, true)
//            LivestreamsManager.livestreamsClassic.append(livestreamModel)
//        }
//        
//        return LivestreamsManager.livestreamsClassic
//    }
    
    static func getLivestreamsInternetChannels() -> [LivestreamModel] {
        if (LivestreamsManager.livestreamsInternetChannels == nil) {
            LivestreamsManager.livestreamsInternetChannels = [LivestreamModel]()
            
            // Pieci Ziemassvētki
            var id = LivestreamsManager.ID_PIECI_ZIEMASSVETKI
            var name = "Pieci Ziemassvētki"
            var title = "Priecīgus Ziemassvētkus!"
            var imageResourceId = ImagesHelper.LOGO_INTERNET_CHANNEL_PIECI_ZIEMASSVETKI
            var wideImageResourceId = ImagesHelper.LOGO_WIDE_INTERNET_CHANNEL_PIECI_ZIEMASSVETKI
            var largeArtworkImageResourceId: String? = ImagesHelper.LOGO_INTERNET_CHANNEL_PIECI_ZIEMASSVETKI_LARGE_ARTWORK
            var stationIdInMqttService = "14"
            var streamUrl = "https://5a44e5b800a41.streamlock.net/pieci/mp4:k10/playlist.m3u8"
            
            var livestreamModel = LivestreamModel(id, LivestreamsManager.TYPE_INTERNET_CHANNEL, name, title, imageResourceId, wideImageResourceId, largeArtworkImageResourceId, stationIdInMqttService, streamUrl, false)
            LivestreamsManager.livestreamsInternetChannels.append(livestreamModel)
            
            
            // LR Svētku studija
            /*
            id = LivestreamsManager.ID_LR_POP_UP
            name = "Svētku studija"
            title = "Kopā būt, kopā just!"
            imageResourceId = ImagesHelper.LOGO_INTERNET_CHANNEL_LR_POP_UP
            wideImageResourceId = ImagesHelper.LOGO_WIDE_INTERNET_CHANNEL_LR_POP_UP
            largeArtworkImageResourceId = ImagesHelper.LOGO_INTERNET_CHANNEL_LR_POP_UP_LARGE_ARTWORK
            stationIdInMqttService = "15"
            streamUrl = "https://5a44e5b800a41.streamlock.net/pieci/mp4:k7/playlist.m3u8"
            
            livestreamModel = LivestreamModel(id, LivestreamsManager.TYPE_INTERNET_CHANNEL, name, title, imageResourceId, wideImageResourceId, largeArtworkImageResourceId, stationIdInMqttService, streamUrl, false)
            LivestreamsManager.livestreamsInternetChannels.append(livestreamModel)
            */
            
            // LR2 Līgo Muciņas
            /*
             id = LivestreamsManager.ID_LR_POP_UP
             name = "Līga muciņas"
             title = "Līga jauni, līgo veci!"
             imageResourceId = ImagesHelper.LOGO_INTERNET_CHANNEL_LR_POP_UP
             wideImageResourceId = ImagesHelper.LOGO_WIDE_INTERNET_CHANNEL_LR_POP_UP
             largeArtworkImageResourceId = ImagesHelper.LOGO_INTERNET_CHANNEL_LR_POP_UP_LARGE_ARTWORK
             stationIdInMqttService = "15"
             streamUrl = "https://5a44e5b800a41.streamlock.net/pieci/mp4:k7/playlist.m3u8"
             
             livestreamModel = LivestreamModel(id, LivestreamsManager.TYPE_INTERNET_CHANNEL, name, title, imageResourceId, wideImageResourceId, largeArtworkImageResourceId, stationIdInMqttService, streamUrl, false)
             LivestreamsManager.livestreamsInternetChannels.append(livestreamModel)
            */
            
            
            // Pieci Hiti
            id = LivestreamsManager.ID_PIECI_HITI
            name = "Pieci Hiti"
            title = "Pati aktuālākā mūzika"
            imageResourceId = ImagesHelper.LOGO_INTERNET_CHANNEL_PIECI_HITI
            wideImageResourceId = ImagesHelper.LOGO_WIDE_INTERNET_CHANNEL_PIECI_HITI
            largeArtworkImageResourceId = nil
            stationIdInMqttService = "10"
            streamUrl = "https://5a44e5b800a41.streamlock.net/pieci/mp4:k3/playlist.m3u8"
            
            livestreamModel = LivestreamModel(id, LivestreamsManager.TYPE_INTERNET_CHANNEL, name, title, imageResourceId, wideImageResourceId, largeArtworkImageResourceId, stationIdInMqttService, streamUrl, false)
            LivestreamsManager.livestreamsInternetChannels.append(livestreamModel)
            
            
            // Pieci Latvieši
            id = LivestreamsManager.ID_PIECI_LATVIESI
            name = "Pieci Latvieši"
            title = "Jaunākā latviešu mūzika"
            imageResourceId = ImagesHelper.LOGO_INTERNET_CHANNEL_PIECI_LATVIESI
            wideImageResourceId = ImagesHelper.LOGO_WIDE_INTERNET_CHANNEL_PIECI_LATVIESI
            largeArtworkImageResourceId = nil
            stationIdInMqttService = "8"
            streamUrl = "https://5a44e5b800a41.streamlock.net/pieci/mp4:k6/playlist.m3u8"
            
            livestreamModel = LivestreamModel(id, LivestreamsManager.TYPE_INTERNET_CHANNEL, name, title, imageResourceId, wideImageResourceId, largeArtworkImageResourceId, stationIdInMqttService, streamUrl, false)
            LivestreamsManager.livestreamsInternetChannels.append(livestreamModel)
            
            
            // Pieci Latgalieši
            id = LivestreamsManager.ID_PIECI_LATGALIESI
            name = "Pieci Latgalieši"
            title = "Dzīsmis latgalīšu volūdā"
            imageResourceId = ImagesHelper.LOGO_INTERNET_CHANNEL_PIECI_LATGALIESI
            wideImageResourceId = ImagesHelper.LOGO_WIDE_INTERNET_CHANNEL_PIECI_LATGALIESI
            largeArtworkImageResourceId = nil
            stationIdInMqttService = "13"
            streamUrl = "https://5a44e5b800a41.streamlock.net/pieci/mp4:k5/playlist.m3u8"
            
            livestreamModel = LivestreamModel(id, LivestreamsManager.TYPE_INTERNET_CHANNEL, name, title, imageResourceId, wideImageResourceId, largeArtworkImageResourceId, stationIdInMqttService, streamUrl, false)
            LivestreamsManager.livestreamsInternetChannels.append(livestreamModel)
            
            
            // Ukrainas mūzika
            id = LivestreamsManager.ID_UKRAINAS_MUZIKA
            name = "Ukrainas mūzika"
            title = "Mēs esam kopā!"
            imageResourceId = ImagesHelper.LOGO_INTERNET_CHANNEL_UKRAINAS_MUZIKA
            largeArtworkImageResourceId = nil
            wideImageResourceId = ImagesHelper.LOGO_WIDE_INTERNET_CHANNEL_UKRAINAS_MUZIKA
            stationIdInMqttService = "16"
            streamUrl = "https://5a44e5b800a41.streamlock.net/pieci/mp4:k9/playlist.m3u8"
            
            livestreamModel = LivestreamModel(id, LivestreamsManager.TYPE_INTERNET_CHANNEL, name, title, imageResourceId, wideImageResourceId, largeArtworkImageResourceId, stationIdInMqttService, streamUrl, false)
            LivestreamsManager.livestreamsInternetChannels.append(livestreamModel)
            
            
            // LR2 Vecās plates
            id = LivestreamsManager.ID_LR2_VP
            name = "Vecās plates"
            title = "Latviešu estrādes pērles"
            imageResourceId = ImagesHelper.LOGO_INTERNET_CHANNEL_LR_VP
            wideImageResourceId = ImagesHelper.LOGO_WIDE_INTERNET_CHANNEL_LR2_VP
            largeArtworkImageResourceId = nil
            stationIdInMqttService = "12"
            streamUrl = "https://5a44e5b800a41.streamlock.net/pieci/mp4:k4/playlist.m3u8"
            
            livestreamModel = LivestreamModel(id, LivestreamsManager.TYPE_INTERNET_CHANNEL, name, title, imageResourceId, wideImageResourceId, largeArtworkImageResourceId, stationIdInMqttService, streamUrl, false)
            LivestreamsManager.livestreamsInternetChannels.append(livestreamModel)
            
            
            // Pieci Atklājumi
            id = LivestreamsManager.ID_PIECI_ATKLAJUMI
            name = "Pieci Atklājumi"
            title = "Eksperimentālā un indie mūzika"
            imageResourceId = ImagesHelper.LOGO_INTERNET_CHANNEL_PIECI_ATKLAJUMI
            wideImageResourceId = ImagesHelper.LOGO_WIDE_INTERNET_CHANNEL_PIECI_ATKLAJUMI
            largeArtworkImageResourceId = nil
            stationIdInMqttService = "7"
            streamUrl = "https://5a44e5b800a41.streamlock.net/pieci/mp4:k1/playlist.m3u8"
            
            livestreamModel = LivestreamModel(id, LivestreamsManager.TYPE_INTERNET_CHANNEL, name, title, imageResourceId, wideImageResourceId, largeArtworkImageResourceId, stationIdInMqttService, streamUrl, false)
            LivestreamsManager.livestreamsInternetChannels.append(livestreamModel)
            
            
            // Rīta Radio
//            id = LivestreamsManager.ID_RITA_RADIO
//            name = "Rīta Radio"
//            title = "Rīta radio 24 stundas diennaktī"
//            imageResourceId = ImagesHelper.LOGO_INTERNET_CHANNEL_RITA_RADIO
//            wideImageResourceId = ImagesHelper.LOGO_WIDE_INTERNET_CHANNEL_RITA_RADIO
//            largeArtworkImageResourceId = nil
//            stationIdInMqttService = "9"
//            streamUrl = "https://5a44e5b800a41.streamlock.net/pieci/mp4:k8/playlist.m3u8"
//
//            livestreamModel = LivestreamModel(id, LivestreamsManager.TYPE_INTERNET_CHANNEL, name, title, imageResourceId, wideImageResourceId, largeArtworkImageResourceId, stationIdInMqttService, streamUrl, false)
//            LivestreamsManager.livestreamsInternetChannels.append(livestreamModel)
        }
        
        return LivestreamsManager.livestreamsInternetChannels
    }
    
    static func getLivestreamByIdFromAllChannels(_ lookUpLivestreamId: String /*, _ allLivestreams1: [RadioChannel]*/) -> RadioChannel?  /*LivestreamModel?*/ {
        var result: RadioChannel? //LivestreamModel?

//        var allLivestreams = [RadioChannel]() // [LivestreamModel]()
//        allLivestreams.append(contentsOf: getLivestreamsClassic())
//        allLivestreams.append(contentsOf: getLivestreamsInternetChannels())

        let d1 = readFromFile(fileName: "radioChannels1.json")
        do {
            if let data1 = d1 {
                dataset.removeAll()
                let someDictionaryFromJSON = try JSONSerialization.jsonObject(with: data1, options: .allowFragments) as! [String: Any]
                print("LivestreamsManager handleRadioChannelsResponse someDictionaryFromJSON = \(someDictionaryFromJSON)")
    //            let json4Swift_Base = try SearchSuccess(someDictionaryFromJSON)
                let jsonDecoder = JSONDecoder()
                let json4Swift_Base = try jsonDecoder.decode(ChannelsSuccess.self, from: data1)

                let radioChannels = json4Swift_Base.results
                //        let hits = data[SearchRequest.RESPONSE_PARAM_HITS] as! [[String: Any]]
                print("LivestreamsManager handleRadioChannelsResponse radioChannels = \(String(describing: radioChannels))")
                if (radioChannels?.count ?? 0 > 0) {
                    for i in (0..<(radioChannels?.count ?? 0)) {
                        if let radioChannel = radioChannels?[i] {
                            dataset.append(radioChannel)
                        }
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        var finalLivestreamsDataset: [RadioChannel] //[LivestreamModel]!
        var allLivestreams = [RadioChannel]()
        allLivestreams.append(contentsOf: dataset)

        for i in (0..<allLivestreams.count) {
            let livestreamModel = allLivestreams[i]

            if (livestreamModel.id /*getId()*/ == Int(lookUpLivestreamId)) {
                result = livestreamModel
                
                break
            }
        }
        
        return result
    }
    
    static func getOnlyPlayableLivestreams(_ livestreams: [RadioChannel] /*[LivestreamModel]*/) -> [RadioChannel] /*[LivestreamModel]*/ {
        var playableLivestreams = /*[LivestreamModel]*/ [RadioChannel]()

        for i in (0..<livestreams.count) {
            let livestreamModel = livestreams[i]

//            livestreamModel.name?.contains("Radioteātris") == false
//            if (!livestreamModel.getFakeLivestream()) {
            if (livestreamModel.name?.contains("Radioteātris") == false) {
                playableLivestreams.append(livestreamModel)
            }
        }
        
        return playableLivestreams
    }
    
    /**
     Get list either in default order or, if exists, in a user defined custom order.
     Adds new hardcoded livestreams at the end of the array.
     Makes sure unsupported livestreams (ones that were once saved to appData, but are no longer hardcoded) are excluded.
     */
    static func getOrderedList(_ currentUser: UserModel /*, _ allLivestreams1: [RadioChannel] */) -> [RadioChannel]  /*[LivestreamModel]*/ {
//        performRequestGetRadioChannels()


        let d1 = readFromFile(fileName: "radioChannels1.json")
        do {
            if let data1 = d1 {
                dataset.removeAll()
                let someDictionaryFromJSON = try JSONSerialization.jsonObject(with: data1, options: .allowFragments) as! [String: Any]
                print("LivestreamsManager handleRadioChannelsResponse someDictionaryFromJSON = \(someDictionaryFromJSON)")
    //            let json4Swift_Base = try SearchSuccess(someDictionaryFromJSON)
                let jsonDecoder = JSONDecoder()
                let json4Swift_Base = try jsonDecoder.decode(ChannelsSuccess.self, from: data1)

                let radioChannels = json4Swift_Base.results
                //        let hits = data[SearchRequest.RESPONSE_PARAM_HITS] as! [[String: Any]]
                print("LivestreamsManager handleRadioChannelsResponse radioChannels = \(String(describing: radioChannels))")
                if (radioChannels?.count ?? 0 > 0) {
                    for i in (0..<(radioChannels?.count ?? 0)) {
                        if let radioChannel = radioChannels?[i] {
                            dataset.append(radioChannel)
                        }
                    }
                    var finalLivestreamsDataset: [RadioChannel] //[LivestreamModel]!
                    var allLivestreams = [RadioChannel]()
                    allLivestreams.append(contentsOf: dataset)

            //        var allLivestreams = /*[LivestreamModel]*/ [RadioChannel]()
            //        allLivestreams.append(contentsOf: getLivestreamsClassic())
            //        allLivestreams.append(contentsOf: getLivestreamsInternetChannels())

                    if let livestreamIds = currentUser.getLivestreamsOrder() {
                        // Show livestreams in user specifier order.
                        var allLivestreamsInUserSpecifierOrder = [/*LivestreamModel*/ RadioChannel]()

                        for livestreamId in livestreamIds {
                            // The livestream might be null (not found), because it is not supported by app anymore.
                            if let livestreamModel = getLivestreamByIdFromAllChannels(livestreamId /*, allLivestreams*/) {
                                allLivestreamsInUserSpecifierOrder.append(livestreamModel)
                            }
                        }

                        // Make sure list contains all currently hardcoded livestreams.
                        for livestreamModel in allLivestreams {
                            if (!allLivestreamsInUserSpecifierOrder.contains(where: { $0.id /* getId()*/ == livestreamModel.id /*getId()*/ })) {
                                allLivestreamsInUserSpecifierOrder.append(livestreamModel)
                            }
                        }

                        finalLivestreamsDataset = allLivestreamsInUserSpecifierOrder
                    } else {
                        // Show livestreams in default order.
                        finalLivestreamsDataset = allLivestreams
                    }

                    return finalLivestreamsDataset
                }
            }
        } catch {
            print(error.localizedDescription)
            var allLivestreams = [RadioChannel]()
            allLivestreams.append(contentsOf: dataset)
            return allLivestreams
        }
        var allLivestreams = [RadioChannel]()
        allLivestreams.append(contentsOf: dataset)
        return allLivestreams
    }
    
    /**
     Properly adds/removes livestreams that are dynamic (admin can enable/disable them remotely).
     */
    static func getCuratedList(_ livestreams: [RadioChannel] /*[LivestreamModel]*/, _ isChristmasLivestreamCampaignEnabled: Bool) -> [RadioChannel] /*[LivestreamModel]*/ {
        var result = livestreams
        
        if let livestreamModel = getLivestreamByIdFromAllChannels(ID_PIECI_ZIEMASSVETKI /*, livestreams*/) /*!*/ {

            if (isChristmasLivestreamCampaignEnabled) {
                // Christmas livestream campaign is enabled and should show.
                // If it is not in provided livestreams array, append it.
                let index = getIndexOfLivestreamModelFromDatasetById(result, ID_PIECI_ZIEMASSVETKI)
                if (index == nil) {
                    result.append(livestreamModel)
                }
            } else {
                // Make sure the christmas livestream is not the resulting array
                if let index = getIndexOfLivestreamModelFromDatasetById(result, ID_PIECI_ZIEMASSVETKI) {
                    result.remove(at: index)
                }
            }
        }

        return result
    }
    
    static func getIndexOfLivestreamModelFromDatasetById(_ livestreams: [RadioChannel] /*[LivestreamModel]*/, _ lookUpId: String) -> Int? {
        var index: Int?
        
        for i in (0..<livestreams.count) {
            let livestreamModel = livestreams[i]
            
            if (livestreamModel.id /*getId()*/ == Int(lookUpId)) {
                index = i
                
                break
            }
        }
        
        return index
    }

    static func readFromFile(fileName: String) -> Data? {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            do {
                let content = try Data.init(contentsOf: fileURL) // try String(contentsOf: fileURL, encoding: .utf8)
                return content
            } catch {
                print("Failed to read file: \(error)")
            }
        }
        return nil
    }

}

