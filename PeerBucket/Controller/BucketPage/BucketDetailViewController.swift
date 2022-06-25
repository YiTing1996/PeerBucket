//
//  BucketDetailViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/16.
//

import Foundation
import UIKit

class BucketDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
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
    
    var addListTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type New List Here"
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 10
        textField.setLeftPaddingPoints(amount: 10)
        textField.backgroundColor = UIColor.lightGray
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        view.backgroundColor = .lightGray
        tableView.backgroundColor = .lightGray
        
        configureUI()
        addListTextField.isHidden = true
        submitButton.isHidden = true
        
        tableView.addGestureRecognizer(longPressGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchFromFirebase()
    }
    
    func configureUI() {
        
        view.addSubview(addListButton)
        view.addSubview(addListTextField)
        view.addSubview(submitButton)
        
        addListButton.anchor(top: view.topAnchor, right: view.rightAnchor,
                             paddingTop: 120, paddingRight: 20, width: 50, height: 50)
        submitButton.anchor(top: view.topAnchor, right: addListButton.leftAnchor,
                            paddingTop: 120, paddingRight: 5, width: 50, height: 50)
        addListTextField.anchor(top: view.topAnchor, left: view.leftAnchor,
                                paddingTop: 120, paddingLeft: 30, width: 250, height: 50)
        
    }
    
    func fetchFromFirebase() {
        
        BucketListManager.shared.fetchBucketList(categoryID: selectedBucket?.id ?? "", completion: { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let bucketList):
                self.allBucketList = bucketList
                print(self.allBucketList)
            case .failure(let error):
                print(error.localizedDescription)
            }
            
        })
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
    
    @objc func tappedSubmitBtn() {
        
        guard let selectedBucket = selectedBucket,
              addListTextField.text != "" else {
            presentErrorAlert(message: "Please fill all the field")
            return
        }
        
        var bucketList: BucketList = BucketList(
            senderId: testUserID,
            //            createdTime: Date().millisecondsSince1970,
            createdTime: Date(),
            status: false,
            list: addListTextField.text ?? "",
            categoryId: selectedBucket.id,
            listId: ""
        )
        
        BucketListManager.shared.addBucketList(bucketList: &bucketList) { result in
            switch result {
            case .success:
                self.presentSuccessAlert()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                self.presentErrorAlert(message: error.localizedDescription + " Please try again")
            }
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
                
                self.presentDeleteAlert(title: "Delete List", message: "Do you want to delete this list?") {
                    
                    let deleteId = self.allBucketList[row].listId
                    
                    BucketListManager.shared.deleteBucketList(id: deleteId) { result in
                        
                        switch result {
                        case .success:
                            // UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [deleteId])
                            self.presentSuccessAlert()
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        case .failure(let error):
                            self.presentErrorAlert(message: error.localizedDescription + " Please try again")
                        }
                    }
                }
                
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
        let deleteAction = UIContextualAction(style: .destructive, title: "delete") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            
            self.presentDeleteAlert(title: "Delete List", message: "Do you want to delete this list?") {
                
                let deleteId = self.allBucketList[indexPath.row].listId
                
                BucketListManager.shared.deleteBucketList(id: deleteId) { result in
                    
                    switch result {
                    case .success:
                        //                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [deleteId])
                        self.presentSuccessAlert()
                    case .failure(let error):
                        self.presentErrorAlert(message: error.localizedDescription + " Please try again")
                    }
                }
            }
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = .lightGray
        
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeAction.performsFirstActionWithFullSwipe = false
        return swipeAction
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}

extension BucketDetailViewController: BucketDetailTableViewCellDelegate {
    
    func didTappedStatus(cell: UITableViewCell) {
        
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        var status: Bool = false
        
        if allBucketList[indexPath.row].status == true {
            status = false
        } else {
            status = true
        }
        
        let bucketList: BucketList = BucketList(
            senderId: allBucketList[indexPath.row].senderId,
            createdTime: allBucketList[indexPath.row].createdTime,
            status: status,
            list: allBucketList[indexPath.row].list,
            categoryId: allBucketList[indexPath.row].categoryId,
            listId: allBucketList[indexPath.row].listId
        )
        
        BucketListManager.shared.updateBucketListStatus(bucketList: bucketList) { result in
            switch result {
            case .success:
                self.presentSuccessAlert()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                self.presentErrorAlert(message: error.localizedDescription + " Please try again")
            }
        }
    }
}
