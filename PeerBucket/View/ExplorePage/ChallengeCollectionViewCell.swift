//
//  ChallengeCollectionViewCell.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/15.
//

import UIKit

final class ChallengeCollectionViewCell: UICollectionViewCell {
        
    private lazy var mainImageView: UIImageView = create {
        $0.contentMode = .scaleAspectFill
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        backgroundColor = UIColor.lightGray
        clipsToBounds = true
        layer.cornerRadius = frame.height / 10
        addSubview(mainImageView)
        mainImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
    }
    
    func configureCell(image: String) {
        mainImageView.image = UIImage(named: image)
    }
}
