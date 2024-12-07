//
//  EpisodesCompactDraggableCollectionViewCell.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class EpisodesCompactDraggableCollectionViewCell: UICollectionViewCell {
    
    static var TAG = String(describing: EpisodesCompactDraggableCollectionViewCell.classForCoder())

    @IBOutlet weak var imageDragger: UIImageView!
    @IBOutlet weak var textBroadcastName: UILabelLabel5!
    @IBOutlet weak var textTitle: UILabelLabel2!
}
