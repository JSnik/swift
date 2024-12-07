//
//  UIButtonContentPopupClose.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class UIButtonContentPopupClose: UIButtonBase {
   
    // MARK: Custom
    
    override func setStyle() {
        // borders & corners
        clipsToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor(named: ColorsHelper.BLACK)?.cgColor
        layer.cornerRadius = 15

        setBaseStyle()

        // setup constraints
        var constraintHeight: NSLayoutConstraint?
        
        for constraint in constraints {
            if (constraint.firstAttribute == .width) {
                constraint.isActive = false
            }
            
            if (constraint.firstAttribute == .height) {
                constraintHeight = constraint
            }
        }
        
        widthAnchor.constraint(equalToConstant: CGFloat(30)).isActive = true
        constraintHeight?.constant = CGFloat(30)

        configuration?.image = UIImage(named: ImagesHelper.IC_CROSS_ROUNDED)
        configuration?.imageColorTransformer = UIConfigurationColorTransformer {_ in
            return UIColor(named: ColorsHelper.BLACK)!
        }
    }
}
