//
//  BucketDetailTableViewCell.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/16.
//

import UIKit

protocol BucketDetailTableViewCellDelegate: AnyObject {
    func didTappedStatus(cell: UITableViewCell)
}

class BucketDetailTableViewCell: UITableViewCell {
    
    weak var delegate: BucketDetailTableViewCellDelegate?
    
    var bucketLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.semiBold(size: 18)
        label.textColor = .darkGray
        return label
    }()
    
    //    var bucketImageView: UIImageView = {
    //        let imageView = UIImageView()
    //        imageView.translatesAutoresizingMaskIntoConstraints = false
    //        return imageView
    //    }()
    
    var borderView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.masksToBounds = false
        //        view.layer.shadowColor = UIColor.darkGreen.cgColor
        //        view.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        //        view.layer.shadowOpacity = 0.1
        //        view.layer.shadowRadius = 6
        view.layer.borderColor = UIColor.darkGray.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10
        return view
    }()
    
    lazy var doneButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.lightGray
        button.setImage(UIImage(named: "icon_check"), for: .normal)
        button.addTarget(self, action: #selector(tappedDoneBtn), for: .touchUpInside)
        button.setTitleColor(UIColor.darkGreen, for: .normal)
        button.layer.cornerRadius = 20
        button.alpha = 0.5
        return button
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
        //        addSubview(bucketImageView)
        contentView.addSubview(borderView)
        addSubview(doneButton)
        
        //        bucketImageView.anchor(top: topAnchor, left: leftAnchor,
        //                               paddingTop: 20, paddingLeft: 50,
        //                               width: 30, height: 30)
        doneButton.anchor(top: topAnchor, left: leftAnchor,
                               paddingTop: 20, paddingLeft: 50,
                               width: 30, height: 30)
        bucketLabel.anchor(top: topAnchor, left: doneButton.rightAnchor,
                           paddingTop: 20, paddingLeft: 30)
        borderView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor,
                          bottom: contentView.bottomAnchor, right: contentView.rightAnchor,
                          paddingTop: 8, paddingLeft: 24, paddingBottom: 8, paddingRight: 24)
    }
    
    func configureCell(bucketList: BucketList) {
        bucketLabel.text = bucketList.list
        
        if bucketList.status == true {
            doneButton.setImage(UIImage(named: "icon_checked"), for: .normal)
        } else {
            doneButton.setImage(UIImage(named: "icon_check"), for: .normal)
        }
    }
    
    @objc func tappedDoneBtn() {
        delegate?.didTappedStatus(cell: self)
    }
    
}
