//
//  SearchCompactCollectionViewCell.swift
//  Latvijas Radio
//
//  Created by andriy kruglyanko on 22.10.2024.
//  Copyright © 2024 Latvijas Radio. All rights reserved.
//

import UIKit

class SearchCompactCollectionViewCell: UICollectionViewCell {

    static var TAG = String(describing: SearchCompactCollectionViewCell.classForCoder())

    @IBOutlet weak var imageGenericPreview: UIImageView!
    @IBOutlet weak var textGenericPreview: UILabelLabel3!
    @IBOutlet weak var buttonChannel: UIButtonOctonary!
}
