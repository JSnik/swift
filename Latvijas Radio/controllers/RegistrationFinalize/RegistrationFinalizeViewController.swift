//
//  RegistrationFinalizeViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit

class RegistrationFinalizeViewController: UIViewController {
    
    static var TAG = String(describing: RegistrationFinalizeViewController.classForCoder())

    @IBOutlet weak var wrapperForm: UIView!
    @IBOutlet weak var textFieldPassword: UITextFieldPrimary!
    @IBOutlet weak var textFieldPasswordRepeat: UITextFieldPrimary!
    @IBOutlet weak var buttonSave: UIButtonSecondary!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerNotification: UIView!
    
    weak var notificationViewController: NotificationViewController!
    
    var registrationEmailVerificationToken: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(RegistrationFinalizeViewController.TAG, "viewDidLoad")
        
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
        GeneralUtils.log(RegistrationFinalizeViewController.TAG, "deinit")
    }
    
    // MARK: Custom
    
    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonSave) {
            performRequestRegistrationStep2()
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
                    self?.performRequestRegistrationStep2()
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

    func performRequestRegistrationStep2() {
        dismissKeyboard()
        
        setViewStateLoading()

        // params
        let password = textFieldPassword.text
        let appInstanceId = GeneralUtils.getUserDefaults().string(forKey: Configuration.APP_INSTANCE_ID)

        let urlQueryItems = [
            URLQueryItem(name: RegistrationStep2Request.REQUEST_PARAM_REGISTRATION_TYPE, value: RegistrationStep2Request.REGISTRATION_TYPE_EMAIL),
            URLQueryItem(name: RegistrationStep2Request.REQUEST_PARAM_PASSWORD, value: password),
            URLQueryItem(name: RegistrationStep2Request.REQUEST_PARAM_REGISTRATION_EMAIL_VERIFICATION_TOKEN, value: registrationEmailVerificationToken),
            URLQueryItem(name: RegistrationStep2Request.REQUEST_PARAM_DEVICE_ID, value: appInstanceId)
        ]

        let registrationStep2Request = RegistrationStep2Request(notificationViewController, urlQueryItems)

        registrationStep2Request.successCallback = { [weak self] (data) -> Void in
            let userId = data[RegistrationStep2Request.RESPONSE_PARAM_USER_ID] as! String
            let accessToken = data[RegistrationStep2Request.RESPONSE_PARAM_ACCESS_TOKEN] as! String
            let refreshToken = data[RegistrationStep2Request.RESPONSE_PARAM_REFRESH_TOKEN] as! String
            
            let usersManager = UsersManager.getInstance()
            usersManager.performUserCreationOrUpdate(UserModel.LAST_KNOWN_SIGN_IN_METHOD_EMAIL, nil, userId, accessToken, refreshToken)
            
            self?.performRequestUserGet()
        }

        registrationStep2Request.errorCallback = { [weak self] (data) -> Void in
            self?.setViewStateNormal()
        }

        registrationStep2Request.execute()
    }
    
    func performRequestUserGet() {
        setViewStateLoading()
        
        let userGetRequest = UserGetRequest(notificationViewController)

        userGetRequest.successCallback = { [weak self] (data) -> Void in
            let usersManager = UsersManager.getInstance()
            usersManager.updateLocalUserData(data)
            
            PostAuthRegHelper.performPostProcedure({
                let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_DASHBOARD_CONTAINER, bundle: nil)
                                        .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_DASHBOARD_CONTAINER) as! DashboardContainerViewController)
                
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

