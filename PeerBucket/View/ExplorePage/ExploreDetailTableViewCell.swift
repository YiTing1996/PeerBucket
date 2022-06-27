//
//  ExploreDetailTableViewCell.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/15.
//

import UIKit
import SwiftUI

protocol ExploreDetailTableViewCellDelegate: AnyObject {
    func didTappedCollect()
    func didTappedWeb()
}

class ExploreDetailTableViewCell: UITableViewCell, UIScrollViewDelegate {
    
    weak var delegate: ExploreDetailTableViewCellDelegate?
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()
    
    var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.isUserInteractionEnabled = false
        pageControl.numberOfPages = 4
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .gray
        pageControl.pageIndicatorTintColor = .darkGray
        return pageControl
    }()
    
    var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.clipsToBounds = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
        
    var detailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.semiBold(size: 18)
        label.textColor = UIColor.darkGreen
        return label
    }()
    
    var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = UIFont.regular(size: 20)
//        label.addCharacterSpacing()
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    
    lazy var webButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.semiBold(size: 18)
        button.addTarget(self, action: #selector(tappedWebBtn), for: .touchUpInside)
        button.backgroundColor = .darkGreen
        button.clipsToBounds = true
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 10
        return button
    }()
    
    lazy var collectButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.semiBold(size: 18)
        button.addTarget(self, action: #selector(tappedCollectBtn), for: .touchUpInside)
        button.setTitle("Collect", for: .normal)
        button.backgroundColor = .darkGreen
        button.clipsToBounds = true
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        return button
    }()
    
    var actionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .lightGray
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @objc func tappedWebBtn() {
        delegate?.didTappedWeb()
    }
    
    @objc func tappedCollectBtn() {
        delegate?.didTappedCollect()
    }
    
    func configureImageCell(content: ExploreBucket) {
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        addSubview(pageControl)

        scrollView.anchor(top: topAnchor, left: leftAnchor,
                          bottom: bottomAnchor, right: rightAnchor)

        scrollView.contentSize.height = stackView.frame.height
        stackView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, right: scrollView.rightAnchor)
        
        pageControl.anchor(left: leftAnchor, bottom: bottomAnchor, paddingBottom: -50)
        
        for index in 0...content.images.count-1 {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.image = content.images[index]
            stackView.addArrangedSubview(imageView)
            if index == 1 {
//                imageView.anchor(width: scrollView.frame.width, height: scrollView.frame.height)
                imageView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true
                imageView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor).isActive = true
            }
        }
    }
    
    func configureRatingCell(content: ExploreBucket) {
        addSubview(actionStackView)
        actionStackView.addArrangedSubview(webButton)
        actionStackView.addArrangedSubview(collectButton)

        actionStackView.anchor(top: topAnchor, left: leftAnchor,
                               bottom: bottomAnchor, right: rightAnchor,
                               paddingTop: 10, paddingLeft: 10,
                               paddingBottom: 10, paddingRight: 10)

        webButton.setTitle(content.rating, for: .normal)
        
    }
    
    // tableview automatic dimension
    func configureInfoCell(content: ExploreBucket) {
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        
        titleLabel.anchor(top: contentView.topAnchor, left: contentView.leftAnchor,
                          paddingTop: 10, paddingLeft: 10, height: 30)
        titleLabel.text = content.title
        descriptionLabel.anchor(top: titleLabel.bottomAnchor, left: contentView.leftAnchor,
                                bottom: contentView.bottomAnchor, right: contentView.rightAnchor,
                                paddingTop: 20, paddingLeft: 10, paddingBottom: 10, paddingRight: 10)
        descriptionLabel.text = content.description
    }
    
}
