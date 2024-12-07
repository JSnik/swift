//
//  UIButtonForgotPassword.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class UIButtonForgotPassword: UIButtonBase {
   
    // MARK: Custom
    
    override func setStyle() {
        uppercase = false
        
        setBaseStyle()
        
        attributeContainer = AttributeContainer()
        attributeContainer.font = UIFont(name: FontsHelper.FUTURA_PT_BOOK, size: 10.0)
        attributeContainer.foregroundColor = UIColor(named: ColorsHelper.GRAY_3)
        
        configuration?.contentInsets = NSDirectionalEdgeInsets(
            top: layer.borderWidth + 0,
            leading: layer.borderWidth + 0,
            bottom: layer.borderWidth + 0,
            trailing: layer.borderWidth + 0)
        
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
