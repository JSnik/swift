//
//  ChannelsCollectionViewCell.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class ChannelsCollectionViewCell: UICollectionViewCell {
    
    static var TAG = String(describing: ChannelsCollectionViewCell.classForCoder())

    @IBOutlet weak var buttonChannel: UIButtonOctonary!
    @IBOutlet weak var imageChannel: UIImageView!
}
