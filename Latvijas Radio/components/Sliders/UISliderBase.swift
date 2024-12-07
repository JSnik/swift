//
//  UISliderBase.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class UISliderBase: UISlider {
    
    let height: CGFloat = 2
   
    required init() {
        super.init(frame: CGRect.zero)
        
        commonInit()
    }


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
       var newBounds = super.trackRect(forBounds: bounds)
       newBounds.size.height = height
       return newBounds
    }
    
    func commonInit() {
        setStyle()
    }
    
    func setStyle() {
        setBaseStyle()
        
        setThumbStyle()
    }
    
    func setBaseStyle() {
        // setup track colors
        minimumTrackTintColor = UIColor(named: ColorsHelper.RED)!
        maximumTrackTintColor = UIColor(named: ColorsHelper.GRAY_5)!
    }
    
    func setThumbStyle() {
        // removes thumb handle and allows it to be dragged fully to the sides
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0)
        UIColor.clear.setFill()
        UIRectFill(rect)
        if let blankImg = UIGraphicsGetImageFromCurrentImageContext() {
            setThumbImage(blankImg, for: .normal)
            setThumbImage(blankImg, for: .highlighted)
        }
        UIGraphicsEndImageContext()
    }
    
    func setRectangleCorners() {
        setMinimumTrackImage(imageWith(color: UIColor(named: ColorsHelper.RED)!), for: .normal)
        setMaximumTrackImage(imageWith(color: UIColor(named: ColorsHelper.GRAY_5)!), for: .normal)
    }
    
    private func imageWith(color: UIColor, size: CGSize? = nil) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size?.width ?? 1, height: size?.height ?? height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
