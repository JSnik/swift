//
//  UILabelHtml.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

@IBDesignable class UILabelHtml: UILabel {
        
    // MARK: Custom

    func setText(_ textString: NSAttributedString) {
        let mutableAttributedString = NSMutableAttributedString(attributedString: textString)

        mutableAttributedString.addAttribute(
            NSAttributedString.Key.font,
            value: font as Any,
            range: NSRange(location: 0, length: textString.length)
        )
        
        mutableAttributedString.addAttribute(
            NSAttributedString.Key.foregroundColor,
            value: textColor as Any,
            range: NSRange(location: 0, length: textString.length)
        )
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        
        mutableAttributedString.addAttribute(
            NSAttributedString.Key.paragraphStyle,
            value: paragraphStyle as Any,
            range: NSRange(location: 0, length: textString.length)
        )
        
        attributedText = mutableAttributedString
    }
}
