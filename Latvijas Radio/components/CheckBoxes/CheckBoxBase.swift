//
//  UIButtonBase.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

@IBDesignable class CheckBoxBase: UIButton {
   
    var originalTitle: String?
    var attributeContainer: AttributeContainer!
    let defaultFont = UIFont(name: "FuturaPT-Book", size: 10.0)
    let defaultForegroundColor = UIColor(named: ColorsHelper.BLACK)
    
    var layerCheckBoxImage = CALayer()

    var isChecked: Bool = false {
        didSet {
            updateCheckBox()
        }
    }
    
    // initialised from Interface Builder
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    // initialised from code
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }

    // MARK: Custom
    
    func commonInit() {
        setStyle()
        
        updateCheckBox()

        originalTitle = titleLabel?.text
        
        setText(originalTitle)
        
        self.addTarget(self, action:#selector(buttonClicked), for: .touchUpInside)
    }
    
    func setStyle() {
        let layerCheckBox = CALayer()
        layerCheckBox.frame = CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: CGSize(width: 20, height: 20)
        )
        layerCheckBox.borderWidth = 1
        layerCheckBox.borderColor = UIColor(named: ColorsHelper.BLACK)?.cgColor
        layerCheckBox.cornerRadius = 10
        
        layerCheckBoxImage = CALayer()
        layerCheckBoxImage.frame = CGRect(
            origin: CGPoint(x: (20 - 10) / 2, y: (20 - 10) / 2),
            size: CGSize(width: 10, height: 10)
        )
        
        // https://riptutorial.com/ios/example/16243/how-to-add-a-uiimage-to-a-calayer
        layerCheckBoxImage.contentsGravity = CALayerContentsGravity.resizeAspect
        //checkBoxLayer.geometryFlipped = true
        
        layerCheckBox.addSublayer(layerCheckBoxImage)
        layer.addSublayer(layerCheckBox)
        
        // button
        var configuration = UIButton.Configuration.filled()
        configuration.titlePadding = 0
        configuration.imagePadding = 0
        configuration.background.backgroundColor = UIColor.clear
        configuration.background.cornerRadius = 0
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: layer.borderWidth + 3,
            leading: layer.borderWidth + 24,
            bottom: layer.borderWidth + 0,
            trailing: layer.borderWidth + 0)
        
        attributeContainer = AttributeContainer()
        let customFont = UIFont(name: "FuturaPT-Book", size: 10.0)
        attributeContainer.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: defaultFont ?? UIFont.systemFont(ofSize: 10.0))
//        attributeContainer.font = defaultFont
        attributeContainer.foregroundColor = defaultForegroundColor
        
        self.configuration = configuration
        
//        heightAnchor.constraint(greaterThanOrEqualToConstant: CGFloat(20)).isActive = true
        
        contentHorizontalAlignment = .left
        contentVerticalAlignment = .top
    }
    
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            isChecked = !isChecked
        }
    }

    func updateCheckBox() {
        if (isEnabled) {
            if (isChecked) {
                setStateChecked()
            } else {
                setStateUnchecked()
            }
        } else {
            setStateDisabled()
        }
    }
    
    func setStateChecked() {
        layerCheckBoxImage.contents = UIImage(named: ImagesHelper.IC_CHEVRON_DOWN)!.cgImage
    }
    
    func setStateUnchecked() {
        layerCheckBoxImage.contents = nil
    }
    
    func setStateDisabled() {

    }

    func setText(_ textString: String?, _ translate: Bool = true) {
        var text = textString

        if (text == nil) {
            return
        }

        if (translate) {
            text = text!.localized()
        }
        
        // this also sets titleLabel.text value
        configuration?.attributedTitle = AttributedString(text!.htmlToAttributedString!)
        configuration?.attributedTitle?.mergeAttributes(attributeContainer)
    }
}
