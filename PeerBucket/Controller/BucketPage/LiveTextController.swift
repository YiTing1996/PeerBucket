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

class LiveTextController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var eventTextView: UITextView!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var liveTextLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    lazy var submitButton: UIButton = {
        let button = UIButton()
        button.setTitle("SUBMIT", for: .normal)
        button.addTarget(self, action: #selector(tappedSubmitBtn), for: .touchUpInside)
        button.setTextButton(bgColor: .mediumGray, titleColor: .white, font: 15)
        return button
    }()
    
    let imagePicker = UIImagePickerController()
    
    var bucketCategories: [BucketCategory] = []
    var currentUserUID: String?
    var userIDList: [String] = []
    var selectedRow: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isBeta {
            self.currentUserUID = "AITNzRSyUdMCjV4WrQxT"
        } else {
            self.currentUserUID = Auth.auth().currentUser?.uid ?? nil
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .lightGray
        
        configureUI()
        view.backgroundColor = .lightGray
        imagePicker.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let currentUserUID = currentUserUID else { return }
        getData(userID: currentUserUID)
    }
    
    func configureUI() {
        
        eventImageView.layer.cornerRadius = 10
//        eventImageView.backgroundColor = .white
        liveTextLabel.font = UIFont.bold(size: 20)
        liveTextLabel.textColor = .darkGray
        categoryLabel.textColor = .darkGray
        categoryLabel.font = UIFont.bold(size: 20)
        eventTextView.font = UIFont.semiBold(size: 15)
        eventTextView.layer.cornerRadius = 10
        eventTextView.layer.borderWidth = 1
        eventTextView.textColor = .darkGray
        eventTextView.backgroundColor = .lightGray
        
        view.addSubview(submitButton)
        submitButton.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor,
                            paddingLeft: 30, paddingBottom: 50, paddingRight: 30, height: 50)
        
    }
    
    // MARK: - Firebase data process
    
    func getData(userID: String) {
        
        UserManager.shared.fetchUserData(userID: userID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                
                self.userIDList = [userID]
                if user.paringUser != [] {
                    self.userIDList.append(user.paringUser[0])
                }
                
                self.bucketCategories = []
                for userID in self.userIDList {
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
                
            case .failure(let error):
                self.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
                print("Can't find user in liveTextVC")
            }
        }
    }
    
    @objc func tappedSubmitBtn() {
        guard let title = self.eventTextView.text,
              let currentUserUID = currentUserUID,
              let selectedRow = selectedRow
        else {
            return
        }
                
        var bucketList: BucketList = BucketList(
            senderId: currentUserUID,
            createdTime: Date(),
            status: false,
            list: title,
            categoryId: bucketCategories[selectedRow].id,
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
        
        self.presentAlert()
        self.dismiss(animated: true)
        
    }
    
    // MARK: - Live text process
    
    private func recognizeText(image: UIImage?) {
        guard let cgImage = image?.cgImage else {
            fatalError("Could not get cgimage")
        }
        
        // Handler
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        // Request
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let observation = request.results as? [VNRecognizedTextObservation],
                  error == nil else {
                return
            }
            
            let text = observation.compactMap({
                $0.topCandidates(1).first?.string
            }).joined(separator: ", ")
            
            DispatchQueue.main.async {
                self?.eventTextView.text = text
            }
        }
        
        request.recognitionLanguages = ["zh-Hant", "en-US"]
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        // Process Request
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    // MARK: - Image process
    
    @IBAction func tappedCameraBtn(_ sender: UIButton) {
        imagePicker.sourceType = .camera
        self.present(imagePicker, animated: true)
    }
    
    @IBAction func tappedAlbumBtn(_ sender: UIButton) {
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image = info[.originalImage] as? UIImage
        recognizeText(image: image)
        DispatchQueue.main.async {
            self.eventImageView.image = image
        }
        imagePicker.dismiss(animated: true)
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
