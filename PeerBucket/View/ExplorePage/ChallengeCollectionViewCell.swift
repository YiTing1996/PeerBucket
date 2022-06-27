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
        imageView.contentMode = .scaleAspectFill
        return imageView
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
        
        mainImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
        
    }
    
    func configureCell(image: String) {
        mainImageView.image = UIImage(named: image)
    }
    
}
