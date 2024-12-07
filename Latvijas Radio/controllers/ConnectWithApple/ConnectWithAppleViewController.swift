//
//  ConnectWithAppleViewController.swift
//  Latvijas Radio
//
//  Created by Sandis Putnis on 13/12/2021.
//

// https://firebase.google.com/docs/auth/ios/apple

import UIKit
import Firebase
import GoogleSignIn
import AuthenticationServices
import CryptoKit

protocol ConnectWithAppleDelegate: AnyObject {
    func onAppleSignInSuccess(_ firebaseUserId: String, _ firebaseAuthIdToken: String, _ firebaseUser: User, _ appleIdCredential: ASAuthorizationAppleIDCredential)
}

class ConnectWithAppleViewController: UIViewController {
    
    static var TAG = String(describing: ConnectWithAppleViewController.classForCoder())
    
    @IBOutlet weak var buttonConnectWithApple: UIButtonTertiaryIconed!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    weak var delegate: ConnectWithAppleDelegate?
    
    var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralUtils.log(ConnectWithAppleViewController.TAG, "viewDidLoad")
        
        // listeners
        buttonConnectWithApple.addTarget(self, action: #selector(clickHandler), for: .touchUpInside)
        
        // UI
        view.translatesAutoresizingMaskIntoConstraints = false
        
        setViewStateNormal()
    }
    
    deinit {
        GeneralUtils.log(ConnectWithAppleViewController.TAG, "deinit")
    }
    
    @objc func clickHandler(_ sender: UIView) {
        if (sender == buttonConnectWithApple) {
            performAppleLogin()
        }
    }
    
    func setViewStateNormal() {
        buttonConnectWithApple.isEnabled = true
        
        buttonConnectWithApple.isHidden = false
        activityIndicator.isHidden = true
    }
    
    func setViewStateLoading() {
        buttonConnectWithApple.isEnabled = false
        
        buttonConnectWithApple.isHidden = true
        activityIndicator.isHidden = false
    }
    
    func performAppleLogin() {
        setViewStateLoading()
        
        let request = createAppleIdRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        
        authorizationController.performRequests()
    }
    
    func createAppleIdRequest() -> ASAuthorizationAppleIDRequest {
        let appleIdProvider = ASAuthorizationAppleIDProvider()
        let request = appleIdProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        currentNonce = nonce
        
        return request
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
    
    func authenticateAppleWithFirebase(_ idTokenString: String, _ nonce: String, _ appleIdCredential: ASAuthorizationAppleIDCredential) {
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)

        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                GeneralUtils.log(ConnectWithAppleViewController.TAG, "signIn error: ", error)

                (self.parent as! AuthenticationViewController).notificationViewController.showNotification(text: error.localizedDescription)

                self.setViewStateNormal()

                return
            }

            // User is signed in
//            GeneralUtils.log(ConnectWithAppleViewController.TAG, "authResult: ", authResult)
//            GeneralUtils.log(ConnectWithAppleViewController.TAG, "user: ", authResult!.user)
//            GeneralUtils.log(ConnectWithAppleViewController.TAG, "email: ", authResult!.user.email)
//            GeneralUtils.log(ConnectWithAppleViewController.TAG, "displayName: ", authResult!.user.displayName)
//            GeneralUtils.log(ConnectWithAppleViewController.TAG, "uid: ", authResult!.user.uid)
//            GeneralUtils.log(ConnectWithAppleViewController.TAG, "phoneNumber: ", authResult!.user.phoneNumber)

            authResult!.user.getIDTokenResult(forcingRefresh: true, completion: { result, error in
                if let error = error {
                    GeneralUtils.log(ConnectWithAppleViewController.TAG, "getIDTokenResult error: ", error)

                    (self.parent as! AuthenticationViewController).notificationViewController.showNotification(text: error.localizedDescription)

                    self.setViewStateNormal()

                  return
                }

                let firebaseAuthIdToken = result!.token

                self.delegate?.onAppleSignInSuccess(authResult!.user.uid, firebaseAuthIdToken, authResult!.user, appleIdCredential)
            })
        }
    }
}

extension ConnectWithAppleViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent")
            }
            guard let appleIdToken = appleIdCredential.identityToken else {
                fatalError("Unable to fetch identity token")
            }
            guard let idTokenString = String(data: appleIdToken, encoding: .utf8) else {
                fatalError("Unable to serialize token string from data: \(appleIdToken.debugDescription)")
            }

            authenticateAppleWithFirebase(idTokenString, nonce, appleIdCredential)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        GeneralUtils.log(ConnectWithAppleViewController.TAG, "didCompleteWithError: ", error)
        
        setViewStateNormal()
    }
}

extension ConnectWithAppleViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
