//
//  UIButtonDecary.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 12/08/2022.
//

import UIKit

class UIButtonDecary: UIButtonBase {
   
    // MARK: Custom
    
    override func setStyle() {
        // borders & corners
        clipsToBounds = true
        layer.cornerRadius = 15
        
        setBaseStyle()
        
        configuration?.background.backgroundColor = UIColor(named: ColorsHelper.GRAY_2)

        attributeContainer = AttributeContainer()
        attributeContainer.font = defaultFont
        attributeContainer.foregroundColor = UIColor(named: ColorsHelper.BLACK)
    }
}
