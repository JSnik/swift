//
//  LivestreamsCollectionViewCell.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class LivestreamsCollectionViewCell: UICollectionViewCell {
    
    static var TAG = String(describing: LivestreamsCollectionViewCell.classForCoder())

    @IBOutlet weak var imageLivestream: UIImageView!
    @IBOutlet weak var textTitlePrimary: UILabelLabel5!
    @IBOutlet weak var textTitleSecondary: UILabelLabel2!
    @IBOutlet weak var buttonTogglePlayback: UIButtonGenericWithImage!
}
