//
//  ChannelsResult.swift
//  Latvijas Radio
//
//  Created by andriy kruglyanko on 04.11.2024.
//  Copyright © 2024 Latvijas Radio. All rights reserved.
//

struct ChannelsSuccess : Codable {
    let next : String?
    let previous : String?
    let results : [RadioChannel]?

    enum CodingKeys: String, CodingKey {

        case next = "next"
        case previous = "previous"
        case results = "results"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        next = try values.decodeIfPresent(String.self, forKey: .next)
        previous = try values.decodeIfPresent(String.self, forKey: .previous)
        results = try values.decodeIfPresent([RadioChannel].self, forKey: .results)
    }
}

// MARK: - RadioChannel
struct RadioChannel: Codable {
    var id : Int?
    var name : String?
    var display_name : String?
    let slogan : String?
    let color : String?
    var image : String?
    let streams : [Streams]?
    let have_mqtt : Bool?
    let is_active : Bool?
    let is_fm : Bool?
    let start_on : String?
    let end_on : String?
    let is_explicit : Bool?
    let supervisor : Int?
    let first_broadcast_date : String?
    var mobile : Mobile?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case name = "name"
        case display_name = "display_name"
        case slogan = "slogan"
        case color = "color"
        case image = "image"
        case streams = "streams"
        case have_mqtt = "have_mqtt"
        case is_active = "is_active"
        case is_fm = "is_fm"
        case start_on = "start_on"
        case end_on = "end_on"
        case is_explicit = "is_explicit"
        case supervisor = "supervisor"
        case first_broadcast_date = "first_broadcast_date"
        case mobile = "mobile"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        print("name = \(String(describing: name)) radiochannel")
        display_name = try values.decodeIfPresent(String.self, forKey: .display_name)
        slogan = try values.decodeIfPresent(String.self, forKey: .slogan)
        color = try values.decodeIfPresent(String.self, forKey: .color)
        image = try values.decodeIfPresent(String.self, forKey: .image)
        streams = try values.decodeIfPresent([Streams].self, forKey: .streams)
        have_mqtt = try values.decodeIfPresent(Bool.self, forKey: .have_mqtt)
        is_active = try values.decodeIfPresent(Bool.self, forKey: .is_active)
        is_fm = try values.decodeIfPresent(Bool.self, forKey: .is_fm)
        start_on = try values.decodeIfPresent(String.self, forKey: .start_on)
        end_on = try values.decodeIfPresent(String.self, forKey: .end_on)
        is_explicit = try values.decodeIfPresent(Bool.self, forKey: .is_explicit)
        supervisor = try values.decodeIfPresent(Int.self, forKey: .supervisor)
        first_broadcast_date = try values.decodeIfPresent(String.self, forKey: .first_broadcast_date)
        print("first_broadcast_date = \(String(describing: first_broadcast_date)) radiochannel")
        mobile = try values.decodeIfPresent(Mobile.self, forKey: .mobile)
    }

    func getMediaStreamUrl() -> String {
        return streams?.first?.url ?? ""
    }
}

struct Streams : Codable {
    let url : String?
    let content_type : String?
    let default_k : Bool?
    let is_default : Bool?

    enum CodingKeys: String, CodingKey {

        case url = "url"
        case content_type = "content_type"
        case default_k = "default"
        case is_default = "is_default"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        content_type = try values.decodeIfPresent(String.self, forKey: .content_type)
        default_k = try values.decodeIfPresent(Bool.self, forKey: .default_k)
        is_default = try values.decodeIfPresent(Bool.self, forKey: .is_default)
    }

}

struct Mobile : Codable {
    var square_image : String?
    var wide_image : String?

    enum CodingKeys: String, CodingKey {

        case square_image = "square_image"
        case wide_image = "wide_image"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        square_image = try values.decodeIfPresent(String.self, forKey: .square_image)
        wide_image = try values.decodeIfPresent(String.self, forKey: .wide_image)
    }

}
