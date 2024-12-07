//
//  UIString+Localized.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import Foundation

extension String {
    
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        // We might be accessing translation functionality when app is not started yet (ex. in push notifications).
        // Each target has its own "LanguageManager.currentInterfaceLanguageId" variable, so we can't use it here.
        
        let appInterfaceLanguage = GeneralUtils.getUserDefaults().string(forKey: LanguageManager.APP_INTERFACE_LANGUAGE)
        if (appInterfaceLanguage == nil) {
            LanguageManager.setupAppInterfaceLanguage()
        }

        // Get the file path for current language.
        guard let path = Bundle.main.path(forResource: appInterfaceLanguage, ofType: "lproj") else {
            return self
        }
        guard let bundle = Bundle(path: path) else {
            return self
        }

        return NSLocalizedString(self, tableName: tableName, bundle: bundle, value: "**\(self)**", comment: "")
    }
}
