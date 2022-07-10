//
//  AddToBucketCollectionViewCell.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/15.
//

import UIKit
import Kingfisher

class AddToBucketCollectionViewCell: UICollectionViewCell {
    
    var categoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGreen
        label.font = UIFont.semiBold(size: 18)
        label.numberOfLines = 0
        return label
    }()
    
    var categoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
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
