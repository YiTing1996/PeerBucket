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
    
    var bucketLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.semiBold(size: 18)
        label.textColor = .darkGray
        return label
    }()
    
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
    
    var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.semiBold(size: 15)
        label.textColor = .hightlightYellow
        return label
    }()
    
    var hStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 2
        return stackView
    }()
    
    var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
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
        addSubview(scrollView)
        addSubview(doneButton)
        addSubview(dateLabel)
        scrollView.addSubview(hStack)
        contentView.addSubview(borderView)
        
        doneButton.anchor(top: topAnchor, left: leftAnchor,
                          paddingTop: 20, paddingLeft: 50,
                          width: 30, height: 30)
        bucketLabel.anchor(top: topAnchor, left: doneButton.rightAnchor,
                           paddingTop: 20, paddingLeft: 30)
 
        dateLabel.anchor(top: bucketLabel.bottomAnchor, left: doneButton.rightAnchor,
                         paddingTop: 5, paddingLeft: 30)
        
        scrollView.anchor(top: dateLabel.bottomAnchor, left: doneButton.rightAnchor,
                          paddingTop: 10, paddingLeft: 30, width: 220, height: 120)
        
        hStack.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor,
                      bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor)
        
        borderView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor,
                          bottom: contentView.bottomAnchor, right: contentView.rightAnchor,
                          paddingTop: 8, paddingLeft: 24, paddingBottom: 8, paddingRight: 24)
    }
    
    func configureCell(bucketList: BucketList) {
        bucketLabel.text = bucketList.list
                
        if bucketList.status == true {
            doneButton.setImage(UIImage(named: "icon_checked"), for: .normal)
            dateLabel.text = Date.dateFormatter.string(from: bucketList.createdTime)
            dateLabel.isHidden = false
        } else {
            doneButton.setImage(UIImage(named: "icon_check"), for: .normal)
            dateLabel.isHidden = true
        }
        
        guard bucketList.images != [] else { return }
        for index in 0...bucketList.images.count-1 {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.anchor(width: 220, height: 150)
            
            guard let urlString = bucketList.images[index] as String?,
                  let url = URL(string: urlString) else {
                return
            }

            let task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
                guard let data = data, error == nil else {
                    return
                }

                DispatchQueue.main.async {
                    imageView.image = UIImage(data: data)
                }
            })
            task.resume()
            
            hStack.spacing = 10
            hStack.addArrangedSubview(imageView)
        }
        
    }
    
    @objc func tappedDoneBtn() {
        delegate?.didTappedStatus(cell: self)
    }
}
