//
//  BucketListViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/16.
//

import Foundation
import UIKit
import CoreMIDI

class BucketListViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var menuBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var containerView: UIView!

    lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(tappedAddBtn), for: .touchUpInside)
        button.setImage(UIImage(named: "icon_func_add"), for: .normal)
        return button
    }()
    
    lazy var randomPickButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(tappedPickBtn), for: .touchUpInside)
        button.setImage(UIImage(named: "icon_func_random"), for: .normal)
        return button
    }()
    
    lazy var longPressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer()
        gesture.addTarget(self, action: #selector(handleLongPress(gestureReconizer:)))
        gesture.minimumPressDuration = 0.5
        gesture.delaysTouchesBegan = true
        gesture.delegate = self
        return gesture
    }()
    
    var progressView: UIProgressView = {
        let progress = UIProgressView()
        progress.progressTintColor = UIColor.hightlightYellow
        progress.trackTintColor = UIColor.darkGreen
        progress.progress = 0.8
        return progress
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGreen
        label.font = UIFont.bold(size: 28)
        //        label.text = "Bucket Progress 60%"
        return label
    }()
    
    var progressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .hightlightYellow
        label.font = UIFont.semiBold(size: 20)
        label.text = "60 of 100 accomplished"
        return label
    }()
    
    var bucketCategories: [BucketCategory] = []
    var bucketLists: [BucketList] = []
    var shareBucketListCount: Int = 0
    var shareFinishedListCount: Int = 0
    
    var selectedBucket: BucketCategory?
    var userIDList: [String] = [currentUserUID]
    var progress: Float?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .lightGray
        collectionView.backgroundColor = .lightGray
        
        getData(userID: currentUserUID)
        
        configureUI()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        menuBottomConstraint.constant = -600
        blackView.backgroundColor = .black
        blackView.alpha = 0
        
        view.bringSubviewToFront(blackView)
        view.bringSubviewToFront(containerView)
        
        collectionView.addGestureRecognizer(longPressGesture)
        
    }
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizer.State.ended {
            return
        }
        
        let location = gestureReconizer.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: location)
        
        if let indexPath = indexPath {
            // _ = self.collectionView.cellForItem(at: indexPath)
            self.presentDeleteAlert(title: "Delete Category", message: "Do you want to delete this category?") {
                let deleteId = self.bucketCategories[indexPath.row].id
                
                BucketListManager.shared.deleteBucketCategory(id: deleteId) { result in
                    switch result {
                    case .success:
                        self.presentSuccessAlert()
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    case .failure(let error):
                        self.presentErrorAlert(message: error.localizedDescription + " Please try again")
                    }
                }
            }
            
        } else {
            print("Could not find index path")
        }
    }
    
    func configureUI() {
        view.addSubview(addCategoryButton)
        view.addSubview(progressView)
        view.addSubview(progressLabel)
        view.addSubview(titleLabel)
        view.addSubview(randomPickButton)
        
        addCategoryButton.anchor(bottom: collectionView.topAnchor, right: view.rightAnchor,
                                 paddingBottom: 20, paddingRight: 10)
        randomPickButton.anchor(bottom: collectionView.topAnchor, right: addCategoryButton.leftAnchor,
                                paddingBottom: 20, paddingRight: 10)
        titleLabel.anchor(top: view.topAnchor, left: view.leftAnchor, paddingTop: 100,
                          paddingLeft: 20, height: 40)
        progressLabel.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor,
                             paddingTop: 10, paddingLeft: 20, height: 30)
        progressView.anchor(top: progressLabel.bottomAnchor, left: view.leftAnchor,
                            paddingTop: 10, paddingLeft: 20, width: 200, height: 20)
        
    }
    
    @objc func tappedAddBtn() {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.menuBottomConstraint.constant = 0
            self.blackView.alpha = 0.5
        }
    }
    
    @objc func tappedPickBtn() {
        let unFinishedBucketList = bucketLists.filter { $0.status == false }
        let randomNum = Int.random(in: 0..<unFinishedBucketList.count)
        self.presentSuccessAlert(title: "Recommend To You", message: "Let's plan to finished bucket \(unFinishedBucketList[randomNum].list)!")
    }
    
    func getData(userID: String) {
        
        //        let semaphore = DispatchSemaphore(value: 1)
        //        semaphore.wait()
        
        // fetch current user's paring user and append to userList
        UserManager.shared.fetchUserData(userID: userID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                
                if user.paringUser != [] {
                    self.userIDList.append(user.paringUser[0])
                }
                
                self.bucketCategories = []
                self.bucketLists = []
                self.shareBucketListCount = 0
                self.shareFinishedListCount = 0

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
                        
                        //                        semaphore.signal()
                    }
                    
                    // fetch all bucket lists
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
    
    // fetch bucket category by self & paring user ID
    func loadBucketCategory() {
        self.bucketCategories = []
        for userID in userIDList {
            BucketListManager.shared.fetchBucketCategory(userID: userID, completion: { [weak self] result in
                
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
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AddNewBucketViewController {
            destination.delegate = self
        }
    }
    
}

extension BucketListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bucketCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "BucketListCollectionViewCell",
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
        return CGSize(width: 190, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let detailBucketVC = storyboard?.instantiateViewController(withIdentifier: "BucketDetailViewController")
        guard let detailBucketVC = detailBucketVC as? BucketDetailViewController else { return }
        
        selectedBucket = bucketCategories[indexPath.row]
        detailBucketVC.selectedBucket = selectedBucket
        navigationController?.pushViewController(detailBucketVC, animated: true)
        
    }
    
}

extension BucketListViewController: AddNewBucketDelegate {
    
    func didTappedClose() {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.menuBottomConstraint.constant = -600
            self.blackView.alpha = 0
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}
