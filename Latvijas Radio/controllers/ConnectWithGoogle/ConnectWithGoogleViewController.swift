//
//  ConnectWithGoogleViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

// https://firebase.google.com/docs/auth/ios/google-signin

import UIKit
import Firebase
import GoogleSignIn

protocol ConnectWithGoogleDelegate: AnyObject {
    func onGoogleSignInSuccess(_ firebaseUserId: String, _ firebaseAuthIdToken: String, _ firebaseUser: User, _ googleUser: GIDGoogleUser)
}

class ConnectWithGoogleViewController: UIViewController {
    
    static var TAG = String(describing: ConnectWithGoogleViewController.classForCoder())
    
    @IBOutlet weak var buttonConnectWithGoogle: UIButtonTertiaryIconed!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    weak var delegate: ConnectWithGoogleDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(ConnectWithGoogleViewController.TAG, "viewDidLoad")
        
        // Setup Google SignIn
        setupGoogleSignIn()
        
        // listeners
        buttonConnectWithGoogle.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        
        // UI
        view.translatesAutoresizingMaskIntoConstraints = false
        
        setViewStateNormal()
    }
    
    deinit {
        GeneralUtils.log(ConnectWithGoogleViewController.TAG, "deinit")
    }
    
    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonConnectWithGoogle) {
            performGoogleLogin()
        }
    }
    
    private func setupGoogleSignIn() {
        guard let clientID = GIDSignIn.sharedInstance.currentUser?.userID else { return }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
    }
    
    func setViewStateNormal() {
        buttonConnectWithGoogle.isEnabled = true
        
        buttonConnectWithGoogle.isHidden = false
        activityIndicator.isHidden = true
    }
    
    func setViewStateLoading() {
        buttonConnectWithGoogle.isEnabled = false
        
        buttonConnectWithGoogle.isHidden = true
        activityIndicator.isHidden = false
    }
    
    func performGoogleLogin() {
        setViewStateLoading()
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
            if let error = error {
                self.setViewStateNormal()
                print("DEBUG: Failed with error \(error.localizedDescription)")
                return
            }
            if let user = result?.user {
                self.authenticateGoogleWithFirebase(user)
            }
        }

        // Start the sign in flow!
//        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { user, error in
//
//            //if let error = error, user == nil {
//            if let error = error {
//                //GeneralUtils.log(ConnectWithGoogleViewController.TAG, "signIn error: ", error)
//
//                //if (error._code != -5) {
//                //    (self.parent as! AuthenticationViewController).notificationViewController.showNotification(text: error.localizedDescription)
//                //}
//
//                self.setViewStateNormal()
//
//                return
//            }
//
//            if let user = user {
//                authenticateGoogleWithFirebase(user)
//            }
//        }
    }
    
    func authenticateGoogleWithFirebase(_ googleUser: GIDGoogleUser) {
        //let credential = GoogleAuthProvider.credential(withIDToken: googleUser.authentication.idToken!,
        //                                               accessToken: googleUser.authentication.accessToken)
        let credential = GoogleAuthProvider.credential(withIDToken: googleUser.idToken?.tokenString ?? "", accessToken: googleUser.accessToken.tokenString)
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                GeneralUtils.log(ConnectWithGoogleViewController.TAG, "signIn error: ", error)
                
                (self.parent as! AuthenticationViewController).notificationViewController.showNotification(text: error.localizedDescription)
                
                self.setViewStateNormal()

              return
            }
            
            // User is signed in
//            GeneralUtils.log(ConnectWithGoogleViewController.TAG, "authResult: ", authResult)
//            GeneralUtils.log(ConnectWithGoogleViewController.TAG, "user: ", authResult!.user)
//            GeneralUtils.log(ConnectWithGoogleViewController.TAG, "email: ", authResult!.user.email)
//            GeneralUtils.log(ConnectWithGoogleViewController.TAG, "displayName: ", authResult!.user.displayName)
//            GeneralUtils.log(ConnectWithGoogleViewController.TAG, "uid: ", authResult!.user.uid)
//            GeneralUtils.log(ConnectWithGoogleViewController.TAG, "phoneNumber: ", authResult!.user.phoneNumber)

            authResult!.user.getIDTokenResult(forcingRefresh: true, completion: { result, error in
                if let error = error {
                    GeneralUtils.log(ConnectWithFacebookViewController.TAG, "getIDTokenResult error: ", error)
                    
                    (self.parent as! AuthenticationViewController).notificationViewController.showNotification(text: error.localizedDescription)
                    
                    self.setViewStateNormal()

                  return
                }

                let firebaseAuthIdToken = result!.token

                self.delegate?.onGoogleSignInSuccess(authResult!.user.uid, firebaseAuthIdToken, authResult!.user, googleUser)
            })
        }
    }
}

