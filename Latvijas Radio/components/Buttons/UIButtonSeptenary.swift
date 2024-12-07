//
//  UIButtonSeptenary.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class UIButtonSeptenary: UIButtonBase {
    
    var layerBackground: CALayer!
    var layerImage: CALayer!
    
    var customTintColor: UIColor? {
        didSet {
            updateImageLayer()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        updateBackgroundLayer()
        updateImageLayer()
    }
    
    override func commonInit() {
        super.commonInit()
        
        customTintColor = UIColor(named: ColorsHelper.GRAY_3, in: Bundle(for: type(of: self)), compatibleWith: self.traitCollection)
    }
   
    // MARK: Custom
    
    override func setStyle() {
        uppercase = false

        setBaseStyle()
        
        attributeContainer = AttributeContainer()
        attributeContainer.font = UIFont(name: FontsHelper.FUTURA_PT_BOOK, size: 13.0)
        attributeContainer.foregroundColor = UIColor(named: ColorsHelper.BLACK)
        
        configuration?.contentInsets = NSDirectionalEdgeInsets(
            top: layer.borderWidth + 0,
            leading: layer.borderWidth + 32,
            bottom: layer.borderWidth + 0,
            trailing: layer.borderWidth + 32)
        
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
        
        constraintWidth?.isActive = false
        constraintHeight?.constant = 40
    }
    
    func updateBackgroundLayer() {
        if (layerBackground != nil) {
            layerBackground.removeFromSuperlayer()
        }

        // define background layer
        let paddingLeft = 24.0
        let paddingRight = 24.0
        let backgroundWidth = bounds.width - paddingLeft - paddingRight
        let backgroundHeight = CGFloat(1.0)

        layerBackground = CALayer()
        layerBackground.frame = CGRect(
            origin: CGPoint(x: paddingLeft, y: 39),
            size: CGSize(width: backgroundWidth, height: backgroundHeight)
        )
        layerBackground.backgroundColor = UIColor(named: ColorsHelper.BLACK_10_PERCENT)?.cgColor
        layerBackground.zPosition = -1
        
        layer.addSublayer(layerBackground)
    }
    
    func updateImageLayer() {
        if (layerImage != nil) {
            layerImage.removeFromSuperlayer()
        }
        
        if let image = imageView?.image {
            // define image layer
            let backgroundWidth = 16.0
            let backgroundHeight = 16.0

            layerImage = CALayer()
            layerImage.frame = CGRect(
                origin: CGPoint(x: bounds.width - backgroundWidth - 32, y: 40 / 2 - backgroundHeight / 2),
                size: CGSize(width: backgroundWidth, height: backgroundHeight)
            )

            layerImage.zPosition = -1
            
            let maskLayer = CALayer()
            maskLayer.frame = layerImage.bounds
            maskLayer.contents = image.cgImage
            maskLayer.contentsGravity = .resizeAspect
            
            layerImage.mask = maskLayer
            layerImage.backgroundColor = customTintColor?.cgColor
  
            layer.addSublayer(layerImage)
        }
    }
}
