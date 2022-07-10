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
    
    static let identifier = "eventCell"
    
    weak var delegate: ScheduleCollectionViewCellDelegate?
    
    var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.font = UIFont.semiBold(size: 13)
        return label
    }()
    
    var eventLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGreen
        label.numberOfLines = 0
        label.font = UIFont.semiBold(size: 18)
        return label
    }()
    
    var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.image = UIImage(named: "icon_avatar_none")
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 30
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
//    lazy var editButton: UIButton = {
//        let button = UIButton()
//        button.backgroundColor = UIColor.lightGray
//        button.setImage(UIImage(named: "icon_delete"), for: .normal)
//        button.addTarget(self, action: #selector(tappedEditBtn), for: .touchUpInside)
//        button.setTitleColor(UIColor.darkGreen, for: .normal)
//        button.layer.cornerRadius = 20
//        button.alpha = 0.5
//        return button
//    }()
    
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
                          paddingTop: 20, paddingLeft: 20,
                          width: 150, height: 20)
        dateLabel.anchor(top: eventLabel.bottomAnchor, left: avatarImageView.rightAnchor,
                          paddingTop: 5, paddingLeft: 20,
                          width: 150, height: 20)
        
    }
    
    func configureCell(event: Schedule) {
        
        eventLabel.text = event.event
        dateLabel.text = Date.dateFormatter.string(from: event.eventDate)
        
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
