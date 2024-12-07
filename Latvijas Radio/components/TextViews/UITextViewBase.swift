//
//  UITextViewBase.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

@IBDesignable class UITextViewBase: UITextView, UITextViewDelegate {

    let defaultHeight = CGFloat(140)
    var textViewDidChangeHandler: (() -> (Void))!
    let colorText = UIColor(named: ColorsHelper.BLACK)
    let colorPlaceholder = UIColor(named: ColorsHelper.BLACK_50_PERCENT)

    @IBInspectable var placeholder: String? {
        didSet {
            checkPlaceholder()
        }
    }
    
    // initialised from Interface Builder
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        commonInit()
    }
    
    // initialised from code
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }

    // MARK: UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        checkPlaceholder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        checkPlaceholder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if (textViewDidChangeHandler != nil) {
            textViewDidChangeHandler()
        }
    }
        
    // MARK: Custom
    
    func commonInit() {
        delegate = self
        
        //addTarget(self, action: #selector(textViewDidChange(textView:)), for: .editingChanged)
        
        setStyle()
        
        updateTextView()
    }
    
    func setStyle() {
        setBaseStyle()
    }
    
    func setBaseStyle() {
        clipsToBounds = true
        //borderStyle = UITextView.BorderStyle.none
        autocorrectionType = UITextAutocorrectionType.no
        font = UIFont(name: FontsHelper.FUTURA_PT_BOOK, size: 13.0)
        textColor = colorText
        
        backgroundColor = UIColor(named: ColorsHelper.WHITE)

        heightAnchor.constraint(equalToConstant: defaultHeight).isActive = true

        // padding
        textContainer.lineFragmentPadding = 0
        textContainerInset = UIEdgeInsets.zero
        contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    func updateTextView() {
        if (isEditable) {
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
    
    func checkPlaceholder() {
        if (text.isEmpty) {
            text = placeholder?.localized()
            textColor = colorPlaceholder
        } else if (text == placeholder?.localized()) {
            text = nil
            textColor = colorText
        }
    }
}
