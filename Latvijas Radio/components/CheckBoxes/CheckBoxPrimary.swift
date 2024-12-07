//
//  CheckBoxPrimary.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

@IBDesignable class CheckBoxPrimary: CheckBoxBase {
    
    var layerCheckBox: CALayer!

    override func layoutSubviews() {
        super.layoutSubviews()

        updateLayerCheckBox()
        
        updateCheckBox()
    }
    
    override func setStyle() {
        // button
        var configuration = UIButton.Configuration.filled()
        configuration.titlePadding = 0
        configuration.imagePadding = 0
        configuration.background.backgroundColor = UIColor.clear
        configuration.background.cornerRadius = 0
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: layer.borderWidth + 12,
            leading: layer.borderWidth + 0,
            bottom: layer.borderWidth + 12,
            trailing: layer.borderWidth + 30)
        
        attributeContainer = AttributeContainer()
        let customFont = UIFont(name: "FuturaPT-Book", size: 12.0)
        attributeContainer.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont ?? UIFont.systemFont(ofSize: 13.0))
//        attributeContainer.font = UIFont(name: "FuturaPT-Book", size: 12.0)
        attributeContainer.foregroundColor = defaultForegroundColor
        
        self.configuration = configuration

        contentHorizontalAlignment = .left
        contentVerticalAlignment = .top
    }
    
    func updateLayerCheckBox() {
        if (layerCheckBox != nil) {
            layerCheckBox.removeFromSuperlayer()
        }
        
        let layerCheckBoxWidth: CGFloat = 20.0
        let layerCheckBoxHeight: CGFloat = 20.0
        
        layerCheckBox = CALayer()
        layerCheckBox.frame = CGRect(
            origin: CGPoint(x: bounds.width - layerCheckBoxWidth, y: frame.height / 2 - layerCheckBoxHeight / 2),
            size: CGSize(width: layerCheckBoxWidth, height: layerCheckBoxHeight)
        )
        layerCheckBox.borderWidth = 1
        layerCheckBox.borderColor = UIColor(named: ColorsHelper.BLACK)?.cgColor
        layerCheckBox.cornerRadius = 10
        layerCheckBox.zPosition = -1
        
        layerCheckBoxImage = CALayer()
        layerCheckBoxImage.frame = CGRect(
            origin: CGPoint(x: (20 - 10) / 2, y: (20 - 10) / 2),
            size: CGSize(width: 10, height: 10)
        )
        
        // https://riptutorial.com/ios/example/16243/how-to-add-a-uiimage-to-a-calayer
        layerCheckBoxImage.contentsGravity = CALayerContentsGravity.resizeAspect
        layerCheckBoxImage.zPosition = -1
        //checkBoxLayer.geometryFlipped = true
        
        layerCheckBox.addSublayer(layerCheckBoxImage)
        layer.addSublayer(layerCheckBox)
    }
}
