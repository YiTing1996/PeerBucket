//
//  AddToBucketCollectionViewCell.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/15.
//

import UIKit
import Kingfisher

class AddToBucketCollectionViewCell: UICollectionViewCell {
    
    lazy var categoryLabel: UILabel = create {
        $0.textColor = .darkGreen
        $0.font = UIFont.semiBold(size: 18)
        $0.numberOfLines = 0
    }
    
    lazy var categoryImageView: UIImageView = create {
        $0.contentMode = .scaleAspectFit
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // initialize what is needed
        configureUI()
    }
    
    func configureUI() {
        addSubview(categoryLabel)
        addSubview(categoryImageView)

        categoryImageView.anchor(top: topAnchor, paddingTop: 10, width: 50, height: 50)
        categoryImageView.centerX(inView: self)
        
        categoryLabel.centerX(inView: self)
        categoryLabel.anchor(top: categoryImageView.bottomAnchor, paddingTop: 10)
        
    }
    
    func configureCell(bucketCategories: BucketCategory) {
        categoryLabel.text = bucketCategories.category
        
        let url = URL(string: bucketCategories.image)
        categoryImageView.kf.setImage(with: url)
        
    }
    
}
