//
//  ChallengeViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/17.
//

import Foundation
import UIKit
import SwiftUI

class ChallengeViewController: UIViewController {
    
    var bgView = ChallengeUIView()
    
    lazy var clearButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.bgGray
        button.addTarget(self, action: #selector(tappedClearBtn), for: .touchUpInside)
        button.setTitle("Clear", for: .normal)
        button.setTitleColor(UIColor.textGray, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        return button
    }()
    
    lazy var shareButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.bgGray
        button.addTarget(self, action: #selector(tappedShareBtn), for: .touchUpInside)
        button.setTitle("Share", for: .normal)
        button.setTitleColor(UIColor.textGray, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI() {
        view.addSubview(bgView)
        view.addSubview(clearButton)
        view.addSubview(shareButton)
        
        bgView.contentMode = .scaleAspectFill
        bgView.clipsToBounds = true
        bgView.isMultipleTouchEnabled = false
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "challenge_hiking")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        bgView.backgroundColor = UIColor(patternImage: image)
        
        bgView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingBottom: 200)
        
        clearButton.anchor(top: bgView.bottomAnchor, left: view.leftAnchor,
                           paddingTop: 10, paddingLeft: 80, width: 50, height: 50)
        
        shareButton.anchor(top: bgView.bottomAnchor, right: view.rightAnchor,
                           paddingTop: 10, paddingRight: 80, width: 50, height: 50)
        
    }
    
    @objc func tappedClearBtn() {
        bgView.clearCanvas()
    }
    
    @objc func tappedShareBtn() {
        let renderer = UIGraphicsImageRenderer(size: bgView.bounds.size)
        let image = renderer.image(actions: { _ in
           bgView.drawHierarchy(in: bgView.bounds, afterScreenUpdates: true)
        })
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
}
