//
//  NotificationsViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class NotificationsViewController: UIViewController {
    
    var TAG = String(describing: NotificationsViewController.classForCoder())

    @IBOutlet weak var buttonBack: UIButtonQuinary!
    
    weak var notificationsCollectionViewController: NotificationsCollectionViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(TAG, "viewDidLoad")
        
        // listeners
        buttonBack.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)

        // UI
        populateViewWithData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch(segue.identifier ?? "") {
        case StoryboardsHelper.SEGUE_EMBED_NOTIFICATIONS_COLLECTION:
            self.notificationsCollectionViewController = (segue.destination as! NotificationsCollectionViewController)
            
            break
        default:
            break
        }
    }
    
    deinit {
        GeneralUtils.log(TAG, "deinit")
    }
    
    // MARK: Custom
    
    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonBack) {
            navigationController?.popViewController(animated: true)
        }
    }

    func populateViewWithData() {
        let usersManager = UsersManager.getInstance()
        let currentUser = usersManager.getCurrentUser()!

        let dataset = currentUser.getReceivedNotifications()
        
        for i in (0..<dataset.count) {
            let notificationModel = dataset[i]
            
            notificationModel.setIsRead(true)
        }

        usersManager.saveCurrentUserData()
        
        notificationsCollectionViewController.updateDataset(dataset)
    }
}
