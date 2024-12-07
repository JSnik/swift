//
//  UIButtonBase.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

@IBDesignable class UIButtonBase: UIButton {
   
    var originalTitle: String?
    var attributeContainer: AttributeContainer!
    let defaultFont = UIFont(name: FontsHelper.FUTURA_PT_DEMI, size: 12.0)
    var defaultForegroundColor: UIColor?
    var uppercase: Bool = true
    
    /*
        Note: @IBInspectable values are only applied AFTER component init methods have ran
     */
    
    @IBInspectable var translatable: Bool = true {
        didSet {
            setText(originalTitle, translatable)
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            updateButton()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            updateButton()
        }
    }
    
    override var tintColor: UIColor? {
        didSet {
            updateTitleTintColor()
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
        defaultForegroundColor = UIColor(named: ColorsHelper.BLACK, in: Bundle(for: type(of: self)), compatibleWith: self.traitCollection)
        
        setStyle()
        
        updateButton()

        originalTitle = titleLabel?.text
        
        setText(originalTitle)
    }
    
    func setStyle() {
        setBaseStyle()
    }
    
    func setBaseStyle() {
        // https://sarunw.com/posts/new-way-to-style-uibutton-in-ios15/
        
        var configuration = UIButton.Configuration.filled()
        configuration.titlePadding = 0
        configuration.imagePadding = 0
        configuration.background.backgroundColor = UIColor.clear
        configuration.background.cornerRadius = 0
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: layer.borderWidth + 0,
            leading: layer.borderWidth + 24,
            bottom: layer.borderWidth + 0,
            trailing: layer.borderWidth + 24)
        
        attributeContainer = AttributeContainer()

        let customFont1 = UIFont(name: FontsHelper.FUTURA_PT_DEMI, size: 12.0)
//        UIFont(name: FontsHelper.FUTURA_PT_DEMI, size: 12.0)
        self.titleLabel?.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont1 ?? UIFont.systemFont(ofSize: 13.0))
        self.titleLabel?.adjustsFontForContentSizeCategory = true

        attributeContainer.font = defaultFont
        attributeContainer.foregroundColor = defaultForegroundColor
        
        self.configuration = configuration
                
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
        
        if (constraintWidth == nil) {
            widthAnchor.constraint(greaterThanOrEqualToConstant: CGFloat(192)).isActive = true
        }
        
        if (constraintHeight == nil) {
            heightAnchor.constraint(equalToConstant: CGFloat(30)).isActive = true
        }
    }
    
    func updateButton() {
        if (isEnabled) {
            if (isHighlighted) {
                setStateActive()
            } else {
                setStateNormal()
            }
        } else {
            setStateDisabled()
        }
    }
    
    func updateTitleTintColor() {
        attributeContainer?.foregroundColor = tintColor
        configuration?.attributedTitle?.setAttributes(attributeContainer)
    }
    
    func setStateNormal() {
        alpha = 1.0
    }
    
    func setStateActive() {
        alpha = 0.7
    }
    
    func setStateDisabled() {
        alpha = 0.5
    }

    func setText(_ textString: String?, _ translate: Bool = true) {
        var text = textString

        if (text == nil) {
            return
        }

        if (translatable && translate) {
            text = text!.localized()
        }
        
        if (uppercase) {
            text = text!.uppercased()
        }
        
        // this also sets titleLabel.text value
        configuration?.attributedTitle = AttributedString(text!, attributes: attributeContainer)
    }
}
