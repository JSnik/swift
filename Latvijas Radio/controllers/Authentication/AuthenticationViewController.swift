//
//  AuthenticationViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit
import Firebase
import GoogleSignIn
import AuthenticationServices

class AuthenticationViewController: UIViewController, ConnectWithGoogleDelegate, ConnectWithFacebookDelegate, ConnectWithAppleDelegate {
    
    static var TAG = String(describing: AuthenticationViewController.classForCoder())

    static let USER_HAS_GIVEN_PP_AND_TOS_CONSENT = "USER_HAS_GIVEN_PP_AND_TOS_CONSENT"
    static let SETTINGS_FROM_API = "SETTINGS_FROM_API"
    
    @IBOutlet weak var checkBoxTosAgreement: CheckBoxBase!
    @IBOutlet weak var buttonPrivacyPolicyLv: UIButton!
    @IBOutlet weak var buttonPrivacyPolicyRu: UIButton!
    @IBOutlet weak var wrapperContent: UIView!
    @IBOutlet weak var buttonLoginAsGuest: UIButtonPrimary!
    @IBOutlet weak var textFieldEmail: UITextFieldPrimary!
    @IBOutlet weak var textFieldPassword: UITextFieldPrimary!
    @IBOutlet weak var buttonForgotPassword: UIButtonForgotPassword!
    @IBOutlet weak var buttonLoginAsUser: UIButtonSecondary!
    @IBOutlet weak var buttonRegister: UIButtonQuaternary!
    @IBOutlet weak var wrapperForm: UIView!
    @IBOutlet weak var wrapperLoading: UIView!
    @IBOutlet weak var wrapperErrorButtons: UIView!
    @IBOutlet weak var buttonRetry: UIButtonPrimary!
    @IBOutlet weak var buttonListenToDownloads: UIButtonPrimary!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerNotification: UIView!
    
    weak var notificationViewController: NotificationViewController!
    weak var connectWithFacebookViewController: ConnectWithFacebookViewController!
    weak var connectWithGoogleViewController: ConnectWithGoogleViewController!
    weak var connectWithAppleViewController: ConnectWithAppleViewController!
    
    var initialNotificationMessage: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(AuthenticationViewController.TAG, "viewDidLoad")
                
        // listeners
        buttonPrivacyPolicyLv.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonPrivacyPolicyRu.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonLoginAsGuest.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonForgotPassword.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonLoginAsUser.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonRegister.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonRetry.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        buttonListenToDownloads.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)

        // adjusts view size to accomodate for keyboard
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        
        setupCheckBoxTosAgreement()
        
        setupTextFieldEmail()
        setupTextFieldPassword()
        hideKeyboardWhenTappedAround()
        
        // UI
        setViewStateFormNormal()

        validateForm()
        
        if (LanguageManager.currentInterfaceLanguageId == LanguageManager.LANGUAGE_ID_LV) {
            buttonPrivacyPolicyLv.isHidden = false
            buttonPrivacyPolicyRu.isHidden = true
        } else {
            buttonPrivacyPolicyLv.isHidden = true
            buttonPrivacyPolicyRu.isHidden = false
        }
        
        let userHasGivenPpAndTosConsent = GeneralUtils.getUserDefaults().bool(forKey: AuthenticationViewController.USER_HAS_GIVEN_PP_AND_TOS_CONSENT)
        checkBoxTosAgreement.isChecked = userHasGivenPpAndTosConsent
        
        onCheckBoxTosAgreementClick()
        
        performRequestSettings()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch(segue.identifier ?? "") {
        case StoryboardsHelper.SEGUE_EMBED_NOTIFICATION:
            self.notificationViewController = (segue.destination as! NotificationViewController)
            self.notificationViewController.setContainerView(containerNotification)
            
            break
        case StoryboardsHelper.SEGUE_EMBED_CONNECT_WITH_FACEBOOK:
            self.connectWithFacebookViewController = (segue.destination as! ConnectWithFacebookViewController)
            self.connectWithFacebookViewController.delegate = self
            
            break
        case StoryboardsHelper.SEGUE_EMBED_CONNECT_WITH_GOOGLE:
            self.connectWithGoogleViewController = (segue.destination as! ConnectWithGoogleViewController)
            self.connectWithGoogleViewController.delegate = self
            
            break
        case StoryboardsHelper.SEGUE_EMBED_CONNECT_WITH_APPLE:
            self.connectWithAppleViewController = (segue.destination as! ConnectWithAppleViewController)
            self.connectWithAppleViewController.delegate = self
            
            break
        default:
            break
        }
    }
    
    deinit {
        GeneralUtils.log(AuthenticationViewController.TAG, "deinit")
    }
    
    // MARK: ConnectWithGoogleDelegate
    
    func onGoogleSignInSuccess(_ firebaseUserId: String, _ firebaseAuthIdToken: String, _ firebaseUser: User, _ googleUser: GIDGoogleUser) {
        performRequestFederativeAuth(firebaseUserId, firebaseAuthIdToken, UserModel.LAST_KNOWN_SIGN_IN_METHOD_GOOGLE, firebaseUser, googleUser, nil, nil)
    }
    
    // MARK: ConnectWithFacebookDelegate
    
    func onFacebookSignInSuccess(_ firebaseUserId: String, _ firebaseAuthIdToken: String, _ firebaseUser: User, _ facebookUser: [String: Any]) {
        performRequestFederativeAuth(firebaseUserId, firebaseAuthIdToken, UserModel.LAST_KNOWN_SIGN_IN_METHOD_FACEBOOK, firebaseUser, nil, facebookUser, nil)
    }
    
    // MARK: ConnectWithAppleDelegate
    
    func onAppleSignInSuccess(_ firebaseUserId: String, _ firebaseAuthIdToken: String, _ firebaseUser: User, _ appleIdCredential: ASAuthorizationAppleIDCredential) {
        performRequestFederativeAuth(firebaseUserId, firebaseAuthIdToken, UserModel.LAST_KNOWN_SIGN_IN_METHOD_APPLE, firebaseUser, nil, nil, appleIdCredential)
    }
    
    // MARK: Custom
    
    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonPrivacyPolicyLv || sender == buttonPrivacyPolicyRu) {
            showContentPopup(ContentPopupViewController.CONTENT_TYPE_PRIVACY_POLICY)
        }
        if (sender == buttonLoginAsGuest) {
            performRequestRegistrationGuest()
        }
        if (sender == buttonForgotPassword) {
            let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_FORGOT_PASSWORD, bundle: nil)
                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_FORGOT_PASSWORD) as! ForgotPasswordViewController)
            
            navigationController?.pushViewController(viewController, animated: true)
        }
        if (sender == buttonLoginAsUser) {
            performRequestAuth()
        }
        if (sender == buttonRegister) {
            let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_REGISTRATION, bundle: nil)
                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_REGISTRATION) as! RegistrationViewController)
            
            navigationController?.pushViewController(viewController, animated: true)
        }
        if (sender == buttonRetry) {
            performRequestSettings()
        }
        if (sender == buttonListenToDownloads) {
            let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_OFFLINE_PLAYBACK, bundle: nil)
                                    .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_OFFLINE_PLAYBACK) as! OfflinePlaybackViewController)
            
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func setupCheckBoxTosAgreement() {
        checkBoxTosAgreement.addTarget(self, action: #selector(onCheckBoxTosAgreementClick), for: .touchUpInside)
    }
    
    @objc func onCheckBoxTosAgreementClick() {
        if (checkBoxTosAgreement.isChecked) {
            setViewStateContentEnabled()
        } else {
            setViewStateContentDisabled()
        }

        GeneralUtils.getUserDefaults().set(checkBoxTosAgreement.isChecked, forKey: AuthenticationViewController.USER_HAS_GIVEN_PP_AND_TOS_CONSENT)
    }

    func setupTextFieldEmail() {
        textFieldEmail.textFieldDidChangeHandler = { [weak self] in
            self?.validateForm()
        }
        
        textFieldEmail.textFieldShouldReturnHandler = { [weak self] in
            self?.textFieldPassword.becomeFirstResponder()
        }
    }
    
    func setupTextFieldPassword() {
        textFieldPassword.textFieldDidChangeHandler = { [weak self] in
            self?.validateForm()
        }
        
        textFieldPassword.textFieldShouldReturnHandler = { [weak self] in
            if (self != nil) {
                if (self!.validateForm()) {
                    self?.performRequestAuth()
                }
            }
        }
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        SoftKeyboardUtils.keyboardNotification(notification, scrollViewBottomConstraint, self.view)
    }
    
    func setViewStateContentEnabled() {
        wrapperContent.alpha = 1
        wrapperContent.isUserInteractionEnabled = true
    }
    
    func setViewStateContentDisabled() {
        wrapperContent.alpha = Configuration.FORM_DISABLED_STATE_OPACITY
        wrapperContent.isUserInteractionEnabled = false
    }
    
    func setViewStateFormNormal() {
        wrapperForm.setVisibility(UIView.VISIBILITY_VISIBLE)
        wrapperLoading.setVisibility(UIView.VISIBILITY_GONE)
        wrapperErrorButtons.setVisibility(UIView.VISIBILITY_GONE)
    }
    
    func setViewStateFormLoading() {
        wrapperForm.setVisibility(UIView.VISIBILITY_GONE)
        wrapperLoading.setVisibility(UIView.VISIBILITY_VISIBLE)
        wrapperErrorButtons.setVisibility(UIView.VISIBILITY_GONE)
    }
    
    func setViewStateRetry() {
        wrapperForm.setVisibility(UIView.VISIBILITY_GONE)
        wrapperLoading.setVisibility(UIView.VISIBILITY_GONE)
        wrapperErrorButtons.setVisibility(UIView.VISIBILITY_VISIBLE)
        buttonListenToDownloads.setVisibility(UIView.VISIBILITY_GONE)
        
        let usersManager = UsersManager.getInstance()
        let currentUser = usersManager.getCurrentUser()
        
        if (currentUser != nil) {
            buttonListenToDownloads.setVisibility(UIView.VISIBILITY_VISIBLE)
        }
    }
    
    @discardableResult func validateForm() -> Bool {
        var emailValid = false
        var passwordValid = false
        
        let email = EmailValidatorHelper.getValidatedEmail(textFieldEmail)
        if (email != nil) {
            emailValid = true
        }
        
        if (textFieldPassword.text?.count ?? 0 >= Configuration.PASSWORD_MIN_LENGTH ) {
            passwordValid = true
        }

        if (emailValid && passwordValid) {
            buttonLoginAsUser.isEnabled = true

            return true
        } else {
            buttonLoginAsUser.isEnabled = false

            return false
        }
    }
    
    func showContentPopup(_ contentType: String) {
        let viewControllerContentPopup = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_CONTENT_POPUP, bundle: nil)
                                            .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_CONTENT_POPUP) as! ContentPopupViewController)

        viewControllerContentPopup.modalTransitionStyle = .crossDissolve
        viewControllerContentPopup.contentType = contentType

        navigationController?.present(viewControllerContentPopup, animated: true, completion: nil)
    }
    
    func performRequestSettings() {
        dismissKeyboard()
        
        setViewStateFormLoading()

        let settingsRequest = SettingsRequest(notificationViewController)

        settingsRequest.successCallback = { [weak self] (data) -> Void in
            // save received content to appData
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions.prettyPrinted)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    GeneralUtils.getUserDefaults().set(jsonString, forKey: AuthenticationViewController.SETTINGS_FROM_API)
                }

            } catch {
                GeneralUtils.log(AuthenticationViewController.TAG, error.localizedDescription)
            }
            
            self?.performAutoLoginLogic()
        }

        settingsRequest.errorCallback = { [weak self] in
            self?.setViewStateRetry()
        }
        
        settingsRequest.execute()
    }
    
    func performAutoLoginLogic() {
        // if current user exists, do auto-login by getting user data (that check if accessToken is still valid)
        let usersManager = UsersManager.getInstance()
        if let currentUser = usersManager.getCurrentUser() {
            // for debugging purposes
            GeneralUtils.log(AuthenticationViewController.TAG, currentUser.getAccessToken() as Any)
            
            performRequestUserGet()
        } else {
            setViewStateFormNormal()
            
            if let initialNotificationMessage = initialNotificationMessage {
                notificationViewController?.showNotification(text: initialNotificationMessage)
            }
        }
    }
    
    func performRequestRegistrationGuest() {
        setViewStateFormLoading()
        
        // params
        let appInstanceId = GeneralUtils.getUserDefaults().string(forKey: Configuration.APP_INSTANCE_ID)

        let urlQueryItems = [
            URLQueryItem(name: RegistrationGuestRequest.REQUEST_PARAM_DEVICE_ID, value: appInstanceId)
        ]
        
        let registrationGuestRequest = RegistrationGuestRequest(notificationViewController, urlQueryItems)

        registrationGuestRequest.successCallback = { [weak self] (data) -> Void in
            let userId = data[RegistrationGuestRequest.RESPONSE_PARAM_USER_ID] as! String
            let accessToken = data[RegistrationGuestRequest.RESPONSE_PARAM_ACCESS_TOKEN] as! String
            let refreshToken = data[RegistrationGuestRequest.RESPONSE_PARAM_REFRESH_TOKEN] as! String
            
            let usersManager = UsersManager.getInstance()
            usersManager.performUserCreationOrUpdate(UserModel.LAST_KNOWN_SIGN_IN_METHOD_GUEST, nil, userId, accessToken, refreshToken)

            self?.performRequestUserGet()
        }

        registrationGuestRequest.errorCallback = { [weak self] in
            self?.setViewStateFormNormal()
        }
        
        registrationGuestRequest.execute()
    }
    
    func performRequestAuth() {
        dismissKeyboard()
        
        setViewStateFormLoading()

        // params
        let email = textFieldEmail.text ?? ""
        let password = textFieldPassword.text ?? ""
        let appInstanceId = GeneralUtils.getUserDefaults().string(forKey: Configuration.APP_INSTANCE_ID)!

        let urlQueryItems = [
            URLQueryItem(name: AuthRequest.REQUEST_PARAM_EMAIL, value: email),
            URLQueryItem(name: AuthRequest.REQUEST_PARAM_PASSWORD, value: password),
            URLQueryItem(name: AuthRequest.REQUEST_PARAM_DEVICE_ID, value: appInstanceId)
        ]

        let authRequest = AuthRequest(notificationViewController, urlQueryItems)

        authRequest.successCallback = { [weak self] (data) -> Void in
            let userId = data[AuthRequest.RESPONSE_PARAM_USER_ID] as! String
            let accessToken = data[AuthRequest.RESPONSE_PARAM_ACCESS_TOKEN] as! String
            let refreshToken = data[AuthRequest.RESPONSE_PARAM_REFRESH_TOKEN] as! String
            
            let usersManager = UsersManager.getInstance()
            usersManager.performUserCreationOrUpdate(UserModel.LAST_KNOWN_SIGN_IN_METHOD_EMAIL, nil, userId, accessToken, refreshToken)
            
            self?.performRequestUserGet()
        }

        authRequest.errorCallback = { [weak self] in
            self?.setViewStateFormNormal()
        }
        
        authRequest.execute()
    }
    
    func performRequestFederativeAuth(_ firebaseUserId: String, _ firebaseAuthIdToken: String, _ lastKnownSignInMethod: String, _ firebaseUser: User, _ googleUser: GIDGoogleUser?, _ facebookUser: [String: Any]?, _ appleIdCredential: ASAuthorizationAppleIDCredential?) {
        // params
        let appInstanceId = GeneralUtils.getUserDefaults().string(forKey: Configuration.APP_INSTANCE_ID)
        
        let urlQueryItems = [
            URLQueryItem(name: FederativeAuthRequest.REQUEST_PARAM_FIREBASE_ID, value: firebaseUserId),
            URLQueryItem(name: FederativeAuthRequest.REQUEST_PARAM_FIREBASE_AUTH_ID_TOKEN, value: firebaseAuthIdToken),
            URLQueryItem(name: FederativeAuthRequest.REQUEST_PARAM_DEVICE_ID, value: appInstanceId)
        ]
        
        let federativeAuthRequest = FederativeAuthRequest(notificationViewController, urlQueryItems)

        federativeAuthRequest.successCallback = { [weak self] (data) -> Void in
            let userId = data[FederativeAuthRequest.RESPONSE_PARAM_USER_ID] as! String
            let accessToken = data[FederativeAuthRequest.RESPONSE_PARAM_ACCESS_TOKEN] as! String
            let refreshToken = data[FederativeAuthRequest.RESPONSE_PARAM_REFRESH_TOKEN] as! String
            
            let usersManager = UsersManager.getInstance()
            usersManager.performUserCreationOrUpdate(lastKnownSignInMethod, firebaseUser, userId, accessToken, refreshToken)
            
            self?.performRequestUserGet()
        }

        federativeAuthRequest.errorCallback = { [weak self] (data) -> Void in
            let error = data
            
            if (error == FederativeAuthRequest.RESPONSE_ERROR_USER_NOT_FOUND) {
                self?.performRequestFederativeRegistration(lastKnownSignInMethod, firebaseUserId, firebaseAuthIdToken, firebaseUser, googleUser, facebookUser, appleIdCredential)
            } else {
                switch lastKnownSignInMethod {
                case UserModel.LAST_KNOWN_SIGN_IN_METHOD_GOOGLE:
                    self?.connectWithGoogleViewController.setViewStateNormal()
                    
                    break
                case UserModel.LAST_KNOWN_SIGN_IN_METHOD_FACEBOOK:
                    self?.connectWithFacebookViewController.setViewStateNormal()
                    
                    break
                case UserModel.LAST_KNOWN_SIGN_IN_METHOD_APPLE:
                    self?.connectWithAppleViewController.setViewStateNormal()
                    
                    break
                default:
                    break
                }
            }
        }
        
        federativeAuthRequest.execute()
    }
    
    func performRequestFederativeRegistration(_ lastKnownSignInMethod: String, _ firebaseUserId: String, _ firebaseAuthIdToken: String, _ firebaseUser: User, _ googleUser: GIDGoogleUser?, _ facebookUser: [String: Any]?, _ appleIdCredential: ASAuthorizationAppleIDCredential?) {
        // params
        var regType = ""
        let appInstanceId = GeneralUtils.getUserDefaults().string(forKey: Configuration.APP_INSTANCE_ID)
        
        var name = firebaseUser.displayName
        var email = ""
        
        switch lastKnownSignInMethod {
        case UserModel.LAST_KNOWN_SIGN_IN_METHOD_GOOGLE:
            regType = RegistrationStep2Request.REGISTRATION_TYPE_GOOGLE
            email = googleUser!.profile!.email
            
            break
        case UserModel.LAST_KNOWN_SIGN_IN_METHOD_FACEBOOK:
            regType = RegistrationStep2Request.REGISTRATION_TYPE_FACEBOOK
            
            if let facebookEmail = facebookUser!["email"] as? String {
                email = facebookEmail
            } else {
                // User has no email because he has registered in Facebook with phone number.
                // Show error and stop further execution.
                
                connectWithFacebookViewController.setViewStateNormal()
                
                notificationViewController.showNotification(text: "facebook_registration_fail_no_email".localized())
                
                return
            }
            
            break
        case UserModel.LAST_KNOWN_SIGN_IN_METHOD_APPLE:
            regType = RegistrationStep2Request.REGISTRATION_TYPE_APPLE
            email = appleIdCredential!.email ?? ""
            
            // No matter if we have logged in with apple user first or consecutive times,
            // firebase "displayName" will always be empty.
            // We get user name from appleIdCredential the very first time user signs up.
            // Consecutive times Apple won't provide name/email anymore.
            
            var fullName = appleIdCredential!.fullName?.givenName ?? ""
            
            if let familyName = appleIdCredential!.fullName?.familyName {
                fullName = fullName + " " + familyName
            }
            
            name = fullName
            
            break
        default:
            break
        }

        let urlQueryItems = [
            URLQueryItem(name: RegistrationStep2Request.REQUEST_PARAM_REGISTRATION_TYPE, value: regType),
            URLQueryItem(name: RegistrationStep2Request.REQUEST_PARAM_DEVICE_ID, value: appInstanceId),
            URLQueryItem(name: RegistrationStep2Request.REQUEST_PARAM_FIREBASE_ID, value: firebaseUserId),
            URLQueryItem(name: RegistrationStep2Request.REQUEST_PARAM_FIREBASE_AUTH_ID_TOKEN, value: firebaseAuthIdToken),
            URLQueryItem(name: RegistrationStep2Request.REQUEST_PARAM_EMAIL, value: email),
            URLQueryItem(name: RegistrationStep2Request.REQUEST_PARAM_NAME, value: name)
        ]
        
        let registrationStep2Request = RegistrationStep2Request(notificationViewController, urlQueryItems)

        registrationStep2Request.successCallback = { [weak self] (data) -> Void in
            let userId = data[RegistrationStep2Request.RESPONSE_PARAM_USER_ID] as! String
            let accessToken = data[RegistrationStep2Request.RESPONSE_PARAM_ACCESS_TOKEN] as! String
            let refreshToken = data[RegistrationStep2Request.RESPONSE_PARAM_REFRESH_TOKEN] as! String
            
            let usersManager = UsersManager.getInstance()
            usersManager.performUserCreationOrUpdate(lastKnownSignInMethod, firebaseUser, userId, accessToken, refreshToken)
            
            self?.performRequestUserGet()
        }

        registrationStep2Request.errorCallback = { [weak self] (data) -> Void in
            switch lastKnownSignInMethod {
            case UserModel.LAST_KNOWN_SIGN_IN_METHOD_GOOGLE:
                self?.connectWithGoogleViewController.setViewStateNormal()
                
                break
            case UserModel.LAST_KNOWN_SIGN_IN_METHOD_FACEBOOK:
                self?.connectWithFacebookViewController.setViewStateNormal()
                
                break
            case UserModel.LAST_KNOWN_SIGN_IN_METHOD_APPLE:
                self?.connectWithAppleViewController.setViewStateNormal()
                
                break
            default:
                break
            }
        }
        
        registrationStep2Request.execute()
    }
    
    func performRequestUserGet() {
        dismissKeyboard()
        
        setViewStateFormLoading()
        
        let userGetRequest = UserGetRequest(notificationViewController)

        userGetRequest.successCallback = { [weak self] (data) -> Void in
            let usersManager = UsersManager.getInstance()
            usersManager.updateLocalUserData(data)
            
            self?.getUserSubscribedEpisodes()
        }

        userGetRequest.errorCallback = { [weak self] in
            self?.setViewStateFormNormal()
        }
        
        userGetRequest.execute()
    }
    
    func getUserSubscribedEpisodes() {
        UserSubscribedEpisodesManager.getInstance().getUserSubscribedEpisodesIds({ [weak self] in
            PostAuthRegHelper.performPostProcedure({
                self?.proceed()
            })
        })
    }
    
    func proceed() {
        let viewController = (UIStoryboard(name: StoryboardsHelper.STORYBOARD_ID_DASHBOARD_CONTAINER, bundle: nil)
                                .instantiateViewController(withIdentifier: StoryboardsHelper.STORYBOARD_VIEW_CONTROLLER_ID_DASHBOARD_CONTAINER) as! DashboardContainerViewController)
        
        navigationController?.pushViewController(viewController, animated: true)

        removeSelfAsPreviousVCFromNavigationController()
    }
}

