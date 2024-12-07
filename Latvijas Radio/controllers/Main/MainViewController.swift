//
//  MainViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class MainViewController: UIViewController {
    
    static var TAG = String(describing: MainViewController.classForCoder())

    override func viewDidLoad() {
        super.viewDidLoad()

        GeneralUtils.log(MainViewController.TAG, "viewDidLoad")
  
//        var viewController: UIViewController!
//
//        let appInterfaceLanguage = GeneralUtils.getUserDefaults().string(forKey: LanguageManager.APP_INTERFACE_LANGUAGE)
//        if (appInterfaceLanguage == nil) {
//            viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_LANGUAGE, bundle: nil)
//                                .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_LANGUAGE) as! LanguageViewController)
//        } else {
//            LanguageManager.setupAppInterfaceLanguage()
//
//            viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_AUTHENTICATION, bundle: nil)
//                                .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_AUTHENTICATION) as! AuthenticationViewController)
//        }
        
        LanguageManager.setupAppInterfaceLanguage()
        
        let viewController: UIViewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_AUTHENTICATION, bundle: nil)
            .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_AUTHENTICATION) as! AuthenticationViewController)
        
        navigationController?.pushViewController(viewController, animated: false)

        removeSelfAsPreviousVCFromNavigationController()
    }
    
    deinit {
        GeneralUtils.log(MainViewController.TAG, "deinit")
    }
}

