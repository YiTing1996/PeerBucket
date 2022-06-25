//
//  ScheduleHeaderView.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/18.
//

import UIKit

protocol ScheduleHeaderViewDelegate: AnyObject {
    func didTapAddButton()
}

class ScheduleHeaderView: UICollectionReusableView {
    
    static let identifier = "ScheduleHeaderView"
    
    weak var delegate: ScheduleHeaderViewDelegate?
    
    var headerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.semiBold(size: 20)
        return label
    }()
    
    lazy var addButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.lightGray
        button.addTarget(self, action: #selector(tappedAddBtn), for: .touchUpInside)
        button.setTitle("+", for: .normal)
        button.setTitleColor(UIColor.darkGreen, for: .normal)
        button.layer.cornerRadius = 20
        button.alpha = 0.5
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(headerLabel)
        addSubview(addButton)
        headerLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor,
                           paddingTop: 6, paddingLeft: 6, paddingBottom: 6)
        addButton.anchor(top: topAnchor, right: rightAnchor, paddingTop: 6, paddingRight: 6,
                         width: 50, height: 50)
        
    }
    
    func configureHeader(eventCount: Int) {
        if eventCount == 0 {
            headerLabel.text = "There's no event today"
        } else if eventCount <= 3 {
            headerLabel.text = "There's \(eventCount) events today"
        } else if eventCount > 3 {
            headerLabel.text = "Cheer up! Seems like a busy day"
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tappedAddBtn() {
        delegate?.didTapAddButton()
    }
    
}
