//
//  UIButtonTertiaryFluid.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class UIButtonTertiaryFluid: UIButtonTertiary {
   
    // MARK: Custom
    
    override func setStyle() {
        super.setStyle()
        
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
