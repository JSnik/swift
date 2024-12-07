//
//  RegistrationViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class RegistrationViewController: UIViewController {
    
    static var TAG = String(describing: RegistrationViewController.classForCoder())

    @IBOutlet weak var buttonBack: UIButtonQuinary!
    @IBOutlet weak var wrapperForm: UIView!
    @IBOutlet weak var textFieldName: UITextFieldPrimary!
    @IBOutlet weak var textFieldEmail: UITextFieldPrimary!
    @IBOutlet weak var buttonRegister: UIButtonSecondary!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerNotification: UIView!
    
    weak var notificationViewController: NotificationViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(RegistrationViewController.TAG, "viewDidLoad")
        
        // listeners
        buttonBack.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonRegister.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)

        // adjusts view size to accomodate for keyboard
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)

        setupTextFieldName()
        setupTextFieldEmail()
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
        GeneralUtils.log(RegistrationViewController.TAG, "deinit")
    }
    
    // MARK: Custom
    
    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonBack) {
            navigationController?.popViewController(animated: true)
        }
        if (sender == buttonRegister) {
            performRequestRegistrationStep1()
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
            if (self != nil) {
                if (self!.validateForm()) {
                    self?.performRequestRegistrationStep1()
                }
            }
        }
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        SoftKeyboardUtils.keyboardNotification(notification, scrollViewBottomConstraint, self.view)
    }

    func setViewStateNormal() {
        wrapperForm.alpha = 1
        wrapperForm.isUserInteractionEnabled = true
        
        buttonRegister.setVisibility(UIView.VISIBILITY_VISIBLE)
        activityIndicator.setVisibility(UIView.VISIBILITY_GONE)
    }

    func setViewStateLoading() {
        wrapperForm.alpha = Configuration.FORM_DISABLED_STATE_OPACITY
        wrapperForm.isUserInteractionEnabled = false
        
        buttonRegister.setVisibility(UIView.VISIBILITY_GONE)
        activityIndicator.setVisibility(UIView.VISIBILITY_VISIBLE)
    }

    @discardableResult func validateForm() -> Bool {
        var nameValid = false
        var emailValid = false
        
        if (textFieldName.text?.count ?? 0 > 0 ) {
            nameValid = true
        }

        let email = EmailValidatorHelper.getValidatedEmail(textFieldEmail)
        if (email != nil) {
            emailValid = true
        }

        if (nameValid && emailValid) {
            buttonRegister.isEnabled = true

            return true
        } else {
            buttonRegister.isEnabled = false

            return false
        }
    }

    func performRequestRegistrationStep1() {
        dismissKeyboard()
        
        setViewStateLoading()

        // params
        let name = textFieldName.text
        let email = textFieldEmail.text

        let urlQueryItems = [
            URLQueryItem(name: RegistrationStep1Request.REQUEST_PARAM_NAME, value: name),
            URLQueryItem(name: RegistrationStep1Request.REQUEST_PARAM_EMAIL, value: email)
        ]

        let registrationStep1Request = RegistrationStep1Request(notificationViewController, urlQueryItems)

        registrationStep1Request.successCallback = { [weak self] (data) -> Void in
            let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_REGISTRATION_CHECK_EMAIL, bundle: nil)
                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_REGISTRATION_CHECK_EMAIL) as! RegistrationCheckEmailViewController)
            
            self?.navigationController?.pushViewController(viewController, animated: true)
            
            self?.removeSelfAsPreviousVCFromNavigationController()
        }

        registrationStep1Request.errorCallback = { [weak self] in
            self?.setViewStateNormal()
        }

        registrationStep1Request.execute()
    }
}

