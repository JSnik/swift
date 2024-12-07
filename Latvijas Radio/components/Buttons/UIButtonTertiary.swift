//
//  UIButtonTertiary.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class UIButtonTertiary: UIButtonBase {
   
    // MARK: Custom
    
    override func setStyle() {
        // borders & corners
        clipsToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor(named: ColorsHelper.BLACK)?.cgColor
        layer.cornerRadius = 15
        
        setBaseStyle()
    }
}
