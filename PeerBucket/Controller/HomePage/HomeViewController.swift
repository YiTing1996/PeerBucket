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

class HomeViewController: UIViewController, UIImagePickerControllerDelegate,
                          UINavigationControllerDelegate {
    
    private let storage = Storage.storage().reference()
    
    var upcomingEvent: String = ""
    var upcomingDate: Int = 0
    
    var currentUser: User?
    
    var currentUserUID: String?
    
    var profileVC: ProfileViewController?
    
    var bgImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Signin to enjoy more feature"
        label.font = UIFont.bold(size: 26)
        label.textColor = .lightGray
        return label
    }()
    
    var eventView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 20
        view.alpha = 0.6
        return view
    }()
    
    var eventLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.bold(size: 25)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var bgButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(tappedBgBtn), for: .touchUpInside)
        button.setImage(UIImage(named: "icon_changeBg"), for: .normal)
        button.setTitleColor(UIColor.darkGreen, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    lazy var eventButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(tappedEventBtn), for: .touchUpInside)
        button.setImage(UIImage(named: "icon_calendar_dark"), for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    var chatView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 20
        view.alpha = 0.6
        return view
    }()
    
    var chatLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.bold(size: 25)
        label.text = "Hamburger: Hello"
        label.numberOfLines = 0
        return label
    }()
    
    lazy var chatButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(tappedChatBtn), for: .touchUpInside)
        button.setImage(UIImage(named: "icon_chat_2"), for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isBeta {
            self.currentUserUID = "AITNzRSyUdMCjV4WrQxT"
        } else {
            self.currentUserUID = Auth.auth().currentUser?.uid
        }
        
        guard let currentUserUID = currentUserUID else {
            // If user not login then hidden schedule & chat view
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
        view.addSubview(bgButton)
        view.addSubview(eventView)
        view.addSubview(eventLabel)
        view.addSubview(eventButton)
        view.addSubview(chatView)
        view.addSubview(chatLabel)
        view.addSubview(chatButton)
        
        bgImageView.anchor(top: view.topAnchor, left: view.leftAnchor,
                           bottom: view.bottomAnchor, right: view.rightAnchor)
        bgButton.anchor(top: view.topAnchor, right: view.rightAnchor,
                        paddingTop: 80, paddingRight: 20, width: 50, height: 50)
        
        eventView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor,
                         right: view.rightAnchor, paddingLeft: 20,
                         paddingBottom: 120, paddingRight: 20, height: 150)
        eventButton.anchor(top: eventView.topAnchor, right: eventView.rightAnchor,
                           paddingTop: 20, paddingRight: 20, width: 50, height: 50)
        eventLabel.anchor(top: eventView.topAnchor, left: eventView.leftAnchor,
                          right: eventView.rightAnchor, paddingTop: 50, paddingLeft: 20, paddingRight: 20)
        
        chatView.anchor(left: view.leftAnchor, bottom: eventView.topAnchor,
                        right: view.rightAnchor, paddingLeft: 20,
                        paddingBottom: 20, paddingRight: 20, height: 150)
        chatButton.anchor(top: chatView.topAnchor, right: chatView.rightAnchor,
                          paddingTop: 20, paddingRight: 20, width: 50, height: 50)
        chatLabel.anchor(top: chatView.topAnchor, left: chatView.leftAnchor,
                         right: chatView.rightAnchor, paddingTop: 50, paddingLeft: 20, paddingRight: 20)
        
    }
    
    func configureGuestUI() {
        view.addSubview(bgImageView)
        view.addSubview(titleLabel)
        bgImageView.backgroundColor = .darkGreen
        bgImageView.anchor(top: view.topAnchor, left: view.leftAnchor,
                           bottom: view.bottomAnchor, right: view.rightAnchor)
        titleLabel.centerY(inView: view)
        titleLabel.centerX(inView: view)
    }
    
    @objc func tappedEventBtn() {
        let scheduleVC = storyboard?.instantiateViewController(withIdentifier: "scheduleVC")
        guard let scheduleVC = scheduleVC as? ScheduleViewController else { return }
        navigationController?.pushViewController(scheduleVC, animated: true)
    }
    
    @objc func tappedChatBtn() {
        
        if currentUser?.paringUser == [] {
            self.presentErrorAlert(title: "Please Invite Friend First",
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
                    "\(String(describing: self.upcomingEvent))\nCount down \(String(describing: self.upcomingDate)) Days"
                } else if self.upcomingEvent == "" {
                    self.eventLabel.text =
                    "There's no upcoming event"
                } else {
                    self.eventLabel.text =
                    "\(String(describing: self.upcomingEvent)) is Today!"
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
//                print("current user is: \(String(describing: self.currentUser))")
                
            case .failure(let error):
                self.presentErrorAlert(message: error.localizedDescription + " Please try again")
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
                self.presentErrorAlert(message: error.localizedDescription + " Please try again")
            }
        }
    }

    // MARK: - Image picker controller delegate
    
    @objc func tappedBgBtn() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        guard let imageData = image.pngData() else {
            return
        }
        
        // upload to firebase storage
        let imageName = NSUUID().uuidString
        storage.child("homeImage/\(imageName).png").putData(imageData, metadata: nil) { _, error in
            
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
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // fetch background image from firebase
    func downloadPhoto() {
                
        UserManager.shared.fetchUserData(userID: currentUserUID!) { result in
            switch result {
            case .success(let user):
                
                let url = URL(string: user.userHomeBG)
                self.bgImageView.kf.setImage(with: url)
                
            case .failure(let error):
                self.presentErrorAlert(message: error.localizedDescription + " Please try again")
            }
        }
    }
}
