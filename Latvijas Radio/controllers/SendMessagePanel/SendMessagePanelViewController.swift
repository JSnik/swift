//
//  SendMessagePanelViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class SendMessagePanelViewController: UIViewController {
    
    static var TAG = String(describing: SendMessagePanelViewController.classForCoder())

    @IBOutlet weak var imageMedia: UIImageView!
    @IBOutlet weak var textBroadcastName: UILabelLabel5!
    @IBOutlet weak var textMediaTitle: UILabelLabel2!
    @IBOutlet weak var buttonClose: UIButtonGenericWithCustomBackground!
    @IBOutlet var textFieldName: UITextFieldPrimary!
    @IBOutlet var textFieldMessage: UITextFieldPrimary!
    @IBOutlet var buttonSend: UIButtonSenary!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    
    weak var notificationViewController: NotificationViewController!
    
    var containerSendMessagePanel: UIView!
    var containerSendMessagePanelBottomConstraint: NSLayoutConstraint!
    var isOpened = false
    var episodeModel: EpisodeModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(SendMessagePanelViewController.TAG, "viewDidLoad")

        // listeners
        buttonClose.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonSend.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        
        // adjusts view size to accomodate for keyboard
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        
        setupTextFieldName()
        setupTextFieldMessage()
        hideKeyboardWhenTappedAround()

        // UI
        view.translatesAutoresizingMaskIntoConstraints = false
        
        self.containerSendMessagePanelBottomConstraint.constant = -self.view.frame.height
        
        validateForm()
        
        setViewStateNormal()
    }

    deinit {
        GeneralUtils.log(SendMessagePanelViewController.TAG, "deinit")
    }

    // MARK: Custom
    
    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonClose) {
            closePanel()
        }
        if (sender == buttonSend) {
            if (validateForm()) {
                performRequestMessageBroadcast()
            }
        }
    }
    
    func setupTextFieldName() {
        textFieldName.textFieldDidChangeHandler = { [weak self] in
            self?.validateForm()
        }
        
        textFieldName.textFieldShouldReturnHandler = { [weak self] in
            self?.textFieldMessage.becomeFirstResponder()
        }
    }
    
    func setupTextFieldMessage() {
        textFieldMessage.textFieldDidChangeHandler = { [weak self] in
            self?.validateForm()
        }
        
        textFieldMessage.textFieldShouldReturnHandler = { [weak self] in
            if (self != nil) {
                if (self!.validateForm()) {
                    self?.performRequestMessageBroadcast()
                }
            }
        }
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        SoftKeyboardUtils.keyboardNotification(notification, scrollViewBottomConstraint, self.view)
    }
    
    func setContainerView(_ containerSendMessagePanel: UIView) {
        self.containerSendMessagePanel = containerSendMessagePanel
    }
    
    func setContainerBottomConstraintReference(_ containerSendMessagePanelBottomConstraint: NSLayoutConstraint) {
        self.containerSendMessagePanelBottomConstraint = containerSendMessagePanelBottomConstraint
    }

    func setEpisodeModel(_ episodeModel: EpisodeModel?) {
        self.episodeModel = episodeModel
        
        closePanelInstantly()
    }

    func openPanel() {
        isOpened = true

        DispatchQueue.main.async { [weak self] in
            if (self != nil) {
                self!.containerSendMessagePanelBottomConstraint.constant = -self!.view.frame.height
                self!.containerSendMessagePanel.superview!.layoutIfNeeded()

                UIView.animate(withDuration: 0.3, animations: {
                    self!.containerSendMessagePanelBottomConstraint.constant = 0
                    self!.containerSendMessagePanel.superview!.layoutIfNeeded()
                })
            }
        }
    }

    func closePanel() {
        isOpened = false

        UIView.animate(withDuration: 0.3, animations: {
            self.containerSendMessagePanelBottomConstraint.constant = -self.view.frame.height
            self.containerSendMessagePanel.superview!.layoutIfNeeded()
        })
    }
    
    func closePanelInstantly() {
        isOpened = false

        self.containerSendMessagePanelBottomConstraint.constant = -self.view.frame.height

        DispatchQueue.main.async { [weak self] in
            if (self != nil) {
                self!.containerSendMessagePanelBottomConstraint.constant = -self!.view.frame.height
                self!.containerSendMessagePanel.superview!.layoutIfNeeded()
            }
        }
    }

    func togglePanel() {
        if (isOpened) {
            closePanel()
        } else {
            openPanel()
        }
    }

    func updateSendMessagePanel() {
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
    }
    
    func setViewStateNormal() {
        textFieldName.alpha = 1
        textFieldName.isUserInteractionEnabled = true
        textFieldMessage.alpha = 1
        textFieldMessage.isUserInteractionEnabled = true
        
        buttonSend.isHidden = false
        activityIndicator.setVisibility(UIView.VISIBILITY_GONE)
    }
    
    func setViewStateLoading() {
        textFieldName.alpha = Configuration.FORM_DISABLED_STATE_OPACITY
        textFieldName.isUserInteractionEnabled = false
        textFieldMessage.alpha = Configuration.FORM_DISABLED_STATE_OPACITY
        textFieldMessage.isUserInteractionEnabled = false
        
        buttonSend.isHidden = true
        activityIndicator.setVisibility(UIView.VISIBILITY_VISIBLE)
    }
    
    @discardableResult func validateForm() -> Bool {
        var nameValid = false
        var messageValid = false
        
        if (textFieldName.text?.count ?? 0 > 0) {
            nameValid = true
        }
        
        if (textFieldMessage.text?.count ?? 0 > 0) {
            messageValid = true
        }

        if (nameValid && messageValid) {
            buttonSend.isEnabled = true

            return true
        } else {
            buttonSend.isEnabled = false

            return false
        }
    }
    
    func performRequestMessageBroadcast() {
        dismissKeyboard()
        
        if (episodeModel != nil) {
            setViewStateLoading()

            // params
            let name = textFieldName.text!
            let message = textFieldMessage.text!
            let email = episodeModel.getBroadcastEmail()

            let urlQueryItems = [
                URLQueryItem(name: MessageBroadcastRequest.REQUEST_PARAM_NAME, value: name),
                URLQueryItem(name: MessageBroadcastRequest.REQUEST_PARAM_MESSAGE, value: message),
                URLQueryItem(name: MessageBroadcastRequest.REQUEST_PARAM_EMAIL, value: email)
            ]

            let messageBroadcastRequest = MessageBroadcastRequest(notificationViewController, urlQueryItems)

            messageBroadcastRequest.successCallback = { [weak self] (data) -> Void in
                // reset form
                self?.textFieldName.text = ""
                self?.textFieldMessage.text = ""
                
                self?.setViewStateNormal()
                
                if (self?.parent != nil) {
                    Toast.show(message: "message_sent".localized(), controller: self!.parent!)
                }
                
                self?.closePanel()
            }
            
            messageBroadcastRequest.errorCallback = { [weak self] in
                self?.setViewStateNormal()
            }

            messageBroadcastRequest.execute()
        }
    }
}

