//
//  UILabelBase.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

@IBDesignable class UILabelBase: UILabel {
    @IBInspectable var initialText: String? {
        didSet {
            setText(initialText)
        }
    }
    
    @IBInspectable var translatable: Bool = true {
        didSet {
            setText(initialText)
        }
    }
    
    @IBInspectable var uppercase: Bool = false {
        didSet {
            setText(initialText)
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
        
        setText(initialText)
    }
    
    func setStyle() {
        setBaseStyle()
    }
    
    func setBaseStyle() {
        // we don't set any defaults here at base style, so we can use Interface Builder
        
        //let fontSize = 16.0
        
        //font = UIFont(name: "FuturaPT-Bold", size: fontSize)
        //font = UIFont(name: "FuturaPT-Book", size: fontSize)
        //font = UIFont(name: "FuturaPT-Demi", size: fontSize)
        //font = UIFont(name: "FuturaPT-Medium", size: fontSize)
        
        //textColor = UIColor(named: ColorsHelper.BLACK)
    }

    func setText(_ textString: String?, _ translate: Bool = true) {
        text = textString
        
        if (text == nil) {
            return
        }
        
        if (translatable && translate) {
            text = text!.localized()
        }
        
        if (uppercase) {
            text = text!.uppercased()
        }
    }
}
