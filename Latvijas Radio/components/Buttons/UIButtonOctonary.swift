//
//  UIButtonOctonary.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class UIButtonOctonary: UIButtonBase {
   
    @IBInspectable var hasLeadingSpace: Bool = false {
        didSet {
            updateContentInsets()
        }
    }
    
    @IBInspectable var hasSmallImageSpace: Bool = false {
        didSet {
            updateImageLayer()
        }
    }
    
    @IBInspectable var largeMode: Bool = false {
        didSet {
            updateFont()
            setText(originalTitle)
        }
    }
    
    var layerBackground: CALayer!
    var layerImage: CALayer!
    
    override func layoutSubviews() {
        super.layoutSubviews()

        updateBackgroundLayer()
        updateImageLayer()
    }
    
    // MARK: Custom
    
    override func setStyle() {
        uppercase = false
        
        setBaseStyle()
        
        attributeContainer = AttributeContainer()
        attributeContainer.foregroundColor = UIColor(named: ColorsHelper.BLACK)
        
        updateFont()
        
        updateContentInsets()
        
        // setup constraints
        var constraintHeight: NSLayoutConstraint?
        
        for constraint in constraints {
            if (constraint.firstAttribute == .height) {
                constraintHeight = constraint
            }
        }
        
//        constraintHeight?.constant = CGFloat(40)

        contentHorizontalAlignment = .leading
        configuration?.imageColorTransformer = UIConfigurationColorTransformer {_ in
            return UIColor(named: ColorsHelper.BLACK)!
        }

        // Frame size at this point is still not known,
        // so there is no reason to draw layers that depend on them.
        // We get correct frame sizes in "layoutSubviews"
    }
    
    func updateFont() {
        if (largeMode) {
            let customFont4 = UIFont(name: FontsHelper.FUTURA_PT_DEMI, size: 16.0)
            attributeContainer.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont4 ?? UIFont.systemFont(ofSize: 16.0)) //UIFont(name: FontsHelper.FUTURA_PT_DEMI, size: 16.0)
        } else {
            let customFont4 = UIFont(name: FontsHelper.FUTURA_PT_MEDIUM, size: 14.0)
            attributeContainer.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont4 ?? UIFont.systemFont(ofSize: 14.0)) //UIFont(name: FontsHelper.FUTURA_PT_MEDIUM, size: 14.0)
        }
    }
    
    func updateContentInsets() {
        if (hasLeadingSpace) {
            configuration?.contentInsets = NSDirectionalEdgeInsets(
                top: layer.borderWidth + 0,
                leading: layer.borderWidth + 24,
                bottom: layer.borderWidth + 0,
                trailing: layer.borderWidth + 24)
        } else {
            configuration?.contentInsets = NSDirectionalEdgeInsets(
                top: layer.borderWidth + 0,
                leading: layer.borderWidth + 0,
                bottom: layer.borderWidth + 0,
                trailing: layer.borderWidth + 24)
        }
    }
    
    func updateBackgroundLayer() {
        if (layerBackground != nil) {
            layerBackground.removeFromSuperlayer()
        }

        // define background layer
        let backgroundWidth = bounds.width
        let backgroundHeight = CGFloat(1.0)

        layerBackground = CALayer()
        layerBackground.frame = CGRect(
            origin: CGPoint(x: 0, y: 39),
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
            let backgroundWidth = CGFloat(image.size.width)
            let backgroundHeight = CGFloat(image.size.height)
            
            var imageTrailingSpace = 24.0
            if (hasSmallImageSpace) {
                imageTrailingSpace = 8.0
            }

            layerImage = CALayer()
            layerImage.frame = CGRect(
                origin: CGPoint(x: frame.size.width - backgroundWidth - imageTrailingSpace, y: 40 / 2 - backgroundHeight / 2),
                size: CGSize(width: backgroundWidth, height: backgroundHeight)
            )

            layerImage.contents = image.cgImage
            layerImage.contentsGravity = .resizeAspect
            layerImage.zPosition = -1
            
            layer.addSublayer(layerImage)
        }
    }
}
