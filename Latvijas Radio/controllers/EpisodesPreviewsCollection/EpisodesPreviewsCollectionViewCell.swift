//
//  EpisodesPreviewsCollectionViewCell.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class EpisodesPreviewsCollectionViewCell: UICollectionViewCell {
    
    static var TAG = String(describing: EpisodesPreviewsCollectionViewCell.classForCoder())
    
    @IBOutlet weak var imageEpisodePreview: UIImageView!
    @IBOutlet weak var textBroadcastTitle: UILabelLabel5!
    @IBOutlet weak var textEpisodeTitle: UILabelLabel2!
}
