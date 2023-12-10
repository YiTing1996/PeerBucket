//
//  Info.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2023/12/4.
//

import UIKit
import AuthenticationServices
import CryptoKit
import Firebase
import FirebaseAuth

#warning("fix user crud and navigation process")
class Info: NSObject {
    
    static let shared = Info()
    
    private override init() {
        super.init()
    }
    
    var currentUser: User?
    var paringUser: User?
    
    private var currentNonce: String?
    private weak var presenter: UIViewController?
    
    func prepareForAppLaunch() {
        if let userID = Auth.auth().currentUser?.uid {
            fetchUserData(identityType: .currentUser, id: userID) { _ in }
        }
    }
    
    func fetchUserData(identityType: IdentityType, id: String? = nil, completion: @escaping (Bool) -> Void) {
        let mockUserUID = identityType == .currentUser ? "AITNzRSyUdMCjV4WrQxT" : (id ?? "")
        UserManager.shared.fetchUserData(userID: mockUserUID) { [weak self] results in
            switch results {
            case .success(let user):
                if identityType == .currentUser {
                    self?.currentUser = user
                } else {
                    self?.paringUser = user
                }
                completion(true)
            case .failure(let error):
                Log.e(error.localizedDescription)
                completion(false)
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            Info.shared.signOut()
            guard let loginVC = presenter?.initFromStoryboard(with: .login) as? LoginViewController else { return }
            loginVC.modalPresentationStyle = .fullScreen
            presenter?.present(loginVC, animated: true)
        } catch let signOutError as NSError {
            Log.e(signOutError)
            presenter?.presentErrorAlert()
        }
        clearNotification()
    }
    
    func signIn() {
        signInWithApple()
    }
    
    func deleteAccount() {
        Auth.auth().currentUser?.delete { [weak self] error in
//            guard let self = self, let currentUser = self.currentUser, error == nil else {
//                guard let errorCode = error?._code, AuthErrorCode.Code(rawValue: errorCode) == .requiresRecentLogin else {
//                    Log.e(error?.localizedDescription)
//                    return
//                }
//                self?.presenter?.presentActionAlert(
//                    action: "Login",
//                    title: "Authentication Required",
//                    message: "Delete account requires authentication which needs to relogin. Do you want to login again?") {
//                        self?.signOut()
//                    }
//                return
//            }
//            self.deleteUserData(userID: currentUser.userID)
//            self.updateUserData(for: .paringUser, paringUser: [])
        }
    }
    
    private func loginHandler(_ result: Result<(User, Bool), Error>) {
        switch result {
        case .success(let (user, _)):
            currentUser = user
            presenter?.routeToLaunchScreen()
        case .failure(let error):
            presenter?.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
        }
    }
    
    private func clearNotification() {
        UIApplication.shared.unregisterForRemoteNotifications()
        let notifications = UNUserNotificationCenter.current()
        notifications.removeAllPendingNotificationRequests()
        notifications.removeAllDeliveredNotifications()
    }
    
    private func deleteUserData() {
//        UserManager.shared.deleteUserData(uid: userID) { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success:
//                guard let loginVC = self.initFromStoryboard(with: .login) as? LoginViewController else { return }
//                loginVC.modalPresentationStyle = .fullScreen
//                self.present(loginVC, animated: true)
//                self.presentAlert()
//                Log.v("delete account success")
//            case .failure(let error):
//                self.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
//                Log.e(error.localizedDescription)
//            }
//        }
    }
}

// MARK: Apple SignIn
extension Info: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {

            // Retrieve the secure nonce generated during Apple sign in
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }

            // Retrieve Apple identity token
            guard let appleIDToken = appleIDCredential.identityToken else {
                Log.e("Unable to fetch identity token")
                return
            }

            // Convert Apple identity token to string
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                Log.e("Unable to serialize token string from data: \(appleIDToken).")
                return
            }

            // Initialize a Firebase credential using secure nonce and Apple identity token
            let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)

            // User is signed in to Firebase with Apple
            Auth.auth().signIn(with: firebaseCredential) { [weak self] (authResult, error) in
                guard let self = self else { return }
                if let user = authResult?.user {
                    Log.v("Successfully signed in as \(user.uid)")
                    // to check if need to create a new user in firebase
                    UserManager.shared.signInWithApple(
                        uid: user.uid,
                        name: appleIDCredential.fullName?.givenName,
                        completion: self.loginHandler(_:))
                } else if let error = error {
                    Log.e(error.localizedDescription)
                }
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Log.e(error.localizedDescription)
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return presenter?.view.window ?? .init()
    }

    private func signInWithApple() {
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
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        return hashString
    }
}
