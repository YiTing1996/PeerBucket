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
    
    lazy var mainImageView: UIImageView = create {
        $0.contentMode = .scaleAspectFill
    }
    
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
    
    func configureCell(content: ExploreBucket) {
        mainImageView.image = content.images[0]
    }
    
}
