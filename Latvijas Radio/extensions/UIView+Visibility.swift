//
//  UIView+Visibility.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

extension UIView {
    
    static let VISIBILITY_VISIBLE = "VISIBLE"
    static let VISIBILITY_GONE = "GONE"
    static let CONSTRAINT_IDENTIFIER_WIDTH = "CONSTRAINT_IDENTIFIER_WIDTH"
    static let CONSTRAINT_IDENTIFIER_HEIGHT = "CONSTRAINT_IDENTIFIER_HEIGHT"
    
    func setVisibility(_ visibility_state: String) {
        switch visibility_state {
        case UIView.VISIBILITY_VISIBLE:
            isHidden = false
            
            // If our visibility constraints exist, deactivate them
            for constraint in constraints {
                if constraint.identifier == UIView.CONSTRAINT_IDENTIFIER_WIDTH {
                    constraint.isActive = false
                }
                if constraint.identifier == UIView.CONSTRAINT_IDENTIFIER_HEIGHT {
                    constraint.isActive = false
                }
            }
            
            break
        case UIView.VISIBILITY_GONE:
            isHidden = true
            
            // If the visibility constraint is already set, don't set another one.
            // No need to check for both width and height, we apply them together, we deactivate them together.
            var alreadyExists = false
            for constraint in constraints {
                if constraint.identifier == UIView.CONSTRAINT_IDENTIFIER_HEIGHT {
                    alreadyExists = true
                    
                    break
                }
            }
            
            if (!alreadyExists) {
                let constraintWidth = widthAnchor.constraint(equalToConstant: CGFloat(0))
                constraintWidth.isActive = true
                constraintWidth.identifier = UIView.CONSTRAINT_IDENTIFIER_WIDTH
                
                let constraintHeight = heightAnchor.constraint(equalToConstant: CGFloat(0))
                constraintHeight.isActive = true
                constraintHeight.identifier = UIView.CONSTRAINT_IDENTIFIER_HEIGHT
            }
            
            break
        default:
            break
        }
    }
}
