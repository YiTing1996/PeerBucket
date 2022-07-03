//
//  BucketDetailViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/16.
//

import Foundation
import UIKit
import PhotosUI
import FirebaseStorage
import FirebaseAuth
import Lottie

class BucketDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let storage = Storage.storage().reference()
    
    var swippedRow: Int?
    var imageUrlString: [String] = []
    var allListImages: [String] = []
    
    lazy var longPressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer()
        gesture.addTarget(self, action: #selector(longPressGestureRecognized(_:)))
        gesture.minimumPressDuration = 0.5
        gesture.delaysTouchesBegan = true
        return gesture
    }()
    
    lazy var addListButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(tappedAddBtn), for: .touchUpInside)
        button.setImage(UIImage(named: "icon_func_add"), for: .normal)
        return button
    }()
    
    lazy var submitButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(tappedSubmitBtn), for: .touchUpInside)
        button.setImage(UIImage(named: "icon_func_upload"), for: .normal)
        return button
    }()
    
    lazy var memoryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(tappedMemoryBtn), for: .touchUpInside)
        button.setImage(UIImage(named: "icon_album"), for: .normal)
        return button
    }()

    lazy var menuBarItem = UIBarButtonItem(customView: self.memoryButton)
    
//    lazy var loadingAnimation = LottieAnimation.shared.createLoopAnimation(lottieName: "lottieLoading")
    
    var addListTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type New List Here"
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 10
        textField.setLeftPaddingPoints(amount: 10)
        textField.backgroundColor = UIColor.lightGray
        textField.textColor = .darkGray
        return textField
    }()
    
    var selectedBucket: BucketCategory?
    var allBucketList: [BucketList] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var currentUserUID: String?
    //    var currentUserUID = Auth.auth().currentUser?.uid
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isBeta {
            self.currentUserUID = "AITNzRSyUdMCjV4WrQxT"
        } else {
            self.currentUserUID = Auth.auth().currentUser?.uid ?? nil
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        view.backgroundColor = .lightGray
        tableView.backgroundColor = .lightGray
        tableView.addGestureRecognizer(longPressGesture)
        
        configureUI()
        addListTextField.isHidden = true
        submitButton.isHidden = true
        
        navigationItem.title = selectedBucket?.category
        
        navigationItem.rightBarButtonItem = menuBarItem
        
    }
    
    @objc func tappedMemoryBtn() {
        configureAnimation()
        
        for list in allBucketList where list.images != [] {
            allListImages += list.images
        }
        
        guard allListImages != [] else {
            self.presentAlert(title: "Error", message: "To use album feature, please add photo to list first")
            return
        }
        
        let imageVC = storyboard?.instantiateViewController(withIdentifier: "imageVC")
        guard let imageVC = imageVC as? ImageDetailViewController else { return }

        imageVC.selectedLists = allBucketList
        navigationController?.pushViewController(imageVC, animated: true)
//        LottieAnimation.shared.stopAnimation(lottieAnimation: loadingAnimation)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        fetchFromFirebase()
    }
    
    func configureUI() {
        
        view.addSubview(addListButton)
        view.addSubview(addListTextField)
        view.addSubview(submitButton)
        
        addListButton.anchor(bottom: view.bottomAnchor, right: view.rightAnchor,
                             paddingBottom: 110, paddingRight: 10, width: 50, height: 50)
        submitButton.anchor(bottom: view.bottomAnchor, right: addListButton.leftAnchor,
                            paddingBottom: 110, paddingRight: 2, width: 50, height: 50)
        addListTextField.anchor(bottom: view.bottomAnchor, right: submitButton.leftAnchor,
                                paddingBottom: 110, paddingRight: 2, width: 250, height: 50)
        
    }
    
    func configureAnimation() {
//        view.addSubview(loadingAnimation)
//
//        let width = self.view.frame.width
//        loadingAnimation.frame = CGRect(x: 0, y: 0, width: width, height: 200)
//        loadingAnimation.center = self.view.center
        
        let animationView = loadAnimation(name: "lottieLoading", loopMode: .loop)
        animationView.play()
        
//        loadAnimation(name: "lottieLoading", loopMode: .loop).play()
        
    }
    
    @objc func tappedAddBtn() {
        if addListTextField.isHidden == true {
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
                self.addListTextField.isHidden = false
                self.submitButton.isHidden = false
                self.addListButton.setImage(UIImage(named: "icon_func_cancel"), for: .normal)
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.addListTextField.isHidden = true
                self.submitButton.isHidden = true
                self.addListButton.setImage(UIImage(named: "icon_func_add"), for: .normal)
            }
        }
    }
    
    // MARK: - Firebase data process
    
    func fetchFromFirebase() {
        
        BucketListManager.shared.fetchBucketList(categoryID: selectedBucket?.id ?? "", completion: { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let bucketList):
                self.allBucketList = bucketList
//                print(self.allBucketList)
            case .failure(let error):
                print(error.localizedDescription)
            }
            
        })
    }
    
    @objc func tappedSubmitBtn() {
        
        guard let selectedBucket = selectedBucket,
              let currentUserUID = currentUserUID,
              addListTextField.text != "" else {
            presentAlert(title: "Error", message: "Please fill all the field")
            return
        }
        
        var bucketList: BucketList = BucketList(
            senderId: currentUserUID,
            createdTime: Date(),
            status: false,
            list: addListTextField.text ?? "",
            categoryId: selectedBucket.id,
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
        
        fetchFromFirebase()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        addListButton.setImage(UIImage(named: "icon_func_add"), for: .normal)
        addListTextField.text = ""
        addListTextField.isHidden = true
        submitButton.isHidden = true
    }
    
    @objc func longPressGestureRecognized(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            if let row = self.tableView.indexPathForRow(at: sender.location(in: self.tableView))?.row {
                let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
                feedbackGenerator.prepare()
                feedbackGenerator.impactOccurred()
                
                self.presentActionAlert(action: "Delete", title: "Delete List", message: "Do you want to delete this list?") {
                    
                    let deleteId = self.allBucketList[row].listId
                    self.deleteBucketList(deleteId: deleteId, row: row)
                    
                }
            }
        }
    }
    
    func deleteBucketList(deleteId: String, row: Int) {
        
        BucketListManager.shared.deleteBucketList(id: deleteId) { result in
            
            switch result {
            case .success:
                self.presentAlert()
                self.allBucketList.remove(at: row)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                self.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
            }
        }
    }
    
    func updateListStatus(status: Bool, row: Int, date: Date) {
        
        let bucketList: BucketList = BucketList(
            senderId: allBucketList[row].senderId,
            createdTime: date,
            status: status,
            list: allBucketList[row].list,
            categoryId: allBucketList[row].categoryId,
            listId: allBucketList[row].listId,
            images: allBucketList[row].images
        )
        
        BucketListManager.shared.updateBucketList(bucketList: bucketList) { result in
            switch result {
            case .success:
                self.presentAlert()
                self.fetchFromFirebase()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                self.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
            }
        }
    }
}

// MARK: - TableView
extension BucketDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allBucketList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BucketDetailTableViewCell", for: indexPath)
        
        guard let bucketDetailCell = cell as? BucketDetailTableViewCell else { return cell }
        
        bucketDetailCell.delegate = self
        bucketDetailCell.configureCell(bucketList: allBucketList[indexPath.row])
        bucketDetailCell.contentView.backgroundColor = .clear
        bucketDetailCell.backgroundColor = .lightGray
        
        return bucketDetailCell
    }
    
    // swipe left to add photo in album
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let addPhotoAction = UIContextualAction(style: .destructive, title: "Add Photo") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            
            // pop album
            var configuration = PHPickerConfiguration()
            configuration.filter = .images
            configuration.selectionLimit = 5
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            self.present(picker, animated: true)
            
            // save row
            self.swippedRow = indexPath.row
            
            completionHandler(true)
        }
        
        addPhotoAction.backgroundColor = .darkGray
        let swipeAction = UISwipeActionsConfiguration(actions: [addPhotoAction])
        swipeAction.performsFirstActionWithFullSwipe = false
        return swipeAction
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if allBucketList[indexPath.row].images != [] {
            return 250
        } else {
            return 80
        }
    }
    
}

// MARK: - Photo processor

extension BucketDetailViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
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
                    
                    self.storage.child("listImage/\(imageName).png").putData(imageData, metadata: nil) { _, error in
                        
                        guard error == nil else {
                            print("Fail to upload image")
                            return
                        }
                        self.downloadImageURL(imageName: imageName)
                    }
                    print("Uploaded to firebase")
                } else {
                    print("There was an error.")
                }
            }
            
        }
    }
    
    func downloadImageURL(imageName: String) {
        
        self.storage.child("listImage/\(imageName).png").downloadURL(completion: { url, error in
            
            guard let url = url, error == nil else {
                return
            }
            
            let urlString = url.absoluteString
            self.imageUrlString.append(urlString)
            UserDefaults.standard.set(urlString, forKey: "url")
            
            guard let swippedRow = self.swippedRow, self.imageUrlString != [] else { return }
            
            let bucketList: BucketList = BucketList(
                senderId: self.allBucketList[swippedRow].senderId,
                createdTime: self.allBucketList[swippedRow].createdTime,
                status: self.allBucketList[swippedRow].status,
                list: self.allBucketList[swippedRow].list,
                categoryId: self.allBucketList[swippedRow].categoryId,
                listId: self.allBucketList[swippedRow].listId,
                images: self.imageUrlString
            )
            
            BucketListManager.shared.updateBucketList(bucketList: bucketList) { result in
                switch result {
                case .success:
                    self.presentAlert()
                    DispatchQueue.main.async {
                        self.fetchFromFirebase()
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    self.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
                }
            }
            
        })
        
    }
    
}

// MARK: - Delegate

extension BucketDetailViewController: BucketDetailTableViewCellDelegate {
    
    func didTappedStatus(cell: UITableViewCell) {
        
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        var status: Bool = false
        var date: Date = Date()
        
        if allBucketList[indexPath.row].status == true {
            status = false
            date = allBucketList[indexPath.row].createdTime
        } else {
            // if status become true, change date from created to finished
            date = Date()
            status = true
        }
        
        updateListStatus(status: status, row: indexPath.row, date: date)
        
    }
}
