//
//  UITextFieldPrimary.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

@IBDesignable class UITextFieldPrimary: UITextFieldBase {

    override func setStyle() {
        setBaseStyle()

        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: defaultHeight - 1, width: frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor(named: ColorsHelper.GRAY_2, in: Bundle(for: type(of: self)), compatibleWith: self.traitCollection)!.cgColor
        layer.addSublayer(bottomLine)
    }
}
