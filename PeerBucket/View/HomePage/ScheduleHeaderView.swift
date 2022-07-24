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
    
    lazy var headerLabel: UILabel = create {
        $0.textColor = .darkGray
        $0.font = UIFont.semiBold(size: 20)
    }
    
    lazy var addButton: UIButton = create {
        $0.addTarget(self, action: #selector(tappedAddBtn), for: .touchUpInside)
        $0.setImage(UIImage(named: "icon_func_add"), for: .normal)
    }
    
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
