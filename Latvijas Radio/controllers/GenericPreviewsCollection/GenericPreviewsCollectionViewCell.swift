//
//  GenericPreviewsCollectionViewCell.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class GenericPreviewsCollectionViewCell: UICollectionViewCell {
    
    static var TAG = String(describing: GenericPreviewsCollectionViewCell.classForCoder())
    
    @IBOutlet weak var imageGenericPreview: UIImageView!
    @IBOutlet weak var textGenericPreview: UILabelLabel3!
}
