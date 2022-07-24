//
//  LiveTextTableViewCell.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/7/6.
//

import UIKit
import Kingfisher

class LiveTextTableViewCell: UITableViewCell {

    lazy var categoryImageView: UIImageView = create {
        $0.contentMode = .scaleAspectFill
    }
    
    lazy var categoryLabel: UILabel = create {
        $0.font = UIFont.semiBold(size: 18)
        $0.textColor = .darkGray
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configureUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureUI() {
        addSubview(categoryLabel)
        addSubview(categoryImageView)
        
        categoryImageView.centerY(inView: self)
        categoryImageView.anchor(left: leftAnchor, paddingLeft: 10, width: 25, height: 25)
        
        categoryLabel.centerY(inView: self)
        categoryLabel.anchor(left: categoryImageView.rightAnchor, paddingLeft: 20)

    }
    
    func configureCell(bucketList: BucketCategory) {
        categoryLabel.text = bucketList.category
        let url = URL(string: bucketList.image)
        categoryImageView.kf.setImage(with: url)
    }

}
