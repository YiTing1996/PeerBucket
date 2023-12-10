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

final class BucketDetailViewController: UIViewController {
    
    // MARK: - Properties

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    private lazy var longPressGesture: UILongPressGestureRecognizer = create {
        $0.addTarget(self, action: #selector(longPressGestureRecognized(_:)))
        $0.minimumPressDuration = 0.5
        $0.delaysTouchesBegan = true
    }
    
    private lazy var submitButton: UIButton = create {
        $0.addTarget(self, action: #selector(tappedSubmitBtn), for: .touchUpInside)
        $0.setImage(UIImage(named: "icon_func_upload"), for: .normal)
        $0.isHidden = true
    }
    
    private lazy var memoryButton: UIButton = create {
        $0.addTarget(self, action: #selector(tappedMemoryBtn), for: .touchUpInside)
        $0.setImage(UIImage(named: "icon_album"), for: .normal)
    }
    
    private lazy var addListButton: UIButton = create {
        $0.addTarget(self, action: #selector(tappedAddBtn), for: .touchUpInside)
        $0.setImage(UIImage(named: "icon_func_add"), for: .normal)
    }
    
    private lazy var addListTextField: UITextField = create {
        $0.setThemeTextField(placeholder: "Type New List Here")
        $0.isHidden = true
    }
        
    private var updatedImages: [String]?
    private var updatedStatus: Bool?
    private var updatedDate: Date?
    
    private var imageSwippedRow: Int?
    private var scheduleSwippedRow: Int?
    
    private var imageUrlString: [String] = []
    private var allListImages: [String] = []
    
    var selectedCategory: BucketCategory?
    private var allBucketLists: [BucketList] = []
    
    private weak var scheduleVC: AddScheduleViewController?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.addGestureRecognizer(longPressGesture)
        navigationItem.title = selectedCategory?.category
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.memoryButton)
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchBucketLists()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? AddScheduleViewController else { return }
        destination.delegate = self
        self.scheduleVC = destination
    }
    
    // MARK: - User interaction processor
    
    @objc
    private func tappedMemoryBtn() {
        guard allListImages.isNotEmpty else {
            presentAlert(
                title: "Error",
                message: "To use album feature, please add photo to list first")
            return
        }
        guard let imageVC = initFromStoryboard(with: .memory) as? ImageDetailViewController else { return }
        imageVC.allBucketList = self.allBucketLists
        navigationController?.pushViewController(imageVC, animated: true)
    }
    
    @objc
    private func tappedAddBtn() {
        addListTextField.isHidden ? showAddList() : hideAddList()
    }
    
    @objc
    private func tappedSubmitBtn() {
        guard let text = addListTextField.text, text.isNotEmpty else {
            presentAlert(title: "Error", message: "Please fill all the field")
            return
        }
        addBucketList()
        hideAddList()
    }
    
    @objc
    private func longPressGestureRecognized(_ sender: UILongPressGestureRecognizer) {
        guard let row = tableView.indexPathForRow(at: sender.location(in: tableView))?.row,
              sender.state == .began else {
            return
        }
        
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
        
        presentActionAlert(
            action: "Delete",
            title: "Delete List",
            message: "Do you want to delete this list?") { [weak self] in
                guard let self = self else { return }
                let deleteId = self.allBucketLists[row].listId
                self.deleteBucketList(deleteId: deleteId, row: row)
            }
    }
    
    // MARK: - UI
    
    private func hideAddList() {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.addListTextField.isHidden = true
            self.addListTextField.text = ""
            self.submitButton.isHidden = true
            self.addListButton.setImage(UIImage(named: "icon_func_add"), for: .normal)
        }
    }
    
    private func showAddList() {
        UIView.animate(withDuration: 0.5) {
            self.addListTextField.isHidden = false
            self.addListTextField.text = ""
            self.submitButton.isHidden = false
            self.addListButton.setImage(UIImage(named: "icon_func_cancel"), for: .normal)
        }
    }
    
    private func hideScheduleMenu() {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.menuBottomConstraint.constant = ScreenConstant.hideMenuBottomConstraint
            self.blackView.alpha = 0
        }
    }
    
    private func showScheduleMenu() {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.menuBottomConstraint.constant = 0
            self.blackView.alpha = 0.5
        }
    }
    
    private func showImagePicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 5
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    private func configureUI() {
        view.addSubviews([addListButton, addListTextField, submitButton])
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
    
    private func fetchBucketLists() {
        guard let selectedCategory = selectedCategory else { return }
        BucketListManager.shared.fetchBucketList(categoryID: selectedCategory.id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let bucketList):
                self.allBucketLists = bucketList
                self.allListImages = []
                for list in self.allBucketLists where list.images.isNotEmpty {
                    self.allListImages += list.images
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                Log.e(error.localizedDescription)
            }
        }
    }
    
    private func addBucketList() {
        guard var newBucketList = formateDataModal(bucketList: nil) else { return }
        BucketListManager.shared.addBucketList(bucketList: &newBucketList) { [weak self] result in
            switch result {
            case .success:
                self?.presentAlert()
            case .failure(let error):
                self?.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
            }
        }
        fetchBucketLists()
    }
    
    private func checkBucketList(element: CheckElement, bucketList: BucketList) {
        switch element {
        case .image:
            updatedImages = self.imageUrlString
            updatedStatus = bucketList.status
            updatedDate = bucketList.createdTime
        case .status:
            updatedImages = bucketList.images
            updatedStatus = !bucketList.status
            updatedDate = bucketList.status ? bucketList.createdTime : Date()
        default:
            break
        }
        
        let updatedBucketList = formateDataModal(bucketList: bucketList)
        guard let updatedBucketList = updatedBucketList else { return }
        updateBucketList(bucketList: updatedBucketList)
    }
    
    private func formateDataModal(bucketList: BucketList?) -> BucketList? {
        guard let selectedCategory = selectedCategory,
              let currentUserUID = Info.shared.currentUser?.userID else {
            presentErrorAlert()
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
    
    private func deleteBucketList(deleteId: String, row: Int) {
        BucketListManager.shared.deleteBucketList(id: deleteId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.presentAlert()
                self.allBucketLists.remove(at: row)
                self.fetchBucketLists()
            case .failure(let error):
                self.presentAlert(
                    title: "Error",
                    message: error.localizedDescription + " Please try again")
            }
        }
    }
    
    func updateBucketList(bucketList: BucketList) {
        BucketListManager.shared.updateBucketList(bucketList: bucketList) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.fetchBucketLists()
            case .failure(let error):
                self.presentAlert(
                    title: "Error",
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
        let cell = tableView.dequeueReusableCell(withIdentifier: BucketDetailTableViewCell.cellIdentifier, for: indexPath)
        guard let cell = cell as? BucketDetailTableViewCell else {
            return .init()
        }
        cell.delegate = self
        cell.configureCell(bucketList: allBucketLists[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let scheduleAction = UIContextualAction(style: .destructive, title: "Schedule") { [weak self] (_, _, completion) in
            guard let self = self, let scheduleVC = self.scheduleVC else { return }
            self.scheduleSwippedRow = indexPath.row
            scheduleVC.eventTextField.text = self.allBucketLists[indexPath.row].list
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
        allBucketLists[indexPath.row].images.isNotEmpty ? 250 : 80
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
        results.forEach {
            compressImage(result: $0)
        }
    }
    
    private func compressImage(result: PHPickerResult) {
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
            guard let image = image as? UIImage,
                  let imageData = image.jpegData(compressionQuality: 0.5),
                  let self = self, error == nil else {
                Log.v(error?.localizedDescription)
                return
            }
            let imageName = NSUUID().uuidString
            self.uploadImage(imageName: imageName, imageData: imageData)
        }
    }
    
    private func uploadImage(imageName: String, imageData: Data) {
        storage.child("listImage/\(imageName).png").putData(imageData, metadata: nil) { [weak self]  _, error in
            guard let self = self, error == nil else {
                Log.e(error?.localizedDescription)
                return
            }
            self.downloadImage(imageName: imageName)
        }
    }
    
    private func downloadImage(imageName: String) {
        storage.child("listImage/\(imageName).png").downloadURL { [weak self] url, error in
            guard let self = self, let url = url, error == nil else {
                Log.e(error?.localizedDescription)
                return
            }
            let urlString = url.absoluteString
            self.imageUrlString.append(urlString)
            UserDefaults.standard.set(urlString, forKey: "url")
            guard let swippedRow = self.imageSwippedRow, self.imageUrlString.isNotEmpty else { return }
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
        animationView.play { [weak self] _ in
            self?.stopAnimation(animationView: animationView)
        }
    }
    
    func didTappedClose() {
        hideScheduleMenu()
    }
}
