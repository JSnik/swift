//
//  UIButtonPlayerMini.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class UIButtonPlayerMini: UIButtonBase {
   
    // MARK: Custom
    
    override func setStyle() {
        setBaseStyle()
        
        configuration?.background.backgroundColor = UIColor(named: ColorsHelper.GRAY_6)

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
    
    override func setStateNormal() {
        configuration?.background.backgroundColor = UIColor(named: ColorsHelper.GRAY_6)
    }
    
    override func setStateActive() {
        configuration?.background.backgroundColor = UIColor(named: ColorsHelper.GRAY_7)
    }
}
