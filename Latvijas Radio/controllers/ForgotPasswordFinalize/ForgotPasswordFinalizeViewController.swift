//
//  ForgotPasswordFinalizeViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class ForgotPasswordFinalizeViewController: UIViewController {
    
    static var TAG = String(describing: ForgotPasswordFinalizeViewController.classForCoder())

    @IBOutlet weak var wrapperForm: UIView!
    @IBOutlet weak var textFieldPassword: UITextFieldPrimary!
    @IBOutlet weak var textFieldPasswordRepeat: UITextFieldPrimary!
    @IBOutlet weak var buttonSave: UIButtonSecondary!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerNotification: UIView!
    
    weak var notificationViewController: NotificationViewController!
    
    var passwordResetEmailVerificationToken: String!
    var email: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(ForgotPasswordFinalizeViewController.TAG, "viewDidLoad")
        
        // listeners
        buttonSave.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)

        // adjusts view size to accomodate for keyboard
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)

        setupTextFieldPassword()
        setupTextFieldPasswordRepeat()
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
        GeneralUtils.log(ForgotPasswordFinalizeViewController.TAG, "deinit")
    }
    
    // MARK: Custom
    
    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonSave) {
            performRequestForgotPasswordStep2()
        }
    }
    
    func setupTextFieldPassword() {
        textFieldPassword.textFieldDidChangeHandler = { [weak self] in
            self?.validateForm()
        }
        
        textFieldPassword.textFieldShouldReturnHandler = { [weak self] in
            self?.textFieldPasswordRepeat.becomeFirstResponder()
        }
    }

    func setupTextFieldPasswordRepeat() {
        textFieldPasswordRepeat.textFieldDidChangeHandler = { [weak self] in
            self?.validateForm()
        }

        textFieldPasswordRepeat.textFieldShouldReturnHandler = { [weak self] in
            if (self != nil) {
                if (self!.validateForm()) {
                    self?.performRequestForgotPasswordStep2()
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
        
        buttonSave.setVisibility(UIView.VISIBILITY_VISIBLE)
        activityIndicator.setVisibility(UIView.VISIBILITY_GONE)
    }

    func setViewStateLoading() {
        wrapperForm.alpha = Configuration.FORM_DISABLED_STATE_OPACITY
        wrapperForm.isUserInteractionEnabled = false
        
        buttonSave.setVisibility(UIView.VISIBILITY_GONE)
        activityIndicator.setVisibility(UIView.VISIBILITY_VISIBLE)
    }

    @discardableResult func validateForm() -> Bool {
        var passwordValid = false
        var passwordRepeatValid = false
        
        if (textFieldPassword.text?.count ?? 0 >= Configuration.PASSWORD_MIN_LENGTH ) {
            passwordValid = true
        }
        
        if (textFieldPasswordRepeat.text == textFieldPassword.text) {
            passwordRepeatValid = true
        }

        if (passwordValid && passwordRepeatValid) {
            buttonSave.isEnabled = true

            return true
        } else {
            buttonSave.isEnabled = false

            return false
        }
    }

    func performRequestForgotPasswordStep2() {
        dismissKeyboard()
        
        setViewStateLoading()

        // params
        let password = textFieldPassword.text

        let urlQueryItems = [
            URLQueryItem(name: ForgotPasswordStep2Request.REQUEST_PARAM_EMAIL, value: email),
            URLQueryItem(name: ForgotPasswordStep2Request.REQUEST_PARAM_PASSWORD_RESET_EMAIL_VERIFICATION_TOKEN, value: passwordResetEmailVerificationToken),
            URLQueryItem(name: ForgotPasswordStep2Request.REQUEST_PARAM_PASSWORD, value: password),
        ]

        let forgotPasswordStep2Request = ForgotPasswordStep2Request(notificationViewController, urlQueryItems)

        forgotPasswordStep2Request.successCallback = { [weak self] (data) -> Void in
            let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_AUTHENTICATION, bundle: nil)
                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_AUTHENTICATION) as! AuthenticationViewController)
            
            self?.navigationController?.pushViewController(viewController, animated: true)
            
            self?.removeSelfAsPreviousVCFromNavigationController()
        }

        forgotPasswordStep2Request.errorCallback = { [weak self] in
            self?.setViewStateNormal()
        }

        forgotPasswordStep2Request.execute()
    }
    
    func performRequestUserGet() {
        setViewStateLoading()
        
        let userGetRequest = UserGetRequest(notificationViewController)

        userGetRequest.successCallback = { [weak self] (data) -> Void in
            let usersManager = UsersManager.getInstance()
            usersManager.updateLocalUserData(data)
            
            PostAuthRegHelper.performPostProcedure({
                let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_DASHBOARD, bundle: nil)
                                        .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_DASHBOARD) as! DashboardViewController)
                
                self?.navigationController?.pushViewController(viewController, animated: true)

                self?.removeSelfAsPreviousVCFromNavigationController()
            })
        }

        userGetRequest.errorCallback = { [weak self] in
            self?.setViewStateNormal()
        }
        
        userGetRequest.execute()
    }
}

