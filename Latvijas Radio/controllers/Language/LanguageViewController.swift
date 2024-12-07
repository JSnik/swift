//
//  LanguageViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class LanguageViewController: UIViewController {
    
    static var TAG = String(describing: LanguageViewController.classForCoder())
    
    @IBOutlet weak var buttonLanguageLatvian: UIButtonTertiary!
    @IBOutlet weak var buttonLanguageRussian: UIButtonTertiary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(LanguageViewController.TAG, "viewDidLoad")
        
        // listeners
        buttonLanguageLatvian.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonLanguageRussian.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        
        // UI
        buttonLanguageLatvian.setText(LanguageManager.LANGUAGE_DISPLAY_NAME_LV, false)
        buttonLanguageRussian.setText(LanguageManager.LANGUAGE_DISPLAY_NAME_RU, false)
    }
    
    deinit {
        GeneralUtils.log(LanguageViewController.TAG, "deinit")
    }
    
    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonLanguageLatvian) {
            proceed(LanguageManager.LANGUAGE_ID_LV)
        }
        if (sender == buttonLanguageRussian) {
            proceed(LanguageManager.LANGUAGE_ID_RU)
        }
    }
    
    func proceed(_ chosenLanguageId: String) {
        LanguageManager.setLanguage(chosenLanguageId)

        let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_AUTHENTICATION, bundle: nil)
                                .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_AUTHENTICATION) as! AuthenticationViewController)
        
        navigationController?.pushViewController(viewController, animated: true)

        removeSelfAsPreviousVCFromNavigationController()
    }
}

