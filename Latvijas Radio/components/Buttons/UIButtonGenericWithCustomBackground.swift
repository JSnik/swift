//
//  UIButtonGenericWithCustomBackground.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//



import UIKit

@IBDesignable class UIButtonGenericWithCustomBackground: UIButtonBase {
   
    @IBInspectable var radius: CGFloat = 0 {
        didSet {
            updateBackgroundLayer()
        }
    }
    
    @IBInspectable var bgColor: UIColor = UIColor.clear {
        didSet {
            updateBackgroundLayer()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            updateBackgroundLayer()
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            updateBackgroundLayer()
        }
    }
    
    var layerBackground: CALayer!
    
    override func layoutSubviews() {
        super.layoutSubviews()

        updateBackgroundLayer()
    }
    
    // MARK: Custom
    
    override func setStyle() {
        // Frame size at this point is still not known,
        // so there is no reason to draw layers that depend on them.
        // We get correct frame sizes in "layoutSubviews"
    }
    
    func updateBackgroundLayer() {
        if (layerBackground != nil) {
            layerBackground.removeFromSuperlayer()
        }

        // define background layer
        let backgroundWidth = radius * 2
        let backgroundHeight = radius * 2

        layerBackground = CALayer()
        layerBackground.frame = CGRect(
            origin: CGPoint(x: frame.width / 2 - backgroundWidth / 2, y: frame.height / 2 - backgroundHeight / 2),
            size: CGSize(width: backgroundWidth, height: backgroundHeight)
        )
        layerBackground.backgroundColor = bgColor.cgColor
        layerBackground.cornerRadius = radius
        layerBackground.borderWidth = borderWidth
        layerBackground.borderColor = borderColor.cgColor
        layerBackground.zPosition = -1
        
        layer.addSublayer(layerBackground)
        
//        // leaving for reference: problem with this is that backgroundImage is simply uncontrollable - no paddings/insets
//
//        // generate image from layer
//        UIGraphicsBeginImageContextWithOptions(layerBackground.frame.size, layerBackground.isOpaque, 0)
//        layerBackground.render(in: UIGraphicsGetCurrentContext()!)
//        var image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
    }
    
    override func setStateDisabled() {
        alpha = 0.3
    }
}
