//
//  DateUtils.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class DateUtils {
    
    // https://stackoverflow.com/questions/35700281/date-format-in-swift
    private static let FORMAT_DATE_EXTENDED = "dd. MMMM, hh:mm"

    static func getTimelineFromSeconds(_ mediaDurationInSeconds: Int) -> String {
        let seconds: Int = mediaDurationInSeconds % 60
        let minutes: Int = (mediaDurationInSeconds / 60) % 60
        let hours: Int = mediaDurationInSeconds / 3600
        
        if (hours > 0) {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    static func getAppDateFromMillis(_ milliseconds: Double) -> String {
        let date = Date(timeIntervalSinceReferenceDate: milliseconds)

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: LanguageManager.getCurrentInterfaceLanguageId()!)
        dateFormatter.dateFormat = DateUtils.FORMAT_DATE_EXTENDED

        return dateFormatter.string(from: date)
    }
}
