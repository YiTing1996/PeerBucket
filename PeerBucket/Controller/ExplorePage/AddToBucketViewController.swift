//
//  AddToBucketViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/15.
//

import UIKit
import FirebaseAuth

protocol AddToBucketViewControllerDelegate: AnyObject {
    func didTappedClose()
}

final class AddToBucketViewController: BaseViewController {
    
    // MARK: - Properties

    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var delegate: AddToBucketViewControllerDelegate?
    
    private var bucketCategories: [BucketCategory] = []
    var selectedBucketTitle: String?
    private var userIDList: [String] = []
    
    private lazy var cancelButton: UIButton = create {
        $0.setImage(UIImage(named: "icon_func_cancel"), for: .normal)
        $0.addTarget(self, action: #selector(tappedCloseBtn), for: .touchUpInside)
    }
    
    private lazy var titleLabel: UILabel = create {
        $0.textColor = .darkGray
        $0.font = UIFont.semiBold(size: 20)
        $0.text = "Select a bucket category you want to add !"
        $0.numberOfLines = 0
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .lightGray
        configureUI()
    }
    
    override func configureAfterFetchUserData() {
        guard let currentUser = currentUser else { return }
        userIDList = [currentUser.userID]
        if let paringUserId = currentUser.paringUser.first {
            userIDList.append(paringUserId)
        }
        for userID in userIDList {
            fetchBucketCatgory(userID: userID)
        }
    }
    
    // MARK: - UI

    func configureUI() {
        view.layer.cornerRadius = 30
        view.clipsToBounds = true
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.backgroundColor = .lightGray
        view.addSubview(titleLabel)
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.topAnchor, right: view.rightAnchor, paddingTop: 10, paddingRight: 30)
        titleLabel.anchor(top: cancelButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
                          paddingTop: 5, paddingLeft: 20, paddingRight: 20, height: 50)
    }
    
    @objc
    private func tappedCloseBtn() {
        delegate?.didTappedClose()
    }
    
    // MARK: - Firebase data handler
    
    private func fetchBucketCatgory(userID: String) {
        self.bucketCategories = []
        BucketListManager.shared.fetchBucketCategory(userID: userID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let bucketLists):
                self.bucketCategories += bucketLists
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                Log.e(error.localizedDescription)
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
            withReuseIdentifier: AddToBucketCollectionViewCell.cellIdentifier, for: indexPath)
        guard let cell = cell as? AddToBucketCollectionViewCell else { return .init() }
        cell.configureCell(bucketCategories: bucketCategories[indexPath.row])
        return cell
    }
}

extension AddToBucketViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ScreenConstant.width / 3.5, height: ScreenConstant.width / 3.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let title = selectedBucketTitle, let currentUser = currentUser else { return }
        var bucketList: BucketList = BucketList(
            senderId: currentUser.userID,
            createdTime: Date(),
            status: false,
            list: title,
            categoryId: bucketCategories[indexPath.row].id,
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
        presentAlert()
        delegate?.didTappedClose()
    }
}
