//
//  ExternalLinkModel.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class ExternalLinkModel: Codable {
    
    static let TAG = String(describing: ExternalLinkModel.self)

    private let name: String
    private var link: String
    
    init(_ name: String, _ link: String){
        self.name = name
        self.link = link
    }
    
    func getName() -> String {
        return name
    }
    
    func getLink() -> String {
        return link
    }
}
