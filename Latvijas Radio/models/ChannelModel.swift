//
//  ChannelModel.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class ChannelModel: Codable {
    
    let id: String
    private var name: String!
    private var imageResourceId: String!

    init(
        _ id: String,
        _ name: String,
        _ imageResourceId: String
    ){
        self.id = id
        self.name = name
        self.imageResourceId = imageResourceId
    }
    
    func getId() -> String {
        return id
    }

    func getName() -> String {
        return name
    }

    func getImageResourceId() -> String {
        return imageResourceId
    }
}
