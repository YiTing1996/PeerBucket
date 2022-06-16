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
        imageView.image = UIImage(named: "Icon_Star")
        return imageView
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
        
        bucketImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 10, paddingLeft: 10, width: 100, height: 100)
        bucketLabel.anchor(top: topAnchor, left: bucketImageView.rightAnchor, paddingTop: 10, paddingLeft: 10)

    }
    
    func configureCell(bucketText: String) {
        bucketLabel.text = bucketText
    }

}
