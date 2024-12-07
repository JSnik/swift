//
//  UIString+ParseHTML.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

extension Data {
    
    var htmlToAttributedString: NSAttributedString? {
        // TODO: causes 281 memory leaks. Problem in iOS:
        // https://developer.apple.com/forums/thread/715411
        // https://github.com/apple/swift-corelibs-foundation/issues/3574
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

extension String {
    
    var htmlToAttributedString: NSAttributedString? {
        return Data(utf8).htmlToAttributedString
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
