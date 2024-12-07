//
//  UISliderWithHandle.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class UISliderWithHandle: UISliderBase {
    
    @IBInspectable var thumbRadius: CGFloat = 10

    var thumbColor: UIColor = UIColor(named: ColorsHelper.RED)! {
        didSet {
            setThumbStyle()
        }
    }

    override func setThumbStyle() {
        let thumb = thumbImage(radius: thumbRadius)
        
        setThumbImage(thumb, for: .normal)
    }

    private func thumbImage(radius: CGFloat) -> UIImage {
        let thumbView: UIView = {
            let thumb = UIView()
            thumb.backgroundColor = thumbColor
            thumb.layer.borderWidth = 0
            //thumb.layer.borderColor = UIColor.clear.cgColor
            return thumb
        }()
        
        // Set proper frame
        // y: radius / 2 will correctly offset the thumb

        thumbView.frame = CGRect(x: 0, y: radius / 2, width: radius, height: radius)
        thumbView.layer.cornerRadius = radius / 2

        // Convert thumbView to UIImage
        // See this: https://stackoverflow.com/a/41288197/7235585

        let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)
        return renderer.image { rendererContext in
            thumbView.layer.render(in: rendererContext.cgContext)
        }
    }
}
