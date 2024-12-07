//
//  ContainedCollectionViewHeightHelper.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class ContainedCollectionViewHeightHelper {

    static func updateCollectionContainerHeightConstraint(view: UIView, collectionView: UICollectionView) {
        var constraintHeight: NSLayoutConstraint?

        for constraint in view.constraints {
            if (constraint.firstAttribute == .height) {
                constraintHeight = constraint
            }
        }

        let newHeight = CGFloat(collectionView.contentSize.height)
        
        // If collectionView gets rendered later (ex. after network call),
        // then its content height will be 0.
        // We must not set constraint to 0, because that will prevent the content
        // height from automatically growing to its real value.
        if (newHeight != 0) {
            constraintHeight?.constant = newHeight
        }
    }
}
