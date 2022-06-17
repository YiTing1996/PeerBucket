//
//  BucketListViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/16.
//

import Foundation
import UIKit

class BucketListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var menuBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var blackView: UIView!
    
    lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.bgGray
        button.addTarget(self, action: #selector(tappedAddBtn), for: .touchUpInside)
        button.setTitle("Add", for: .normal)
        button.setTitleColor(UIColor.textGray, for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        return button
    }()
    
    var bucketLists: [BucketCategory] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var selectedBucket: BucketCategory?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        fetchFromFirebase()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        
        menuBottomConstraint.constant = -500
        blackView.backgroundColor = .black
        blackView.alpha = 0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchFromFirebase()
    }
    
    func configureUI() {
        view.addSubview(addCategoryButton)
        addCategoryButton.anchor(bottom: collectionView.topAnchor, right: view.rightAnchor,
                               paddingBottom: 20, paddingRight: 10, width: 120, height: 50)
    }
    
    @objc func tappedAddBtn() {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.menuBottomConstraint.constant = 0
            self.blackView.alpha = 0.5
//            self.layoutIfNeeded()
        }
    }
    
    func fetchFromFirebase() {
        BucketListManager.shared.fetchBucketCategory(completion: { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let bucketLists):
                self.bucketLists = bucketLists
                print(self.bucketLists)
            case .failure(let error):
                print(error.localizedDescription)
            }
            
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AddNewBucketViewController {
            destination.delegate = self
        }
    }
    
}

extension BucketListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bucketLists.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "BucketListCollectionViewCell",
            for: indexPath)
        guard let cell = cell as? BucketListCollectionViewCell else { return cell }
        
        cell.clipsToBounds = true
        cell.layer.cornerRadius = cell.frame.height/30
        cell.backgroundColor = UIColor.bgGray
        
        cell.configureCell(category: bucketLists[indexPath.row])
        
        return cell
        
    }
    
}

extension BucketListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 240)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        let totalWidth = UIScreen.main.bounds.width
        return (totalWidth-360)/6
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let detailBucketVC = storyboard?.instantiateViewController(withIdentifier: "BucketDetailViewController")
        guard let detailBucketVC = detailBucketVC as? BucketDetailViewController else { return }
        
        selectedBucket = bucketLists[indexPath.row]
        detailBucketVC.selectedBucket = selectedBucket
//        self.present(detailBucketVC, animated: true)
        navigationController?.pushViewController(detailBucketVC, animated: true)
    
    }
    
}

extension BucketListViewController: AddNewBucketDelegate {
    
    func didTappedClose() {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0) {
            self.menuBottomConstraint.constant = -500
            self.blackView.alpha = 0
        }
    }
    
}
