//
//  CollectionViewCellHelper.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class CollectionViewCellHelper {

    static func setHighlightedStyle(_ cell: UICollectionViewCell) {
        cell.alpha = 0.8
    }
    
    static func setUnhighlightedStyle(_ cell: UICollectionViewCell) {
        cell.alpha = 1.0
    }
}
