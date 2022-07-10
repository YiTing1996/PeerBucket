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
    var bgImage: String = ""
    
    lazy var clearButton: UIButton = {
        let button = UIButton()
        button.setTitle("Clear", for: .normal)
        button.setTextButton(bgColor: .lightGray, titleColor: .darkGreen,
                             border: 2.5, font: 20)
        button.addTarget(self, action: #selector(tappedClearBtn), for: .touchUpInside)
//        button.setTitle("Clear", for: .normal)
//        button.titleLabel?.font = UIFont.bold(size: 18)
//        button.setTitleColor(UIColor.darkGreen, for: .normal)
//        button.clipsToBounds = true
//        button.layer.borderWidth = 2.5
//        button.layer.cornerRadius = 10
//        button.layer.borderColor = UIColor.darkGreen.cgColor
        return button
    }()
    
    lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setTitle("Share", for: .normal)
        button.setTextButton(bgColor: .darkGreen, titleColor: .lightGray,
                             border: 2.5, font: 20)
        
//        button.backgroundColor = UIColor.darkGreen
        button.addTarget(self, action: #selector(tappedShareBtn), for: .touchUpInside)
//        button.setTitle("Share", for: .normal)
//        button.setTitleColor(UIColor.white, for: .normal)
//        button.titleLabel?.font = UIFont.bold(size: 18)
//        button.clipsToBounds = true
//        button.layer.cornerRadius = 10
//        button.layer.borderWidth = 2.5
//        button.layer.borderColor = UIColor.darkGreen.cgColor
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        view.backgroundColor = .lightGray
    }
    
    func configureUI() {
        view.addSubview(bgView)
        view.addSubview(clearButton)
        view.addSubview(shareButton)
        
        bgView.contentMode = .scaleAspectFill
        bgView.clipsToBounds = true
        bgView.isMultipleTouchEnabled = false
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: bgImage)?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        bgView.backgroundColor = UIColor(patternImage: image)
        
        bgView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor,
                      right: view.rightAnchor, paddingBottom: 180)
        
        clearButton.anchor(top: bgView.bottomAnchor, left: view.leftAnchor,
                           paddingTop: 20, paddingLeft: 80, width: 100, height: 50)
        
        shareButton.anchor(top: bgView.bottomAnchor, right: view.rightAnchor,
                           paddingTop: 20, paddingRight: 80, width: 100, height: 50)
        
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
