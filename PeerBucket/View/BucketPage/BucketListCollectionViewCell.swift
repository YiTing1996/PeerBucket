//
//  BucketListCollectionViewCell.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/16.
//

import UIKit
import Kingfisher

class BucketListCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "BucketListCollectionViewCell"
    
    lazy var categoryLabel: UILabel = create {
        $0.textColor = .darkGray
        $0.font = UIFont.semiBold(size: 20)
        $0.numberOfLines = 0
    }
    
    lazy var categoryImageView: UIImageView = create {
        $0.contentMode = .scaleAspectFill
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // initialize what is needed
        configureUI()
    }
    
    func configureUI() {
        addSubview(categoryImageView)
        addSubview(categoryLabel)
        
        categoryImageView.centerX(inView: self)
        categoryLabel.centerX(inView: self)

        categoryImageView.anchor(top: topAnchor, paddingTop: 20, width: 50, height: 50)
        categoryLabel.anchor(top: categoryImageView.bottomAnchor, paddingTop: 15)
        
    }
    
    var image: UIImage?
    
    func configureCell(category: BucketCategory) {

        categoryLabel.text = category.category
        let url = URL(string: category.image)
        categoryImageView.kf.setImage(with: url)
        
    }
    
}
