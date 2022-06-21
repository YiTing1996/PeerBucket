//
//  WebViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/19.
//

import Foundation
import WebKit

class WebViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!

    var link: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TO-DO: 如果網頁打不開跳錯誤訊息
        if link != "" {
            let url: URL = URL(string: link)!
            let urlRequest: URLRequest = URLRequest(url: url)
            webView.load(urlRequest)
        } else {
            self.presentErrorAlert(message: "Something went wrong, try again later")
            self.navigationController?.popViewController(animated: true)
        }

    }
    
}
