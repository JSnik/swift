//
//  UILabelH3.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class UILabelH3: UILabelBase {
    
    override func setStyle() {
        //font = UIFont(name: "FuturaPT-Bold", size: 18.0)
        let customFont = UIFont(name: "FuturaPT-Bold", size: 18.0)
        font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont ?? UIFont.systemFont(ofSize: 18.0))
        textColor = UIColor(named: ColorsHelper.BLACK)
    }
}
