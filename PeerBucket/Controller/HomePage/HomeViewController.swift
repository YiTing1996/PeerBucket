//
//  HomeViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/18.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import PhotosUI
import Lottie

class HomeViewController: UIViewController, PHPickerViewControllerDelegate,
                          UINavigationControllerDelegate {
    
    private let storage = Storage.storage().reference()
    
    var pinMessage: String = ""
    var upcomingEvent: String = ""
    var upcomingDate: Int = 0
    
    var currentUser: User?
    
    var currentUserUID: String?
    
    var profileVC: ProfileViewController?
    
    var bgImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    let blurEffect = UIBlurEffect(style: .light)

    lazy var eventView: UIVisualEffectView = {
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.clipsToBounds = true
        effectView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
        effectView.layer.cornerRadius = 50
        return effectView
    }()
    
    var decoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.semiBold(size: 20)
        label.text = "Upcoming Events"
        return label
    }()
    
    var decoView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    var eventLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.bold(size: 24)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var moreButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(tappedMoreBtn), for: .touchUpInside)
        button.setImage(UIImage(named: "icon_func_drop"), for: .normal)
        button.setTitleColor(UIColor.darkGreen, for: .normal)
        return button
    }()
    
    var moreView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 25
        return view
    }()
    
    lazy var bgButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(tappedBgBtn), for: .touchUpInside)
        button.setImage(UIImage(named: "icon_func_bg"), for: .normal)
        button.setTitleColor(UIColor.darkGreen, for: .normal)
        return button
    }()
    
    lazy var eventButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(tappedEventBtn), for: .touchUpInside)
        button.setImage(UIImage(named: "icon_func_calendar"), for: .normal)
        return button
    }()
    
    lazy var chatButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(tappedChatBtn), for: .touchUpInside)
        button.setImage(UIImage(named: "icon_func_chat"), for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        moreView.alpha = 0
        view.backgroundColor = .darkGreen
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isBeta {
            self.currentUserUID = "AITNzRSyUdMCjV4WrQxT"
        } else {
            self.currentUserUID = Auth.auth().currentUser?.uid
        }
        
        guard let currentUserUID = currentUserUID else {
            configureGuestUI()
            return
        }
        
        configureUI()
        loadSchedule()
        downloadPhoto()
        fetchUserData(userID: currentUserUID)
        
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
        
        moreView.anchor(top: eventView.topAnchor, right: view.rightAnchor,
                        paddingTop: 10, paddingRight: 20,
                        width: 50, height: 220)
        moreButton.anchor(top: moreView.topAnchor, right: moreView.rightAnchor,
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
    
    @objc func tappedMoreBtn() {
        UIView.animate(withDuration: 0.3, animations: {
            if self.moreView.alpha == 0 {
                self.moreView.alpha = 0.7
            } else {
                self.moreView.alpha = 0
            }
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
    
    // MARK: - Firebase data process
    
    // fetch upcoming event
    func loadSchedule() {
        
        guard let currentUserUID = currentUserUID else {
            print("can't find current user in homeVC")
            return
        }
        
        ScheduleManager.shared.fetchSchedule(userID: currentUserUID) { [weak self] result in
            
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
    
    // fetch current user's data
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
                self.downloadPhoto()
            case .failure(let error):
                self.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
            }
        }
    }
    
    // MARK: - Image picker controller delegate
        
    @objc func tappedBgBtn() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        let animationView = self.loadAnimation(name: "lottieLoading", loopMode: .repeat(3))
        animationView.play {_ in
            self.stopAnimation(animationView: animationView)
        }
        
        for result in results {
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                
                guard error == nil else {
                    print("Error \(error!.localizedDescription)")
                    return
                }
                
                if let image = image as? UIImage {
                    guard let imageData = image.jpegData(compressionQuality: 0.5),
                          let self = self else { return }
                    
                    let imageName = NSUUID().uuidString
                    
                    self.storage.child("homeImage/\(imageName).png").putData(imageData, metadata: nil) { _, error in
                        
                        guard error == nil else {
                            print("Fail to upload image")
                            return
                        }
                        
                        self.storage.child("homeImage/\(imageName).png").downloadURL(completion: { url, error in
                            guard let url = url, error == nil else {
                                return
                            }
                            let urlString = url.absoluteString
                            UserDefaults.standard.set(urlString, forKey: "url")
                            
                            // save to firebase
                            self.updateBGImage(urlString: urlString)
                            
                        })
                        
                    }
                    print("Uploaded to firebase")
                } else {
                    print("There was an error.")
                }
            }
            
        }
    }
    
    // fetch background image from firebase
    func downloadPhoto() {
        
        guard self.currentUserUID != nil else {
            print("Error: can't find paring user in home VC")
            return
        }
        
        UserManager.shared.fetchUserData(userID: currentUserUID ?? "") { result in
            switch result {
            case .success(let user):
                
                let url = URL(string: user.userHomeBG)
                self.bgImageView.kf.setImage(with: url)
                
            case .failure(let error):
                self.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
            }
        }
    }
}
