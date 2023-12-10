//
//  WebViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/7/4.
//

import Foundation
import WebKit

final class WebViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!

    var link: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url = URL(string: link) else {
            presentErrorAlert()
            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true)
            return
        }
        let urlRequest: URLRequest = URLRequest(url: url)
        webView.load(urlRequest)
    }
}
