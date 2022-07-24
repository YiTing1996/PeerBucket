//
//  LiveTextController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/7/6.
//

import Foundation
import Vision
import UIKit
import FirebaseAuth
import AVFoundation

class LiveTextController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var liveTextLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    lazy var eventTextField: UITextField = create {
        $0.isUserInteractionEnabled = false
        $0.setTextField(placeholder: "Scan text will show here.")
    }
    
    lazy var submitButton: UIButton = create {
        $0.setTitle("SUBMIT", for: .normal)
        $0.addTarget(self, action: #selector(tappedSubmitBtn), for: .touchUpInside)
        $0.setTextButton(bgColor: .mediumGray, titleColor: .white, font: 15)
    }
    
    private var cameraInputView: CameraKeyboard = {
        let view = CameraKeyboard()
        return view
    }()
    
    let imagePicker = UIImagePickerController()
    
    var bucketCategories: [BucketCategory] = []
    var userIDList: [String] = []
    var selectedRow: Int?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .lightGray
        
        configureUI()
        view.backgroundColor = .lightGray
        imagePicker.delegate = self
        
        cameraInputView.textField = self.eventTextField
        eventTextField.inputView = cameraInputView
        cameraInputView.startCamera()
        eventTextField.reloadInputViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let currentUserUID = currentUserUID else { return }
        getData(userID: currentUserUID)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraInputView.stopCamera()
    }
    
    // MARK: - Configure UI
    
    func configureUI() {
        
        liveTextLabel.font = UIFont.bold(size: 20)
        liveTextLabel.textColor = .darkGray
        categoryLabel.textColor = .darkGray
        categoryLabel.font = UIFont.bold(size: 20)
        
        view.addSubview(eventTextField)
        view.addSubview(cameraInputView)
        view.addSubview(submitButton)
        submitButton.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor,
                            paddingLeft: 30, paddingBottom: 50, paddingRight: 30, height: 50)
        eventTextField.anchor(left: view.leftAnchor, bottom: categoryLabel.topAnchor,
                              right: view.rightAnchor, paddingLeft: 50, paddingBottom: 30,
                              paddingRight: 50, height: 50)
        cameraInputView.anchor(top: liveTextLabel.bottomAnchor, left: view.leftAnchor,
                               bottom: eventTextField.topAnchor, right: view.rightAnchor,
                               paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10)
        
    }
    
    // MARK: - User interaction handler

    @objc func tappedSubmitBtn() {
        guard let title = self.eventTextField.text,
              title != "",
              let currentUserUID = currentUserUID,
              let selectedRow = selectedRow
        else {
            return
        }
        
        addBucketList(userID: currentUserUID, list: title, row: selectedRow)
        self.presentAlert(title: "Congrats", message: "Successfully add list!", completion: {
            self.view.window!.rootViewController?.dismiss(animated: true)
        })
        
    }
    
    // MARK: - Firebase handler
    
    func getData(userID: String) {
        
        UserManager.shared.fetchUserData(userID: userID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.userIDList = [userID]
                if user.paringUser != [] {
                    self.userIDList.append(user.paringUser[0])
                }
                
                for userID in self.userIDList {
                    self.fetchBucketCategory(userID: userID)
                }
                
            case .failure(let error):
                self.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
                print("Can't find user in liveTextVC")
            }
        }
    }
    
    func fetchBucketCategory(userID: String) {
        self.bucketCategories = []
        BucketListManager.shared.fetchBucketCategory(userID: userID) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let bucketLists):
                self.bucketCategories += bucketLists
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func addBucketList(userID: String, list: String, row: Int) {
        var bucketList: BucketList = BucketList(
            senderId: userID,
            createdTime: Date(),
            status: false,
            list: list,
            categoryId: bucketCategories[row].id,
            listId: "",
            images: []
        )
        
        BucketListManager.shared.addBucketList(bucketList: &bucketList) { result in
            
            switch result {
            case .success:
                self.presentAlert()
            case .failure(let error):
                self.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
            }
        }
    }
    
}

// MARK: - TableView

extension LiveTextController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bucketCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LiveTextTableViewCell", for: indexPath)
        
        guard let liveTextCell = cell as? LiveTextTableViewCell else { return cell }
        
        liveTextCell.configureCell(bucketList: bucketCategories[indexPath.row])
        liveTextCell.contentView.backgroundColor = .clear
        liveTextCell.backgroundColor = .lightGray
        liveTextCell.selectionStyle = .gray
        
        return liveTextCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRow = indexPath.row
    }
}
