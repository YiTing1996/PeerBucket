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
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var mainTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .lightGray
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        addSubview(mainImageView)
        addSubview(mainTitleLabel)
        
        mainImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingBottom: 50)
        mainTitleLabel.anchor(top: mainImageView.bottomAnchor, left: mainImageView.leftAnchor, paddingTop: 16, paddingLeft: 16)
        
    }
    
    func configureCell(content: ExploreBucket) {
        mainImageView.image = content.images[0]
        mainTitleLabel.text = content.title
    }
    
}
