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

class BucketListViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var menuBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var containerView: UIView!
        
    lazy var alertImageView: UIImageView = create {
        $0.image = UIImage(named: "default_view")
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    
    lazy var alertLabel: UILabel = create {
        $0.font = UIFont.bold(size: 25)
        $0.textColor = .lightGray
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    lazy var closeButton: UIButton = create {
        $0.addTarget(self, action: #selector(tappedCloseBtn), for: .touchUpInside)
        $0.setImage(UIImage(named: "icon_func_cancel"), for: .normal)
    }
    
    lazy var addCategoryButton: UIButton = create {
        $0.addTarget(self, action: #selector(tappedAddBtn), for: .touchUpInside)
        $0.setImage(UIImage(named: "icon_func_add"), for: .normal)
    }
    
    lazy var randomPickButton: UIButton = create {
        $0.addTarget(self, action: #selector(tappedPickBtn), for: .touchUpInside)
        $0.setImage(UIImage(named: "icon_func_random"), for: .normal)
    }
    
    lazy var liveTextButton: UIButton = create {
        $0.addTarget(self, action: #selector(tappedLiveTextBtn), for: .touchUpInside)
        $0.setImage(UIImage(named: "icon_func_livetext"), for: .normal)
    }
    
    lazy var longPressGesture: UILongPressGestureRecognizer = create {
        $0.addTarget(self, action: #selector(handleLongPress(gestureReconizer:)))
        $0.minimumPressDuration = 0.5
        $0.delaysTouchesBegan = true
        $0.delegate = self
    }
    
    lazy var progressView: UIProgressView = create {
        $0.progressTintColor = UIColor.hightlightYellow
        $0.trackTintColor = UIColor.darkGreen
    }
    
    lazy var titleLabel: UILabel = create {
        $0.textColor = .darkGreen
        $0.font = UIFont.bold(size: 28)
    }
    
    lazy var progressLabel: UILabel = create {
        $0.textColor = .hightlightYellow
        $0.font = UIFont.semiBold(size: 20)
    }
    
    lazy var buttonHStack: UIStackView = create {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 6
    }
    
    var bucketCategories: [BucketCategory] = []
    var bucketLists: [BucketList] = []
    var shareBucketListCount: Int = 0
    var shareFinishedListCount: Int = 0
    
    var selectedCategory: BucketCategory?
    var progress: Float?
    
    var userIDList: [String] = []
    
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
            let loginVC = storyboard?.instantiateViewController(withIdentifier: "loginVC")
            guard let loginVC = loginVC as? LoginViewController else { return }
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

    func configureUI() {
        self.view.backgroundColor = .lightGray
        collectionView.backgroundColor = .lightGray
        
        view.addSubview(buttonHStack)
        
        view.addSubview(progressView)
        view.addSubview(progressLabel)
        view.addSubview(titleLabel)

        buttonHStack.addArrangedSubview(randomPickButton)
        buttonHStack.addArrangedSubview(liveTextButton)
        buttonHStack.addArrangedSubview(addCategoryButton)

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
    
    func configureAlertViewUI() {
        
        view.addSubview(alertImageView)
        alertImageView.addSubview(alertLabel)
        view.addSubview(closeButton)
            
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
    
    func updateProgressUI(bucketListCount: Int) {
        
        if bucketLists.count == 0 {
            DispatchQueue.main.async {
                self.titleLabel.text = "There's no bucket."
                self.progressLabel.text = "Let's add new bucket list!"
                self.randomPickButton.isEnabled = false
                self.collectionView.reloadData()
            }
        } else {
            DispatchQueue.main.async {
                self.titleLabel.text = "Bucket Progress \(Int(self.progress!*100))%"
                self.progressLabel.text = "\(self.shareFinishedListCount) of \(self.shareBucketListCount) buckets accomplished"
                self.randomPickButton.isEnabled = true
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK: - User interaction handler

    @objc func tappedCloseBtn() {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.alertImageView.alpha = 0
            self.blackView.alpha = 0
            self.closeButton.isHidden = true
        }
    }
    
    @objc func tappedAddBtn() {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.menuBottomConstraint.constant = 0
            self.blackView.alpha = 0.5
        }
    }
    
    @objc func tappedPickBtn() {
        
        guard bucketLists != [] else { return }
        let unFinishedBucketList = bucketLists.filter { $0.status == false }
        guard unFinishedBucketList != [] else { return }
        let randomNum = Int.random(in: 0...unFinishedBucketList.count-1)
        let randomList = unFinishedBucketList[randomNum].list
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.alertImageView.alpha = 1
            self.alertLabel.text = randomList
            self.blackView.alpha = 0.5
            self.closeButton.isHidden = false
        }
    }
    
    @objc func tappedLiveTextBtn() {
        let liveVC = storyboard?.instantiateViewController(withIdentifier: "liveVC")
        guard let liveVC = liveVC as? LiveTextController else { return }
        self.present(liveVC, animated: true)
    }
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizer.State.ended {
            return
        }
        
        let location = gestureReconizer.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: location)
        
        guard let indexPath = indexPath else {
            print("Could not find index path")
            return
        }

        self.presentActionAlert(action: "Delete", title: "Delete Category",
                                message: "Do you want to delete this category?") {
            let deleteId = self.bucketCategories[indexPath.row].id
            
            self.deleteBucketList(deleteId: deleteId)
            self.deleteBucketCategory(deleteId: deleteId, row: indexPath.row)
        }
    }
    
    // MARK: - Firebase handler
    
    func fetchUser(userID: String) {
        
        UserManager.shared.fetchUserData(userID: userID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                
                self.userIDList = [userID]

                if user.paringUser != [] {
                    self.userIDList.append(user.paringUser[0])
                }
                
                self.fetchBucketCategory()
                self.fetchAllBucketList()
                
            case .failure(let error):
                self.presentAlert(title: "Error", message: error.localizedDescription + " Please try again")
                print("Can't find user in bucketListVC")
            }
        }
    }
    
    func fetchBucketCategory() {
        self.bucketCategories = []
        
        for userID in self.userIDList {
            BucketListManager.shared.fetchBucketCategory(userID: userID) { [weak self] result in

                guard let self = self else { return }

                switch result {
                case .success(let bucketLists):
                    self.bucketCategories += bucketLists
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func fetchAllBucketList() {
        
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

                    self.progress = Float(self.shareFinishedListCount) / Float(self.shareBucketListCount)
                    self.progressView.progress = self.progress!
                    self.updateProgressUI(bucketListCount: bucketLists.count)

                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func deleteBucketCategory(deleteId: String, row: Int) {
        BucketListManager.shared.deleteBucketCategory(id: deleteId) { result in
            switch result {
            case .success:
                self.bucketCategories.remove(at: row)
                self.presentAlert()
            case .failure(let error):
                self.presentAlert(title: "Error",
                                  message: error.localizedDescription + " Please try again")
            }
        }
    }
    
    func deleteBucketList(deleteId: String) {
        BucketListManager.shared.deleteBucketListByCategory(id: deleteId) { result in
            switch result {
            case .success:
                self.fetchAllBucketList()
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                self.presentAlert()
            case .failure(let error):
                self.presentAlert(title: "Error",
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
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: BucketListCollectionViewCell.identifier,
            for: indexPath)
        guard let cell = cell as? BucketListCollectionViewCell else { return cell }
        
        cell.clipsToBounds = true
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = cell.frame.height/30
        
        cell.backgroundColor = UIColor.lightGray
        
        cell.configureCell(category: bucketCategories[indexPath.row])
        
        return cell
        
    }
}

extension BucketListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (screenWidth-30)/2, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let detailBucketVC = storyboard?.instantiateViewController(withIdentifier: "BucketDetailViewController")
        guard let detailBucketVC = detailBucketVC as? BucketDetailViewController else { return }
        
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
        animationView.play {_ in
            self.stopAnimation(animationView: animationView)
        }
        
        guard let currentUserUID = currentUserUID else { return }
        fetchUser(userID: currentUserUID)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}
