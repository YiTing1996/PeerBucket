//
//  ChallengeHeaderView.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/15.
//

import Foundation
import UIKit

class ChallengeHeaderView: UICollectionReusableView {
    static let identifier = "ChallengeHeaderView"

   var headerLabel: UILabel = {
       let label = UILabel()
        label.textColor = .darkGray
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.text = "Recommed Bucket List"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(headerLabel)
        headerLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor,
                           paddingTop: 6, paddingLeft: 6, paddingBottom: 6, width: 200)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
