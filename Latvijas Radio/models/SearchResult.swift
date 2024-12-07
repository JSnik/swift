//
//  SearchResult.swift
//  Latvijas Radio
//
//  Created by andriy kruglyanko on 19.10.2024.
//  Copyright © 2024 Latvijas Radio. All rights reserved.
//
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let searchSuccess = try? JSONDecoder().decode(SearchSuccess.self, from: jsonData)

import Foundation

// MARK: - SearchResult
struct SearchResult: Codable {
    var error: Bool?
    var data: SearchResultData?

//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        error = try values.decodeIfPresent(Bool.self, forKey: .error)
//        data = try values.decodeIfPresent(SearchResultData.self, forKey: .data)
//    }
}

// MARK: SearchResult convenience initializers and mutators

extension SearchResult {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(SearchResult.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        error: Bool?? = nil,
        data: SearchResultData?? = nil
    ) -> SearchResult {
        return SearchResult(
            error: error ?? self.error,
            data: data ?? self.data
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - SearchResultData
struct SearchResultData: Codable {
    var total: String?
    var items: [Item]?

    enum CodingKeys: String, CodingKey {

        case total = "total"
        case items = "items"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        total = try values.decodeIfPresent(String.self, forKey: .total)
        items = try values.decodeIfPresent([Item].self, forKey: .items)
    }
}

// MARK: SearchResultData convenience initializers and mutators

extension SearchResultData {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(SearchResultData.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

//    func with(
//        total: String?? = nil,
//        items: [Item]?? = nil
//    ) -> SearchResultData {
//        return SearchResultData(
//            total: total ?? self.total,
//            items: items ?? self.items
//        )
//    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Item
struct Item: Codable {
    var id: Int?
    var title: String?
    var aired, published, created: Int?
    var url: String?
    var lead: String?
    var lang: Lang?
    var catid: String?
    var comments, views: Int?
    var images: Images?
    var newsblocks: [Newsblock]?
    var category: Category?
    var channel: Int?
    var media: Media?
    var properties: [String]?
    var lsmTags: [LsmTag]?
    var youtubeLink: String?

    enum CodingKeys: String, CodingKey {
        case id, title, aired, published, created, url, lead, lang, catid, comments, views, images, newsblocks, category, channel, media, properties
        case lsmTags = "lsm_tags"
        case youtubeLink = "youtube_link"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        aired = try values.decodeIfPresent(Int.self, forKey: .aired)
        published = try values.decodeIfPresent(Int.self, forKey: .published)
        created = try values.decodeIfPresent(Int.self, forKey: .created)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        lead = try values.decodeIfPresent(String.self, forKey: .lead)
        lang = try values.decodeIfPresent(Lang.self, forKey: .lang)
        catid = try values.decodeIfPresent(String.self, forKey: .catid)
        comments = try values.decodeIfPresent(Int.self, forKey: .comments)
        views = try values.decodeIfPresent(Int.self, forKey: .views)
        images = try values.decodeIfPresent(Images.self, forKey: .images)
        newsblocks = try values.decodeIfPresent([Newsblock].self, forKey: .newsblocks)
        category = try values.decodeIfPresent(Category.self, forKey: .category)
        channel = try values.decodeIfPresent(Int.self, forKey: .channel)
        media = try values.decodeIfPresent(Media.self, forKey: .media)
        properties = try values.decodeIfPresent([String].self, forKey: .properties)
        lsmTags = try values.decodeIfPresent([LsmTag].self, forKey: .lsmTags)
        youtubeLink = try values.decodeIfPresent(String.self, forKey: .youtubeLink)
    }
}

// MARK: Item convenience initializers and mutators

extension Item {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Item.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

//    func with(
//        id: Int?? = nil,
//        title: String?? = nil,
//        aired: Int?? = nil,
//        published: Int?? = nil,
//        created: Int?? = nil,
//        url: String?? = nil,
//        lead: String?? = nil,
//        lang: Lang?? = nil,
//        catid: String?? = nil,
//        comments: Int?? = nil,
//        views: Int?? = nil,
//        images: Images?? = nil,
//        newsblocks: [Newsblock]?? = nil,
//        category: Category?? = nil,
//        channel: Int?? = nil,
//        media: Media?? = nil,
//        properties: [String]?? = nil,
//        lsmTags: [LsmTag]?? = nil,
//        youtubeLink: JSONNull?? = nil
//    ) -> Item {
//        return Item(
//            id: id ?? self.id,
//            title: title ?? self.title,
//            aired: aired ?? self.aired,
//            published: published ?? self.published,
//            created: created ?? self.created,
//            url: url ?? self.url,
//            lead: lead ?? self.lead,
//            lang: lang ?? self.lang,
//            catid: catid ?? self.catid,
//            comments: comments ?? self.comments,
//            views: views ?? self.views,
//            images: images ?? self.images,
//            newsblocks: newsblocks ?? self.newsblocks,
//            category: category ?? self.category,
//            channel: channel ?? self.channel,
//            media: media ?? self.media,
//            properties: properties ?? self.properties,
//            lsmTags: lsmTags ?? self.lsmTags,
//            youtubeLink: youtubeLink ?? self.youtubeLink
//        )
//    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Category
struct Category: Codable {
    var id: Int?
    var title, channel: String?
    var link: String?
    var descr, airInfo: String?
    var email: String?
    var phone: String?
    var theme, status: Int?
    var logo: String?
    var poster: String?
    var hosts: [Host]?
    var categories: [Newsblock]?
    var keywords: [JSONAny]?

    enum CodingKeys: String, CodingKey {
        case id, title, channel, link, descr
        case airInfo = "air_info"
        case email, phone, theme, status, logo, poster, hosts, categories, keywords
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        channel = try values.decodeIfPresent(String.self, forKey: .channel)
        link = try values.decodeIfPresent(String.self, forKey: .link)
        descr = try values.decodeIfPresent(String.self, forKey: .descr)
        airInfo = try values.decodeIfPresent(String.self, forKey: .airInfo)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        phone = try values.decodeIfPresent(String.self, forKey: .phone)
        theme = try values.decodeIfPresent(Int.self, forKey: .theme)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
        logo = try values.decodeIfPresent(String.self, forKey: .logo)
        poster = try values.decodeIfPresent(String.self, forKey: .poster)
        hosts = try values.decodeIfPresent([Host].self, forKey: .hosts)
        categories = try values.decodeIfPresent([Newsblock].self, forKey: .categories)
        keywords = try values.decodeIfPresent([JSONAny].self, forKey: .keywords)
    }
}

enum Lang: String, Codable {
    case lv = "lv"
}

struct Categories : Codable {
    let id : String?
    let title : String?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case title = "title"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        title = try values.decodeIfPresent(String.self, forKey: .title)
    }

}

// MARK: - Newsblock
struct Newsblock: Codable {
    let id, title: String
}

struct Media : Codable {
    let audio : [Audio]?

    enum CodingKeys: String, CodingKey {

        case audio = "audio"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        audio = try values.decodeIfPresent([Audio].self, forKey: .audio)
    }

}

// MARK: - LsmTag
struct LsmTag: Codable {
    let id: Int
    let title: String

    enum CodingKeys: String, CodingKey {
        case id, title
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id) ?? 0
        title = try values.decodeIfPresent(String.self, forKey: .title) ?? ""
    }
}

struct Images : Codable {
    let gallery : String?
    let large : String?
    let mlarge : String?
    let msmall : String?
    let original : String?
    let small : String?
    let square : String?
    let xlarge : String?

    enum CodingKeys: String, CodingKey {

        case gallery = "gallery"
        case large = "large"
        case mlarge = "mlarge"
        case msmall = "msmall"
        case original = "original"
        case small = "small"
        case square = "square"
        case xlarge = "xlarge"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        gallery = try values.decodeIfPresent(String.self, forKey: .gallery)
        large = try values.decodeIfPresent(String.self, forKey: .large)
        mlarge = try values.decodeIfPresent(String.self, forKey: .mlarge)
        msmall = try values.decodeIfPresent(String.self, forKey: .msmall)
        original = try values.decodeIfPresent(String.self, forKey: .original)
        small = try values.decodeIfPresent(String.self, forKey: .small)
        square = try values.decodeIfPresent(String.self, forKey: .square)
        xlarge = try values.decodeIfPresent(String.self, forKey: .xlarge)
    }

}

struct Audio : Codable {
    let id : Int?
    let type : String?
    let duration : Int?
    let data : Data?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case type = "type"
        case duration = "duration"
        case data = "data"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        duration = try values.decodeIfPresent(Int.self, forKey: .duration)
        data = try values.decodeIfPresent(Data.self, forKey: .data)
    }

}

// MARK: - SearchSuccess
struct SearchSuccess: Codable {
    var facetCounts: [JSONAny]?
    var found: Int?
    var hits: [Hit]?
    var outOf, page: Int?
    var requestParams: RequestParams?
    var searchCutoff: Bool?
    var searchTimeMS: Int?

    enum CodingKeys: String, CodingKey {
        case facetCounts = "facet_counts"
        case found, hits
        case outOf = "out_of"
        case page
        case requestParams = "request_params"
        case searchCutoff = "search_cutoff"
        case searchTimeMS = "search_time_ms"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        facetCounts = try values.decodeIfPresent([JSONAny].self, forKey: .facetCounts)
        found = try values.decodeIfPresent(Int.self, forKey: .found)
        hits = try values.decodeIfPresent([Hit].self, forKey: .hits)
        outOf = try values.decodeIfPresent(Int.self, forKey: .outOf)
        page = try values.decodeIfPresent(Int.self, forKey: .page)
        requestParams = try values.decodeIfPresent(RequestParams.self, forKey: .requestParams)
        searchCutoff = try values.decodeIfPresent(Bool.self, forKey: .searchCutoff)
        searchTimeMS = try values.decodeIfPresent(Int.self, forKey: .searchTimeMS)
        print("searchTimeMS = \(searchTimeMS)")
    }
}

struct Host : Codable {
    let name : String?
    let url : String?

    enum CodingKeys: String, CodingKey {

        case name = "name"
        case url = "url"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        url = try values.decodeIfPresent(String.self, forKey: .url)
    }

}

// MARK: SearchSuccess convenience initializers and mutators

extension SearchSuccess {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(SearchSuccess.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

//    func with(
//        facetCounts: [JSONAny]?? = nil,
//        found: Int?? = nil,
//        hits: [JSONAny]?? = nil,
//        outOf: Int?? = nil,
//        page: Int?? = nil,
//        requestParams: RequestParams?? = nil,
//        searchCutoff: Bool?? = nil,
//        searchTimeMS: Int?? = nil
//    ) -> SearchSuccess {
//        return SearchSuccess(
//            facetCounts: facetCounts ?? self.facetCounts,
//            found: found ?? self.found,
//            hits: hits ?? self.hits,
//            outOf: outOf ?? self.outOf,
//            page: page ?? self.page,
//            requestParams: requestParams ?? self.requestParams,
//            searchCutoff: searchCutoff ?? self.searchCutoff,
//            searchTimeMS: searchTimeMS ?? self.searchTimeMS
//        )
//    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Hit
struct Hit: Codable {
    var document: Document?
    var highlight: PurpleHighlight?
    var highlights: [HighlightElement]?
    var textMatch: Double?
    var textMatchInfo: TextMatchInfo?

    enum CodingKeys: String, CodingKey {
        case document, highlight, highlights
        case textMatch = "text_match"
        case textMatchInfo = "text_match_info"
    }
}

// MARK: Hit convenience initializers and mutators

extension Hit {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Hit.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        document = try values.decodeIfPresent(Document.self, forKey: .document)
        highlight = try values.decodeIfPresent(PurpleHighlight.self, forKey: .highlight)
        highlights = try values.decodeIfPresent([HighlightElement].self, forKey: .highlights)
        textMatch = try values.decodeIfPresent(Double.self, forKey: .textMatch)
        textMatchInfo = try values.decodeIfPresent(TextMatchInfo.self, forKey: .textMatchInfo)
        print("textMatchInfo = \(textMatchInfo)")
    }

/*
    func with(
        document: Document?? = nil,
        highlight: PurpleHighlight?? = nil,
        highlights: [HighlightElement]?? = nil,
        textMatch: Double?? = nil,
        textMatchInfo: TextMatchInfo?? = nil
    ) -> Hit {
        return Hit(
            document: document ?? self.document,
            highlight: highlight ?? self.highlight,
            highlights: highlights ?? self.highlights,
            textMatch: textMatch ?? self.textMatch,
            textMatchInfo: textMatchInfo ?? self.textMatchInfo
        )
    }
*/

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Document
struct Document: Codable {
    var authors, categories: [String]?
    var description, documentType, episodeTitle, id: String?
    var image: String?
    var showName: String?

    enum CodingKeys: String, CodingKey {
        case authors, categories, description
        case documentType = "document_type"
        case episodeTitle = "episode_title"
        case id, image
        case showName = "show_name"
    }
}

// MARK: Document convenience initializers and mutators

extension Document {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Document.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        authors = try values.decodeIfPresent([String].self, forKey: .authors)
        categories = try values.decodeIfPresent([String].self, forKey: .categories)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        documentType = try values.decodeIfPresent(String.self, forKey: .documentType)
        episodeTitle = try values.decodeIfPresent(String.self, forKey: .episodeTitle)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        image = try values.decodeIfPresent(String.self, forKey: .image)
        showName = try values.decodeIfPresent(String.self, forKey: .showName)
        print("showName = \(showName)")
    }

    /*func with(
        authors: [String]?? = nil,
        categories: [String]?? = nil,
        description: String?? = nil,
        documentType: String?? = nil,
        episodeTitle: String?? = nil,
        id: String?? = nil,
        image: String?? = nil,
        showName: String?? = nil
    ) -> Document {
        return Document(
            authors: authors ?? self.authors,
            categories: categories ?? self.categories,
            description: description ?? self.description,
            documentType: documentType ?? self.documentType,
            episodeTitle: episodeTitle ?? self.episodeTitle,
            id: id ?? self.id,
            image: image ?? self.image,
            showName: showName ?? self.showName
        )
    }*/

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - PurpleHighlight
struct PurpleHighlight: Codable {
    var authors: [Description]?
    var description, episodeTitle: Description?

    enum CodingKeys: String, CodingKey {
        case authors, description
        case episodeTitle = "episode_title"
    }
}

// MARK: PurpleHighlight convenience initializers and mutators

extension PurpleHighlight {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(PurpleHighlight.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        authors = try values.decodeIfPresent([Description].self, forKey: .authors)
        description = try values.decodeIfPresent(Description.self, forKey: .description)
        episodeTitle = try values.decodeIfPresent(Description.self, forKey: .episodeTitle)
        print("episodeTitle = \(episodeTitle)")
    }

    /*func with(
        authors: [Description]?? = nil,
        description: Description?? = nil,
        episodeTitle: Description?? = nil
    ) -> PurpleHighlight {
        return PurpleHighlight(
            authors: authors ?? self.authors,
            description: description ?? self.description,
            episodeTitle: episodeTitle ?? self.episodeTitle
        )
    }*/

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Description
struct Description: Codable {
    var matchedTokens: [String]?
    var snippet: String?

    enum CodingKeys: String, CodingKey {
        case matchedTokens = "matched_tokens"
        case snippet
    }
}

// MARK: Description convenience initializers and mutators

extension Description {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Description.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        matchedTokens = try values.decodeIfPresent([String].self, forKey: .matchedTokens)
        snippet = try values.decodeIfPresent(String.self, forKey: .snippet)
        print("snippet = \(snippet)")
    }

//    func with(
//        matchedTokens: [FirstQ]?? = nil,
//        snippet: String?? = nil
//    ) -> Description {
//        return Description(
//            matchedTokens: matchedTokens ?? self.matchedTokens,
//            snippet: snippet ?? self.snippet
//        )
//    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

enum FirstQ: String, Codable {
    case a = "A"
    case firstQA = "a"
    case ā = "Ā"
}

// MARK: - HighlightElement
struct HighlightElement: Codable {
    var field: String? //Field?
    var matchedTokens: [JSONAny]?
    var snippet: String?
    var indices: [Int]?
    var snippets: [String]?

    enum CodingKeys: String, CodingKey {
        case field
        case matchedTokens = "matched_tokens"
        case snippet, indices, snippets
    }
}

// MARK: HighlightElement convenience initializers and mutators

extension HighlightElement {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(HighlightElement.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        field = try values.decodeIfPresent(String.self, forKey: .field)
        print("field = \(field)")
        matchedTokens = try values.decodeIfPresent([JSONAny].self, forKey: .matchedTokens)
        print("matchedTokens = \(matchedTokens)")
        snippet = try values.decodeIfPresent(String.self, forKey: .snippet)
        print("snippet = \(snippet)")
        snippets = try values.decodeIfPresent([String].self, forKey: .snippets)
        print("snippets = \(snippets)")
        indices = try values.decodeIfPresent([Int].self, forKey: .indices)
        print("indices = \(indices)")
    }

//    func with(
//        field: Field?? = nil,
//        matchedTokens: [MatchedToken]?? = nil,
//        snippet: String?? = nil,
//        indices: [Int]?? = nil,
//        snippets: [String]?? = nil
//    ) -> HighlightElement {
//        return HighlightElement(
//            field: field ?? self.field,
//            matchedTokens: matchedTokens ?? self.matchedTokens,
//            snippet: snippet ?? self.snippet,
//            indices: indices ?? self.indices,
//            snippets: snippets ?? self.snippets
//        )
//    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

enum Field: String, Codable {
    case authors = "authors"
    case description = "description"
    case episodeTitle = "episode_title"
}

enum MatchedToken: Codable {
    case enumArray([FirstQ])
    case enumeration(FirstQ)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode([FirstQ].self) {
            self = .enumArray(x)
            return
        }
        if let x = try? container.decode(FirstQ.self) {
            self = .enumeration(x)
            return
        }
        throw DecodingError.typeMismatch(MatchedToken.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for MatchedToken"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .enumArray(let x):
            try container.encode(x)
        case .enumeration(let x):
            try container.encode(x)
        }
    }
}

// MARK: - TextMatchInfo
struct TextMatchInfo: Codable {
    var bestFieldScore: String?
    var bestFieldWeight, fieldsMatched, numTokensDropped: Int?
    var score: String?
    var tokensMatched, typoPrefixScore: Int?

    enum CodingKeys: String, CodingKey {
        case bestFieldScore = "best_field_score"
        case bestFieldWeight = "best_field_weight"
        case fieldsMatched = "fields_matched"
        case numTokensDropped = "num_tokens_dropped"
        case score
        case tokensMatched = "tokens_matched"
        case typoPrefixScore = "typo_prefix_score"
    }
}

// MARK: TextMatchInfo convenience initializers and mutators

extension TextMatchInfo {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(TextMatchInfo.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        bestFieldScore = try values.decodeIfPresent(String.self, forKey: .bestFieldScore)
        bestFieldWeight = try values.decodeIfPresent(Int.self, forKey: .bestFieldWeight)
        fieldsMatched = try values.decodeIfPresent(Int.self, forKey: .fieldsMatched)
        numTokensDropped = try values.decodeIfPresent(Int.self, forKey: .numTokensDropped)
        score = try values.decodeIfPresent(String.self, forKey: .score)
        tokensMatched = try values.decodeIfPresent(Int.self, forKey: .tokensMatched)
        typoPrefixScore = try values.decodeIfPresent(Int.self, forKey: .typoPrefixScore)
        print("typoPrefixScore = \(typoPrefixScore)")
    }

//    func with(
//        bestFieldScore: String?? = nil,
//        bestFieldWeight: Int?? = nil,
//        fieldsMatched: Int?? = nil,
//        numTokensDropped: Int?? = nil,
//        score: String?? = nil,
//        tokensMatched: Int?? = nil,
//        typoPrefixScore: Int?? = nil
//    ) -> TextMatchInfo {
//        return TextMatchInfo(
//            bestFieldScore: bestFieldScore ?? self.bestFieldScore,
//            bestFieldWeight: bestFieldWeight ?? self.bestFieldWeight,
//            fieldsMatched: fieldsMatched ?? self.fieldsMatched,
//            numTokensDropped: numTokensDropped ?? self.numTokensDropped,
//            score: score ?? self.score,
//            tokensMatched: tokensMatched ?? self.tokensMatched,
//            typoPrefixScore: typoPrefixScore ?? self.typoPrefixScore
//        )
//    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - RequestParams
struct RequestParams: Codable {
    var collectionName: String?
    var firstQ: String?
    var perPage: Int?
    var q: String?

    enum CodingKeys: String, CodingKey {
        case collectionName = "collection_name"
        case firstQ = "first_q"
        case perPage = "per_page"
        case q
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        collectionName = try values.decodeIfPresent(String.self, forKey: .collectionName)
        firstQ = try values.decodeIfPresent(String.self, forKey: .firstQ)
        perPage = try values.decodeIfPresent(Int.self, forKey: .perPage)
        q = try values.decodeIfPresent(String.self, forKey: .q)
        print("q = \(q)")
    }
}

// MARK: RequestParams convenience initializers and mutators

extension RequestParams {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(RequestParams.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

//    func with(
//        collectionName: String?? = nil,
//        firstQ: String?? = nil,
//        perPage: Int?? = nil,
//        q: String?? = nil
//    ) -> RequestParams {
//        return RequestParams(
//            collectionName: collectionName ?? self.collectionName,
//            firstQ: firstQ ?? self.firstQ,
//            perPage: perPage ?? self.perPage,
//            q: q ?? self.q
//        )
//    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
            return true
    }

    public var hashValue: Int {
            return 0
    }

    public func hash(into hasher: inout Hasher) {
            // No-op
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if !container.decodeNil() {
                    throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
            }
    }

    public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encodeNil()
    }
}

class JSONCodingKey: CodingKey {
    let key: String

    required init?(intValue: Int) {
            return nil
    }

    required init?(stringValue: String) {
            key = stringValue
    }

    var intValue: Int? {
            return nil
    }

    var stringValue: String {
            return key
    }
}

class JSONAny: Codable {

    let value: Any

    static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
            return DecodingError.typeMismatch(JSONAny.self, context)
    }

    static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
            let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
            return EncodingError.invalidValue(value, context)
    }

    static func decode(from container: SingleValueDecodingContainer) throws -> Any {
            if let value = try? container.decode(Bool.self) {
                    return value
            }
            if let value = try? container.decode(Int64.self) {
                    return value
            }
            if let value = try? container.decode(Double.self) {
                    return value
            }
            if let value = try? container.decode(String.self) {
                    return value
            }
            if container.decodeNil() {
                    return JSONNull()
            }
            throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
            if let value = try? container.decode(Bool.self) {
                    return value
            }
            if let value = try? container.decode(Int64.self) {
                    return value
            }
            if let value = try? container.decode(Double.self) {
                    return value
            }
            if let value = try? container.decode(String.self) {
                    return value
            }
            if let value = try? container.decodeNil() {
                    if value {
                            return JSONNull()
                    }
            }
            if var container = try? container.nestedUnkeyedContainer() {
                    return try decodeArray(from: &container)
            }
            if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
                    return try decodeDictionary(from: &container)
            }
            throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
            if let value = try? container.decode(Bool.self, forKey: key) {
                    return value
            }
            if let value = try? container.decode(Int64.self, forKey: key) {
                    return value
            }
            if let value = try? container.decode(Double.self, forKey: key) {
                    return value
            }
            if let value = try? container.decode(String.self, forKey: key) {
                    return value
            }
            if let value = try? container.decodeNil(forKey: key) {
                    if value {
                            return JSONNull()
                    }
            }
            if var container = try? container.nestedUnkeyedContainer(forKey: key) {
                    return try decodeArray(from: &container)
            }
            if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
                    return try decodeDictionary(from: &container)
            }
            throw decodingError(forCodingPath: container.codingPath)
    }

    static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
            var arr: [Any] = []
            while !container.isAtEnd {
                    let value = try decode(from: &container)
                    arr.append(value)
            }
            return arr
    }

    static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
            var dict = [String: Any]()
            for key in container.allKeys {
                    let value = try decode(from: &container, forKey: key)
                    dict[key.stringValue] = value
            }
            return dict
    }

    static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
            for value in array {
                    if let value = value as? Bool {
                            try container.encode(value)
                    } else if let value = value as? Int64 {
                            try container.encode(value)
                    } else if let value = value as? Double {
                            try container.encode(value)
                    } else if let value = value as? String {
                            try container.encode(value)
                    } else if value is JSONNull {
                            try container.encodeNil()
                    } else if let value = value as? [Any] {
                            var container = container.nestedUnkeyedContainer()
                            try encode(to: &container, array: value)
                    } else if let value = value as? [String: Any] {
                            var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                            try encode(to: &container, dictionary: value)
                    } else {
                            throw encodingError(forValue: value, codingPath: container.codingPath)
                    }
            }
    }

    static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
            for (key, value) in dictionary {
                    let key = JSONCodingKey(stringValue: key)!
                    if let value = value as? Bool {
                            try container.encode(value, forKey: key)
                    } else if let value = value as? Int64 {
                            try container.encode(value, forKey: key)
                    } else if let value = value as? Double {
                            try container.encode(value, forKey: key)
                    } else if let value = value as? String {
                            try container.encode(value, forKey: key)
                    } else if value is JSONNull {
                            try container.encodeNil(forKey: key)
                    } else if let value = value as? [Any] {
                            var container = container.nestedUnkeyedContainer(forKey: key)
                            try encode(to: &container, array: value)
                    } else if let value = value as? [String: Any] {
                            var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                            try encode(to: &container, dictionary: value)
                    } else {
                            throw encodingError(forValue: value, codingPath: container.codingPath)
                    }
            }
    }

    static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
            if let value = value as? Bool {
                    try container.encode(value)
            } else if let value = value as? Int64 {
                    try container.encode(value)
            } else if let value = value as? Double {
                    try container.encode(value)
            } else if let value = value as? String {
                    try container.encode(value)
            } else if value is JSONNull {
                    try container.encodeNil()
            } else {
                    throw encodingError(forValue: value, codingPath: container.codingPath)
            }
    }

    public required init(from decoder: Decoder) throws {
            if var arrayContainer = try? decoder.unkeyedContainer() {
                    self.value = try JSONAny.decodeArray(from: &arrayContainer)
            } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
                    self.value = try JSONAny.decodeDictionary(from: &container)
            } else {
                    let container = try decoder.singleValueContainer()
                    self.value = try JSONAny.decode(from: container)
            }
    }

    public func encode(to encoder: Encoder) throws {
            if let arr = self.value as? [Any] {
                    var container = encoder.unkeyedContainer()
                    try JSONAny.encode(to: &container, array: arr)
            } else if let dict = self.value as? [String: Any] {
                    var container = encoder.container(keyedBy: JSONCodingKey.self)
                    try JSONAny.encode(to: &container, dictionary: dict)
            } else {
                    var container = encoder.singleValueContainer()
                    try JSONAny.encode(to: &container, value: self.value)
            }
    }
}
