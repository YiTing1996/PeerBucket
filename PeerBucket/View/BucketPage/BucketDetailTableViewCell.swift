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
        button.setImage(UIImage(named: "icon_check"), for: .normal)
        button.addTarget(self, action: #selector(tappedDoneBtn), for: .touchUpInside)
        return button
    }()
    
    var bucketLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.semiBold(size: 18)
        label.textColor = .darkGray
        return label
    }()
    
    var borderView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.masksToBounds = false
        view.layer.borderColor = UIColor.darkGray.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 10
        return view
    }()
    
    var dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.semiBold(size: 15)
        label.textColor = .hightlightYellow
        return label
    }()
    
    var hStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 2
        return stackView
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        return scrollView
    }()
    
    var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.alpha = 0.6
        pageControl.isUserInteractionEnabled = false
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .thirdGray
        pageControl.pageIndicatorTintColor = .secondGray
        return pageControl
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
        addSubview(pageControl)
        addSubview(doneButton)
        addSubview(dateLabel)
        scrollView.addSubview(hStack)
        contentView.addSubview(borderView)
        
        doneButton.anchor(top: topAnchor, left: leftAnchor,
                          paddingTop: 20, paddingLeft: 40,
                          width: 30, height: 30)
        bucketLabel.anchor(top: topAnchor, left: doneButton.rightAnchor, right: rightAnchor,
                           paddingTop: 18, paddingLeft: 10, paddingRight: 30)
        
        dateLabel.anchor(top: bucketLabel.bottomAnchor, left: doneButton.rightAnchor,
                         paddingTop: 5, paddingLeft: 10)
        
        scrollView.anchor(top: dateLabel.bottomAnchor, left: doneButton.rightAnchor,
                          paddingTop: 10, paddingLeft: 10, width: 240, height: 150)
        
        hStack.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor,
                      bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor)
        
        borderView.anchor(top: contentView.topAnchor, left: contentView.leftAnchor,
                          bottom: contentView.bottomAnchor, right: contentView.rightAnchor,
                          paddingTop: 6, paddingLeft: 24, paddingBottom: 6, paddingRight: 24)
        
        pageControl.anchor(bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor)
        
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
                
        guard bucketList.images != [] else {
            hStack.isHidden = true
            pageControl.isHidden = true
            return
        }
        
        hStack.isHidden = false
        for hstackImage in hStack.arrangedSubviews {
            hStack.removeArrangedSubview(hstackImage)
        }
        
        if bucketList.images.count == 1 {
            pageControl.isHidden = true
        } else {
            pageControl.isHidden = false
            pageControl.numberOfPages = bucketList.images.count
        }

        for index in 0...bucketList.images.count-1 {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.anchor(width: 240, height: 150)
            
            let url = URL(string: bucketList.images[index])
            imageView.kf.setImage(with: url)
            
            hStack.addArrangedSubview(imageView)
        }
                
    }
    
    @objc func tappedDoneBtn() {
        delegate?.didTappedStatus(cell: self)
    }
}

extension BucketDetailTableViewCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        pageControl.currentPage = page
    }
    
}
