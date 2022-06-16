//
//  AddToBucketViewController.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/15.
//

import Foundation
import UIKit

class AddToBucketViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        self.view.backgroundColor = .lightGray
//        self.view.clipsToBounds = true
//        self.view.layer.cornerRadius = view.frame.width/3*2
        
    }
    
}

extension AddToBucketViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "AddToBucketCollectionViewCell",
            for: indexPath)
        guard let cell = cell as? AddToBucketCollectionViewCell else { return cell }
        
        cell.clipsToBounds = true
        cell.layer.cornerRadius = cell.frame.height/4
        cell.backgroundColor = .darkGray
        
        cell.configureCell(index: indexPath.item)
        
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
        return (totalWidth-360)/6

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // 把選取的資料存到fireBase內
        
    }
    
}
