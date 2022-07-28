//
//  HomeViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/18.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth
import PhotosUI
import Lottie

class HomeViewController: UIViewController, PHPickerViewControllerDelegate,
                          UINavigationControllerDelegate {
    
    // MARK: - Properties

    var pinMessage: String = ""
    var upcomingEvent: String = ""
    var upcomingDate: Int = 0
    
    var currentUser: User?
    
    var profileVC: ProfileViewController?
    
    lazy var bgImageView: UIImageView = create {_ in }
    
    let blurEffect = UIBlurEffect(style: .light)
    
    lazy var eventView: UIVisualEffectView = {
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.clipsToBounds = true
        effectView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
        effectView.layer.cornerRadius = 50
        return effectView
    }()
    
    lazy var decoLabel: UILabel = create {
        $0.textColor = .lightGray
        $0.font = UIFont.semiBold(size: 20)
        $0.text = "Upcoming Events"
    }
    
    lazy var decoView: UIView = create {
        $0.backgroundColor = .white
    }
    
    lazy var eventLabel: UILabel = create {
        $0.textColor = .lightGray
        $0.font = UIFont.bold(size: 24)
        $0.numberOfLines = 0
    }
    
    lazy var moreButton: UIButton = create {
        $0.addTarget(self, action: #selector(tappedMoreBtn), for: .touchUpInside)
        $0.setImage(UIImage(named: "icon_func_drop"), for: .normal)
        $0.setTitleColor(UIColor.darkGreen, for: .normal)
    }
    
    lazy var moreView: UIView = create {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 25
    }
    
    lazy var bgButton: UIButton = create {
        $0.addTarget(self, action: #selector(tappedBgBtn), for: .touchUpInside)
        $0.setImage(UIImage(named: "icon_func_bg"), for: .normal)
        $0.setTitleColor(UIColor.darkGreen, for: .normal)
    }
    
    lazy var eventButton: UIButton = create {
        $0.addTarget(self, action: #selector(tappedEventBtn), for: .touchUpInside)
        $0.setImage(UIImage(named: "icon_func_calendar"), for: .normal)
    }
    
    lazy var chatButton: UIButton = create {
        $0.addTarget(self, action: #selector(tappedChatBtn), for: .touchUpInside)
        $0.setImage(UIImage(named: "icon_func_chat"), for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        moreView.alpha = 0
        view.backgroundColor = .darkGreen
        
    }
    
    // MARK: - Lifecycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let currentUserUID = currentUserUID else {
            configureGuestUI()
            return
        }
        
        configureUI()
        configureConstraint()
        loadSchedule()
        fetchUserData(userID: currentUserUID)
        
    }
    
    // MARK: - User interaction handler
    
    @objc func tappedMoreBtn() {
        UIView.animate(withDuration: 0.3, animations: {
            self.moreView.alpha = self.moreView.alpha == 0 ? 0.7: 0
        })
        
    }
    
    @objc func tappedEventBtn() {
        let scheduleVC = storyboard?.instantiateViewController(withIdentifier: "scheduleVC")
        guard let scheduleVC = scheduleVC as? ScheduleViewController else { return }
        navigationController?.pushViewController(scheduleVC, animated: true)
    }
    
    @objc func tappedChatBtn() {
        
        if currentUser?.paringUser == [] {
            self.presentAlert(title: "Please Invite Friend First",
                              message: "To use chatroom please invite friends in profile page.")
        } else {
            let chatVC = storyboard?.instantiateViewController(withIdentifier: "chatVC")
            guard let chatVC = chatVC as? ChatViewController else { return }
            navigationController?.pushViewController(chatVC, animated: true)
        }
    }
    
    @objc func tappedBgBtn() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    // MARK: - Firebase handler
    
    // fetch upcoming event
    func loadSchedule() {
        
        guard let currentUserUID = currentUserUID else {
            print("can't find current user in homeVC")
            return
        }
        
        ScheduleManager.shared.fetchUpcomingSchedule(userID: currentUserUID) { [weak self] result in
            
            guard self != nil else { return }
            
            switch result {
            case .success(let result):
                guard let self = self else { return }
                self.upcomingEvent = result.event
                self.upcomingDate = result.distance
                
                if self.upcomingDate != 0 {
                    self.eventLabel.text =
                    "\(String(describing: self.upcomingEvent))\n\(String(describing: self.upcomingDate)) Day Left"
                    
                } else if self.upcomingEvent == "" {
                    self.eventLabel.text =
                    "No upcoming event"
                }
                
            case .failure(let error):
                print("Fail to fetch upcoming events: \(error)")
            }
        }
    }
    
    func fetchUserData(userID: String) {
        UserManager.shared.fetchUserData(userID: userID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.currentUser = user
                guard user.userHomeBG != "" else {
                    self.bgImageView.image = UIImage(named: "bg_home")
                    return
                }
                
                let url = URL(string: user.userHomeBG)
                self.bgImageView.kf.setImage(with: url)
                
            case .failure(let error):
                self.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
                print("Can't find user in homeVC")
            }
        }
    }
    
    func updateBGImage(urlString: String) {
        guard let currentUser = self.currentUser else {
            return
        }
        
        let user = User(userID: currentUser.userID,
                        userAvatar: currentUser.userAvatar,
                        userHomeBG: urlString,
                        userName: currentUser.userName,
                        paringUser: currentUser.paringUser)
        
        UserManager.shared.updateUserData(user: user) { result in
            switch result {
            case .success:
                print("Successfully update home bg to firebase")
                self.fetchUserData(userID: currentUser.userID)
            case .failure(let error):
                self.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
            }
        }
    }
    
    // MARK: - Image handler
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let animationView = self.loadAnimation(name: "lottieLoading", loopMode: .repeat(3))
        animationView.play {_ in
            self.stopAnimation(animationView: animationView)
        }
        
        for result in results {
            compressImage(result: result)
        }
    }
    
    func compressImage(result: PHPickerResult) {
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
            
            guard let image = image as? UIImage,
                  let imageData = image.jpegData(compressionQuality: 0.5),
                  let self = self,
                  error == nil
            else {
                print("Error fetch image")
                return
            }
            
            let imageName = NSUUID().uuidString
            self.uploadImage(imageName: imageName, imageData: imageData)
        }
    }
    
    func uploadImage(imageName: String, imageData: Data) {
        storage.child("homeImage/\(imageName).png").putData(imageData, metadata: nil) { _, error in
            guard error == nil else {
                print("Fail to upload image")
                return
            }
            self.downloadImage(imageName: imageName)
            print("Uploaded to firebase")
        }
    }
    
    func downloadImage(imageName: String) {
        
        storage.child("homeImage/\(imageName).png").downloadURL { url, error in
            
            guard let url = url, error == nil else {
                return
            }
            
            let urlString = url.absoluteString
            UserDefaults.standard.set(urlString, forKey: "url")
            self.updateBGImage(urlString: urlString)
        }
    }
    
    func configureUI() {
        
        view.addSubview(bgImageView)
        view.addSubview(eventView)
        view.addSubview(decoLabel)
        view.addSubview(decoView)
        view.addSubview(eventLabel)
        
        view.addSubview(moreView)
        view.addSubview(moreButton)
        moreView.addSubview(bgButton)
        moreView.addSubview(eventButton)
        moreView.addSubview(chatButton)
        
    }
    
    // MARK: - UI processor
    
    func configureConstraint() {
        
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
    
    func configureGuestUI() {
        view.addSubview(bgImageView)
        bgImageView.image = UIImage(named: "bg_home")
        bgImageView.anchor(top: view.topAnchor, left: view.leftAnchor,
                           bottom: view.bottomAnchor, right: view.rightAnchor)
    }
    
}
