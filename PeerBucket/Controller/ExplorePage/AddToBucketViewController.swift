//
//  AddToBucketViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/15.
//

import Foundation
import UIKit

protocol AddToBucketViewControllerDelegate: AnyObject {
    func didTappedClose()
}

class AddToBucketViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var delegate: AddToBucketViewControllerDelegate?
    
    var bucketCategories: [BucketCategory] = []
    var userIDList: [String] = [currentUserUID]
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.lightGray
        button.addTarget(self, action: #selector(tappedCloseBtn), for: .touchUpInside)
        return button
    }()
    
    var selectedBucketTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.topAnchor, right: view.rightAnchor, paddingTop: 10, paddingRight: 10)
        
        getData(userID: currentUserUID)
        
    }
    
    func getData(userID: String) {
        
        // fetch current user's paring user and append to userList
        UserManager.shared.fetchUserData(userID: userID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.userIDList.append(user.paringUser[0])
                print("Find paring user: \(String(describing: user.paringUser[0]))")
                
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
                            print("fetch bucket categories: \(bucketLists)")
                            print("category count: \(bucketLists.count)")
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
//                        print("userIDList: \(self.userIDList)")
                    }
                }
                
            case .failure(let error):
                self.presentErrorAlert(message: error.localizedDescription + " Please try again")
                print("Can't find user in bucketListVC")
            }
        }
    }
    
    @objc func tappedCloseBtn() {
        delegate?.didTappedClose()
    }
    
}

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
        
        cell.clipsToBounds = true
        cell.layer.cornerRadius = cell.frame.height/4
        cell.backgroundColor = UIColor.hightlightYellow
        
        cell.categoryLabel.text = bucketCategories[indexPath.row].category
        
        return cell
        
    }
    
}

extension AddToBucketViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        let totalWidth = UIScreen.main.bounds.width
        return (totalWidth-360)/10
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let title = selectedBucketTitle else { return }
                    
        var bucketList: BucketList = BucketList(
            senderId: testUserID,
            createdTime: Date(),
            status: false,
            list: title,
            categoryId: bucketCategories[indexPath.row].id,
            listId: ""
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
