//
//  UIButtonXI.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 12/08/2022.
//

import UIKit

class UIButtonXI: UIButtonBase {
   
    // MARK: Custom
    
    override func setStyle() {
        setBaseStyle()
        
        attributeContainer = AttributeContainer()
        attributeContainer.font = UIFont(name: FontsHelper.FUTURA_PT_DEMI, size: 14.0)
        attributeContainer.foregroundColor = UIColor(named: ColorsHelper.BLACK)

        configuration?.contentInsets = NSDirectionalEdgeInsets(
            top: layer.borderWidth + 0,
            leading: layer.borderWidth + 16,
            bottom: layer.borderWidth + 0,
            trailing: layer.borderWidth + 16)
        
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
