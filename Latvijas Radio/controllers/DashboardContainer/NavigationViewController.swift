//
//  NavigationViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

protocol NavigationDelegate: AnyObject {
    func onNavigationItemClicked(_ position: Int)
}

class NavigationViewController: UIViewController {
    
    static var TAG = String(describing: NavigationViewController.classForCoder())

    static let NAVIGATION_ITEM_INDEX_DASHBOARD = 0
    static let NAVIGATION_ITEM_INDEX_LIVESTREAMS = 1
    static let NAVIGATION_ITEM_INDEX_BROADCASTS = 2
    static let NAVIGATION_ITEM_INDEX_SEARCH = 3
    static let NAVIGATION_ITEM_INDEX_MY_RADIO = 4
    
    @IBOutlet weak var buttonDashboard: UIButton!
    @IBOutlet weak var buttonLivestreams: UIButton!
    @IBOutlet weak var buttonBroadcasts: UIButton!
    @IBOutlet weak var buttonSearch: UIButton!
    @IBOutlet weak var buttonMyRadio: UIButton!
    @IBOutlet weak var textDashboard: UILabelLabel3Navigation!
    @IBOutlet weak var textLivestreams: UILabelLabel3Navigation!
    @IBOutlet weak var textBroadcasts: UILabelLabel3Navigation!
    @IBOutlet weak var textSearch: UILabelLabel3Navigation!
    @IBOutlet weak var textMyRadio: UILabelLabel3Navigation!
    
    weak var delegate: NavigationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(NavigationViewController.TAG, "viewDidLoad")

        // listeners
        buttonDashboard.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonLivestreams.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonBroadcasts.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonSearch.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonMyRadio.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)

        // UI
        view.translatesAutoresizingMaskIntoConstraints = false
        // Make the navigation bar's title with red text.
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: ColorsHelper.WHITE)! // UIColor.systemRed
        appearance.titleTextAttributes = [.foregroundColor: UIColor.lightText] // With a red background, make the title more readable.
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance // For iPhone small navigation bar in landscape.
            }

    deinit {
        GeneralUtils.log(NavigationViewController.TAG, "deinit")
    }
    
    // MARK: Custom
    
    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonDashboard) {
            delegate?.onNavigationItemClicked(NavigationViewController.NAVIGATION_ITEM_INDEX_DASHBOARD)
        }
        if (sender == buttonLivestreams) {
            delegate?.onNavigationItemClicked(NavigationViewController.NAVIGATION_ITEM_INDEX_LIVESTREAMS)
        }
        if (sender == buttonBroadcasts) {
            delegate?.onNavigationItemClicked(NavigationViewController.NAVIGATION_ITEM_INDEX_BROADCASTS)
        }
        if (sender == buttonSearch) {
            delegate?.onNavigationItemClicked(NavigationViewController.NAVIGATION_ITEM_INDEX_SEARCH)
        }
        if (sender == buttonMyRadio) {
            delegate?.onNavigationItemClicked(NavigationViewController.NAVIGATION_ITEM_INDEX_MY_RADIO)
        }
    }
    
    func setActiveNavigationIndex(_ position: Int) {
        let colorInactive = UIColor(named: ColorsHelper.BLACK)!
        let colorActive = UIColor(named: ColorsHelper.RED)!
        
        buttonDashboard.tintColor = colorInactive
        buttonLivestreams.tintColor = colorInactive
        buttonBroadcasts.tintColor = colorInactive
        buttonSearch.tintColor = colorInactive
        buttonMyRadio.tintColor = colorInactive
        
        textDashboard.textColor = colorInactive
        textLivestreams.textColor = colorInactive
        textBroadcasts.textColor = colorInactive
        textSearch.textColor = colorInactive
        textMyRadio.textColor = colorInactive
        
        switch (position) {
        case NavigationViewController.NAVIGATION_ITEM_INDEX_DASHBOARD:
            buttonDashboard.tintColor = colorActive
            textDashboard.textColor = colorActive
            
            break
        case NavigationViewController.NAVIGATION_ITEM_INDEX_LIVESTREAMS:
            buttonLivestreams.tintColor = colorActive
            textLivestreams.textColor = colorActive
            
            break
        case NavigationViewController.NAVIGATION_ITEM_INDEX_BROADCASTS:
            buttonBroadcasts.tintColor = colorActive
            textBroadcasts.textColor = colorActive
            
            break
        case NavigationViewController.NAVIGATION_ITEM_INDEX_SEARCH:
            buttonSearch.tintColor = colorActive
            textSearch.textColor = colorActive
            
            break
        case NavigationViewController.NAVIGATION_ITEM_INDEX_MY_RADIO:
            buttonMyRadio.tintColor = colorActive
            textMyRadio.textColor = colorActive
            
            break
        default:
            break
        }
    }
}

