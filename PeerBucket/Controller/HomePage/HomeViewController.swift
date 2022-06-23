//
//  HomeViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/18.
//

import Foundation
import UIKit
import FirebaseStorage

class HomeViewController: UIViewController, UIImagePickerControllerDelegate,
                          UINavigationControllerDelegate {
    
    private let storage = Storage.storage().reference()
    
    var upcomingEvent: String = ""
    var upcomingDate: Int = 0
    var currentUser: User?
    
    var bgImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var eventView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .bgGray
        view.layer.cornerRadius = 20
        view.alpha = 0.6
        return view
    }()
    
    var eventLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        //        label.font = UIFont.semiBold(size: 30)
        label.font = UIFont(name: "Academy Engraved LET", size: 28)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var bgButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.bgGray
        button.addTarget(self, action: #selector(tappedBgBtn), for: .touchUpInside)
        button.setTitle("BG", for: .normal)
        button.setTitleColor(UIColor.textGray, for: .normal)
        button.layer.cornerRadius = 20
        //        button.alpha = 0.5
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
    
    var chatView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .bgGray
        view.layer.cornerRadius = 20
        view.alpha = 0.6
        return view
    }()
    
    var chatLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: "Academy Engraved LET", size: 28)
        label.text = "Hamburger: Hello"
        label.numberOfLines = 0
        return label
    }()
    
    lazy var chatButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.bgGray
        button.addTarget(self, action: #selector(tappedChatBtn), for: .touchUpInside)
        button.setTitle("Chat", for: .normal)
        button.setTitleColor(UIColor.textGray, for: .normal)
        button.layer.cornerRadius = 20
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        loadSchedule()
        fetchUserData(userID: currentUserUID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downloadPhoto()
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
        eventLabel.anchor(top: eventView.topAnchor, left: eventView.leftAnchor, right: eventView.rightAnchor,
                          paddingTop: 50, paddingLeft: 20, paddingRight: 20)
        
        chatView.anchor(left: view.leftAnchor, bottom: eventView.topAnchor,
                        right: view.rightAnchor, paddingLeft: 20,
                        paddingBottom: 20, paddingRight: 20, height: 150)
        chatButton.anchor(top: chatView.topAnchor, right: chatView.rightAnchor,
                          paddingTop: 20, paddingRight: 20, width: 50, height: 50)
        chatLabel.anchor(top: chatView.topAnchor, left: chatView.leftAnchor, right: chatView.rightAnchor,
                         paddingTop: 50, paddingLeft: 20, paddingRight: 20)
        
    }
    
    func loadSchedule() {
        ScheduleManager.shared.fetchSchedule(userID: testUserID) { [weak self] result in
            
            guard self != nil else { return }
            
            switch result {
            case .success(let result):
                guard let self = self else { return }
                self.upcomingEvent = result.event
                self.upcomingDate = result.distance
//                print("Sucess fetch upcoming evnets: \(result)")

                if self.upcomingDate != 0 {
                    self.eventLabel.text =
                    "\(String(describing: self.upcomingEvent))\nCount down \(String(describing: self.upcomingDate))days"
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
                print("current user is: \(String(describing: self.currentUser))")
            case .failure(let error):
                self.presentErrorAlert(message: error.localizedDescription + " Please try again")
                print("Can't find user in homeVC")
            }
        }
    }
    
    @objc func tappedBgBtn() {
        print("Did tapped button")
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @objc func tappedEventBtn() {
        let scheduleVC = storyboard?.instantiateViewController(withIdentifier: "scheduleVC")
        guard let scheduleVC = scheduleVC as? ScheduleViewController else { return }
        navigationController?.pushViewController(scheduleVC, animated: true)
    }
    
    @objc func tappedChatBtn() {
        let chatVC = storyboard?.instantiateViewController(withIdentifier: "chatVC")
        guard let chatVC = chatVC as? ChatViewController else { return }
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    // MARK: - Image picker controller delegate
    
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
                print("currentUser: \(String(describing: self.currentUser))")
                guard let currentUser = self.currentUser else {
                    return
                }

                let user = User(userEmail: currentUser.userEmail,
                                userID: currentUserUID,
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
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func downloadPhoto() {
        
        // fetch background photo from firebase
        UserManager.shared.fetchUserData(userID: currentUserUID) { result in
            switch result {
            case .success(let user):
                
                guard let urlString = user.userHomeBG as String?,
                      let url = URL(string: urlString) else {
                    return
                }
                
                let task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
                    guard let data = data, error == nil else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        let image = UIImage(data: data)
                        self.bgImageView.image = image
                    }
                })
                task.resume()
                
            case .failure(let error):
                self.presentErrorAlert(message: error.localizedDescription + " Please try again")
            }
        }
        
    }
    
}
