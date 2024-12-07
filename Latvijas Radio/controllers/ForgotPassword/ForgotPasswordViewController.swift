//
//  ForgotPasswordViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class ForgotPasswordViewController: UIViewController {
    
    static var TAG = String(describing: ForgotPasswordViewController.classForCoder())

    @IBOutlet weak var wrapperForm: UIView!
    @IBOutlet weak var buttonBack: UIButtonQuinary!
    @IBOutlet weak var textFieldEmail: UITextFieldPrimary!
    @IBOutlet weak var buttonSend: UIButtonSecondary!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerNotification: UIView!
    
    weak var notificationViewController: NotificationViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(ForgotPasswordViewController.TAG, "viewDidLoad")
        
        // listeners
        buttonBack.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonSend.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)

        // adjusts view size to accomodate for keyboard
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)

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
        GeneralUtils.log(ForgotPasswordViewController.TAG, "deinit")
    }
    
    // MARK: Custom
    
    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonBack) {
            navigationController?.popViewController(animated: true)
        }
        if (sender == buttonSend) {
            performRequestForgotPasswordStep1()
        }
    }

    func setupTextFieldEmail() {
        textFieldEmail.textFieldDidChangeHandler = { [weak self] in
            self?.validateForm()
        }

        textFieldEmail.textFieldShouldReturnHandler = { [weak self] in
            if (self != nil) {
                if (self!.validateForm()) {
                    self?.performRequestForgotPasswordStep1()
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
        
        buttonSend.setVisibility(UIView.VISIBILITY_VISIBLE)
        activityIndicator.setVisibility(UIView.VISIBILITY_GONE)
    }

    func setViewStateLoading() {
        wrapperForm.alpha = Configuration.FORM_DISABLED_STATE_OPACITY
        wrapperForm.isUserInteractionEnabled = false
        
        buttonSend.setVisibility(UIView.VISIBILITY_GONE)
        activityIndicator.setVisibility(UIView.VISIBILITY_VISIBLE)
    }

    @discardableResult func validateForm() -> Bool {
        var emailValid = false

        let email = EmailValidatorHelper.getValidatedEmail(textFieldEmail)
        if (email != nil) {
            emailValid = true
        }

        if (emailValid) {
            buttonSend.isEnabled = true

            return true
        } else {
            buttonSend.isEnabled = false

            return false
        }
    }

    func performRequestForgotPasswordStep1() {
        dismissKeyboard()
        
        setViewStateLoading()

        // params
        let email = textFieldEmail.text

        let urlQueryItems = [
            URLQueryItem(name: ForgotPasswordStep1Request.REQUEST_PARAM_EMAIL, value: email)
        ]

        let forgotPasswordStep1Request = ForgotPasswordStep1Request(notificationViewController, urlQueryItems)

        forgotPasswordStep1Request.successCallback = { [weak self] (data) -> Void in
            let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_FORGOT_PASSWORD_CHECK_EMAIL, bundle: nil)
                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_FORGOT_PASSWORD_CHECK_EMAIL) as! ForgotPasswordCheckEmailViewController)
            
            self?.navigationController?.pushViewController(viewController, animated: true)
            
            self?.removeSelfAsPreviousVCFromNavigationController()
        }

        forgotPasswordStep1Request.errorCallback = { [weak self] in
            self?.setViewStateNormal()
        }

        forgotPasswordStep1Request.execute()
    }
}

