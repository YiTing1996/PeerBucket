//
//  AddToBucketViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/15.
//

import Foundation
import UIKit
import FirebaseAuth

protocol AddToBucketViewControllerDelegate: AnyObject {
    func didTappedClose()
}

class AddToBucketViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var delegate: AddToBucketViewControllerDelegate?
    
    var bucketCategories: [BucketCategory] = []
    
    var currentUserUID: String?
    //    var currentUserUID = Auth.auth().currentUser?.uid
    var userIDList: [String] = []
    
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_func_cancel"), for: .normal)
        button.addTarget(self, action: #selector(tappedCloseBtn), for: .touchUpInside)
        return button
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.semiBold(size: 20)
        label.text = "Select a bucket category you want to add !"
        return label
    }()
    
    var selectedBucketTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isBeta {
            self.currentUserUID = "AITNzRSyUdMCjV4WrQxT"
        } else {
            self.currentUserUID = Auth.auth().currentUser?.uid ?? nil
        }
//        print(currentUserUID)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .lightGray
        
        configureUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let currentUserUID = currentUserUID else { return }
        userIDList.append(currentUserUID)
        getData(userID: currentUserUID)
        
    }
    
    func configureUI() {
        
        view.layer.cornerRadius = 30
        view.clipsToBounds = true
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.backgroundColor = .lightGray
        
        view.addSubview(titleLabel)
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.topAnchor, right: view.rightAnchor, paddingTop: 10, paddingRight: 10)
        titleLabel.anchor(top: cancelButton.bottomAnchor, left: view.leftAnchor, paddingTop: 5, paddingLeft: 20, height: 50)
    }
    
    @objc func tappedCloseBtn() {
        delegate?.didTappedClose()
    }
    
    // MARK: - Firebase data process
    
    func getData(userID: String) {
        
        UserManager.shared.fetchUserData(userID: userID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                
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
                                self.collectionView.reloadData()
                            }
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                }
                
            case .failure(let error):
                self.presentErrorAlert(message: error.localizedDescription + " Please try again")
                print("Can't find user in bucketListVC")
            }
        }
    }
}

// MARK: - Collection View

extension AddToBucketViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bucketCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "AddToBucketCollectionViewCell",
            for: indexPath)
        guard let cell = cell as? AddToBucketCollectionViewCell else { return cell }
        
        cell.layer.cornerRadius = 20
        cell.layer.borderColor = UIColor.darkGray.cgColor
        cell.layer.borderWidth = 1
        
        cell.configureCell(bucketCategories: bucketCategories[indexPath.row])
        
        return cell
        
    }
    
}

extension AddToBucketViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let title = selectedBucketTitle else { return }
        
        guard let currentUserUID = currentUserUID else { return }

        var bucketList: BucketList = BucketList(
            senderId: currentUserUID,
            createdTime: Date(),
            status: false,
            list: title,
            categoryId: bucketCategories[indexPath.row].id,
            listId: "",
            images: []
        )
        
        BucketListManager.shared.addBucketList(bucketList: &bucketList) { result in
            
            switch result {
            case .success:
                self.presentSuccessAlert()
            case .failure(let error):
                self.presentErrorAlert(message: error.localizedDescription + " Please try again")
            }
        }
        
        self.presentSuccessAlert()
        self.delegate?.didTappedClose()
        
    }
    
}
