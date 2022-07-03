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
        
        guard let url = URL(string: link) else {
            self.presentAlert(title: "Error", message: "Something went wrong, try again later")
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        let urlRequest: URLRequest = URLRequest(url: url)
        webView.load(urlRequest)

    }
    
}
