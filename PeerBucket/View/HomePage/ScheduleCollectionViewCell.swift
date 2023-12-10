//
//  ScheduleCollectionViewCell.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/18.
//

import UIKit
import Kingfisher

protocol ScheduleCollectionViewCellDelegate: AnyObject {
    func didTappedEdit(cell: UICollectionViewCell)
}

final class ScheduleCollectionViewCell: UICollectionViewCell {
        
    private weak var delegate: ScheduleCollectionViewCellDelegate?
    
    private lazy var dateLabel: UILabel = create {
        $0.textColor = .darkGray
        $0.numberOfLines = 0
        $0.font = UIFont.semiBold(size: 13)
    }
    
    private lazy var eventLabel: UILabel = create {
        $0.textColor = .darkGreen
        $0.numberOfLines = 0
        $0.font = UIFont.semiBold(size: 18)
    }
    
    private lazy var avatarImageView: UIImageView = create {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 30
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
        backgroundColor = .lightGray
        layer.borderWidth = 1
        layer.borderColor = UIColor.darkGray.cgColor
        layer.cornerRadius = 10
        addSubviews([eventLabel, avatarImageView, dateLabel])
        avatarImageView.centerY(inView: self)
        avatarImageView.anchor(left: leftAnchor, paddingLeft: 20,
                               width: 60, height: 60)
        eventLabel.anchor(top: topAnchor, left: avatarImageView.rightAnchor,
                          right: rightAnchor, paddingTop: 20, paddingLeft: 20,
                          paddingRight: 20, height: 20)
        dateLabel.anchor(top: eventLabel.bottomAnchor, left: avatarImageView.rightAnchor,
                         paddingTop: 5, paddingLeft: 20,
                         width: 150, height: 20)
    }
    
    func configureCell(event: Schedule) {
        eventLabel.text = event.event
        dateLabel.text = Date.timeFormatter.string(from: event.eventDate)
        
        guard let currentUser = Info.shared.currentUser, currentUser.userAvatar.isNotEmpty else {
            avatarImageView.image = UIImage(named: "icon_avatar_none")
            return
        }
        let url = URL(string: currentUser.userAvatar)
        avatarImageView.kf.setImage(with: url)
    }
}
