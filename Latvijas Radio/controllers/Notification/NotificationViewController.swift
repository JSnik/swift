//
//  NotificationViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class NotificationViewController: UIViewController {
    
    static var TAG = String(describing: NotificationViewController.classForCoder())
    
    var STATE_OPENING = "STATE_OPENING"
    var STATE_OPENED = "STATE_OPENED"
    var STATE_CLOSED = "STATE_CLOSED"
    
    var containerNotification: UIView!
    var wrapperNotification: UIView!
    var textNotification: UILabel!
    var buttonNotificationErrorClose: UIButton!
    var currentNotificationWrapperHeight: CGFloat!
    
    var currentState: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(NotificationViewController.TAG, "viewDidLoad")

        // variables
        wrapperNotification = self.view.viewWithTag(1)!
        textNotification = (self.view.viewWithTag(2) as! UILabel)
        buttonNotificationErrorClose = (self.view.viewWithTag(3) as! UIButton)
        
        // listeners
        buttonNotificationErrorClose.addTarget(self, action: #selector(hideNotification), for: .touchUpInside)
        
        // UI
        view.translatesAutoresizingMaskIntoConstraints = false
        
        currentState = STATE_CLOSED

        hideNotificationInstantly()
    }
    
    override func viewDidLayoutSubviews() {
        checkState()
    }

    deinit {
        GeneralUtils.log(NotificationViewController.TAG, "deinit")
    }
    
    func setContainerView(_ containerNotification: UIView) {
        self.containerNotification = containerNotification
    }
    
    func checkState() {
        // this views height might have changed
        // do appropriate animations based on current state

        // set new height
        currentNotificationWrapperHeight = wrapperNotification.frame.size.height
        containerNotification.frame.size.height = currentNotificationWrapperHeight
        
        if (currentState == STATE_OPENING) {
            // set container to be out of screen and then translate
            containerNotification.transform = CGAffineTransform.identity.translatedBy(x: 0, y: -currentNotificationWrapperHeight)

            // animate
            UIView.animate(withDuration: 0.3, animations: {
                self.containerNotification.transform = self.containerNotification.transform.translatedBy(x: 0.0, y: self.currentNotificationWrapperHeight)
            }, completion: { _ in
                self.currentState = self.STATE_OPENED
            })
        }
    }
    
    func showNotification(text: String) {
        containerNotification.isHidden = false
        currentState = STATE_OPENING
        textNotification.text = text // setting text will trigger layoutSubviews

        // If we have a height constraint on wrapperNotification, then, because of automatic-constraint-break-recovery, settings text will not trigger layoutSubviews.
        // In that case call checkState() manually.
        //checkState()
    }
    
    @objc func hideNotification() {
        UIView.animate(withDuration: 0.3, animations: {
            var transform = CATransform3DIdentity
            transform = CATransform3DTranslate(transform, 0, -self.currentNotificationWrapperHeight, 0)
            self.containerNotification.layer.transform = transform
        }, completion: { (finished: Bool) in
            self.containerNotification.isHidden = true
            self.textNotification.text = ""
        })
    }
    
    func hideNotificationInstantly() {
        containerNotification.isHidden = true
        textNotification.text = ""
    }
}
