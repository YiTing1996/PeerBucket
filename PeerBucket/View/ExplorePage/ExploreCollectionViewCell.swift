//
//  ExploreCollectionViewCell.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/15.
//

import Foundation
import UIKit

class ExploreCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ExploreCollectionViewCell"
    
    var mainImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var mainTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.semiBold(size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .textGray
        label.backgroundColor = .bgGray
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        addSubview(mainImageView)
        addSubview(mainTitleLabel)
        
        mainImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        mainTitleLabel.anchor(left: mainImageView.leftAnchor, bottom: bottomAnchor, paddingLeft: 16, paddingBottom: 16)
        
    }
    
    func configureCell(content: ExploreBucket) {
        mainImageView.image = content.images[0]
        mainTitleLabel.text = content.title
    }
    
}
