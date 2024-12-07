//
//  TabsNavigationViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

protocol TabsNavigationDelegate: AnyObject {
    func onNavigationItemClicked(_ position: Int)
}

class TabsNavigationViewController: UIViewController {
    
    static var TAG = String(describing: TabsNavigationViewController.classForCoder())
    
    @IBOutlet weak var buttonLatin: UIButtonIBCustomizable!
    @IBOutlet weak var buttonCyrillic: UIButtonIBCustomizable!
    
    weak var delegate: TabsNavigationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(TabsNavigationViewController.TAG, "viewDidLoad")

        // listeners
        buttonLatin.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonCyrillic.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)

        // UI
        view.translatesAutoresizingMaskIntoConstraints = false
    }

    deinit {
        GeneralUtils.log(TabsNavigationViewController.TAG, "deinit")
    }
    
    // MARK: Custom
    
    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonLatin) {
            delegate?.onNavigationItemClicked(AllBroadcastsPageViewController.PAGE_INDEX_LATIN)
        }
        if (sender == buttonCyrillic) {
            delegate?.onNavigationItemClicked(AllBroadcastsPageViewController.PAGE_INDEX_CYRILLIC)
        }
    }
    
    func setActiveNavigationIndex(_ position: Int) {
        let colorInactive = UIColor(named: ColorsHelper.BLACK)!
        let colorActive = UIColor(named: ColorsHelper.RED)!
        
        buttonLatin.tintColor = colorInactive
        buttonCyrillic.tintColor = colorInactive
        
        switch (position) {
        case AllBroadcastsPageViewController.PAGE_INDEX_LATIN:
            buttonLatin.tintColor = colorActive

            break
        case AllBroadcastsPageViewController.PAGE_INDEX_CYRILLIC:
            buttonCyrillic.tintColor = colorActive
            
            break
        default:
            break
        }
    }
}

