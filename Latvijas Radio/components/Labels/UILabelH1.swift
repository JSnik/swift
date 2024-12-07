//
//  UILabelH1.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class UILabelH1: UILabelBase {
    
    override func setStyle() {
//        font = UIFont(name: "FuturaPT-Bold", size: 22.0)
          let customFont = UIFont(name: "FuturaPT-Bold", size: 22.0)
        font = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: customFont ?? UIFont.systemFont(ofSize: 22.0))

        textColor = UIColor(named: ColorsHelper.BLACK)
    }
}
