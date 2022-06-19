//
//  ScheduleCollectionViewCell.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/18.
//

import UIKit

protocol ScheduleCollectionViewCellDelegate: AnyObject {
    func didTappedEdit(cell: UICollectionViewCell)
}

class ScheduleCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "eventCell"
    
    weak var delegate: ScheduleCollectionViewCellDelegate?
    
    var eventLabel: UILabel = {
        let label = UILabel()
        label.textColor = .textGray
        label.numberOfLines = 0
        return label
    }()
    
    var eventImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "mock_avatar")
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var editButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.bgGray
        button.setImage(UIImage(named: "icon_delete"), for: .normal)
        button.addTarget(self, action: #selector(tappedEditBtn), for: .touchUpInside)
        button.setTitleColor(UIColor.textGray, for: .normal)
        button.layer.cornerRadius = 20
        button.alpha = 0.5
        return button
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
        addSubview(eventImageView)
//        addSubview(editButton)
        
        eventImageView.anchor(top: topAnchor, left: leftAnchor,
                              paddingTop: 20, paddingLeft: 50,
                              width: 50, height: 50)
        eventLabel.anchor(top: topAnchor, left: eventImageView.rightAnchor,
                          paddingTop: 20, paddingLeft: 50,
                          width: 100, height: 20)
        
//        editButton.anchor(top: topAnchor, right: rightAnchor,
//                            paddingTop: 20, paddingRight: 30, width: 30, height: 30)
    }
    
    func configureCell(eventText: String) {
        eventLabel.text = eventText
    }
    
    @objc func tappedEditBtn() {
        // TBC
    }
    
}
