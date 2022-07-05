//
//  PrivacyViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/7/4.
//

import Foundation
import UIKit
import WebKit
import Lottie

class PrivacyViewController: UIViewController, WKNavigationDelegate {
    
    convenience init(urlString: String) {
        self.init()
        self.urlString = urlString
    }
    private var urlString: String!

//    private let loadingAnimationView = LottieAnimation.shared.createLoopAnimation(lottieName: "lottieLoading")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadURL(urlString: urlString)
    }
    
    private func loadURL(urlString: String) {
        let url = URL(string: urlString)
        if let url = url {
            let request = URLRequest(url: url)
            let webView = WKWebView()
            webView.navigationDelegate = self
            webView.load(request)
            webView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(webView)
            view.sendSubviewToBack(webView)
            NSLayoutConstraint.activate([
                webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        }
    }
}

// MARK: - WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {

//        view.addSubview(loadingAnimationView)
//        NSLayoutConstraint.activate([
//            loadingAnimationView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
//            loadingAnimationView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
//            loadingAnimationView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
//            loadingAnimationView.heightAnchor.constraint(equalTo: loadingAnimationView.widthAnchor)
//        ])
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
//        LottieAbnimation.shared.stopAnimation(lottieAnimation: loadingAnimationView)
    }
}
