//
//  ChallengeHeaderView.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/15.
//

import UIKit

final class ChallengeHeaderView: UICollectionReusableView {
        
    private lazy var headerLabel: UILabel = create {
        $0.backgroundColor = .hightlightYellow
        $0.textColor = .white
        $0.font = UIFont.bold(size: 20)
        $0.text = " #CHALLENGE #BUCKET "
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(headerLabel)
        headerLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor,
                           paddingTop: 6, paddingLeft: 6, paddingBottom: 10)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
