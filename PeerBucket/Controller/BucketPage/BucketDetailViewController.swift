//
//  BucketDetailViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/16.
//

import Foundation
import UIKit
import PhotosUI
import Lottie

class BucketDetailViewController: UIViewController {
    
    // MARK: - Properties

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    lazy var longPressGesture: UILongPressGestureRecognizer = create {
        $0.addTarget(self, action: #selector(longPressGestureRecognized(_:)))
        $0.minimumPressDuration = 0.5
        $0.delaysTouchesBegan = true
    }
    
    lazy var submitButton: UIButton = create {
        $0.addTarget(self, action: #selector(tappedSubmitBtn), for: .touchUpInside)
        $0.setImage(UIImage(named: "icon_func_upload"), for: .normal)
        $0.isHidden = true
    }
    
    lazy var memoryButton: UIButton = create {
        $0.addTarget(self, action: #selector(tappedMemoryBtn), for: .touchUpInside)
        $0.setImage(UIImage(named: "icon_album"), for: .normal)
    }
    
    lazy var addListButton: UIButton = create {
        $0.addTarget(self, action: #selector(tappedAddBtn), for: .touchUpInside)
        $0.setImage(UIImage(named: "icon_func_add"), for: .normal)
    }
    
    lazy var addListTextField: UITextField = create {
        $0.setTextField(placeholder: "Type New List Here")
        $0.isHidden = true
    }
    
    lazy var menuBarItem = UIBarButtonItem(customView: self.memoryButton)
    
    var updatedImages: [String]?
    var updatedStatus: Bool?
    var updatedDate: Date?
    
    var imageSwippedRow: Int?
    var scheduleSwippedRow: Int?
    
    var imageUrlString: [String] = []
    var allListImages: [String] = []
    
    var selectedCategory: BucketCategory?
    var allBucketLists: [BucketList] = []
    
    var scheduleVC = AddScheduleViewController()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.addGestureRecognizer(longPressGesture)
        
        configureUI()
        
        navigationItem.title = selectedCategory?.category
        navigationItem.rightBarButtonItem = menuBarItem
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFromFirebase()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? AddScheduleViewController else { return }
        destination.delegate = self
        self.scheduleVC = destination
    }
    
    // MARK: - User interaction processor
    
    @objc func tappedMemoryBtn() {
        
        guard allListImages != [] else {
            self.presentAlert(title: "Error",
                              message: "To use album feature, please add photo to list first")
            return
        }
        
        let imageVC = self.storyboard?.instantiateViewController(withIdentifier: "imageVC")
        guard let imageVC = imageVC as? ImageDetailViewController else { return }
        imageVC.allBucketList = self.allBucketLists
        
        self.navigationController?.pushViewController(imageVC, animated: true)
        
    }
    
    @objc func tappedAddBtn() {
        if addListTextField.isHidden == true {
            showAddList()
        } else {
            hideAddList()
        }
    }
    
    @objc func tappedSubmitBtn() {
        guard addListTextField.text != "" else {
            presentAlert(title: "Error", message: "Please fill all the field")
            return
        }
        
        addBucketList()
        hideAddList()
    }
    
    @objc func longPressGestureRecognized(_ sender: UILongPressGestureRecognizer) {
        
        guard let row = self.tableView.indexPathForRow(at: sender.location(in: self.tableView))?.row,
              sender.state == .began else { return }
        
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
        
        self.presentActionAlert(action: "Delete", title: "Delete List",
                                message: "Do you want to delete this list?") {
            
            let deleteId = self.allBucketLists[row].listId
            self.deleteBucketList(deleteId: deleteId, row: row)
        }
    }
    
    // MARK: - UI processor
    
    func hideAddList() {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.addListTextField.isHidden = true
            self.addListTextField.text = ""
            self.submitButton.isHidden = true
            self.addListButton.setImage(UIImage(named: "icon_func_add"), for: .normal)
        }
    }
    
    func showAddList() {
        UIView.animate(withDuration: 0.5) {
            self.addListTextField.isHidden = false
            self.addListTextField.text = ""
            self.submitButton.isHidden = false
            self.addListButton.setImage(UIImage(named: "icon_func_cancel"), for: .normal)
        }
    }
    
    func hideScheduleMenu() {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.menuBottomConstraint.constant = hideMenuBottomConstraint
            self.blackView.alpha = 0
        }
    }
    
    func showScheduleMenu() {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.menuBottomConstraint.constant = 0
            self.blackView.alpha = 0.5
        }
    }
    
    func showImagePicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 5
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    func configureUI() {
        
        view.addSubview(addListButton)
        view.addSubview(addListTextField)
        view.addSubview(submitButton)
        view.bringSubviewToFront(containerView)
        
        view.backgroundColor = .lightGray
        tableView.backgroundColor = .lightGray
        blackView.backgroundColor = .black
        containerView.layer.cornerRadius = 10
        
        hideScheduleMenu()
        
        addListButton.anchor(bottom: view.bottomAnchor, right: view.rightAnchor,
                             paddingBottom: 90, paddingRight: 10, width: 50, height: 50)
        submitButton.anchor(bottom: view.bottomAnchor, right: addListButton.leftAnchor,
                            paddingBottom: 90, paddingRight: 2, width: 50, height: 50)
        addListTextField.anchor(bottom: view.bottomAnchor, right: submitButton.leftAnchor,
                                paddingBottom: 90, paddingRight: 2, width: screenWidth * 0.6, height: 50)
        
    }
    
    // MARK: - Firebase processor
    
    func fetchFromFirebase() {
        
        BucketListManager.shared.fetchBucketList(categoryID: selectedCategory?.id ?? "",
                                                 completion: { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let bucketList):
                self.allBucketLists = bucketList
                self.allListImages = []
                for list in self.allBucketLists where list.images != [] {
                    self.allListImages += list.images
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
            
        })
    }
    
    func addBucketList() {
        
        var newBucketList = formateDataModal(bucketList: nil)
        
        BucketListManager.shared.addBucketList(bucketList: &newBucketList!) { result in
            switch result {
            case .success:
                self.presentAlert()
            case .failure(let error):
                self.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
            }
        }
        
        self.fetchFromFirebase()
    }
    
    func checkBucketList(element: CheckElement, bucketList: BucketList) {
        
        switch element {
        case .image:
            updatedImages = self.imageUrlString
            updatedStatus = bucketList.status
            updatedDate = bucketList.createdTime
        case .status:
            updatedImages = bucketList.images
            if bucketList.status == true {
                updatedStatus = false
                updatedDate = bucketList.createdTime
            } else {
                updatedDate = Date()
                updatedStatus = true
            }
        default:
            break
        }
        
        let updatedBucketList = formateDataModal(bucketList: bucketList)
        guard let updatedBucketList = updatedBucketList else { return }
        updateBucketList(bucketList: updatedBucketList)
        
    }
    
    func formateDataModal(bucketList: BucketList?) -> BucketList? {
        
        guard let selectedCategory = selectedCategory,
              let currentUserUID = currentUserUID else {
            presentAlert(title: "Error", message: "Something went wrong. Please try again later")
            return nil
        }
        
        let newBucketList: BucketList = BucketList(
            senderId: bucketList?.senderId ?? currentUserUID,
            createdTime: updatedDate ?? Date(),
            status: updatedStatus ?? false,
            list: bucketList?.list ?? addListTextField.text ?? "",
            categoryId: bucketList?.categoryId ?? selectedCategory.id,
            listId: bucketList?.listId ?? "",
            images: updatedImages ?? []
        )
        return newBucketList
        
    }
    
    func deleteBucketList(deleteId: String, row: Int) {
        
        BucketListManager.shared.deleteBucketList(id: deleteId) { result in
            
            switch result {
            case .success:
                self.presentAlert()
                self.allBucketLists.remove(at: row)
                self.fetchFromFirebase()
            case .failure(let error):
                self.presentAlert(title: "Error",
                                  message: error.localizedDescription + " Please try again")
            }
        }
    }
    
    func updateBucketList(bucketList: BucketList) {
        
        BucketListManager.shared.updateBucketList(bucketList: bucketList) { result in
            switch result {
            case .success:
                self.fetchFromFirebase()
            case .failure(let error):
                self.presentAlert(title: "Error",
                                  message: error.localizedDescription + " Please try again")
            }
        }
    }
}

// MARK: - TableView

extension BucketDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allBucketLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BucketDetailTableViewCell", for: indexPath)
        guard let bucketDetailCell = cell as? BucketDetailTableViewCell else { return cell }
        
        bucketDetailCell.delegate = self
        bucketDetailCell.configureCell(bucketList: allBucketLists[indexPath.row])
        
        return bucketDetailCell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let scheduleAction = UIContextualAction(style: .destructive, title: "Schedule") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            
            self.scheduleSwippedRow = indexPath.row
            self.scheduleVC.eventTextField.text = self.allBucketLists[self.scheduleSwippedRow!].list
            
            self.showScheduleMenu()
            
            completion(true)
        }
        
        let addPhotoAction = UIContextualAction(style: .destructive, title: "Add Photo") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            
            self.imageSwippedRow = indexPath.row
            self.showImagePicker()
            
            completion(true)
        }
        
        addPhotoAction.backgroundColor = .hightlightYellow
        scheduleAction.backgroundColor = .darkGray
        
        let swipeAction = UISwipeActionsConfiguration(actions: [scheduleAction, addPhotoAction])
        return swipeAction
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if allBucketLists[indexPath.row].images != [] {
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
        
        // present animation
        let animationView = self.loadAnimation(name: "lottieLoading", loopMode: .repeat(3))
        animationView.play { _ in
            self.stopAnimation(animationView: animationView)
        }
        
        self.imageUrlString = []
        
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
        storage.child("listImage/\(imageName).png").putData(imageData, metadata: nil) { _, error in
            guard error == nil else {
                print("Fail to upload image")
                return
            }
            self.downloadImage(imageName: imageName)
            print("Uploaded to firebase")
        }
    }
    
    func downloadImage(imageName: String) {
        
        storage.child("listImage/\(imageName).png").downloadURL { url, error in
            
            guard let url = url, error == nil else {
                return
            }
            
            let urlString = url.absoluteString
            self.imageUrlString.append(urlString)
            UserDefaults.standard.set(urlString, forKey: "url")
            
            guard let swippedRow = self.imageSwippedRow, self.imageUrlString != [] else { return }
            
            self.checkBucketList(element: .image, bucketList: self.allBucketLists[swippedRow])
            
        }
    }
}

// MARK: - Delegate

extension BucketDetailViewController: BucketDetailTableViewCellDelegate, AddScheduleViewControllerDelegate {
    
    func didTappedStatus(cell: UITableViewCell) {
        
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        checkBucketList(element: .status, bucketList: allBucketLists[indexPath.row])
        
        let animationView = self.loadAnimation(name: "lottieCongrats", loopMode: .playOnce)
        animationView.play { _ in
            self.stopAnimation(animationView: animationView)
        }
    }
    
    func didTappedClose() {
        hideScheduleMenu()
    }
}
