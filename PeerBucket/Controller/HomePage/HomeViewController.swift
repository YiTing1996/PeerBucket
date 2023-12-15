//
//  HomeViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/18.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import PhotosUI
import Lottie

final class HomeViewController: BaseViewController {
    
    // MARK: - Properties
        
    private lazy var bgImageView: UIImageView = create { _ in }
    
    private let blurEffect = UIBlurEffect(style: .light)
    
    private lazy var eventView: UIVisualEffectView = {
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.clipsToBounds = true
        effectView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
        effectView.layer.cornerRadius = 50
        return effectView
    }()
    
    private lazy var decoLabel: UILabel = create {
        $0.textColor = .lightGray
        $0.font = UIFont.semiBold(size: 20)
        $0.text = "Upcoming Events"
    }
    
    private lazy var decoView: UIView = create {
        $0.backgroundColor = .white
    }
    
    private lazy var eventLabel: UILabel = create {
        $0.textColor = .lightGray
        $0.font = UIFont.bold(size: 24)
        $0.numberOfLines = 0
    }
    
    private lazy var moreButton: UIButton = create {
        $0.addTarget(self, action: #selector(tappedMoreBtn), for: .touchUpInside)
        $0.setImage(UIImage(named: "icon_func_drop"), for: .normal)
        $0.setTitleColor(UIColor.darkGreen, for: .normal)
    }
    
    private lazy var moreView: UIView = create {
        $0.alpha = 0
        $0.layer.cornerRadius = 25
    }
    
    private lazy var bgButton: UIButton = create {
        $0.addTarget(self, action: #selector(tappedBgBtn), for: .touchUpInside)
        $0.setImage(UIImage(named: "icon_func_bg"), for: .normal)
        $0.setTitleColor(UIColor.darkGreen, for: .normal)
    }
    
    private lazy var eventButton: UIButton = create {
        $0.addTarget(self, action: #selector(tappedEventBtn), for: .touchUpInside)
        $0.setImage(UIImage(named: "icon_func_calendar"), for: .normal)
    }
    
    private lazy var chatButton: UIButton = create {
        $0.addTarget(self, action: #selector(tappedChatBtn), for: .touchUpInside)
        $0.setImage(UIImage(named: "icon_func_chat"), for: .normal)
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGreen
        configureUI()
        guard let url = URL(string: currentUser?.userHomeBG ?? "") else { return }
        bgImageView.kf.setImage(with: url)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let currentUser = currentUser else { return }
        loadSchedule(userID: currentUser.userID)
    }
    
    override func configureGuestUI() {
        view.addSubview(bgImageView)
        bgImageView.image = UIImage(named: "bg_home")
        bgImageView.anchor(
            top: view.topAnchor, left: view.leftAnchor,
            bottom: view.bottomAnchor, right: view.rightAnchor
        )
    }
    
    override func configureAfterFetchUserData() {
        guard let currentUser = currentUser, currentUser.userHomeBG.isNotEmpty else {
            self.bgImageView.image = UIImage(named: "bg_home")
            return
        }
        let url = URL(string: currentUser.userHomeBG)
        self.bgImageView.kf.setImage(with: url)
    }
    
    // MARK: - User interaction handler
    
    @objc
    private func tappedMoreBtn() {
        UIView.animate(withDuration: 0.3) {
            self.moreView.alpha = self.moreView.alpha == 0 ? 0.7: 0
        }
    }
    
    @objc
    private func tappedEventBtn() {
        guard let scheduleVC = initFromStoryboard(with: .schedule) as? ScheduleViewController else {
            return
        }
        navigationController?.pushViewController(scheduleVC, animated: true)
    }
    
    @objc
    private func tappedChatBtn() {
        guard let currentUser = currentUser, currentUser.paringUser.isNotEmpty,
              let chatVC = initFromStoryboard(with: .chat) as? ChatViewController else {
            self.presentAlert(
                title: "Please Invite Friend First",
                message: "To use chatroom please invite friends in profile page."
            )
            return
        }
        chatVC.currentUser = currentUser
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @objc
    private func tappedBgBtn() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    // MARK: - Firebase handler
    
    /// fetch upcoming event
    private func loadSchedule(userID: String) {
        ScheduleManager.shared.fetchUpcomingSchedule(userID: userID) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case .success(let result):
                guard let self = self else { return }
                let upcomingEvent = result.event
                let upcomingDate = result.distance
                if upcomingDate != 0 {
                    self.eventLabel.text =
                    "\(String(describing: upcomingEvent))\n\(String(describing: upcomingDate)) Day Left"
                } else if upcomingEvent.isEmpty {
                    self.eventLabel.text =
                    "No upcoming event"
                }
            case .failure(let error):
                Log.e(error)
            }
        }
    }
    
    // MARK: - Image handler
    
    private func compressImage(result: PHPickerResult) {
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
            guard let image = image as? UIImage,
                  let imageData = image.jpegData(compressionQuality: 0.5),
                  let self = self, error == nil else {
                Log.e(error)
                return
            }
            let imageName = NSUUID().uuidString
            self.uploadImage(imageName: imageName, imageData: imageData)
        }
    }
    
    private func uploadImage(imageName: String, imageData: Data) {
        storage.child("homeImage/\(imageName).png").putData(imageData, metadata: nil) { _, error in
            guard error == nil else {
                Log.e(error)
                return
            }
            self.downloadImage(imageName: imageName)
        }
    }
    
    private func downloadImage(imageName: String) {
        storage.child("homeImage/\(imageName).png").downloadURL { url, error in
            guard let url = url, error == nil else {
                Log.e(error)
                return
            }
            let urlString = url.absoluteString
            UserDefaults.standard.set(urlString, forKey: "url")
            Info.shared.updateUserData(homebg: urlString)
        }
    }
    
    // MARK: - UI
    
    private func configureUI() {
        view.addSubviews([bgImageView, eventView, decoLabel, decoView, eventLabel, moreView, moreButton])
        moreView.addSubviews([bgButton, eventButton, chatButton])
        
        moreView.anchor(top: eventView.topAnchor, right: view.rightAnchor,
                        paddingTop: 10, paddingRight: 20,
                        width: 50, height: 220)
        moreButton.anchor(top: eventView.topAnchor, right: eventView.rightAnchor,
                          paddingTop: 10, paddingRight: 20,
                          width: 45, height: 45)
        bgButton.anchor(top: moreButton.bottomAnchor, right: moreView.rightAnchor,
                        paddingRight: 0, width: 45, height: 45)
        eventButton.anchor(top: bgButton.bottomAnchor, right: moreView.rightAnchor,
                           paddingRight: 0, width: 45, height: 45)
        chatButton.anchor(top: eventButton.bottomAnchor, right: moreView.rightAnchor,
                          paddingRight: 0, width: 45, height: 45)
        
        bgImageView.anchor(top: view.topAnchor, left: view.leftAnchor,
                           bottom: view.bottomAnchor, right: view.rightAnchor)
        
        eventView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor,
                         paddingLeft: 100, paddingBottom: 100, height: 180)
        decoLabel.anchor(top: eventView.topAnchor, left: eventView.leftAnchor,
                         paddingTop: 30, paddingLeft: 20, height: 30)
        decoView.anchor(top: decoLabel.bottomAnchor, left: eventView.leftAnchor, paddingTop: 12,
                        paddingLeft: 20, width: 60, height: 1)
        eventLabel.anchor(top: decoView.bottomAnchor, left: eventView.leftAnchor, right: eventView.rightAnchor,
                          paddingTop: 20, paddingLeft: 20, paddingRight: 20, height: 60)
        
    }
}

// MARK: - Extension

extension HomeViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let animationView = self.loadAnimation(name: "lottieLoading", loopMode: .repeat(3))
        animationView.play { _ in
            self.stopAnimation(animationView: animationView)
        }
        
        results.forEach {
            compressImage(result: $0)
        }
    }
}
