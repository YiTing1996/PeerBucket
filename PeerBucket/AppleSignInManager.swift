//
//  AppleSignInManager.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/27.
//

import Foundation
import CryptoKit
import AuthenticationServices

class AppleSignInManager: NSObject {
    var currentView: UIView?
    
    func signIn(currentView: UIView) {
        guard #available(iOS 13.0, *) else { return }
        self.currentView = currentView
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.email, .fullName]
        request.nonce = "[NONCE]"
        request.state = "[STATE]"
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

extension AppleSignInManager: ASAuthorizationControllerDelegate {
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithError error: Error) {
        // Handle error
        print(error)
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
        // Post identityToken & authorizationCode to your server
        print(String(decoding: credential.identityToken ?? Data.init(), as: UTF8.self))
        print(String(decoding: credential.authorizationCode ?? Data.init(), as: UTF8.self))
    }
}

extension AppleSignInManager: ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.currentView?.window ?? UIApplication.shared.keyWindow!
    }
}
