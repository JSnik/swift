//
//  UIButtonPrimary.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class UIButtonPrimary: UIButtonBase {
   
    // MARK: Custom
    
    override func setStyle() {
        // borders & corners
        clipsToBounds = true
        layer.cornerRadius = 15
        
        setBaseStyle()
        
        configuration?.background.backgroundColor = UIColor(named: ColorsHelper.RED)

        attributeContainer = AttributeContainer()
        attributeContainer.font = defaultFont
        attributeContainer.foregroundColor = UIColor(named: ColorsHelper.WHITE)
    }
}
