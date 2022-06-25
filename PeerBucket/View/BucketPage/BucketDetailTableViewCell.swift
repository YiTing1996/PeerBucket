//
//  BucketDetailTableViewCell.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/16.
//

import UIKit

class BucketDetailTableViewCell: UITableViewCell {
    
    var bucketLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    var bucketImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var borderView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.darkGreen.cgColor
        view.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 6
        view.layer.cornerRadius = 10
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        configureUI()

    }
    
    func configureUI() {
        
        addSubview(bucketLabel)
        addSubview(bucketImageView)
        contentView.addSubview(borderView)
        
        bucketImageView.anchor(top: topAnchor, left: leftAnchor,
                               paddingTop: 15, paddingLeft: 30,
                               width: 30, height: 30)
        bucketLabel.anchor(top: topAnchor, left: bucketImageView.rightAnchor,
                           paddingTop: 15, paddingLeft: 30)
        borderView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor,
                          bottom: contentView.bottomAnchor, right: contentView.rightAnchor,
                          paddingTop: 8, paddingLeft: 24, paddingBottom: -8, paddingRight: -24)
    }
    
    func configureCell(bucketList: BucketList) {
        bucketLabel.text = bucketList.list
        
        if bucketList.status == true {
            bucketImageView.image = UIImage(named: "icon_checked")
        } else {
            bucketImageView.image = UIImage(named: "icon_check")
        }
        
    }

}
