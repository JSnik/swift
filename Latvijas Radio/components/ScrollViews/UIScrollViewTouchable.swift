//
//  UIScrollViewTouchable.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//


import UIKit

class UIScrollViewTouchable: UIScrollView {

    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIControl {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }
}
