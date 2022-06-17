//
//  ChallengeCollectionViewCell.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/15.
//

import Foundation
import UIKit

class ChallengeCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ChallengeCollectionViewCell"
    
    var mainImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var mainTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.semiBold(size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        configureCell()
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
    
    func configureCell() {
        mainImageView.image = UIImage(named: "recommend")
        mainTitleLabel.text = "Penghu, Taiwan"
    }
    
}
