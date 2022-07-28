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

class ScheduleCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ScheduleCollectionViewCell"
    
    weak var delegate: ScheduleCollectionViewCellDelegate?
    
    lazy var dateLabel: UILabel = create {
        $0.textColor = .darkGray
        $0.numberOfLines = 0
        $0.font = UIFont.semiBold(size: 13)
    }
    
    lazy var eventLabel: UILabel = create {
        $0.textColor = .darkGreen
        $0.numberOfLines = 0
        $0.font = UIFont.semiBold(size: 18)
    }
    
    lazy var avatarImageView: UIImageView = create {
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
    
    func configureUI() {
        addSubview(eventLabel)
        addSubview(avatarImageView)
        addSubview(dateLabel)
        
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
        
        // fetch avatar by senderID
        UserManager.shared.fetchUserData(userID: event.senderId) { result in
            switch result {
            case .success(let user):
                
                guard user.userAvatar != "" else {
                    self.avatarImageView.image = UIImage(named: "icon_avatar_none")
                    return
                }
                
                let url = URL(string: user.userAvatar)
                self.avatarImageView.kf.setImage(with: url)
                
            case .failure:
                print("Download avatar error in schedule VC")
            }
        }
        
    }
    
}
