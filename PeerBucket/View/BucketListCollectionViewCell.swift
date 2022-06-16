//
//  BucketListCollectionViewCell.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/16.
//

import UIKit

class BucketListCollectionViewCell: UICollectionViewCell {
    
//    let category = ["Travel", "Movie", "Food", "Book", "Sport", "Add New"]
    
    var categoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.tintColor = .blue
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // initialize what is needed
        configureUI()
    }
    
    func configureUI() {
        addSubview(categoryLabel)
        categoryLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        categoryLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

//        categoryLabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 20, paddingLeft: 20)
    }
    
    func configureCell(category: String) {
        categoryLabel.text = category
    }
    
}
