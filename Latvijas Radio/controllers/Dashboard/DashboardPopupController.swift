//
//  DashboardPopupController.swift
//  Latvijas Radio
//
//  Created by Sergey on 17.05.2023.
//

import Foundation
import UIKit

class DashboardPopupViewController: UIViewController {
    
    var imageLink = ""
    var urlLink = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let closeButton = UIButton()
        let btnImage = UIImage(named:"x_poga")
        closeButton.setImage(btnImage , for: .normal)
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        closeButton.sizeToFit()
        self.view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.layer.zPosition = 1
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            closeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            closeButton.heightAnchor.constraint(equalToConstant: 35),
            closeButton.widthAnchor.constraint(equalToConstant: 35)
        ])
        
        let imageView = UIImageView()
        imageView.downloaded(from: imageLink)
        self.view.addSubview(imageView)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleClickCustomImage))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            imageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
        ])
        
        let activityView = UIActivityIndicatorView(style: .large)
        activityView.color = .red
        activityView.layer.zPosition = -1
        activityView.center = self.view.center
        self.view.addSubview(activityView)
        activityView.startAnimating()
        
        GeneralUtils.getUserDefaults().set(true, forKey: Configuration.IS_BIG_IMAGE_POPUP_SHOW)
    }
    
    @objc func didTapClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleClickCustomImage() {
        if (urlLink != "") {
            if (urlLink.contains("deeplink")) {
                let userActivity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
                userActivity.webpageURL = URL(string: urlLink)
                DeepLinkManager.validateAndExtractDataFromDeepLink(userActivity)
            } else {
                if let url = URL(string: urlLink) {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleToFill) {
        contentMode = mode
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad //.reloadIgnoringLocalCacheData
//        config.urlCache = nil

        let session = URLSession.init(configuration: config)
        session.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleToFill) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
