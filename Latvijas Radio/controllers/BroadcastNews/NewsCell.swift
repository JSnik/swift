//
//  NewsCell.swift
//  Latvijas Radio
//
//  Created by Sergey on 23.10.2024.
//  Copyright © 2024 Latvijas Radio. All rights reserved.
//

import UIKit
class NewsCell: UICollectionViewCell {
    
    @IBOutlet weak var buttonTogglePlay: UIButtonGenericWithImage!
    @IBOutlet weak var buttonDownload: UIButtonGenericWithImage!
    @IBOutlet weak var downloadProgress: CustomProgressView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textEpisodeTitle: UILabelBase!
    
    var broadcastNewsViewControllerButtonDownloadHelper: BroadcastNewsViewControllerButtonDownloadHelper!
    
    
    @IBAction func onDownloadTap(_ sender: Any) {
        broadcastNewsViewControllerButtonDownloadHelper.initDownloadOfEpisodeMediaFile()
    }
}
