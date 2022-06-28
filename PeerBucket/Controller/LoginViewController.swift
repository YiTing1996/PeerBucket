//
//  LoginViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/20.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import CryptoKit
import AuthenticationServices

class LoginViewController: UIViewController {
    
    @IBOutlet weak var grayView: UIView!
    @IBOutlet weak var titleLabelGreen: UILabel!
    @IBOutlet weak var titleLabelGray: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    lazy var appleButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(type: .default, style: .black)
        button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        button.addTarget(self, action: #selector(tappedAppleBtn), for: .touchUpInside)
        return button
    }()
    
    private var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureUI()
        view.backgroundColor = .darkGreen
    }
    
    @objc func tappedAppleBtn() {
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email, .fullName]
        
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        currentNonce = nonce
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        
        controller.performRequests()
        
    }
}

// MARK: - Handle apple signinup
extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    private func loginHandler(_ result: Result<(User, Bool), Error>) {
        switch result {
        case .success((let user, let isExist)):
            
            if isExist {
                UserManager.shared.current = user
            } else {
                UserManager.shared.current = user
            }
            
            print("current user in loginVC: \(user)")
            
        case .failure(let error):
            print("loginHandler", error)
            presentErrorAlert(message: error.localizedDescription + " Please try again")
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            // Retrieve the secure nonce generated during Apple sign in
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            
            // Retrieve Apple identity token
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            
            // Convert Apple identity token to string
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken).")
                return
            }
            
            // Initialize a Firebase credential using secure nonce and Apple identity token
            let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            // User is signed in to Firebase with Apple
            Auth.auth().signIn(with: firebaseCredential) { [weak self] (authResult, error) in
                guard let self = self else { return }
                if let user = authResult?.user {
                    
                    print("Successfully signed in as \(user.uid)")
                    
                    // to check if need to create a new user in firebase
                    UserManager.shared.signInWithApple(uid: user.uid, name: appleIDCredential.fullName?.givenName,
                                                       completion: self.loginHandler(_:))
                    
                } else if let error = error {
                    print("Sign in error:", error.localizedDescription)
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        switch error {
        case ASAuthorizationError.canceled:
            break
        case ASAuthorizationError.failed:
            break
        case ASAuthorizationError.invalidResponse:
            break
        case ASAuthorizationError.notHandled:
            break
        case ASAuthorizationError.unknown:
            break
        default:
            break
        }
        
        print("didCompleteWithError: \(error.localizedDescription)")
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
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
    
    // Unhashed nonce
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
}

// MARK: - Configure UI

extension LoginViewController {
    
    func configureUI() {

        view.addSubview(appleButton)
        
        grayView.layer.cornerRadius = 40
        grayView.backgroundColor = .lightGray
        titleLabelGray.textColor = .lightGray
        titleLabelGreen.textColor = .darkGreen
        descriptionLabel.textColor = .darkGray
        appleButton.anchor(top: descriptionLabel.bottomAnchor, left: view.leftAnchor,
                           paddingTop: 20, paddingLeft: 150, width: 200, height: 50)
        
    }
    
}
