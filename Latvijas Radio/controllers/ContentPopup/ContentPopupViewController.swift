//
//  ContentPopupViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class ContentPopupViewController: UIViewController {
    
    static var TAG = String(describing: ContentPopupViewController.classForCoder())
    
    static let CONTENT_TYPE_PRIVACY_POLICY = "CONTENT_TYPE_PRIVACY_POLICY"
    
    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var textTitle: UILabelH1!
    @IBOutlet weak var textContent: UITextViewHtml!
    
    var contentType: String!
    var content: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(ContentPopupViewController.TAG, "viewDidLoad")
        
        // listeners
        buttonClose.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        
        // UI
        populateViewWithData()
    }
    
    deinit {
        GeneralUtils.log(ContentPopupViewController.TAG, "deinit")
    }
    
    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonClose) {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func populateViewWithData() {
        var title = ""
        var content = ""
        
        if let settingsFromApi = GeneralUtils.getUserDefaults().object(forKey: AuthenticationViewController.SETTINGS_FROM_API) as? String {
            if let settingsFromApiAsData = settingsFromApi.data(using: .utf8) {
                let settingsFromApiJson = try? JSONSerialization.jsonObject(with: settingsFromApiAsData, options: [])
                if let settingsFromApiJson = settingsFromApiJson as? [String: Any] {
                    if (contentType == ContentPopupViewController.CONTENT_TYPE_PRIVACY_POLICY) {
                        title = "privacy_policy".localized()
                        content = settingsFromApiJson[SettingsRequest.RESPONSE_PARAM_PRIVACY_POLICY_AND_TERMS_OF_SERVICE_CONTENT] as! String
                    }
                    var replaced = content
                    if traitCollection.userInterfaceStyle == .light {
                        print("Light mode")
                    } else {
                        print("Dark mode")
                        replaced = content.replacingOccurrences(of: "#FEFFFF", with: "#010000")
                        replaced = replaced.replacingOccurrences(of: "background: white;", with: "background: clear;")
                    }
                    textTitle.setText(title)
                    textContent.setText(replaced.htmlToAttributedString!)
                }
            }
        }
    }
}

