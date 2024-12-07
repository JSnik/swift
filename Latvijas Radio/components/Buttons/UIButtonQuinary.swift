//
//  UIButtonQuinary.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class UIButtonQuinary: UIButtonBase {
   
    // MARK: Custom
    
    override func setStyle() {
        uppercase = false

        let imagePlacement = configuration?.imagePlacement
        
        setBaseStyle()
        
        attributeContainer = AttributeContainer()
        attributeContainer.font = UIFont(name: FontsHelper.FUTURA_PT_MEDIUM, size: 13.0)
        attributeContainer.foregroundColor = UIColor(named: ColorsHelper.BLACK)
        
        configuration?.contentInsets = NSDirectionalEdgeInsets(
            top: layer.borderWidth + 0,
            leading: layer.borderWidth + 8,
            bottom: layer.borderWidth + 0,
            trailing: layer.borderWidth + 8)
        
        // setup constraints
        var constraintWidth: NSLayoutConstraint?
        
        for constraint in constraints {
            if (constraint.firstAttribute == .width) {
                constraintWidth = constraint
            }
        }
        
        constraintWidth?.isActive = false
        
        configuration?.image = imageView?.image
        configuration?.imageColorTransformer = UIConfigurationColorTransformer {_ in
            return UIColor(named: ColorsHelper.BLACK)!
        }
        configuration?.imagePadding = 8
        
        if let imagePlacement = imagePlacement {
            configuration?.imagePlacement = imagePlacement
        }
    }
}
