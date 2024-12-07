//
//  UIButtonTertiaryIconed.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class UIButtonTertiaryIconed: UIButtonBase {
   
    // MARK: Custom
    
    override func setStyle() {
        // borders & corners
        clipsToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor(named: ColorsHelper.BLACK)?.cgColor
        layer.cornerRadius = 15

        setBaseStyle()
        
        configuration?.imagePadding = 8
        
        if let imageView = imageView {
            if let image = imageView.image {
                let tintColor = UIColor(named: ColorsHelper.BLACK, in: Bundle(for: type(of: self)), compatibleWith: self.traitCollection)!
                
                configuration?.image = image.withTintColor(tintColor)
            }
        }
        
        contentHorizontalAlignment = .left
        configuration?.contentInsets = NSDirectionalEdgeInsets(
            top: layer.borderWidth + 0,
            leading: layer.borderWidth + 8,
            bottom: layer.borderWidth + 0,
            trailing: layer.borderWidth + 8)
    }
}
