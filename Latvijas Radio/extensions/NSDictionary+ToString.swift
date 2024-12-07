//
//  NSDictionary+ToString.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import Foundation

extension NSDictionary {

    func toString() throws -> String? {
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(data: data, encoding: .utf8)
        }
        catch (let error){
            throw error
        }
    }
}
