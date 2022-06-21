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
//        label.font = UIFont.semiBold(size: 30)
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
    
//    lazy var inviteButton: UIButton = {
//        let button = UIButton()
//        button.backgroundColor = UIColor.bgGray
//        button.addTarget(self, action: #selector(tappedInviteBtn), for: .touchUpInside)
//        button.setTitle("Invite", for: .normal)
//        button.setTitleColor(UIColor.textGray, for: .normal)
//        button.layer.cornerRadius = 20
//        return button
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchFromFirebase()
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
//        view.addSubview(inviteButton)
        
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
//        inviteButton.anchor(top: chatView.topAnchor, right: chatView.rightAnchor,
//                           paddingTop: 20, paddingRight: 100, width: 50, height: 50)
                
    }
    
    func fetchFromFirebase() {
        ScheduleManager.shared.fetchSchedule(sender: "Doreen") { [weak self] result in
            
            guard self != nil else { return }
            
            switch result {
            case .success(let result):
                guard let self = self else { return }
                self.upcomingEvent = result.event
                self.upcomingDate = result.distance
                print("Sucess fetch upcoming evnets: \(result)")
                self.eventLabel.text =
                "\(String(describing: self.upcomingEvent))\nCount down \(String(describing: self.upcomingDate))days"
                
            case .failure(let error):
                print("Fail to fetch upcoming events: \(error)")
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
    
//    @objc func tappedInviteBtn() {
//        let inviteVC = storyboard?.instantiateViewController(withIdentifier: "inviteVC")
//        guard let inviteVC = inviteVC as? InviteViewController else { return }
//        navigationController?.pushViewController(inviteVC, animated: true)
//    }
    
    // TO-DO 上傳到firebase
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        guard let imageData = image.pngData() else {
            return
        }
        
        let imageName = NSUUID().uuidString
        
        // create a reference to upload data
        storage.child("categoryImage/\(imageName).png").putData(imageData, metadata: nil) { _, error in
            
            guard error == nil else {
                print("Fail to upload image")
                return
            }
            
            self.storage.child("categoryImage/\(imageName).png").downloadURL(completion: { url, error in
                
                guard let url = url, error == nil else {
                    return
                }
                
                let urlString = url.absoluteString
                
                DispatchQueue.main.async {
                    self.bgImageView.image = image
                }
                
                print("Download url: \(urlString)")
                UserDefaults.standard.set(urlString, forKey: "url")
                
            })
            
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
