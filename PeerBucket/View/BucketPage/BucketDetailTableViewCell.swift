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
    
    static let identifier = "BucketDetailTableViewCell"

    weak var delegate: BucketDetailTableViewCellDelegate?
    
    lazy var doneButton: UIButton = create {
        $0.setImage(UIImage(named: "icon_check"), for: .normal)
        $0.addTarget(self, action: #selector(tappedDoneBtn), for: .touchUpInside)
    }
    
    lazy var bucketLabel: UILabel = create {
        $0.numberOfLines = 0
        $0.font = UIFont.semiBold(size: 18)
        $0.textColor = .darkGray
    }
    
    lazy var borderView: UIView = create {
        $0.backgroundColor = .lightGray
        $0.layer.masksToBounds = false
        $0.layer.borderColor = UIColor.darkGray.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 10
    }
    
    lazy var dateLabel: UILabel = create {
        $0.numberOfLines = 0
        $0.font = UIFont.semiBold(size: 15)
        $0.textColor = .hightlightYellow
    }
    
    lazy var hStack: UIStackView = create {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 2
    }
    
    lazy var scrollView: UIScrollView = create {
        $0.isPagingEnabled = true
        $0.delegate = self
    }
    
    lazy var pageControl: UIPageControl = create {
        $0.alpha = 0.6
        $0.isUserInteractionEnabled = false
        $0.currentPage = 0
        $0.currentPageIndicatorTintColor = .thirdGray
        $0.pageIndicatorTintColor = .secondGray
    }
    
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
        
        self.backgroundColor = .lightGray
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
        bucketList.status == true ? setFinishMode(date: bucketList.createdTime): setUnfinishMode()
        
        guard bucketList.images != [] else {
            hStack.isHidden = true
            pageControl.isHidden = true
            return
        }
        
        hStack.isHidden = false
        for hstackImage in hStack.arrangedSubviews {
            hStack.removeArrangedSubview(hstackImage)
        }
        
        setPageControl(images: bucketList.images)
        setImageStack(images: bucketList.images)
    }
    
    func setPageControl(images: [String]) {
        if images.count == 1 {
            pageControl.isHidden = true
        } else {
            pageControl.isHidden = false
            pageControl.numberOfPages = images.count
        }
    }
    
    func setImageStack(images: [String]) {
        for index in 0...images.count-1 {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.anchor(width: 240, height: 150)
            
            let url = URL(string: images[index])
            imageView.kf.setImage(with: url)
            
            hStack.addArrangedSubview(imageView)
        }
    }
    
    func setFinishMode(date: Date) {
        doneButton.setImage(UIImage(named: "icon_checked"), for: .normal)
        dateLabel.text = Date.dateFormatter.string(from: date)
        dateLabel.isHidden = false
    }
    
    func setUnfinishMode() {
        doneButton.setImage(UIImage(named: "icon_check"), for: .normal)
        dateLabel.isHidden = true
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
