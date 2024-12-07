//
//  ColorsHelper.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class ColorsHelper {

    static let BLACK = "lr-black"
    static let BLACK_5_PERCENT = "lr-black-5"
    static let BLACK_10_PERCENT = "lr-black-10"
    static let BLACK_50_PERCENT = "lr-black-50"
    static let CHANNEL_1 = "lr-lr1"
    static let CHANNEL_2 = "lr-lr2"
    static let CHANNEL_3 = "lr-lr3"
    static let CHANNEL_4 = "lr-lr4"
    static let CHANNEL_5 = "lr-lr5"
    static let CHANNEL_6 = "lr-lr6"
    static let CHANNEL_RADIOTEATRIS = "lr-rt"
    static let GRAY = "lr-gray"
    static let GRAY_2 = "gray2"
    static let GRAY_3 = "gray3"
    static let GRAY_4 = "gray4"
    static let GRAY_5 = "gray5"
    static let GRAY_6 = "gray6"
    static let GRAY_7 = "gray7"
    static let GREEN = "lr-green"
    static let RED = "lr-red"
    static let RED_50_PERCENT = "lr-red-50"
    static let WHITE = "lr-white"
    static let WHITE_50_PERCENT = "lr-white-50"
}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return UIColor.gray
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}
