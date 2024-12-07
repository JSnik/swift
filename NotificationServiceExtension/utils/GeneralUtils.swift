//
//  GeneralUtils.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class GeneralUtils {

    static func getUserDefaults() -> UserDefaults {
        return UserDefaults(suiteName: Configuration.SHARED_USER_DEFAULTS_GROUP_ID)!
    }
    
    static func log(_ TAG: String, _ object: Any...) {
        #if DEBUG
        if (object.count == 1) {
            print(TAG, "|", object[0])
        } else {
            print(TAG, "|", object)
        }
        #endif
    }
}
