//
//  CoversCollectionViewCell.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class CoversCollectionViewCell: UICollectionViewCell {
    
    static var TAG = String(describing: CoversCollectionViewCell.classForCoder())
    
    @IBOutlet weak var wrapperItem: UIView!
    @IBOutlet weak var frameLayout: UIView!
}
