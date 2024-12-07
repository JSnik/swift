//
//  UILabelLabel3.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class UILabelLabel3: UILabelBase {
    
    override func setStyle() {
//        font = UIFont(name: "FuturaPT-Demi", size: 12.0)
        let customFont = UIFont(name: "FuturaPT-Demi", size: 12.0)
        font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont ?? UIFont.systemFont(ofSize: 12.0))
        textColor = UIColor(named: ColorsHelper.BLACK)
        uppercase = true
    }
}
