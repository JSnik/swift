//
//  ConnectWithFacebookViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

import UIKit
import FacebookLogin
import Firebase

// https://firebase.google.com/docs/auth/ios/facebook-login

protocol ConnectWithFacebookDelegate: AnyObject {
    func onFacebookSignInSuccess(_ firebaseUserId: String, _ firebaseAuthIdToken: String, _ firebaseUser: User, _ facebookUser: [String: Any])
}

class ConnectWithFacebookViewController: UIViewController {
    
    static var TAG = String(describing: ConnectWithFacebookViewController.classForCoder())
    
    @IBOutlet weak var buttonConnectWithFacebook: UIButtonTertiaryIconed!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    weak var delegate: ConnectWithFacebookDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(ConnectWithFacebookViewController.TAG, "viewDidLoad")
        
        // listeners
        buttonConnectWithFacebook.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        
        // UI
        view.translatesAutoresizingMaskIntoConstraints = false
        
        setViewStateNormal()
    }
    
    deinit {
        GeneralUtils.log(ConnectWithFacebookViewController.TAG, "deinit")
    }
    
    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonConnectWithFacebook) {
            performFacebookLogin()
        }
    }
    
    func setViewStateNormal() {
        buttonConnectWithFacebook.isEnabled = true
        
        buttonConnectWithFacebook.isHidden = false
        activityIndicator.isHidden = true
    }
    
    func setViewStateLoading() {
        buttonConnectWithFacebook.isEnabled = false
        
        buttonConnectWithFacebook.isHidden = true
        activityIndicator.isHidden = false
    }
    
    func performFacebookLogin() {
        setViewStateLoading()
        
        (self.parent as! AuthenticationViewController).notificationViewController.hideNotificationInstantly()
        
        let loginManager = LoginManager()
        loginManager.logOut()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { result, error in
            if let error = error {
                GeneralUtils.log(ConnectWithFacebookViewController.TAG, "logIn error: ", error)
                
                (self.parent as! AuthenticationViewController).notificationViewController.showNotification(text: error.localizedDescription)
                
                self.setViewStateNormal()
            } else if let result = result, result.isCancelled {
                self.setViewStateNormal()
            } else {
                GeneralUtils.log(ConnectWithFacebookViewController.TAG, "authenticationToken: ", result?.authenticationToken as Any)
                GeneralUtils.log(ConnectWithFacebookViewController.TAG, "userID: ", result?.token?.userID as Any)
                
                let graphRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                              parameters: ["fields": "id,email"],
                                                              tokenString: AccessToken.current!.tokenString,
                                                              version: nil,
                                                              httpMethod: .get)
                graphRequest.start { (connection, result, error) -> Void in
                    if error == nil {
                        let facebookUser = result as! [String: Any]
                        
                        self.authenticateFacebookWithFirebase(facebookUser)
                    }
                    else {
                        GeneralUtils.log(ConnectWithFacebookViewController.TAG, "graphRequest error: ", error as Any)
                        
                        (self.parent as! AuthenticationViewController).notificationViewController.showNotification(text: error!.localizedDescription)
                        
                        self.setViewStateNormal()
                    }
                }
            }
        }
    }
    
    func authenticateFacebookWithFirebase(_ facebookUser: [String: Any]) {
        let credential = FacebookAuthProvider
          .credential(withAccessToken: AccessToken.current!.tokenString)
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                GeneralUtils.log(ConnectWithFacebookViewController.TAG, "signIn error: ", error)
                
                (self.parent as! AuthenticationViewController).notificationViewController.showNotification(text: error.localizedDescription)
                
                self.setViewStateNormal()

              return
            }
            
            // User is signed in
//            GeneralUtils.log(ConnectWithFacebookViewController.TAG, "authResult: ", authResult)
//            GeneralUtils.log(ConnectWithFacebookViewController.TAG, "user: ", authResult!.user)
//            GeneralUtils.log(ConnectWithFacebookViewController.TAG, "email: ", authResult!.user.email)
//            GeneralUtils.log(ConnectWithFacebookViewController.TAG, "displayName: ", authResult!.user.displayName)
//            GeneralUtils.log(ConnectWithFacebookViewController.TAG, "uid: ", authResult!.user.uid)
//            GeneralUtils.log(ConnectWithFacebookViewController.TAG, "phoneNumber: ", authResult!.user.phoneNumber)

            authResult!.user.getIDTokenResult(forcingRefresh: true, completion: { result, error in
                if let error = error {
                    GeneralUtils.log(ConnectWithFacebookViewController.TAG, "getIDTokenResult error: ", error)
                    
                    (self.parent as! AuthenticationViewController).notificationViewController.showNotification(text: error.localizedDescription)
                    
                    self.setViewStateNormal()

                  return
                }

                let firebaseAuthIdToken = result!.token

                self.delegate?.onFacebookSignInSuccess(authResult!.user.uid, firebaseAuthIdToken, authResult!.user, facebookUser)
            })
        }
    }
}

