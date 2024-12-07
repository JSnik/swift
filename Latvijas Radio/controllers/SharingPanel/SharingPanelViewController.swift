//
//  SharingPanelViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit
import MessageUI

class SharingPanelViewController: UIViewController {
    
    var TAG = String(describing: SharingPanelViewController.classForCoder())
    
    @IBOutlet weak var imageMedia: UIImageView!
    @IBOutlet weak var textBroadcastName: UILabelLabel5!
    @IBOutlet weak var textMediaTitle: UILabelLabel2!
    @IBOutlet weak var buttonClose: UIButtonGenericWithCustomBackground!
    @IBOutlet weak var buttonShareWhatsApp: UIButtonSenary!
    @IBOutlet weak var buttonShareInstagramStories: UIButtonSenary!
    @IBOutlet weak var buttonShareInstagramDirect: UIButtonSenary!
    @IBOutlet weak var buttonShareFacebook: UIButtonSenary!
    @IBOutlet weak var buttonShareMessenger: UIButtonSenary!
    @IBOutlet weak var buttonShareSms: UIButtonSenary!
    @IBOutlet weak var buttonShareClipboard: UIButtonSenary!
    
    var containerSharingPanel: UIView!
    var containerSharingPanelBottomConstraint: NSLayoutConstraint!
    var isOpened = false
    var episodeModel: EpisodeModel!
    var livestreamModel: /*LivestreamModel*/ RadioChannel!
    var broadcastModel: BroadcastModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(TAG, "viewDidLoad")
        
        // listeners
        buttonClose.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonShareWhatsApp.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonShareInstagramStories.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonShareInstagramDirect.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonShareFacebook.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonShareMessenger.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonShareSms.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonShareClipboard.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        
        // UI
        view.translatesAutoresizingMaskIntoConstraints = false
        
        self.containerSharingPanelBottomConstraint.constant = -self.view.frame.height
    }
    
    deinit {
        GeneralUtils.log(TAG, "deinit")
    }
    
    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonClose) {
            closePanel()
        }
        if (sender == buttonShareWhatsApp) {
            let textContentString = getSharingUrlForMedia()
            let textContentEncoded = textContentString.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
            
            UIApplication.shared.open(URL(string: "whatsapp://send?text=" + textContentEncoded)!, options: [:], completionHandler: nil)
        }
        if (sender == buttonShareInstagramStories) {
            // https://developers.facebook.com/docs/instagram/sharing-to-feed
            // https://developers.facebook.com/docs/instagram/sharing-to-stories/
            
            let bundleID: String = Bundle.main.bundleIdentifier ?? ""
            
            if let storiesUrl = URL(string: "instagram-stories://share?source_application=" + bundleID) {
                if UIApplication.shared.canOpenURL(storiesUrl) {
                    // Get image to share.
                    
                    var urlStringOfImageToShare: String?
                    
                    if (episodeModel != nil) {
                        urlStringOfImageToShare = episodeModel.getImageUrl()
                    }
                    
                    if (broadcastModel != nil) {
                        // update image
                        if let imageUrl = broadcastModel.getImageUrl() {
                            urlStringOfImageToShare = imageUrl
                        }
                    }
                    
                    if (livestreamModel != nil) {
//                        let imageResourceId = livestreamModel.getImageResourceId()
//                        shareImageToInstagram(storiesUrl, UIImage(named: imageResourceId))
//                        if (livestreamModel.image != nil) {
                            shareImageToInstagram(storiesUrl, UIImage(named: livestreamModel.image ?? ""))
//                            shareImageToInstagram(storiesUrl, UIImage(named: imageResourceId))
//                            cell.imageLivestream.sd_setImage(with: URL(string: livestreamModel.image ?? ""))

                    }
                    
                    if (urlStringOfImageToShare != nil) {
                        let imageUrl = URL(string: urlStringOfImageToShare!)
                        
                        // Wait for remote image to be downloaded.
                        let tempImageView = UIImageView()
                        tempImageView.sd_setImage(with: imageUrl, completed: { (image, error, type, url) in
                            self.shareImageToInstagram(storiesUrl, image)
                        })
                    }
                } else {
                    GeneralUtils.log(TAG, "URL can't be opened.")
                }
            }
        }
        if (sender == buttonShareInstagramDirect) {
            let textContentString = getSharingUrlForMedia()
            let textContentEncoded = textContentString.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
            
            if let url = URL(string: "instagram://sharesheet?text=" + textContentEncoded) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        if (sender == buttonShareFacebook) {
            let textContentString = getSharingUrlForMedia()
            let textContentEncoded = textContentString.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
            
            UIApplication.shared.open(URL(string: "https://www.facebook.com/sharer/sharer.php?u=" + textContentEncoded)!, options: [:], completionHandler: nil)
        }
        if (sender == buttonShareMessenger) {
            let textContentString = getSharingUrlForMedia()
            let textContentEncoded = textContentString.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
            let linkAsText = textContentEncoded
            
            let urlStr = String(format: "fb-messenger://share/?link=%@", linkAsText)
            let url  = URL(string: urlStr)!
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        if (sender == buttonShareSms) {
            if (MFMessageComposeViewController.canSendText()) {
                let controller = MFMessageComposeViewController()
                controller.body = getSharingUrlForMedia()
                controller.messageComposeDelegate = self
                self.present(controller, animated: true, completion: nil)
            }
        }
        if (sender == buttonShareClipboard) {
            copyLinkToClipboard()
        }
    }
    
    func setContainerView(_ containerSharingPanel: UIView) {
        self.containerSharingPanel = containerSharingPanel
    }
    
    func setContainerBottomConstraintReference(_ containerSharingPanelBottomConstraint: NSLayoutConstraint) {
        self.containerSharingPanelBottomConstraint = containerSharingPanelBottomConstraint
    }
    
    func setEpisodeModel(_ episodeModel: EpisodeModel) {
        unsetContent()
        
        self.episodeModel = episodeModel
    }
    
    func setLivestreamModel(_ livestreamModel: /*LivestreamModel*/RadioChannel) {
        unsetContent()
        
        self.livestreamModel = livestreamModel
    }
    
    func setBroadcastModel(_ broadcastModel: BroadcastModel) {
        unsetContent()
        
        self.broadcastModel = broadcastModel
    }
    
    func unsetContent() {
        episodeModel = nil
        livestreamModel = nil
        broadcastModel = nil
    }
    
    func openPanel() {
        isOpened = true

        DispatchQueue.main.async { [weak self] in
            if (self != nil) {
                self!.containerSharingPanelBottomConstraint.constant = -self!.view.frame.height
                self!.containerSharingPanel.superview!.layoutIfNeeded()

                UIView.animate(withDuration: 0.3, animations: {
                    self!.containerSharingPanelBottomConstraint.constant = 0
                    self!.containerSharingPanel.superview!.layoutIfNeeded()
                })
            }
        }
    }
    
    func closePanel() {
        isOpened = false

        UIView.animate(withDuration: 0.3, animations: {
            self.containerSharingPanelBottomConstraint.constant = -self.view.frame.height
            self.containerSharingPanel.superview!.layoutIfNeeded()
        })
    }

    func togglePanel() {
        if (isOpened) {
            closePanel()
        } else {
            openPanel()
        }
    }
    
    func updateSharingPanel() {
        // update title
        textMediaTitle.setVisibility(UIView.VISIBILITY_VISIBLE)
        
        if (episodeModel != nil) {
            // update title
            let title = episodeModel.getTitle()
            textMediaTitle.setText(title)
            
            // update category name
            let categoryName = episodeModel.getCategoryName()
            textBroadcastName.setText(categoryName)
            
            // update image
            let imageUrl = episodeModel.getImageUrl()
            imageMedia.sd_setImage(with: URL(string: imageUrl), completed: nil)
        }
        
        if (livestreamModel != nil) {
            // update title
            textMediaTitle.setVisibility(UIView.VISIBILITY_GONE)
            
            // update category name
            let categoryName = livestreamModel.name // getName()
            textBroadcastName.setText(categoryName)
            
            // update image
            //let imageResourceId = livestreamModel.getImageResourceId()
            //imageMedia.image = UIImage(named: imageResourceId)
            if (livestreamModel.image != nil) {
                imageMedia.sd_setImage(with: URL(string: livestreamModel.image ?? ""))
            } else {
                imageMedia.image = nil
            }
        }
        
        if (broadcastModel != nil) {
            // update title
            let title = broadcastModel.getTitle()
            textMediaTitle.setText(title)
            
            // update category name
            let categoryName = broadcastModel.getCategoryName()
            textBroadcastName.setText(categoryName)
            
            // update image
            if let imageUrl = broadcastModel.getImageUrl() {
                imageMedia.sd_setImage(with: URL(string: imageUrl), completed: nil)
            }
        }
        
        // show only valid sharing options
        
        if (!GeneralUtils.isAppInstalled("whatsapp")) {
            buttonShareWhatsApp.setVisibility(UIView.VISIBILITY_GONE)
        }
        
        if (!GeneralUtils.isAppInstalled("instagram")) {
            buttonShareInstagramStories.setVisibility(UIView.VISIBILITY_GONE)
            buttonShareInstagramDirect.setVisibility(UIView.VISIBILITY_GONE)
        }
        
        if (!GeneralUtils.isAppInstalled("fb-messenger")) {
            buttonShareMessenger.setVisibility(UIView.VISIBILITY_GONE)
        }
        
        if (!MFMessageComposeViewController.canSendText()) {
            buttonShareSms.setVisibility(UIView.VISIBILITY_GONE)
        }
    }
    
    func getSharingUrlForMedia() -> String {
        var url = ""

        if let episodeModel = episodeModel {
            let episodeId = episodeModel.getId()
            let episodeUrl: String = episodeModel.getUrl() ?? ""
            
            url = Configuration.HOST + "/" + DeepLinkManager.DEEP_LINK_ID_SHARED_EPISODE + "?" + DeepLinkSharedEpisodeModel.DEEP_LINK_QUERY_PARAM_EPISODE_ID + "=" + episodeId + "&" + DeepLinkSharedEpisodeModel.DEEP_LINK_QUERY_PARAM_EPISODE_URL + "=" + episodeUrl
        }

        if let livestreamModel = livestreamModel {
            let livestreamId = livestreamModel.id //getId().lowercased()

            url = Configuration.HOST + "/" + DeepLinkManager.DEEP_LINK_ID_SHARED_LIVESTREAM + "?" + DeepLinkSharedLivestreamModel.DEEP_LINK_QUERY_PARAM_LIVESTREAM_ID + "=" + String(describing: livestreamId) // livestreamId
        }
        
        if let broadcastModel = broadcastModel {
            let broadcastId = broadcastModel.getId()
            let broadcastUrl: String = broadcastModel.getUrl() ?? ""
            
            url = Configuration.HOST + "/" + DeepLinkManager.DEEP_LINK_ID_SHARED_BROADCAST + "?" + DeepLinkSharedBroadcastModel.DEEP_LINK_QUERY_PARAM_BROADCAST_ID + "=" + broadcastId + "&" + DeepLinkSharedBroadcastModel.DEEP_LINK_QUERY_PARAM_BROADCAST_URL + "=" + broadcastUrl
        }
        
        return url
    }
    
    func copyLinkToClipboard() {
        UIPasteboard.general.string = getSharingUrlForMedia()
        
        Toast.show(message: "copied_to_clipboard".localized(), controller: self)
    }
    
    func shareImageToInstagram(_ storiesUrl: URL, _ image: UIImage?) {
        guard let image = image else { return }
        guard let imageData = image.pngData() else { return }

        let pasteboardItems: [String: Any] = [
            "com.instagram.sharedSticker.backgroundImage": imageData,
            "com.instagram.sharedSticker.contentURL": getSharingUrlForMedia()
            
            // Leaving for reference:
//                        "com.instagram.sharedSticker.stickerImage": imageData,
//                        "com.instagram.sharedSticker.backgroundTopColor": "#33FF33",
//                        "com.instagram.sharedSticker.backgroundBottomColor": "#FF00FF"
        ]
        
        let pasteboardOptions = [
            UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(300)
        ]
            
        UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)

        UIApplication.shared.open(storiesUrl, options: [:], completionHandler: nil)
    }
}

extension SharingPanelViewController: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
}
