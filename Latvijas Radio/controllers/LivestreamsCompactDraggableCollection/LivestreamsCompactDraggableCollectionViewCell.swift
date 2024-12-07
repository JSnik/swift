//
//  LivestreamsCompactDraggableCollectionViewCell.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 23/08/2022.
//

import UIKit

class LivestreamsCompactDraggableCollectionViewCell: UICollectionViewCell {
    
    var TAG = String(describing: LivestreamsCompactDraggableCollectionViewCell.classForCoder())

    @IBOutlet weak var imageDragger: UIImageView!
    @IBOutlet weak var imageLivestream: UIImageView!
    @IBOutlet weak var textLivestreamTitle: UILabelLabel2!
}
