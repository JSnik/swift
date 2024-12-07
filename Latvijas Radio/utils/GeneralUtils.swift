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
    
    static func getScreenWidth() -> CGFloat {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        return screenWidth
    }
    
    static func dpToPixels(_ dp: CGFloat) -> CGFloat {
        return dp * UIScreen.main.scale
    }
    
    static func getAppVersion(longVersion: Bool = false) -> String {
        let keyVersion = "CFBundleShortVersionString"
        let keyBuildNumber = "CFBundleVersion"
        
        let info = Bundle.main.infoDictionary!
        
        guard let version = info[keyVersion] as? String,
              let buildNumber = info[keyBuildNumber] as? String else {
            return "Unknown"
        }
        
        return longVersion ? "\(version).\(buildNumber)" : version
    }
    
    static func degreesToRadians(_ number: Double) -> Double {
        return number * .pi / 180
    }
    
    static func isAppInstalled(_ appName:String) -> Bool {
        let appScheme = "\(appName)://app"
        let appUrl = URL(string: appScheme)!

        if UIApplication.shared.canOpenURL(appUrl){
            return true
        } else {
            return false
        }
    }
}
