//
//  LiveTextController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/7/6.
//

import Vision
import UIKit
import FirebaseAuth
import AVFoundation

final class LiveTextController: BaseViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var liveTextLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    private lazy var eventTextField: UITextField = create {
        $0.isUserInteractionEnabled = false
        $0.setThemeTextField(placeholder: "Scan text will show here.")
    }
    
    private lazy var submitButton: UIButton = create {
        $0.setTitle("SUBMIT", for: .normal)
        $0.addTarget(self, action: #selector(tappedSubmitBtn), for: .touchUpInside)
        $0.setTextBtn(bgColor: .mediumGray, titleColor: .white, font: 15)
    }
    
    private var cameraInputView: CameraKeyboard = {
        let view = CameraKeyboard()
        return view
    }()
        
    private var bucketCategories: [BucketCategory] = []
    private var selectedRow: Int?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .lightGray
        
        configureUI()
        view.backgroundColor = .lightGray
        
        cameraInputView.textField = self.eventTextField
        eventTextField.inputView = cameraInputView
        cameraInputView.startCamera()
        eventTextField.reloadInputViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraInputView.stopCamera()
    }
    
    override func configureAfterFetchUserData() {
        if let currentUser = currentUser, let paringUserId = currentUser.paringUser.first {
            fetchBucketCategory(userID: paringUserId)
        }
    }
    
    // MARK: - Configure UI
    
    private func configureUI() {
        liveTextLabel.font = UIFont.bold(size: 20)
        liveTextLabel.textColor = .darkGray
        categoryLabel.textColor = .darkGray
        categoryLabel.font = UIFont.bold(size: 20)
        view.addSubviews([eventTextField, cameraInputView, submitButton])
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

    @objc
    private func tappedSubmitBtn() {
        guard let title = eventTextField.text, title.isNotEmpty,
              let currentUser = currentUser,
              let selectedRow = selectedRow else {
            return
        }
        addBucketList(userID: currentUser.userID, list: title, row: selectedRow)
        presentAlert(title: "Congrats", message: "Successfully add list!") {
            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true)
        }
    }
    
    // MARK: - Firebase handler
    
    private func fetchBucketCategory(userID: String) {
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
                Log.e(error.localizedDescription)
            }
        }
    }
    
    private func addBucketList(userID: String, list: String, row: Int) {
        var bucketList: BucketList = BucketList(
            senderId: userID,
            createdTime: Date(),
            status: false,
            list: list,
            categoryId: bucketCategories[row].id,
            listId: "",
            images: []
        )
        
        BucketListManager.shared.addBucketList(bucketList: &bucketList) { [weak self] result in
            switch result {
            case .success:
                self?.presentAlert()
            case .failure(let error):
                self?.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: LiveTextTableViewCell.cellIdentifier, for: indexPath)
        guard let liveTextCell = cell as? LiveTextTableViewCell else { return .init() }
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
