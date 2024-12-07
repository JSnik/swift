//
//  UILabelLabel2.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class UILabelLabel2: UILabelBase {
    
    override func setStyle() {
        //font = UIFont(name: "FuturaPT-Medium", size: 13.0)
        let customFont = UIFont(name: "FuturaPT-Medium", size: 13.0)
        font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont ?? UIFont.systemFont(ofSize: 13.0))
        textColor = UIColor(named: ColorsHelper.BLACK)
    }
}
