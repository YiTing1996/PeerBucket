//
//  HomeViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/18.
//

import Foundation
import UIKit

class HomeViewController: UIViewController {
    
    var bgImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "mock_avatar")
        return imageView
    }()
    
    var eventView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .bgGray
        view.layer.cornerRadius = 20
        view.alpha = 0.5
        return view
    }()
    
    lazy var bgButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.bgGray
        button.addTarget(self, action: #selector(tappedBgBtn), for: .touchUpInside)
        button.setTitle("BG", for: .normal)
        button.setTitleColor(UIColor.textGray, for: .normal)
        button.layer.cornerRadius = 20
        button.alpha = 0.5
        return button
    }()
    
    lazy var eventButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.bgGray
        button.addTarget(self, action: #selector(tappedEventBtn), for: .touchUpInside)
        button.setTitle(">", for: .normal)
        button.layer.cornerRadius = 20
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI() {
        
        view.addSubview(bgImageView)
        view.addSubview(bgButton)
        view.addSubview(eventView)
        view.addSubview(eventButton)
        
        bgImageView.anchor(top: view.topAnchor, left: view.leftAnchor,
                           bottom: view.bottomAnchor, right: view.rightAnchor)
        bgButton.anchor(top: view.topAnchor, right: view.rightAnchor,
                        paddingTop: 50, paddingRight: 20, width: 50, height: 50)
        
        eventView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor,
                         right: view.rightAnchor, paddingLeft: 20,
                         paddingBottom: 120, paddingRight: 20, height: 150)
        eventButton.anchor(top: eventView.topAnchor, right: eventView.rightAnchor,
                           paddingTop: 20, paddingRight: 20, width: 50, height: 50)
        
    }
    
    @objc func tappedBgBtn() {
        // 開相機換背景
    }
    
    @objc func tappedEventBtn() {
        let scheduleVC = storyboard?.instantiateViewController(withIdentifier: "scheduleVC")
        guard let scheduleVC = scheduleVC as? ScheduleViewController else { return }
        navigationController?.pushViewController(scheduleVC, animated: true)
    }
    
}
