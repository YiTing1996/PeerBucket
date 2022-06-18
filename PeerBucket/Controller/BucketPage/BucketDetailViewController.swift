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
    
    lazy var addListButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(tappedAddBtn), for: .touchUpInside)
        button.setTitle("Add", for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        button.backgroundColor = UIColor.bgGray
        button.setTitleColor(UIColor.textGray, for: .normal)
        return button
    }()
    
    var addListTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type New List Here"
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 10
        textField.setLeftPaddingPoints(amount: 10)
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
        
        configureUI()
        //        addListTextField.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchFromFirebase()
    }
    
    func configureUI() {
        
        view.addSubview(addListButton)
        view.addSubview(addListTextField)
        
        addListButton.anchor(top: view.topAnchor, right: view.rightAnchor,
                             paddingTop: 120, paddingRight: 50, width: 50, height: 50)
        addListTextField.anchor(top: view.topAnchor, left: view.leftAnchor,
                                paddingTop: 120, paddingLeft: 50, width: 200, height: 50)
        
    }
    
    func fetchFromFirebase() {
        
        BucketListManager.shared.fetchBucketList(id: selectedBucket?.id ?? "", completion: { [weak self] result in
            
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
        //        addListTextField.isHidden = false
        
        guard let selectedBucket = selectedBucket,
              addListTextField.text != "" else {
            presentErrorAlert(message: "Please fill all the field")
            return
        }
        
        var bucketList: BucketList = BucketList(
            senderId: "Doreen",
            createdTime: Date().millisecondsSince1970,
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
        
        addListTextField.text = ""
        
    }
    
}

extension BucketDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allBucketList.count
        //        return selectedBucket?.content.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BucketDetailTableViewCell", for: indexPath)
        
        guard let bucketDetailCell = cell as? BucketDetailTableViewCell else { return cell }
        
        bucketDetailCell.configureCell(bucketText: allBucketList[indexPath.row].list)
        bucketDetailCell.contentView.backgroundColor = UIColor.bgGray
        
        return bucketDetailCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
            case .success(let string):
                self.presentSuccessAlert()
                print(string)
            case .failure(let error):
                self.presentErrorAlert(message: error.localizedDescription + " Please try again")
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "delete") { [weak self] (_, _, completionHandler) in
            guard let self = self else { return }
            
            self.presentDeleteAlert(title: "Delete List", message: "Do you want to delete this list?") {
                
                let deleteId = self.allBucketList[indexPath.row].listId
                
                BucketListManager.shared.deleteBucketList(id: deleteId) { result in
                    
                    switch result {
                    case .success:
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [deleteId])
                    case .failure(let error):
                        self.presentErrorAlert(message: error.localizedDescription + " Please try again")
                    }
                    
                }
                
            }
            
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = .white
        
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeAction.performsFirstActionWithFullSwipe = false
        return swipeAction
    }
    
}
