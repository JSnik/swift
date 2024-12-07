//
//  UIButtonNonary.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class UIButtonNonary: UIButtonBase {
   
    // MARK: Custom
    
    override func setStyle() {
        uppercase = false

        setBaseStyle()

        attributeContainer = AttributeContainer()
        let customFont = UIFont(name: FontsHelper.FUTURA_PT_BOOK, size: 10.0)
        attributeContainer.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont ?? UIFont.systemFont(ofSize: 10.0))
//        attributeContainer.font = UIFont(name: FontsHelper.FUTURA_PT_BOOK, size: 10.0)
        attributeContainer.foregroundColor = UIColor(named: ColorsHelper.BLACK)
        attributeContainer.underlineStyle = .single
        
        configuration?.contentInsets = NSDirectionalEdgeInsets(
            top: layer.borderWidth + 8,
            leading: layer.borderWidth + 8,
            bottom: layer.borderWidth + 8,
            trailing: layer.borderWidth + 8)
        
        // setup constraints
        var constraintWidth: NSLayoutConstraint?
        
        for constraint in constraints {
            if (constraint.firstAttribute == .width) {
                constraintWidth = constraint
            }
        }
        
        constraintWidth?.isActive = false
    }
}
