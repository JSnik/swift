//
//  UIButtonTertiaryDropdown.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class UIButtonTertiaryDropdown: UIButtonTertiary {
   
    var layerImage: CALayer!
    
    override func layoutSubviews() {
        super.layoutSubviews()

        updateImageLayer()
    }
    
    // MARK: Custom
    
    override func setStyle() {
        super.setStyle()
        
        layer.cornerRadius = 10
        
        configuration?.contentInsets = NSDirectionalEdgeInsets(
            top: layer.borderWidth + 0,
            leading: layer.borderWidth + 8,
            bottom: layer.borderWidth + 0,
            trailing: layer.borderWidth + 16)
        
        // setup constraints
        var constraintWidth: NSLayoutConstraint?
        var constraintHeight: NSLayoutConstraint?
        
        for constraint in constraints {
            if (constraint.firstAttribute == .width) {
                constraintWidth = constraint
            }
            if (constraint.firstAttribute == .height) {
                constraintHeight = constraint
            }
        }
        
//        constraintWidth?.constant = 63
//        constraintHeight?.constant = 20
    }
    
    func updateImageLayer() {
        if (layerImage != nil) {
            layerImage.removeFromSuperlayer()
        }
        
        let image = UIImage(named: ImagesHelper.IC_CHEVRON_DOWN)!
        
        // define image layer
        let backgroundWidth = CGFloat(image.size.width)
        let backgroundHeight = CGFloat(image.size.height)

        layerImage = CALayer()
        layerImage.frame = CGRect(
            origin: CGPoint(x: frame.size.width - backgroundWidth - 8, y: 20 / 2 - backgroundHeight / 2),
            size: CGSize(width: backgroundWidth, height: backgroundHeight)
        )

        layerImage.zPosition = -1

        let maskLayer = CALayer()
        maskLayer.frame = layerImage.bounds
        maskLayer.contents = image.cgImage
        maskLayer.contentsGravity = .resizeAspect
        
        layerImage.mask = maskLayer
        layerImage.backgroundColor = UIColor(named: ColorsHelper.GRAY_4)!.cgColor

        layer.addSublayer(layerImage)
//        titleLabel?.preferredMaxLayoutWidth = self.titleLabel!.frame.size.width
//        self.titleLabel?.numberOfLines = 0
//                self.titleLabel?.textAlignment = .center
//                self.setContentHuggingPriority(UILayoutPriority.defaultLow + 1, for: .vertical)
//                self.setContentHuggingPriority(UILayoutPriority.defaultLow + 1, for: .horizontal)
    }

}
