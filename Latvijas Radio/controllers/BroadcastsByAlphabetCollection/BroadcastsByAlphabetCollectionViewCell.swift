//
//  BroadcastsByAlphabetCollectionViewCell.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class BroadcastsByAlphabetCollectionViewCell: UICollectionViewCell {
    
    static var TAG = String(describing: BroadcastsByAlphabetCollectionViewCell.classForCoder())

    @IBOutlet weak var textStartingSymbol: UILabelPadded!
    @IBOutlet weak var buttonBroadcastName: UIButtonIBCustomizable!
}
