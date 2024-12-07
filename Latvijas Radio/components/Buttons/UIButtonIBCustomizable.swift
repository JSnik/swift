//
//  UIButtonIBCustomizable.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

@IBDesignable class UIButtonIBCustomizable: UIButtonBase {

    @IBInspectable override var uppercase: Bool {
        didSet {
            setText(originalTitle)
        }
    }

    override func setStyle() {
        attributeContainer = AttributeContainer()
//        attributeContainer.font = titleLabel?.font
        if let font1 = titleLabel?.font {
            attributeContainer.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: font1)
        }


    }
}
