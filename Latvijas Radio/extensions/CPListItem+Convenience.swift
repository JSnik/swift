//
//  UIView+Visibility.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit
import CarPlay
import SDWebImage

@available(iOS 14.0, *)
extension CPListItem {

    var identifier: String? {
        (userInfo as? [String: Any])?[Self.identifierUserInfoKey] as? String
    }

    private static let identifierUserInfoKey = "CPListItem.Identifier"
    
    convenience init(
        id: String,
        text: String?,
        detailText: String?,
        remoteImageUrl: URL?,
        placeholder: UIImage?,
        placeholderIsVectorImage: Bool,
        carTraitCollection: UITraitCollection?
    ) {
        self.init(text: text, detailText: detailText, image: placeholder)

        userInfo = [Self.identifierUserInfoKey: id]
        
        // If placeholder (local) image is not vector, then image will show up small, so we resize it.
        if let placeholder = placeholder, !placeholderIsVectorImage {
            if let carTraitCollection = carTraitCollection {
                let imageAsset = UIImageAsset()
                imageAsset.register(placeholder, with: carTraitCollection)
                let imageWithTraits = imageAsset.image(with: carTraitCollection)
                
                setImage(imageWithTraits)
            }
        }
        
        // Acquire and resize remote image.
        if let imageUrl = remoteImageUrl {
            let imageView = UIImageView()
            
            DispatchQueue.global(qos: .background).async {
                // There is a known problem with displayScale: https://developer.apple.com/forums/thread/695636
                // On runtime it is 0, even on car stereos.
                // By default, majority scales are x2 or x3, so we default to x2.
                
                var finalDisplayScale: CGFloat = 0
                
                if let carTraitCollection = carTraitCollection {
                    finalDisplayScale = carTraitCollection.displayScale
                }
                
                if (finalDisplayScale == 0) {
                    finalDisplayScale = 2
                }
                
                let maximumWidth = CPListItem.maximumImageSize.width * finalDisplayScale
                let maximumHeight = CPListItem.maximumImageSize.height * finalDisplayScale

                // Makes sure that image is acquired with big enough resolution.
                let transformer = SDImageResizingTransformer(size: CGSize(width: maximumWidth, height: maximumHeight), scaleMode: .aspectFill)

                imageView.sd_setImage(with: imageUrl,
                                      placeholderImage: nil,
                                      options: SDWebImageOptions(rawValue: 0),
                                      context: [.imageTransformer: transformer],
                                      progress: nil) { (image, error, cache, url) in
                    if let networkImage = imageView.image {
                        if let carTraitCollection = carTraitCollection {
                            let imageAsset = UIImageAsset()
                            imageAsset.register(networkImage, with: carTraitCollection)
                            let imageWithTraits = imageAsset.image(with: carTraitCollection)
                            
                            DispatchQueue.main.async { [weak self] in
                                GeneralUtils.log("CPListItem", "Image downloaded, applying...", imageWithTraits)

                                self?.setImage(imageWithTraits)
                            }
                        }
                    }
                }
            }
        }
    }
}

