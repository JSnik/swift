//
//  GenericDropdownItemModel.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class GenericDropdownItemModel {
    
    static let TAG = String(describing: GenericDropdownItemModel.self)

    private let id: String
    private var title: String
    private var object: Any

    init(_ id: String, _ title: String, _ object: Any){
        self.id = id
        self.title = title
        self.object = object
    }
    
    func getId() -> String {
        return id
    }

    func getTitle() -> String {
        return title
    }

    func getObject() -> Any {
        return object
    }
}
