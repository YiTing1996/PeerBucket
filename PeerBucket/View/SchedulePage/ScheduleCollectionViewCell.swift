//
//  ScheduleCollectionViewCell.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/18.
//

import UIKit

class ScheduleCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "eventCell"
    
    var eventLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textGray
        label.numberOfLines = 0
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
        addSubview(eventLabel)
        
        eventLabel.anchor(top: topAnchor, left: leftAnchor,
                          paddingTop: 20, paddingLeft: 10,
                          width: 100, height: 20)
    }
    
    func configureCell(eventText: String) {
        eventLabel.text = eventText
    }
    
}
