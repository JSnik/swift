//
//  UITextFieldBase.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

@IBDesignable class UITextFieldBase: UITextField, UITextFieldDelegate {

    let defaultHeight = CGFloat(40)
    var textFieldDidChangeHandler: (() -> (Void))! // 1st - params that callback receives, 2nd - callbacks type
    var textFieldShouldReturnHandler: (() -> (Void))!
    
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
    
    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        if (textFieldShouldReturnHandler != nil) {
            textFieldShouldReturnHandler()
        }
        
        return true
    }
        
    // MARK: Custom
    
    func commonInit() {
        delegate = self
        
        addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        setStyle()
        
        updateTextField()
    }
    
    @objc func textFieldDidChange(textField: UITextField){
        if (textFieldDidChangeHandler != nil) {
            textFieldDidChangeHandler()
        }
    }
    
    func setStyle() {
        setBaseStyle()
    }
    
    func setBaseStyle() {
        clipsToBounds = true
        borderStyle = UITextField.BorderStyle.none
        autocorrectionType = UITextAutocorrectionType.no

        font = UIFont(name: FontsHelper.FUTURA_PT_BOOK, size: 13.0)
        textColor = UIColor(named: ColorsHelper.BLACK)
        
        // placeholder color
        let placeholderForegroundColor = UIColor(named: ColorsHelper.BLACK_50_PERCENT, in: Bundle(for: type(of: self)), compatibleWith: self.traitCollection)
        let placeholderTitle = placeholder ?? ""
        
        let attributedString = NSAttributedString (
            string: placeholderTitle.localized(),
            attributes: [
                NSAttributedString.Key.foregroundColor: placeholderForegroundColor as Any
            ]
        )

        attributedPlaceholder = attributedString

        backgroundColor = UIColor(named: ColorsHelper.WHITE, in: Bundle(for: type(of: self)), compatibleWith: self.traitCollection)

        heightAnchor.constraint(equalToConstant: defaultHeight).isActive = true

        // padding
//        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16 - 8, height: self.frame.size.height))
//        leftView = leftPaddingView
//        leftViewMode = .always
//
//        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16 - 8, height: self.frame.size.height))
//        rightView = rightPaddingView
//        rightViewMode = .always
    }
    
    func updateTextField() {
        if (isEnabled) {
            setStateNormal()
        } else {
            setStateDisabled()
        }
    }
    
    func setStateNormal() {
        alpha = 1.0
    }

    func setStateDisabled() {
        alpha = 0.5
    }
}
