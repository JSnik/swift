//
//  SupportViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class SupportViewController: UIViewController {
    
    static var TAG = String(describing: SupportViewController.classForCoder())

    @IBOutlet weak var buttonBack: UIButtonQuinary!
    @IBOutlet weak var wrapperForm: UIView!
    @IBOutlet weak var textFieldName: UITextFieldPrimary!
    @IBOutlet weak var textFieldEmail: UITextFieldPrimary!
    @IBOutlet weak var textViewMessage: UITextViewBase!
    @IBOutlet weak var buttonSend: UIButtonSecondary!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerNotification: UIView!
    @IBOutlet weak var wrapperSuccess: UIView!
    
    weak var notificationViewController: NotificationViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(SupportViewController.TAG, "viewDidLoad")
        
        // listeners
        buttonBack.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonSend.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)

        // adjusts view size to accomodate for keyboard
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)

        setupTextFieldName()
        setupTextFieldEmail()
        setupTextViewMessage()
        hideKeyboardWhenTappedAround()

        // UI
        setViewStateNormal()

        validateForm()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch(segue.identifier ?? "") {
        case StoryboardsHelper.SEGUE_EMBED_NOTIFICATION:
            self.notificationViewController = (segue.destination as! NotificationViewController)
            self.notificationViewController.setContainerView(containerNotification)
            
            break
        default:
            break
        }
    }
    
    deinit {
        GeneralUtils.log(SupportViewController.TAG, "deinit")
    }
    
    // MARK: Custom
    
    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonBack) {
            navigationController?.popViewController(animated: true)
        }
        if (sender == buttonSend) {
            performRequestSupport()
        }
    }
    
    func setupTextFieldName() {
        textFieldName.textFieldDidChangeHandler = { [weak self] in
            self?.validateForm()
        }
        
        textFieldName.textFieldShouldReturnHandler = { [weak self] in
            self?.textFieldEmail.becomeFirstResponder()
        }
    }

    func setupTextFieldEmail() {
        textFieldEmail.textFieldDidChangeHandler = { [weak self] in
            self?.validateForm()
        }

        textFieldEmail.textFieldShouldReturnHandler = { [weak self] in
            self?.textViewMessage.becomeFirstResponder()
        }
    }
    
    func setupTextViewMessage() {
        textViewMessage.textViewDidChangeHandler = { [weak self] in
            self?.validateForm()
        }
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        SoftKeyboardUtils.keyboardNotification(notification, scrollViewBottomConstraint, self.view)
    }

    func setViewStateNormal() {
        wrapperForm.alpha = 1
        wrapperForm.isUserInteractionEnabled = true
        wrapperSuccess.setVisibility(UIView.VISIBILITY_GONE)
        
        buttonSend.setVisibility(UIView.VISIBILITY_VISIBLE)
        activityIndicator.setVisibility(UIView.VISIBILITY_GONE)
    }

    func setViewStateLoading() {
        wrapperForm.alpha = Configuration.FORM_DISABLED_STATE_OPACITY
        wrapperForm.isUserInteractionEnabled = false
        wrapperSuccess.setVisibility(UIView.VISIBILITY_GONE)
        
        buttonSend.setVisibility(UIView.VISIBILITY_GONE)
        activityIndicator.setVisibility(UIView.VISIBILITY_VISIBLE)
    }
    
    func setViewStateSent() {
        wrapperForm.setVisibility(UIView.VISIBILITY_GONE)
        wrapperSuccess.setVisibility(UIView.VISIBILITY_VISIBLE)
        
        buttonSend.setVisibility(UIView.VISIBILITY_GONE)
        activityIndicator.setVisibility(UIView.VISIBILITY_GONE)
    }

    @discardableResult func validateForm() -> Bool {
        var nameValid = false
        var emailValid = false
        var messageValid = false
        
        if (textFieldName.text?.count ?? 0 > 0 ) {
            nameValid = true
        }

        let email = EmailValidatorHelper.getValidatedEmail(textFieldEmail)
        if (email != nil) {
            emailValid = true
        }
        
        if (textViewMessage.text?.count ?? 0 > 0 && textViewMessage.text != textViewMessage.placeholder?.localized() ) {
            messageValid = true
        }

        if (nameValid && emailValid && messageValid) {
            buttonSend.isEnabled = true

            return true
        } else {
            buttonSend.isEnabled = false

            return false
        }
    }

    func performRequestSupport() {
        dismissKeyboard()
        
        setViewStateLoading()

        // params
        let name = textFieldName.text
        let email = textFieldEmail.text
        let message = textViewMessage.text
        
        let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let buildNumber: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        let appVersion = appVersionString + "." + buildNumber
        
        var deviceInformation = ""
        deviceInformation = deviceInformation + "System name: " + UIDevice.current.systemName + "\n"
        deviceInformation = deviceInformation + "System version: " + UIDevice.current.systemVersion + "\n"
        deviceInformation = deviceInformation + "Name: " + UIDevice.current.name + "\n"
        deviceInformation = deviceInformation + "Model: " + UIDevice.current.model + "\n"
        deviceInformation = deviceInformation + "App version: " + appVersion

        let urlQueryItems = [
            URLQueryItem(name: SupportRequest.REQUEST_PARAM_NAME, value: name),
            URLQueryItem(name: SupportRequest.REQUEST_PARAM_EMAIL, value: email),
            URLQueryItem(name: SupportRequest.REQUEST_PARAM_MESSAGE, value: message),
            URLQueryItem(name: SupportRequest.REQUEST_PARAM_DEVICE, value: deviceInformation)
        ]

        let supportRequest = SupportRequest(notificationViewController, urlQueryItems)

        supportRequest.successCallback = { [weak self] (data) -> Void in
            self?.setViewStateSent()
        }

        supportRequest.errorCallback = { [weak self] in
            self?.setViewStateNormal()
        }

        supportRequest.execute()
    }
}

