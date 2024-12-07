//
//  UserDefaults+GetSetCustomObject.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

// This let's us save a custom object to userDefaults.
// Requirement: the custom object has to conform to Encodable/Decodable interfaces.

// Note: Json data, that do not contain any value that's "null", can be saved in userDefaults with the default approach, ex.:
// GeneralUtils.getUserDefaults().set(data, forKey: AuthenticationViewController.SETTINGS_FROM_API)

// However, if a single value in that json is "null", it will crash upon saving.
// We also cannot save it as a custom object, because it has to conform to Encodable protocol - it cannot contain any values of type "Any/AnyObject".
// So - to make a generic rule to guard against it - either never send "null" through API,
// or in our case - if dictionary is made from API json data, we save Json as a String, and upon retrieval we deserialize it.

// Example of saving Json to UserDefaults:

//do {
//    let jsonData = try JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions.prettyPrinted)
//    if let jsonString = String(data: jsonData, encoding: .utf8) {
//        GeneralUtils.getUserDefaults().set(jsonString, forKey: AuthenticationViewController.SETTINGS_FROM_API)
//    }
//
//} catch {
//    GeneralUtils.log(AuthenticationViewController.TAG, error.localizedDescription)
//}

// Example of retrieving Json from UserDefaults:

//if let settingsFromApiAsData = settingsFromApi.data(using: .utf8) {
//    let settingsFromApiJson = try? JSONSerialization.jsonObject(with: settingsFromApiAsData, options: [])
//    if let settingsFromApiJson = settingsFromApiJson as? [String: Any] {
//
//    }
//}

extension UserDefaults {
    
    func setCustomObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable {
        let data = try JSONEncoder().encode(object)
        self.set(data, forKey: forKey)
    }
    
    func getCustomObject<Object>(forKey: String, as type: Object.Type) throws -> Object? where Object: Decodable {
        guard let data = self.data(forKey: forKey) else {
            return nil
        }
        return try JSONDecoder().decode(type, from: data)
    }
}
