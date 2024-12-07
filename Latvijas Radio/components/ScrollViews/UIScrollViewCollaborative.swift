//
//  CollaborativeScrollView.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class UIScrollViewCollaborative: UIScrollViewTouchable, UIGestureRecognizerDelegate {

    var lastContentOffset: CGPoint = CGPoint(x: 0, y: 0)
    
    // MARK: UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
