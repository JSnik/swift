//
//  DynamicBlockModel.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class DynamicBlockModel: Codable {
    
    static let TAG = String(describing: DynamicBlockModel.self)

    private var name: String?
    private var presentationTypeId: String!
    private var contentType: String!
    private var items: [String]! // to conform to "Encodable", we keep json structures as strings, decoding them when needed
    
    init(_ name: String?, _ presentationTypeId: String, _ contentType: String){
        self.name = name
        self.presentationTypeId = presentationTypeId
        self.contentType = contentType
        
        items = [String]()
    }
    
    func getName() -> String? {
        return name
    }
    
    func getPresentationTypeId() -> String {
        return presentationTypeId
    }

    func getContentType() -> String {
        return contentType
    }

    func getItems() -> [[String: Any]] {
        var result = [[String: Any]]()
        
        for hostJsonString in items {
            if let data = hostJsonString.data(using: String.Encoding.utf8) {
                let hostJson = try? JSONSerialization.jsonObject(with: data, options: [])
                if let hostJson = hostJson as? [String: Any] {
                    result.append(hostJson)
                }
            }
        }

        return result
    }

    func setItems(_ hostsJson: [NSDictionary]) {
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
        
        self.items = result
    }
}
