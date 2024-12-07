//
//  AVPlayerItem+Url.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit
import AVFoundation

extension AVPlayerItem {
    var url: URL? {
        return (asset as? AVURLAsset)?.url
    }
}
