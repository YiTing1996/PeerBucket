//
//  ChallengeViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/17.
//

import UIKit

final class ChallengeViewController: UIViewController {
    
    // MARK: - Properties

    private var bgView = ChallengeUIView()
    var bgImage: String = ""
    
    private lazy var clearButton: UIButton = create {
        $0.setTitle("Clear", for: .normal)
        $0.setTextBtn(bgColor: .lightGray, titleColor: .darkGreen,
                             border: 2.5, font: 20)
        $0.addTarget(self, action: #selector(tappedClearBtn), for: .touchUpInside)
    }
    
    private lazy var shareButton: UIButton = create {
        $0.setTitle("Share", for: .normal)
        $0.setTextBtn(bgColor: .darkGreen, titleColor: .lightGray, border: 2.5, font: 20)
        $0.addTarget(self, action: #selector(tappedShareBtn), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Configure UI

    private func configureUI() {
        view.backgroundColor = .lightGray
        view.addSubviews([bgView, clearButton, shareButton])
        bgView.contentMode = .scaleAspectFill
        bgView.clipsToBounds = true
        bgView.isMultipleTouchEnabled = false
        
        UIGraphicsBeginImageContext(view.frame.size)
        UIImage(named: bgImage)?.draw(in: view.bounds)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return }
        UIGraphicsEndImageContext()
        bgView.backgroundColor = UIColor(patternImage: image)
        
        bgView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor,
                      right: view.rightAnchor, paddingBottom: 180)
        clearButton.anchor(top: bgView.bottomAnchor, left: view.leftAnchor,
                           paddingTop: 20, paddingLeft: 80, width: 100, height: 50)
        shareButton.anchor(top: bgView.bottomAnchor, right: view.rightAnchor,
                           paddingTop: 20, paddingRight: 80, width: 100, height: 50)
    }
    
    // MARK: - User interaction handler

    @objc
    private func tappedClearBtn() {
        bgView.clearCanvas()
    }
    
    @objc
    private func tappedShareBtn() {
        let renderer = UIGraphicsImageRenderer(size: bgView.bounds.size)
        let image = renderer.image { _ in
           bgView.drawHierarchy(in: bgView.bounds, afterScreenUpdates: true)
        }
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
}
