//
//  LanguageManager.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class LanguageManager {
    
    static let TAG = String(describing: LanguageManager.self)
    
    static let APP_INTERFACE_LANGUAGE = "APP_INTERFACE_LANGUAGE"
    
    static let LANGUAGE_ID_LV = "lv"
    static let LANGUAGE_ID_RU = "ru"
    
    static let LANGUAGE_DISPLAY_NAME_LV = "LV"
    static let LANGUAGE_DISPLAY_NAME_RU = "RU"
    
    static var interfaceLanguages: [LanguageModel]!
    static let defaultInterfaceLanguageId = LANGUAGE_ID_LV
    static var currentInterfaceLanguageId: String?

    static func getLanguages() -> [LanguageModel] {
        if (LanguageManager.interfaceLanguages == nil) {
            LanguageManager.interfaceLanguages = [LanguageModel]()
            
            // lv
            var languageModel = LanguageModel(LanguageManager.LANGUAGE_ID_LV, LanguageManager.LANGUAGE_DISPLAY_NAME_LV)
            LanguageManager.interfaceLanguages.append(languageModel)
            
            // ru
            languageModel = LanguageModel(LanguageManager.LANGUAGE_ID_RU, LanguageManager.LANGUAGE_DISPLAY_NAME_RU)
            LanguageManager.interfaceLanguages.append(languageModel)
        }
        
        return LanguageManager.interfaceLanguages
    }
    
    static func setupAppInterfaceLanguage() {
        let appInterfaceLanguage = GeneralUtils.getUserDefaults().string(forKey: LanguageManager.APP_INTERFACE_LANGUAGE)
        if (appInterfaceLanguage != nil) {
            setLanguage(appInterfaceLanguage!)
        } else {
            setLanguage(LanguageManager.defaultInterfaceLanguageId)
        }
    }
    
    static func setLanguage(_ language: String) {
        GeneralUtils.getUserDefaults().set(language, forKey: LanguageManager.APP_INTERFACE_LANGUAGE)
        LanguageManager.currentInterfaceLanguageId = language
    }
    
    static func getCurrentInterfaceLanguageId() -> String? {
        if (currentInterfaceLanguageId == nil) {
            setupAppInterfaceLanguage()
        }
        
        return currentInterfaceLanguageId
    }
}

