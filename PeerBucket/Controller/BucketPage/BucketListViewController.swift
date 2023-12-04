//
//  BucketListViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/16.
//

import Foundation
import UIKit
import FirebaseAuth
import Lottie

final class BucketListViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var menuBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var containerView: UIView!
        
    private lazy var alertImageView: UIImageView = create {
        $0.image = UIImage(named: "default_view")
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    
    private lazy var alertLabel: UILabel = create {
        $0.font = UIFont.bold(size: 25)
        $0.textColor = .lightGray
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    private lazy var closeButton: UIButton = create {
        $0.addTarget(self, action: #selector(tappedCloseBtn), for: .touchUpInside)
        $0.setImage(UIImage(named: "icon_func_cancel"), for: .normal)
    }
    
    private lazy var addCategoryButton: UIButton = create {
        $0.addTarget(self, action: #selector(tappedAddBtn), for: .touchUpInside)
        $0.setImage(UIImage(named: "icon_func_add"), for: .normal)
    }
    
    private lazy var randomPickButton: UIButton = create {
        $0.addTarget(self, action: #selector(tappedPickBtn), for: .touchUpInside)
        $0.setImage(UIImage(named: "icon_func_random"), for: .normal)
    }
    
    private lazy var liveTextButton: UIButton = create {
        $0.addTarget(self, action: #selector(tappedLiveTextBtn), for: .touchUpInside)
        $0.setImage(UIImage(named: "icon_func_livetext"), for: .normal)
    }
    
    private lazy var longPressGesture: UILongPressGestureRecognizer = create {
        $0.addTarget(self, action: #selector(handleLongPress(gestureReconizer:)))
        $0.minimumPressDuration = 0.5
        $0.delaysTouchesBegan = true
        $0.delegate = self
    }
    
    private lazy var progressView: UIProgressView = create {
        $0.progressTintColor = UIColor.hightlightYellow
        $0.trackTintColor = UIColor.darkGreen
    }
    
    private lazy var titleLabel: UILabel = create {
        $0.textColor = .darkGreen
        $0.font = UIFont.bold(size: 28)
    }
    
    private lazy var progressLabel: UILabel = create {
        $0.textColor = .hightlightYellow
        $0.font = UIFont.semiBold(size: 20)
    }
    
    private lazy var buttonHStack: UIStackView = create {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 6
    }
    
    private var bucketCategories: [BucketCategory] = []
    private var bucketLists: [BucketList] = []
    private var shareBucketListCount: Int = 0
    private var shareFinishedListCount: Int = 0
    
    private var selectedCategory: BucketCategory?
    private var progress: Float {
        Float(shareFinishedListCount) / Float(shareBucketListCount)
    }
    
    private var userIDList: [String] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureAlertViewUI()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let currentUserUID = currentUserUID else {
            guard let loginVC = initFromStoryboard(with: .login) as? LoginViewController else { return }
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true)
            return
        }
        fetchUser(userID: currentUserUID)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AddNewBucketViewController {
            destination.delegate = self
        }
    }
    
    // MARK: - Configure UI

    private func configureUI() {
        view.backgroundColor = .lightGray
        collectionView.backgroundColor = .lightGray
        view.addSubviews([buttonHStack, progressView, progressLabel, titleLabel])
        buttonHStack.addArrangedSubviews([randomPickButton, liveTextButton, addCategoryButton])

        blackView.backgroundColor = .black
        menuBottomConstraint.constant = hideMenuBottomConstraint
        blackView.alpha = 0
        view.bringSubviewToFront(blackView)
        view.bringSubviewToFront(containerView)
        
        buttonHStack.anchor(bottom: collectionView.topAnchor, right: view.rightAnchor,
                            paddingBottom: 20, paddingRight: 10)
        titleLabel.anchor(top: view.topAnchor, left: view.leftAnchor, paddingTop: 100,
                          paddingLeft: 20, height: 40)
        progressLabel.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor,
                             paddingTop: 8, paddingLeft: 20, height: 30)
        progressView.anchor(top: progressLabel.bottomAnchor, left: view.leftAnchor,
                            paddingTop: 10, paddingLeft: 20, width: 200, height: 20)
        
    }
    
    private func configureAlertViewUI() {
        view.addSubviews([alertImageView, closeButton])
        view.addSubview(alertImageView)
        alertImageView.addSubview(alertLabel)
        
        alertImageView.centerX(inView: view)
        alertImageView.centerY(inView: view)
        alertImageView.anchor(width: 280, height: 250)
        alertLabel.centerY(inView: view)
        alertLabel.anchor(right: alertImageView.rightAnchor, paddingRight: 10,
                          width: 120, height: 100)
        closeButton.anchor(top: alertImageView.topAnchor, right: alertImageView.rightAnchor,
                           paddingTop: 5, paddingRight: 5)
        
        closeButton.isHidden = true
        alertImageView.alpha = 0
    }
    
    private func updateProgressUI(bucketListCount: Int) {
        if bucketLists.count == 0 {
            DispatchQueue.main.async {
                self.titleLabel.text = "There's no bucket."
                self.progressLabel.text = "Let's add new bucket list!"
            }
        } else {
            DispatchQueue.main.async {
                let percentProgress = Int(self.progress * 100)
                self.titleLabel.text = "Bucket Progress \(percentProgress)%"
                self.progressLabel.text = "\(self.shareFinishedListCount) of \(self.shareBucketListCount) buckets accomplished"
                self.randomPickButton.isEnabled = true
            }
        }
        collectionView.reloadData()
    }
    
    // MARK: - User interaction handler

    @objc
    private func tappedCloseBtn() {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.alertImageView.alpha = 0
            self.blackView.alpha = 0
            self.closeButton.isHidden = true
        }
    }
    
    @objc
    private func tappedAddBtn() {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.menuBottomConstraint.constant = 0
            self.blackView.alpha = 0.5
        }
    }
    
    @objc
    private func tappedPickBtn() {
        guard bucketLists.isNotEmpty else { return }
        let unFinishedBucketList = bucketLists.filter { $0.status == false }
        guard unFinishedBucketList.isNotEmpty else { return }
        let randomNum = Int.random(in: 0 ... unFinishedBucketList.count - 1)
        let randomList = unFinishedBucketList[randomNum].list
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.alertImageView.alpha = 1
            self.alertLabel.text = randomList
            self.blackView.alpha = 0.5
            self.closeButton.isHidden = false
        }
    }
    
    @objc
    private func tappedLiveTextBtn() {
        guard let liveVC = initFromStoryboard(with: .live) as? LiveTextController else { return }
        self.present(liveVC, animated: true)
    }
    
    @objc
    private func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        guard gestureReconizer.state == UIGestureRecognizer.State.ended else {
            return
        }
        
        let location = gestureReconizer.location(in: self.collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: location) else {
            Log.e("cant locate indexpath")
            return
        }

        presentActionAlert(action: "Delete", title: "Delete Category",
                                message: "Do you want to delete this category?") { [weak self] in
            guard let self = self else { return }
            let deleteId = self.bucketCategories[indexPath.row].id
            self.deleteBucketList(deleteId: deleteId)
            self.deleteBucketCategory(deleteId: deleteId, row: indexPath.row)
        }
    }
    
    // MARK: - Firebase handler
    
    private func fetchUser(userID: String) {
        UserManager.shared.fetchUserData(userID: userID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.userIDList = [userID]
                if user.paringUser.isNotEmpty {
                    self.userIDList.append(user.paringUser[0])
                }
                self.fetchBucketCategory()
                self.fetchAllBucketList()
            case .failure(let error):
                self.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
            }
        }
    }
    
    private func fetchBucketCategory() {
        self.bucketCategories = []
        for userID in self.userIDList {
            BucketListManager.shared.fetchBucketCategory(userID: userID) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let bucketLists):
                    self.bucketCategories += bucketLists
                case .failure(let error):
                    Log.e(error.localizedDescription)
                }
            }
        }
    }
    
    private func fetchAllBucketList() {
        // TODO: reset?
        self.bucketLists = []
        self.shareBucketListCount = 0
        self.shareFinishedListCount = 0
        for userID in userIDList {
            BucketListManager.shared.fetchBucketListBySender(senderId: userID) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let bucketLists):
                    self.bucketLists += bucketLists
                    self.shareBucketListCount += bucketLists.count
                    let finishedBucketList = bucketLists.filter { $0.status == true }
                    self.shareFinishedListCount += finishedBucketList.count
                    self.progressView.progress = self.progress
                    self.updateProgressUI(bucketListCount: bucketLists.count)
                case .failure(let error):
                    Log.e(error.localizedDescription)
                }
            }
        }
    }
    
    private func deleteBucketCategory(deleteId: String, row: Int) {
        BucketListManager.shared.deleteBucketCategory(id: deleteId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.bucketCategories.remove(at: row)
                self.presentAlert()
            case .failure(let error):
                self.presentAlert(
                    title: "Error",
                    message: error.localizedDescription + " Please try again")
            }
        }
    }
    
    private func deleteBucketList(deleteId: String) {
        BucketListManager.shared.deleteBucketListByCategory(id: deleteId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.fetchAllBucketList()
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                self.presentAlert()
            case .failure(let error):
                self.presentAlert(
                    title: "Error",
                    message: error.localizedDescription + " Please try again")
            }
        }
    }
}

// MARK: - CollectionView

extension BucketListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bucketCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BucketListCollectionViewCell.cellIdentifier,
            for: indexPath) as? BucketListCollectionViewCell else {
            return .init()
        }
        cell.configureCell(category: bucketCategories[indexPath.row])
        return cell
    }
}

extension BucketListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (screenWidth - 30) / 2, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let detailBucketVC = initFromStoryboard(with: .bucketDetail) as? BucketDetailViewController else { return }
        selectedCategory = bucketCategories[indexPath.row]
        detailBucketVC.selectedCategory = selectedCategory
        navigationController?.pushViewController(detailBucketVC, animated: true)
    }
}

// MARK: - Delegate

extension BucketListViewController: AddNewBucketDelegate {
    func didTappedClose() {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.menuBottomConstraint.constant = hideMenuBottomConstraint
            self.blackView.alpha = 0
        }
        let animationView = self.loadAnimation(name: "lottieLoading", loopMode: .repeat(1))
        animationView.play { [weak self] _ in
            self?.stopAnimation(animationView: animationView)
        }
        
        guard let currentUserUID = currentUserUID else { return }
        fetchUser(userID: currentUserUID)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}
