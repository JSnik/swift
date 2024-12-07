//
//  MyRadioTabsNavigationViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

protocol MyRadioTabsNavigationDelegate: AnyObject {
    func onNavigationItemClicked(_ position: Int)
}

class MyRadioTabsNavigationViewController: UIViewController {
    
    static var TAG = String(describing: MyRadioTabsNavigationViewController.classForCoder())

    @IBOutlet weak var buttonNewEpisodes: UIButtonIBCustomizable!
    @IBOutlet weak var buttonMyList: UIButtonIBCustomizable!
    @IBOutlet weak var buttonDownloads: UIButtonIBCustomizable!
    @IBOutlet weak var borderIndicatorLeadingConstraint: NSLayoutConstraint!
    
    weak var delegate: MyRadioTabsNavigationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(MyRadioTabsNavigationViewController.TAG, "viewDidLoad")

        // listeners
        buttonNewEpisodes.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonMyList.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonDownloads.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)

        // UI
        view.translatesAutoresizingMaskIntoConstraints = false
    }

    deinit {
        GeneralUtils.log(MyRadioTabsNavigationViewController.TAG, "deinit")
    }
    
    // MARK: Custom
    
    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonNewEpisodes) {
            delegate?.onNavigationItemClicked(MyRadioTabsPageViewController.PAGE_INDEX_NEW_EPISODES_FROM_SUBSCRIBED_BROADCASTS)
        }
        if (sender == buttonMyList) {
            delegate?.onNavigationItemClicked(MyRadioTabsPageViewController.PAGE_INDEX_SUBSCRIBED_EPISODES)
        }
        if (sender == buttonDownloads) {
            delegate?.onNavigationItemClicked(MyRadioTabsPageViewController.PAGE_INDEX_DOWNLOADS)
        }
    }
    
    func setActiveNavigationIndex(_ position: Int) {
        let colorInactive = UIColor(named: ColorsHelper.GRAY_3)!
        let colorActive = UIColor(named: ColorsHelper.BLACK)!

        buttonNewEpisodes.tintColor = colorInactive
        buttonMyList.tintColor = colorInactive
        buttonDownloads.tintColor = colorInactive
        
        var newConstant: CGFloat!
        let itemWidth = UIScreen.main.bounds.size.width / 3

        switch (position) {
        case MyRadioTabsPageViewController.PAGE_INDEX_NEW_EPISODES_FROM_SUBSCRIBED_BROADCASTS:
            buttonNewEpisodes.tintColor = colorActive
            
            newConstant = 0

            break
        case MyRadioTabsPageViewController.PAGE_INDEX_SUBSCRIBED_EPISODES:
            buttonMyList.tintColor = colorActive
            
            newConstant = itemWidth

            break
        case MyRadioTabsPageViewController.PAGE_INDEX_DOWNLOADS:
            buttonDownloads.tintColor = colorActive

            newConstant = itemWidth * 2
            
            break
        default:
            break
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction], animations: {
            self.borderIndicatorLeadingConstraint.constant = newConstant
            
            self.view.layoutIfNeeded()
        })
    }
}

